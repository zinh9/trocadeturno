document.getElementById("formApresentacao").addEventListener("submit", function(event) {
    event.preventDefault();
    const torre = document.getElementById('torreSelect').value;
    const guarita = document.getElementById('guaritaSelect').value;

    if (!torre || !guarita) {
        alert("Por favor, preencha todos os campos.");
        return;
    }

    enviarDados();
});


function carregarTabelaApresentacao() {
    console.log("Atualizando tabela...");
    fetch('carregar_tabela.asp')
    .then(response => response.text())
    .then(data => {
        document.getElementById("tabelaApresentacoes").innerHTML = data;
    })
}

function enviarDados(confirmado = false) {
    const matricula = document.getElementById('matricula').value;
    const torre = document.getElementById('torreSelect').value;
    const guarita = document.getElementById('guaritaSelect').value;

    let body = `matricula=${encodeURIComponent(matricula)}&torre=${encodeURIComponent(torre)}&guarita=${encodeURIComponent(guarita)}`;
    if (confirmado) {
        body += "&confirmado=1";
    }

    fetch("inserir.asp", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: body
    })
    .then(response => response.text())
    .then(data => {
        if (data.trim() === "ok") {
            setTimeout(() => {
                carregarTabelaApresentacao();
            }, 500);
        } else if (data.startsWith("confirmar|")) {
            const supervisaoOriginal = data.split("|")[1];
            const continuar = confirm(`Você está tentando se apresentar em outra supervisão (Selecionada: ${torre}, Original: ${supervisaoOriginal}). Deseja continuar mesmo assim?`);
            if (continuar) {
                enviarDados(true);
            }
        } else {
            alert("Erro ao registrar: " + data);
        }
    });
}


window.onload = carregarTabelaApresentacao;