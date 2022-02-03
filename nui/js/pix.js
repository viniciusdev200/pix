$(function () {
  let actionContainer = $(".pixContainer");
  window.addEventListener("message", function (event) {
    let item = event.data;

    if (item.showmenu) {
      $('body').css('background-color', 'rgba(0, 0, 0, 0.15)')
      actionContainer.fadeIn();
      $(".valueBankPrice").text("R$ " + item.bankBalance);
      if (item.pixKeyValue == false) {
        $(".pixKeyValue").text('Chave não cadastrada.');
      } else {
        $(".pixKeyValue").text(item.pixKeyValue);
      }
    }

    if (item.hidemenu) {
      $('body').css('background-color', 'transparent')
      actionContainer.fadeOut();
    }

    document.onkeyup = function (data) {
      if (data.which == 27) {
        if (actionContainer.is(":visible")) {
          $(".generatePix").css('visibility', 'hidden');
          sendData("Sair", "fechar");
        }
      }
    };
  });
});

function sendData(name, data) {
  $.post("http://pix/" + name, JSON.stringify(data), function (
    datab
  ) {
    if (datab != "ok") {
      console.log(datab);
    }
  });
}

function showGeneratePix() {
  let showGeneratePix = $(".generatePix");
  showGeneratePix.css('visibility', 'visible');
}

function savePix() {
  let showGeneratePix = $(".generatePix");
  let nameKey = $("input[name='sendNameKey']").val();
  let pixKey = $("input[name='sendPixKey']").val();

  if (nameKey && pixKey) {
    sendData("savePix", { nameKey, pixKey });
    sendData("Sair", "fechar");
    showGeneratePix.css('visibility', 'hidden');
  }
}

function sendPix() {
  let sendKey = $("input[name='sendKey']").val();
  let amountValue = $("input[name='amountValue']").val();

  $("input[name='sendKey']").val('');
  $("input[name='amountValue']").val('');

  if (sendKey && amountValue) {
    sendData("sendPix", { sendKey, amountValue });
    sendData("Sair", "fechar");
  }
}

function showPix() {
  let showPix = $(".showPix");
  showPix.css('visibility', 'visible');
}

function closeShowPix() {
  let showPix = $(".showPix");
  showPix.css('visibility', 'hidden');
}