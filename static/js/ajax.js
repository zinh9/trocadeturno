// ajax.js

// Objeto que relaciona cada torre com suas opções de guarita
const guaritasPorTorre = {
    "TORRE_A": ["Guarita_7", "HT6"],
    "TORRE_B": ["Guarita_2", "Guarita_3", "Guarita_4", "Guarita_5"],
    "TORRE_C": ["Guarita_da_Rampa", "Guarita_do_Corte"],
    "TORRE_L": ["Guarita_da_Torre_L"]
};

// Atualiza o select de Guarita com base na torre selecionada
function atualizarGuaritas(torre) {
    const guaritaSelect = document.getElementById("guaritaSelect");
    guaritaSelect.innerHTML = '<option value="" disabled selected>Filtrar por Guarita</option>';
    if (guaritasPorTorre[torre]) {
        guaritasPorTorre[torre].forEach(g => {
            const option = document.createElement("option");
            option.value = g;
            option.textContent = g;
            guaritaSelect.appendChild(option);
        });
    }
    // Carrega a tabela após atualizar as guaritas
    carregarTabela();
}

// Recupera o valor de um parâmetro da query string
function getQueryParam(param) {
    const params = new URLSearchParams(window.location.search);
    return params.get(param);
}

// Carrega a tabela de apresentações com base na torre e guarita selecionadas
function carregarTabela() {
    const torre = document.getElementById("torreSelect").value;
    const guarita = document.getElementById("guaritaSelect").value;

    // Só carrega a tabela se ambos os filtros estiverem preenchidos
    if (!torre || !guarita) {
        console.log("Filtros incompletos. Torre ou guarita não selecionados.");
        document.getElementById("tabelaApresentacoes").innerHTML = `
          <tr>
            <td colspan="4" class="text-center text-warning fs-4">Selecione Torre e Guarita para exibir os dados</td>
          </tr>`;
        return;
    }

    const formData = new FormData();
    formData.append("torre", torre);
    formData.append("guarita", guarita);

    document.getElementById("tabelaApresentacoes").innerHTML = `
  <tr><td colspan="4" class="text-center text-info">Carregando dados...</td></tr>`;


    fetch("carregar_tabela.asp", {
        method: "POST",
        body: formData
    })
        .then(response => response.text())
        .then(data => {
            document.getElementById("tabelaApresentacoes").innerHTML = data;
        })
        .catch(err => {
            console.error("Erro ao carregar tabela:", err);
            document.getElementById("tabelaApresentacoes").innerHTML = `
          <tr><td colspan="4" class="text-center text-danger">Erro ao carregar os dados</td></tr>`;
        });
}

// Quando a página é carregada, preenche os filtros com a query string (se houver) e carrega a tabela
document.addEventListener("DOMContentLoaded", () => {
    console.log("DOM completamente carregado e analisado");

    const torreSelect = document.getElementById("torreSelect");
    const guaritaSelect = document.getElementById("guaritaSelect");
    const btnFiltrar = document.getElementById("btnFiltrar");

    let qsTorre = getQueryParam("torre");
    let qsGuarita = getQueryParam("guarita");

    if (qsTorre) {
        torreSelect.value = qsTorre;
        atualizarGuaritas(qsTorre);

        console.log("Torre selecionada:", qsTorre);
    }
    if (qsGuarita) {
        const observer = new MutationObserver(() => {
            const optionExists = Array.from(guaritaSelect.options).some(opt => opt.value === qsGuarita);
            if (optionExists) {
                guaritaSelect.value = qsGuarita;
                observer.disconnect(); // para de observar após setar
                carregarTabela();
            }
        });
    
        observer.observe(guaritaSelect, { childList: true });
    }
     else {
        carregarTabela();

        console.log("Nenhuma guarita selecionada, carregando tabela padrão.");
    }

    // Evento: quando a torre mudar, atualiza o select de guarita
    torreSelect.addEventListener("change", function () {
        atualizarGuaritas(this.value);

        console.log("Torre alterada:", this.value);
    });

    // Evento: quando o botão de filtrar for clicado, carrega a tabela
    btnFiltrar.addEventListener("click", carregarTabela);

    console.log("Botão de filtrar adicionado com sucesso.");

    // Evento: quando a guarita mudar, recarrega a tabela
    guaritaSelect.addEventListener("change", carregarTabela);

    console.log("Guarita alterada:", guaritaSelect.value);

    // Atualiza a tabela automaticamente a cada 60 segundos
    setInterval(carregarTabela, 60000);
});

document.addEventListener("submit", event => {
    event.preventDefault();
    const matricula = document.getElementById("matricula").value;
    const torre = document.getElementById("torreSelect").value;
    const guarita = document.getElementById("guaritaSelect").value;
    if (!torre || !guarita) {
        alert("Por favor, selecione torre e guarita.");
        return;
    }
    const body = `matricula=${encodeURIComponent(matricula)}&torre=${encodeURIComponent(torre)}&guarita=${encodeURIComponent(guarita)}`;
    fetch("inserir.asp", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: body
    })
        .then(resp => resp.text())
        .then(data => {
            if (data.trim() === "ok") {
                document.getElementById("mensagem").innerHTML = "<span style='color:lime;'>Apresentação registrada com sucesso!</span>";
                carregarTabela();
            } else if (data.startsWith("confirmar|")) {
                const supervisaoOriginal = data.split("|")[1];
                if (confirm(`Você está tentando se apresentar em outra supervisão (Selecionada: ${torre}, Original: ${supervisaoOriginal}). Deseja continuar?`)) {
                    const newBody = body + "&confirmado=1";
                    fetch("inserir.asp", {
                        method: "POST",
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: newBody
                    })
                        .then(r => r.text())
                        .then(resp => {
                            if (resp.trim() === "ok") carregarTabela();
                        });
                }
            } else {
                alert("Erro ao registrar: " + data);
            }
        });
});
