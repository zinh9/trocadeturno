<!DOCTYPE html>
<html lang="pt-br">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Menu de Links</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,200..1000;1,200..1000&family=Oswald:wght@200..700&family=Parisienne&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap"
        rel="stylesheet">

    <style>
        * {
            font-family: 'Oswald', sans-serif;
        }

        .g7 {
            background-color: #4ca4a1;
        }

        .ht6 {
            background-color: #329794;
        }

        .g2 {
            background-color: #f1c862;
        }

        .g3 {
            background-color: #efc04b;
        }

        .g4 {
            background-color: #edb835;
        }

        .g5 {
            background-color: #ecb11f;
        }

        .gc {
            background-color: #bcb771;
        }

        .gr {
            background-color: #b3ad5d;
        }

        .gtl {
            background-color: #1e6f8a;
        }

        .pv {
            background-color: #818E60;
        }

        .ab {
            background-color: #747f56;
        }

        .btn-custom {
            display: inline-block;
            padding: 0.375rem 0.75rem;
            font-size: 1rem;
            text-align: center;
            text-decoration: none;
            border-radius: 0.25rem;
            color: #191919;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-custom:hover {
            transform: translateY(-2px) scale(1.03);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            filter: brightness(1.1);
        }

        .btn-custom:active {
            transform: translateY(0) scale(0.98);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        @media (max-width: 768px) {
            .btn-custom {
                padding: 0.3rem 0.6rem;
                font-size: 0.9rem;
            }
        }

        @media (max-width: 480px) {
            .btn-custom {
                margin-bottom: 0.5rem;
            }
        }
    </style>
</head>

<body style="background-color: rgb(80, 80, 80);">
    <header class="bg-black text-white d-flex align-items-center justify-content-between py-3 px-3 mb-3">
        <img class="img-fluid mr-4" style="height: 60px;" src="static/images/logo-vale.png" alt="VALE">

        <div class="flex-grow-1 text-center mr-5">
            <div class="fs-1 fw-bold">SISTEMA TROCA DE TURNO - OP1</div>
        </div>
    </header>

    <div class="d-flex justify-content-center align-items-center position-relative p-4">
        <div class="card shadow" style="width: 50rem;">
            <div class="card-header bg-dark text-white text-center">
                <h5 class="mb-0">Selecione seu local</h5>
            </div>

            <div class="card-body fs-3">
                <ul class="list-unstyled">
                    <li class="d-flex align-items-center mb-3">
                        <span class="me-2">TORRE A:</span>
                        <div class="d-flex flex-wrap gap-2">
                            <a href="index.asp?torre=TORRE_A&guarita=Guarita_7"
                                class="btn-custom g7 btn-sm fs-5 fw-bold">Guarita 7</a>
                            <a href="index.asp?torre=TORRE_A&guarita=Guarita_HT6"
                                class="btn-custom ht6 btn-sm fs-5 fw-bold">Guarita HT6</a>
                            <span>|</span>
                            <a href="index.asp?torre=TORRE_A&guarita=Inert"
                                class="btn-custom bg-secondary btn-sm fs-5 fw-bold">INERT</a>
                            <a href="index.asp?torre=TORRE_A&guarita=Hump_Yard"
                                class="btn-custom bg-secondary btn-sm fs-5 fw-bold">HUMP
                                YARD</a>
                        </div>
                    </li>
                    <li class="d-flex align-items-center mb-3">
                        <span class="me-2">TORRE B:</span>
                        <div class="d-flex flex-wrap gap-2">
                            <a href="index.asp?torre=TORRE_B&guarita=Guarita_2"
                                class="btn-custom g2 btn-sm fs-5 fw-bold">Guarita 2</a>
                            <a href="index.asp?torre=TORRE_B&guarita=Guarita_3"
                                class="btn-custom g3 btn-sm fs-5 fw-bold">Guarita 3</a>
                            <a href="index.asp?torre=TORRE_B&guarita=Guarita_4"
                                class="btn-custom g4 fs-5 fw-bold">Guarita
                                4</a>
                            <a href="index.asp?torre=TORRE_B&guarita=Guarita_5"
                                class="btn-custom g5 fs-5 fw-bold">Guarita
                                5</a>
                        </div>
                    </li>
                    <li class="d-flex align-items-center mb-3">
                        <span class="me-2">TORRE C:</span>
                        <div class="d-flex flex-wrap gap-2">
                            <a href="index.asp?torre=TORRE_C&guarita=Guarita_do_Corte"
                                class="btn-custom gc btn-sm fs-5 fw-bold">Guarita do Corte</a>
                            <a href="index.asp?torre=TORRE_C&guarita=Guarita_da_Rampa"
                                class="btn-custom gr hover-background btn-sm fs-5 fw-bold">Guarita da Rampa</a>
                        </div>
                    </li>
                    <li class="d-flex align-items-center mb-3">
                        <span class="me-2">TORRE L:</span>
                        <div class="d-flex flex-wrap gap-2">
                            <a href="index.asp?torre=TORRE_L&guarita=Guarita_da_Torre_L"
                                class="btn-custom gtl btn-sm fs-5 fw-bold">Guarita da Torre L</a>
                        </div>
                    </li>
                    <li class="d-flex align-items-center">
                        <span class="me-2">VPN:</span>
                        <div class="d-flex flex-wrap gap-2">
                            <a href="index.asp?torre=PV_AB&guarita=Porto_Velho" class="btn-custom pv btn-sm fs-5 fw-bold">
                            Porto Velho</a>
                            <a href="index.asp?torre=PV_AB&guarita=Aroaba" class="btn-custom ab btn-sm fs-5 fw-bold">
                            Aroaba</a>
                        </div>
                    </li>
                </ul>
            </div>

        </div>


        <!-- Ícone de informações no canto superior direito-->
        <div class="position-absolute top-0 end-0 mt-3 me-4">
            <a href="#" title="Mais informações" id="infoIcon">
                <i class="bi bi-info-circle-fill fs-3 text-white"></i>
            </a>
        </div>
        <div id="infoCard" class="card text-white bg-dark position-absolute top-0 end-0 mt-5 me-4 shadow"
            style="width: 20rem; display: none; z-index: 1050;">
            <div class="card-body">
                <h5 class="card-title">Sobre e Atualizações do Sistema</h5>
                <p class="card-text">
                    O sistema foi implementado para os funcionários se apresentarem ao CPT de forma rápida e simples.
                    <br>
                    O funcionário deve chegar na guarita e realizar sua apresentação de imediato, colocando sua
                    matrícula
                    (a mesma utilizada para assinar o DSS) e clicar no botão "Apresentar". Logo após clicar no botão,
                    a página vai recarregar a colocar as informações na tabela e iniciara um tempo de 15 minutos
                    para fazer seus afazeres, realizar o teste de prontidão e assinar o DSS, <span
                        class="text-warning">somente após assinar
                        o DSS</span>, o botão "Pronto" irá aparecer na coluna para acionar ao CPT que está pronto 
                        receber as ondens.
                </p>
                <button class="btn btn-sm btn-light"
                    onclick="document.getElementById('infoCard').style.display='none'">Fechar</button>
            </div>
        </div>
    </div>
    <script>
        document.getElementById('infoIcon').addEventListener('click', function (e) {
            e.preventDefault();

            const card = document.getElementById('infoCard');

            card.style.display = card.style.display === 'none' ? 'block' : 'none';
        })
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</body>

</html>
