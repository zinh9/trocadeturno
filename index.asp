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
    .dropdown-submenu {
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
          <option value="Torre_A">TORRE A</option>
          <option value="Torre_B">TORRE B</option>
          <option value="Torre_C">TORRE C</option>
          <option value="Torre_L">TORRE L</option>
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
        <!-- Os dados serão preenchidos aqui via tabela_turno -->
      </tbody>
    </table>
  </div>

  <script>
    const guaritasPorTorre = {
      "Torre_A": ["Guarita_7", "HT6"],
      "Torre_B": ["Guarita_2", "Guarita_3", "Guarita_4", "Guarita_5"],
      "Torre_C": ["Guarita_da_Rampa", "Guarita_do_Corte"],
      "Torre_L": ["Guarita_da_Torre_L"]
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
    <script src="./static/js/ajax.js"></script>
  <script src="./static/js/tabela_turno.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>
