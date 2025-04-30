<%@ Language="VBScript" %>
<!--#include file="conexao.asp" -->
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001

' Parâmetros da query string
qsTorre = Request.QueryString("torre")
qsGuarita = Request.QueryString("guarita")
modoControle = Request.QueryString("controle") ' Se "controle=true", não exibe o formulário de apresentação.

%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Controle de Apresentação</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet"><link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,200..1000;1,200..1000&family=Oswald:wght@200..700&family=Parisienne&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap" rel="stylesheet">
  <style>
    * { font-family: 'Oswald', sans-serif; }
  </style>
</head>
<body style="background-color: rgb(85,85,85);">
  <header class="bg-black text-white d-flex align-items-center justify-content-between py-3 px-3 mb-3">
    <img class="img-fluid me-4" style="height: 60px;" src="static/images/logo-vale.png" alt="VALE">
    <div class="flex-grow-1 text-center">
      <div class="fs-1 fw-bold">SISTEMA TROCA DE TURNO - OP1</div>
    </div>
    <div class="fs-6 text-end" style="white-space: nowrap;">
      Última atualização:<br>
      <%
        Dim data_ultima_atualizacao, sqlU
        Set conn = getConexao()
        sqlU = "SELECT TOP 1 data_hora_ra FROM registros_apresentacao ORDER BY data_hora_ra DESC"
        Set data_ultima_atualizacao = conn.execute(sqlU)
        If Not data_ultima_atualizacao.EOF Then
          Response.Write(FormatDateTime(data_ultima_atualizacao("data_hora_ra"), vbShortDate) & " " & FormatDateTime(data_ultima_atualizacao("data_hora_ra"), vbLongTime))
        Else
          Response.Write("--/--/-- --:--:--")
        End If
        conn.close
      %>
    </div>
  </header>

  <div class="container-fluid px-4">
    <!-- Seção para registro de matrícula: exibida somente se não for o modo controle -->
    <% If LCase(modoControle) <> "true" Then %>
      <div class="row mb-3">
        <div class="col-md-auto">
          <form method="post" id="formApresentacao">
            <div class="row g-3 align-items-center">
              <div class="col-auto">
                <input type="text" id="matricula" name="matricula" class="form-control" placeholder="Digite sua matrícula" required>
              </div>
              <div class="col-auto" id="mensagem"></div>
            </div>
          </form>
        </div>
      </div>
    <% End If %>
    <div class="row mb-3">
      <div class="col-md-auto">
        <form id="formFiltros">
          <div class="row g-3 align-items-center">
            <div class="col-auto">
              <select id="torreSelect" name="torre" class="form-select" required>
                <option value="" disabled selected>Filtrar por Torre</option>
                <option value="TORRE_A">TORRE_A</option>
                <option value="TORRE_B">TORRE_B</option>
                <option value="TORRE_C">TORRE_C</option>
                <option value="TORRE_L">TORRE_L</option>
              </select>
            </div>
            <div class="col-auto">
              <select id="guaritaSelect" name="guarita" class="form-select" required>
                <option value="" disabled selected>Filtrar por Guarita</option>
              </select>
            </div>
            <div class="col-auto">
              <button type="button" class="btn btn-primary" id="btnFiltrar">
                <i class="fas fa-filter"></i> Filtrar
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <div class="row">
      <div class="col-12">
        <h5 class="card-title h1 text-white mt-4">Funcionários Apresentados</h5>
      </div>
    </div>

    <!-- Tabela dos registros -->
    <div class="table-responsive mt-3">
      <table class="table table-bordered table-hover table-striped table-dark table-sm">
        <thead class="table-light text-center fs-3 fw-bold">
          <tr>
            <th class="fs-3 fw-bold">Nome</th>
            <th class="fs-3 fw-bold">Matrícula</th>
            <th class="fs-3 fw-bold"><i class="fas fa-house"></i></th>
            <th class="fs-3 fw-bold">DSS</th>
          </tr>
        </thead>
        <tbody id="tabelaApresentacoes">
          <!-- Os registros serão carregados via AJAX -->
        </tbody>
      </table>
    </div>
  </div>

  <!-- Inclui o arquivo de JavaScript com a lógica AJAX e dos filtros -->
  <script src="static/js/ajax.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>