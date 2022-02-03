local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

fn = {}
Tunnel.bindInterface("pix", fn)
Proxy.addInterface("pix", fn)

vRP._prepare("pix/createKey",
             "INSERT INTO pix (userid, namekey, pixkey) VALUES (@userid,@namekey,@pixkey)")
vRP._prepare("pix/updateKey",
             "UPDATE pix SET namekey = @namekey, pixkey = @pixkey WHERE pix.id = @pixid AND pix.userid = @userid")
vRP._prepare("pix/checkKey", "SELECT id, pixkey FROM pix WHERE userid = @userid")
vRP._prepare("pix/checkKeyExists",
             "SELECT userid, pixkey FROM pix WHERE pixkey = @pixkey")

local webPix = "cole-sua-webhook"

function SendWebhookMessage(webhook, message)
    if webhook ~= nil and webhook ~= "" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST',
                           json.encode({content = message}),
                           {['Content-Type'] = 'application/json'})
    end
end

RegisterServerEvent("savePixE")
AddEventHandler("savePixE", function(data)
    local source = source
    local user_id = vRP.getUserId(source)

    local checkKeyOtherUsers = vRP.query("pix/checkKeyExists",
                                         {pixkey = data.pixKey})

    if #checkKeyOtherUsers > 0 then
        TriggerClientEvent("swt_notifications:Warning", source, 'Pix',
                           'Uma chave já existe com esse nome, coloque outro!',
                           'right', 2500, true)
        return false
    end

    local pixKey, pixId = pixCheckKeyFromUser(user_id)

    if pixKey == false then
        local queryInsert = vRP.query("pix/createKey", {
            userid = user_id,
            namekey = data.nameKey,
            pixkey = data.pixKey
        })

        SendWebhookMessage(webPix,
                           "```prolog\n[ID]: " .. user_id ..
                               " \n[Motivo] Criou uma chave PIX" ..
                               os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") ..
                               " \n[Nome da CHAVE/PIX]: " .. data.nameKey ..
                               " / " .. data.pixKey .. " \r```")

        TriggerClientEvent("swt_notifications:Success", source, 'Pix',
                           'Você criou uma chave Pix!', 'right', 2500, true)
    else

        -- If pixId exists
        if pixId ~= nil then
            local queryUpdate = vRP.query("pix/updateKey", {
                namekey = data.nameKey,
                pixkey = data.pixKey,
                pixid = pixId,
                userid = user_id
            })

            SendWebhookMessage(webPix,
                               "```prolog\n[ID]: " .. user_id ..
                                   " \n[Motivo] Atualizou uma chave PIX" ..
                                   os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") ..
                                   " \n[Nome da CHAVE/PIX]: " .. data.nameKey ..
                                   " / " .. data.pixKey .. " \r```")

            TriggerClientEvent("swt_notifications:Success", source, 'Pix',
                               'Chave Pix atualizada!', 'right', 2500, true)
        end
    end
end)

RegisterServerEvent("sendPixE")
AddEventHandler("sendPixE", function(data)
    local source = source
    local user_id = vRP.getUserId(source)

    local checkKeyExists = vRP.query("pix/checkKeyExists",
                                     {pixkey = data.sendKey})

    if #checkKeyExists > 0 and parseInt(data.amountValue) > 0 then
        local targetUser = parseInt(checkKeyExists[1].userid)

        if targetUser == user_id then
            TriggerClientEvent("swt_notifications:Warning", source, 'Pix',
                               'Você não pode enviar um PIX para si mesmo!',
                               'right', 2500, true)
            return false
        else
            local valueCurrentBank = vRP.getBankMoney(user_id)
            local valueTargetBank = vRP.getBankMoney(targetUser)

            if valueCurrentBank <= 0 or valueCurrentBank <
                tonumber(data.amountValue) or tonumber(data.amountValue) <= 0 then
                TriggerClientEvent("swt_notifications:Negative", 'Pix',
                                   'Dinheiro Insuficiente', 'right', 2500, true)
            else
                vRP.setBankMoney(user_id,
                                 valueCurrentBank - tonumber(data.amountValue))
                vRP.setBankMoney(targetUser,
                                 valueTargetBank + tonumber(data.amountValue))

                SendWebhookMessage(webPix, "```prolog\n[ID]: " .. user_id ..
                                       " \n[Motivo] Transferiu um PIX no valor de R$" ..
                                       data.amountValue .. " para a chave/id: " ..
                                       data.sendKey .. " / " .. targetUser ..
                                       os.date(
                                           "\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") ..
                                       " \r```")

                TriggerClientEvent("swt_notifications:Success", source, 'Pix',
                                   'Você enviou um PIX no valor de R$ ' ..
                                       data.amountValue .. 'reais', 'right',
                                   2500, true)

                TriggerClientEvent("swt_notifications:Success",
                                   vRP.getUserSource(targetUser), 'Pix',
                                   'Você recebeu um PIX no valor de R$ ' ..
                                       data.amountValue .. 'reais', 'right',
                                   2500, true)
            end
        end
    else
        TriggerClientEvent("swt_notifications:Negative", source, 'Pix',
                           'Erro ao enviar PIX! Verifique a chave!', 'right',
                           2500, true)

        return false
    end
end)

function fn.pixInfo()
    local source = source
    local user_id = vRP.getUserId(source)

    if user_id then
        local bankAmount = vRP.getBankMoney(user_id)
        local pixKey, pixId = pixCheckKeyFromUser(user_id)

        return vRP.format(parseInt(bankAmount)), pixKey
    else
        return false
    end
end

function pixCheckKeyFromUser(user_id)
    local checkKey = vRP.query("pix/checkKey", {userid = user_id})
    if #checkKey > 0 then
        return checkKey[1].pixkey, checkKey[1].id
    else
        return false
    end
end
