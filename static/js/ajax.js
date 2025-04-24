document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('formApresentacao').addEventListener('submit', function (event) {
        event.preventDefault();

        const matricula = document.getElementById('matricula').value;
        const torre = document.getElementById('torreSelect').value;
        const guarita = document.getElementById('guaritaSelect').value;

        if (!torre || !guarita) {
            alert("Por favor, preencha todos os campos.");
            return;
        }

        fetch("inserir.asp", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: `matricula=${encodeURIComponent(matricula)}&torre=${encodeURIComponent(torre)}&guarita=${encodeURIComponent(guarita)}`
        })
        .then(response => response.text())
        .then(data => {
            const mensagemDiv = document.getElementById('mensagem');
            mensagemDiv.innerHTML = data;

            const confirmacao = document.getElementById('confirmar-supervisao');
            if (confirmacao) {
                const torreConfirm = confirmacao.getAttribute("data-supervisao");
                const guaritaConfirm = confirmacao.getAttribute("data-guarita");

                if (confirm("Você está fazendo uma apresentação fora da sua supervisão. Deseja continuar?")) {
                    fetch("inserir.asp", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/x-www-form-urlencoded"
                        },
                        body: `matricula=${encodeURIComponent(matricula)}&torre=${encodeURIComponent(torreConfirm)}&guarita=${encodeURIComponent(guaritaConfirm)}&confirmado=sim`
                    })
                    .then(response => response.text())
                    .then(data => {
                        mensagemDiv.innerHTML = data;
                    });
                }
            }
        });
    });
});
