<%@ Language="VBScript" %>
<!--#include file='conexao.asp' -->
<!--#include file='carregar_tabela.asp' -->
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001

Dim torreFiltro

if request.QueryString("torre") <> "" then
  torreFiltro = request.QueryString("torre")
else
  torreFiltro = Request.Form("torre")
end if

%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- Atualiza a página a cada minuto -->
  <meta http-equiv="refresh" content="20; URL=ccp.asp?torre=<%=Server.URLEncode(torreFiltro)%>">
  <!--<meta http-equiv="refresh" content="20; URL=ccp_original.asp?torre=<'%=Server.URLEncode(torreFiltro)%>">-->
  <title>Controle de Apresentação | CCP</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,200..1000;1,200..1000&family=Oswald:wght@200..700&family=Parisienne&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap" rel="stylesheet">
  <style>
    * {
      font-family: 'Oswald', sans-serif;
    }
    .btn-aguardando {
      background-color: #f0ad4e;
      color: white;
    }
    .btn-atrasado {
      background-color: #d9534f;
      color: white;
    }
  </style>
</head>
<body style="background-color: rgb(80, 80, 80);">
  <header class="bg-black text-white d-flex align-items-center justify-content-between py-3 px-3 mb-3">
    <img class="img-fluid me-4" style="height: 60px;" src="static/images/logo-vale.png" alt="VALE">
    
    <div class="flex-grow-1 text-center">
      <div class="fs-1 fw-bold">
        <span class="text-danger">CCP</span> | SISTEMA TROCA DE TURNO - OP1
      </div>
    </div>

    <div class="fs-6 text-end" style="white-space: nowrap;">
      Última atualização: <br>
      <%= ultimaAtualizacao(torreFiltro) %>
    </div>
  </header>

  <div class="container-fluid px-4">
    <!-- Formulário de filtragem -->
    <div class="row mb-3">
      <div class="col-md-auto">
        <form method="post" action="ccp.asp"> <!-- ALTERAR ACTION PARA ccp_original.asp -->
          <div class="row g-3 align-items-center">
            <div class="col-auto">
              <select class="form-select" name="torre" id="torre" required>
                <option value="" disabled <% If torreFiltro = "" Then Response.Write "selected" %>>Selecione a Supervisão</option>
                <option value="" <% If torreFiltro = "" Then Response.Write "selected" %>>Todos</option>
                <option value="TORRE_A" <% If torreFiltro = "TORRE_A" Then Response.Write "selected" %>>TORRE A</option>
                <option value="TORRE_B" <% If torreFiltro = "TORRE_B" Then Response.Write "selected" %>>TORRE B</option>
                <option value="TORRE_C" <% If torreFiltro = "TORRE_C" Then Response.Write "selected" %>>TORRE C</option>
                <option value="TORRE_L" <% If torreFiltro = "TORRE_L" Then Response.Write "selected" %>>TORRE L</option>
                <option value="PV_AB" <% If torreFiltro = "PV_AB" Then Response.Write "selected" %>>VPN</option>
              </select>
            </div>
            <div class="col-auto">
              <button class="btn btn-primary" type="submit" id="filtrar" name="filtrarSupervisao">
                <i class="fas fa-filter"></i> Filtrar
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <!-- Título -->
    <div class="row">
      <div class="col-12">
        <h5 class="card-title h1 text-white mt-4">Colaboradores Apresentados</h5>
      </div>
    </div>
  </div>
    <!-- Tabela com os dados filtrados -->
    <div class="table-responsive mt-3">
      <table class="table table-bordered table-hover table-striped table-dark table-sm">
        <thead class="table-light text-center fs-3 fw-bold">
          <tr>
            <th>Nome</th>
            <th><i class="fas fa-house"></i> Local</th>
            <th><i class="fas fa-clock"></i> Apresentação</th>
            <th><i class="fas fa-clock"></i> Prontidão</th>
            <th>Chamada</th>
          </tr>
        </thead>
        <tbody id="tabelaApresentacoes">
          <%= carregarTabelaCCP(torreFiltro) %>
        </tbody>
      </table>
    </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
