local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

fn = {}
Tunnel.bindInterface("pix", fn)
vSERVER = Tunnel.getInterface("pix")

local menuactive = false

function ToggleActionMenu()
    menuactive = not menuactive
    if menuactive then
        local bankAmount, pixKey = vSERVER.pixInfo()
        vRP._CarregarObjeto(
            "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a",
            "idle_b", "prop_cs_tablet", 49, 28422)
        SetNuiFocus(true, true)
        TransitionToBlurred(1000)
        SendNUIMessage({
            showmenu = true,
            bankBalance = bankAmount,
            pixKeyValue = pixKey
        })
    else
        SetNuiFocus(false, false)
        TransitionFromBlurred(1000)
        vRP._DeletarObjeto()
        SendNUIMessage({hidemenu = true})
    end
end

RegisterNUICallback("Sair", function(data, cb)
    if data == "fechar" then ToggleActionMenu() end
end)

RegisterNUICallback("savePix", function(data, cb)
    TriggerServerEvent("savePixE", data)
end)

RegisterNUICallback("sendPix", function(data, cb)
    TriggerServerEvent("sendPixE", data)
end)

RegisterCommand("pix", function(source, args) ToggleActionMenu() end)
