<%@ Language="VBScript" %>
<%
Response.Charset = "UTF-8"
Response.CodePage = 65001
%>
<!DOCTYPE html>
<html lang="pt-br">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Controle de Apresentação</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">

  <style>
   menu {
      position: relative;
    }

    .dropdown-submenu .dropdown-menu {
      display: none;
      position: absolute;
      left: 100%;
      top: 0;
      margin-top: 0;
      margin-left: 0;
    }

    .dropdown-submenu:hover .dropdown-menu {
      display: block;
    }
  </style>
</head>

<body style="background-color: rgb(55, 55, 55);">
  <header class="bg-black text-white d-flex align-items-center py-3 px-3 mb-3">
    <img class="img-fluid me-4" style="height: 60px;" src="static/images/logo-vale.png" alt="VALE">
    <div class="fs-1 fw-bold mt-3">SISTEMA TROCA DE TURNO - OP1</div>
    <div class="fs-6 mr-4 ms-auto text-end">
      Última atualização: <br>
      <%= now() %>
    </div>
  </header>

  <div class="container-fluid px-4">
    <div class="row md-4">
      <div class="col-md-auto">
        <form method="post" id="formApresentacao">
          <div class="row g-3 align-items-center">
            <div class="col-auto d-flex gap-2 ms-auto"></div>
            <div class="col-auto">
              <input type="text" id="matricula" name="matricula" class="form-control" placeholder="Digite sua matrícula" required>
            </div>
            <div class="col-auto">
              <button type="submit" class="btn btn-primary">
                <i class="fas fa-check"></i> Apresentar
              </button>
            </div>
            <div class="col_auto" id="mensagem"></div>
          </div>
        </form>
      </div>

      <div class="col-auto ms-auto">
        <select id="torreSelect" class="form-select" required>
          <option selected disabled>Selecione a Torre</option>
          <option value="TORRE_A">TORRE_A</option>
          <option value="TORRE_B">TORRE_B</option>
          <option value="TORRE_C">TORRE_C</option>
          <option value="TORRE_L">TORRE_L</option>
        </select>
      </div>

      <div class="col-auto">
        <select id="guaritaSelect" class="form-select" required>
          <option selected disabled>Selecione a Guarita</option>
        </select>
      </div>
    </div>

    <div class="row">
      <div class="col-12">
        <h5 class="card-title h1 text-white mt-4">Funcionários Apresentados</h5>
      </div>
    </div>
  </div>

  <div class="table-responsive mt-3">
    <table class="table table-bordered table-hover table-lg table-striped table-dark table-sm rounded">
      <thead class="table-primary">
        <tr>
          <th class="fs-3 fw-bold">Nome</th>
          <th class="fs-3 fw-bold">Matrícula</th>
          <th class="fs-3 fw-bold"><i class="fas fa-house"></i></th>
          <th class="fs-3 fw-bold">DSS</th>
        </tr>
      </thead>
      <tbody id="tabelaApresentacoes">
        <!--#include file='conexao.asp' -->
        <%

        Dim sql, rs
        sql = "SELECT ld.detalhe" &_
        ", ld.usuario_dss" &_
        ", ra.data_hora_ra" &_
        ", ra.supervisao_ra" &_
        ", ra.local_ra " &_
        "FROM registros_apresentacao AS ra " &_
        "INNER JOIN login_dss AS ld ON ra.usuario_dss = ld.usuario_dss"
        Set rs = conn.Execute(sql)

        if rs.EOF = false then
          Do While Not rs.EOF
            response.Write "<tr>"
              response.write "<td class='fs-4 fw-bold'>" & rs("detalhe") & "</td>"
              response.write "<td class='fs-4 fw-bold'>" & rs("usuario_dss") & "</td>"
              response.write "<td class='fs-4 fw-bold'>" & rs("data_hora_ra") & "</td>"
              response.write "<td class='fs-4 fw-bold'>" & rs("supervisao_ra") & "</td>"
              response.write "<td class='fs-4 fw-bold'>" & rs("local_ra") & "</td>"
            response.write "</tr>"
            rs.MoveNext
          Loop
        else
          response.write "<tr class='table-danger'><td colspan='5'>No records found</td></tr>"
        end if

        ' Close the recordset and connection
        rs.Close
        Set rs = Nothing
        conn.Close
        Set conn = Nothing

        %>
      </tbody>
    </table>
  </div>

  <script>
    const guaritasPorTorre = {
      "TORRE_A": ["Guarita_7", "HT6"],
      "TORRE_B": ["Guarita_2", "Guarita_3", "Guarita_4", "Guarita_5"],
      "TORRE_C": ["Guarita_da_Rampa", "Guarita_do_Corte"],
      "TORRE_L": ["Guarita_da_Torre_L"]
    };

    document.getElementById('torreSelect').addEventListener('change', function () {
      const torre = this.value;
      const guaritaSelect = document.getElementById('guaritaSelect');

      guaritaSelect.innerHTML = '<option selected disabled>Selecione a Guarita</option>';
      if (guaritasPorTorre[torre]) {
        guaritasPorTorre[torre].forEach(g => {
          const option = document.createElement('option');
          option.value = g;
          option.textContent = g;
          guaritaSelect.appendChild(option);
        });
      }
    });
  </script>
  
  <script>
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
              });
      });
    });
  </script>
  <script src="./static/js/tabela_turno.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
