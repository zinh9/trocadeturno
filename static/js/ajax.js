document.getElementById("formInserir").addEventListener("submit", function (event) {
  event.preventDefault(); // Impede o envio padrão do formulário

  const formData = new FormData(this);
  
  const matricula = document.getElementById("matricula").value.trim();
  const torre = document.getElementById("torreSelect").value.trim();
  const guarita = document.getElementById("guaritaSelect").value.trim();

  const params = new URLSearchParams();
  const btn = document.getElementById("botaoApresentar");

  btn.disabled = true;
  btn.innerText = "ARGUARDE..."

  params.append("matricula", matricula);
  params.append("torre", torre);
  params.append("guarita", guarita);

  fetch("inserir.asp", {
    method: "POST",
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: params.toString()
  })
  .then(response => response.text())
  .then(data => {
    data = data.trim();

    if (data === "ok") {
      setTimeout(() => {
        document.getElementById("mensagem").innerHTML = "<div class='alert alert-success'>Funcionário apresentado com sucesso!</div>";
        location.reload();
      }, 5000);
    } else if (data.indexOf("confirmar|") === 0) {
      let supervisaoOriginal = data.split("|")[1];
      if (confirm("Você está tentando se apresentar em outra supervisão. Sua supervisão original é: " + supervisaoOriginal + ".\nDeseja continuar?")) {
        params.append("confirmado", "1");
        
        fetch('inserir.asp', {
          method: 'POST',
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: params.toString()
        })
        .then(response => response.text())
        .then(data => {
          if (data.trim() === "ok") {
            setTimeout(() => {
              document.getElementById("mensagem").innerHTML = "<div class='alert alert-success'>Funcionário apresentado com sucesso!</div>";
              location.reload();
            }, 5000);
          } else {
            alert("Erro ao registrar: " + data);
          }
        });
      }
    } else {
      alert("Erro ao registrar: " + data);
    }
  })
  .catch(error => {
    alert("Erro na requisição: " + error);
  });
});
