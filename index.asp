<%@ Language="VBScript" %>
<!--#include file='conexao.asp' -->
<!--#include file='carregar_tabela.asp' -->
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001

qsTorre = request.QueryString("torre")
qsGuarita = request.QueryString("guarita")

%>
<!DOCTYPE html>
<html lang="pt-br">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="60">
  <title>Controle de Apresentação</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,200..1000;1,200..1000&family=Oswald:wght@200..700&family=Parisienne&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap" rel="stylesheet">
  <style>
    * {
      font-family: 'Oswald', sans-serif;
    }
  </style>
</head>

<body style="background-color: rgb(80, 80, 80);">
  <header class="bg-black text-white d-flex align-items-center justify-content-between py-3 px-3 mb-3">
    <img class="img-fluid me-4" style="height: 60px;" src="static/images/logo-vale.png" alt="VALE">

    <div class="flex-grow-1 text-center">
      <div class="fs-1 fw-bold">SISTEMA TROCA DE TURNO - OP1</div>
    </div>

    <div class="fs-6 text-end" style="white-space: nowrap;">
      Última atualização: <br>
      <%
      Dim data_ultima_atualizacao, sql
      Set conn = getConexao()

      sql = "SELECT TOP 1 data_hora_ra "&_
        "FROM registros_apresentacao "&_
        "ORDER BY data_hora_ra DESC"
      Set data_ultima_atualizacao = conn.execute(sql)

      If Not data_ultima_atualizacao.EOF Then
        Response.Write(FormatDateTime(data_ultima_atualizacao("data_hora_ra"), vbShortDate) & " " & FormatDateTime(data_ultima_atualizacao("data_hora_ra"), vbLongTime))
      Else
        Response.Write("--/--/-- --:--:--")
      End If
      
      %>
    </div>
  </header>


  <div class="container-fluid px-4">
    <div class="row mb-3">
      <div class="col-md-auto">
        <form method="post" id="formApresentacao">
          <div class="row g-3 align-items-center">
            <div class="col-auto">
              <input type="text" id="matricula" name="matricula" class="form-control" placeholder="Digite sua matrícula" required>
            </div>
            <div class="col-auto">
              <select id="torreSelect" name="torre" class="form-select" required>
                <!--<option value="" disabled selected>Filtrar por Torre</option>-->
                <option value="<%= qsTorre %>" selected><%= qsTorre %></option>
              </select>
            </div>
            <div class="col-auto">
              <select id="guaritaSelect" name="guarita" class="form-select" required>
                <option value="<%= qsGuarita %>" selected><%= qsGuarita %></option>
              </select>
            </div>
            <div class="col-auto">
              <button type="submit" class="btn btn-primary">
                <i class="fas fa-check"></i> Apresentar
              </button>
            </div>
            <div class="col_auto " id="mensagem"></div>
          </div>
        </form>
      </div>
    </div>

    <div class="row">
      <div class="col-12">
        <h5 class="card-title h1 text-white mt-4">Funcionários Apresentados</h5>
      </div>
    </div>
  </div>

  <div class="table-responsive mt-3">
    <table class="table table-bordered table-hover table-striped table-dark table-sm">
      <thead class="table-light text-center fs-3 fw-bold">
        <tr>
          <th class="fs-3 fw-bold">Nome</th>
          <th class="fs-3 fw-bold">Matrícula</th>
          <th class="fs-3 fw-bold">Local</th>
          <th class="fs-3 fw-bold"><i class="fas fa-clock"></i></th>
          <th class="fs-3 fw-bold">DSS</th>
        </tr>
      </thead>
      <tbody id="tabelaApresentacoes">
        <%= carregarTabela(qsTorre, qsGuarita) %>
      </tbody>
    </table>
  </div>
  <script>
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
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>
