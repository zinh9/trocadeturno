document.getElementById("formApresentacao").addEventListener("submit", function(event) {
    event.preventDefault();
    const torre = document.getElementById('torreSelect').value;
    const guarita = document.getElementById('guaritaSelect').value;

    if (torre === "Selecione a Torre" || guarita === "Selecione a Guarita") {
        alert("Por favor, preencha todos os campos.");
        return;
    }

    enviarDados();
});

document.getElementById("torreSelect").addEventListener("change", function() {
    const torreSelecionada = this.value;
    const guaritaSelect = document.getElementById("guaritaSelect").value;

    if (torreSelecionada !== "Selecione a Torre") {
        carregarGuaritas(torreSelecionada, guaritaSelect);
    }
});

document.getElementById("guaritaSelect").addEventListener("change", function() {
    const torreSelecionada = document.getElementById("torreSelect").value;
    const guaritaSelecionada = this.value;

    if (guaritaSelecionada !== "Selecione a Guarita") {
        carregarTabelaApresentacao(torreSelecionada, guaritaSelecionada);
    }
});

function carregarTabelaApresentacao(torreSelecionada = "", guaritaSelecionada = "") {
    const formData = new FormData();

    if (torreSelecionada) {
        formData.append('torre', torreSelecionada);
    }

    if (guaritaSelecionada) {
        formData.append('guarita', guaritaSelecionada);
    }

    fetch('carregar_tabela.asp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: formData
    })
    .then(response => response.text())
    .then(data => {
        document.getElementById("tabelaApresentacoes").innerHTML = data;
    })
    .catch(error => {
        console.error('Erro ao carregar a tabela:', error);
    });
}

function enviarDados(confirmado = false) {
    const matricula = document.getElementById('matricula').value;
    const torre = document.getElementById('torreSelect').value;
    const guarita = document.getElementById('guaritaSelect').value;
    const mensagem = document.getElementById('mensagem');

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
                document.getElementById('mensagem').innerHTML = "<span style='color:lime;'>Apresentação registrada com sucesso!</span>";
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


window.onload = function() {
    carregarTabelaApresentacao();
}