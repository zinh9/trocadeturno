<%@ Language="VBScript" %>
<!--#include file='conexao.asp' -->
<!--#include file='carregar_tabela.asp' -->
<%
  Response.Charset = "UTF-8"
  Response.CodePage = 65001

  ' Pega os parâmetros da query string
  qsTorre = Request.QueryString("torre")
  qsGuarita = Request.QueryString("guarita")

  select case qsTorre
  case "TORRE_A", "TORRE_B", "TORRE_C", "TORRE_L", "PV_AB"
  case else 
    response.redirect "default.asp"
  end select

  select case qsGuarita 
  case "Guarita_7", "Guarita_HT6", "Inert", "Hump_Yard", _
    "Guarita_2", "Guarita_3", "Guarita_4", "Guarita_5", _
    "Guarita_do_Corte", "Guarita_da_Rampa", _
    "Guarita_da_Torre_L", _
    "Porto_Velho", "Aroaba"
  case else
    response.redirect "default.asp"
  end select
  
%>
<!DOCTYPE html>
<html lang="pt-br">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="20">
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
      <div class="fs-1 fw-bold"><span class="text-warning">PÁTIO</span> | SISTEMA TROCA DE TURNO - OP1</div>
    </div>

    <div class="fs-6 text-end" style="white-space: nowrap;">
      Última atualização: <br>
      <%= ultimaAtualizacao(qsTorre) %>
    </div>
  </header>

  <div class="container-fluid px-4">
    <div class="row mb-4">
      <div class="col-12 d-flex align-items-center">
        <h5 class="card-title h1 text-white mt-1">
        <%
        if qsTorre = "PV_AB" then
          response.write "VPN - " & Replace(qsGuarita, "_", " ")
        else
          response.write Replace(qsTorre, "_", " ") & " - " & Replace(qsGuarita, "_", " ")
        end if
        %>
        </h5>
        <div class="ms-auto text-white fs-2">
          <div class="text-warning fw-bold" id="demo"></div>
        </div>
      </div>
    </div>
    <div class="row mb-3">
      <div class="col-md-auto">
        <form method="post" id="formInserir">
          <div class="row g-3 align-items-center">
            <div class="col-auto">
              <input type="text" id="matricula" name="matricula" class="form-control" placeholder="Digite sua Matrícula" required>
            </div>
            <div class="col-auto">
              <input type="hidden" name="torre" id="torreSelect" value="<%= qsTorre %>">
            </div>
            <div class="col-auto">
              <input type="hidden" name="guarita" id="guaritaSelect" value="<%= qsGuarita %>">
            </div>
            <div class="col-auto">
              <button type="submit" class="btn btn-primary mr-5" id="botaoApresentar">
                <i class="fas fa-check"></i> Apresentar
              </button>
            </div>
            <div class="col-auto" id="mensagem"></div>
          </div>
        </form>
      </div>
      <div class="col-md-auto">
        <div class="col-auto">
          <button type="button" class="btn btn-secondary bg-dark" onclick="window.open('https://efvmworkplace/dss/login_form.asp', '_blank')">
            <i class="fa fa-shield"></i> Assinar DSS
          </button>
        </div>
      </div>
      <div class="col-md-auto ms-auto">
        <button class="btn btn-secondary" type="button" id="menuButton" onclick="window.location.href='http://efvmworkplace/trocadeturno/default.asp'">
          <i class="fas fa-bars"></i> Menu
        </button>
      </div>
    </div>
  </div>

  <div class="table-responsive mt-4">
    <table class="table table-bordered table-hover table-striped table-dark table-sm">
      <thead class="table-light text-center fs-3 fw-bold">
        <tr>
          <th>Nome</th>
          <th class="w-40"><i class="fas fa-house"></i> Local</th>
          <th><i class="fas fa-clock"></i> Apresentação</th>
          <th>Pronto?</th>
          <th><i class="fas fa-clock"></i> Prontidão</th>
        </tr>
      </thead>
      <tbody id="tabelaApresentacoes">
        <%= carregarTabela(qsTorre, qsGuarita) %>
      </tbody>
    </table>
  </div>

  <script>
    var myVar = setInterval(myTimer, 1000);
    function myTimer(){
      var d = new Date(), displayDate;

      if (navigator.userAgent.toLowerCase().indexOf('firefox') > -1) {
        displayDate = d.toLocaleTimeString('pt-BR');
      } else {
        displayDate = d.toLocaleTimeString('pt-BR', {timeZone: 'America/Belem'})
      }

      document.getElementById("demo").innerHTML = displayDate;
    }
  </script>

  <script src="static/ajax.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>
