function carregarTabelaTurno() {
    fetch('horario_turno.php')
        .then(response => response.json())
        .then(data => {
            const tabela = document.getElementById('tabelaApresentacoes');
            tabela.innerHTML = '';

            if (data.length === 0) {
                tabela.innerHTML = '<tr><td colspan="3">Nenhum funcionário apresentado ainda.</td></tr>';
                return;
            }

            data.forEach(item => {
                const func = item; 
                const linha = `
                    <tr>
                    <td class="fs-4 fw-bold">${func.nome}</td>
                    <td class="fs-4 fw-bold">${func.matricula}</td>
                    <td class="fs-4 fw-bold">${new Date(func.data_hora).toLocaleString('pt-BR')}</td>
                    <td class="fs-4 fw-bold">${func.dss}</td>
                    </tr>
                `;
                tabela.innerHTML += linha;
            }); 
            
            console.log('Dados recebidos:', data); // Log dos dados recebidos
        })
        .catch(error => {
            console.error('Erro ao carregar a tabela:', error);
        });
}

document.addEventListener('DOMContentLoaded', carregarTabelaTurno);

setInterval(carregarTabelaTurno, 60000);