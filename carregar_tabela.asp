<!--#include file="conexao.asp" -->
<!--#include file="utils.asp" -->
<%
Response.Charset = "UTF-8"

' Função pra carregar a tabela do pátio
Function carregarTabela(torreFiltro, guaritaFiltro)
    Dim conn, rs, sql, turno
    Set conn = getConexao()
    turno = turnoAtual() ' função de utils.asp que retorna se é "manhã" ou "noite"

    ' SQL pra retornar o nome, matrícula, data e hora da apresentação, supervisão, guarita e data e hora da prontidão
    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_apresentacao, ra.supervisao_ra, ra.local_trabalho_ra, ra.data_hora_prontidao_ra " & _
          "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " & _
          "WHERE DateValue(ra.data_hora_apresentacao) = Date() "

    ' Condição que verifica se o filtro de torre foi passado no parametro e concatena com o SQL com um AND
    If torreFiltro <> "" Then
        sql = sql & "AND ra.supervisao_ra = '" & torreFiltro & "' "
    End If
    
    ' Condição que verifica se o guarita de torre foi passado no parametro e concatena com o SQL com um AND
    If guaritaFiltro <> "" Then
        sql = sql & "AND ra.local_trabalho_ra = '" & guaritaFiltro & "' "
    End If

    ' Condição que verifica se o turno retornou "manhã" ou "noite" 
    If turno = "manha" Then
        sql = sql & "AND DatePart('h', ra.data_hora_apresentacao) BETWEEN 5 AND 17 "
    Else
        sql = sql & "AND (DatePart('h', ra.data_hora_apresentacao) >= 17 OR DatePart('h', ra.data_hora_apresentacao) < 5) "
    End If

    ' Concatenar com o SQL para trazer o registro mais recente
    sql = sql & "ORDER BY ra.data_hora_apresentacao DESC;"
    
    Set rs = conn.Execute(sql)

    ' While para apresentar na tabela da página os funcionários registrados 
    Do While Not rs.EOF
        ' Variaveis para minupular horarios de apresentação e prontidao, diferença de minutos, guarita e torre formatados
        Dim horarioApresentacao, diferencaMinutos, horarioProntidao, guaritaFormatada, torreFormatada 
        
        horarioApresentacao = TimeValue(rs("data_hora_apresentacao")) ' Pega apenas o horário
        diferencaMinutos = DateDiff("n", rs("data_hora_apresentacao"), Now()) ' Pega a diferença de horarios entre apresentacao e atual
        guaritaFormatada = Replace(guaritaFiltro, "_", " ")
        torreFormatada = Replace(torreFiltro, "_", " ")

        Response.Write "<tr>"
        Response.Write "<td class='fs-4 fw-bold text-center'>" & rs("nome") & "</td>"
        Response.Write "<td class='fs-4 fw-bold text-center'>" & torreFormatada & " - " & guaritaFormatada & "</td>"
        Response.Write "<td class='fs-4 fw-bold text-center'>" & horarioApresentacao & "</td>"

        Dim status, buttonClass, botaoProntidao ' Variaveis para status do funcionario, definir o estilo do botão e formatação do botão de prontidao
        Dim rsAss, sqlAss, assinatura

        ' SQL para verificar se o funcionário fez a assinatura do DSS (como a página está sempre 
        'recarregando, ele faz essa verificação a cada vez que recarrega)
        sqlAss = "SELECT COUNT(*) AS total FROM ASSINATURA_DSS WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(DATA_INSERT) = Date()"
        Set rsAss = conn.Execute(sqlAss)

        assinatura = 0
        If Not rsAss.EOF Then
            assinatura = rsAss("total") ' Atribui o valor a variavel
        End If
        rsAss.Close

        ' Condição que verifica se o funcionário fez a assinatura do DSS
        If assinatura > 0 Then
            ' Condição que verifica se o funcionário está dentro dos 15 minutos após a assinatura do DSS
            If diferencaMinutos <= 15 Then
                status = "Pronto"

                botaoProntidao = "<form method='post' action='atualizar_status.asp'>" & _
                "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                "<input type='hidden' name='status' value='" & status & "'>" & _
                "<button type='submit' class='btn btn-success'>Pronto</button></form>"
            Else
                status = "Pronto com atraso"

                botaoProntidao = "<form method='post' action='atualizar_status.asp'>" & _
                "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                "<input type='hidden' name='status' value='" & status & "'>" & _
                "<button type='submit' class='btn btn-danger'>Pronto</button></form>"
            End If
        Else
            ' Caso ainda não fez o DSS, entra na condição onde coloca um botão desabilitado que aguarda o DSS
            If diferencaMinutos <= 15 Then
                botaoProntidao = "<button class='btn btn-aguardando' disabled>Aguardando DSS...</button>"
            Else
                ' Caso passe dos 15 minutos e o funcionário não fez o DSS, o botão é habilitado com a cor
                ' vermelha para dizer que está pronto com atraso
                status = "Pronto com atraso"

                botaoProntidao = "<form method='post' action='atualizar_status.asp'>" & _
                    "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                    "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                    "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                    "<input type='hidden' name='status' value='" & status & "'>" & _
                    "<button type='submit' class='btn btn-danger'>Pronto</button></form>"
            End If
        End If

        ' Lógica do ícone de status
        Dim rsStatus, sqlStatus, statusAtual
        
        ' SQL que retorna o valor da coluna status_funcionario ("Pronto" ou "Pronto com atraso")
        sqlStatus = "SELECT status_funcionario FROM registros_apresentacao WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(data_hora_apresentacao) = Date()"
        Set rsStatus = conn.Execute(sqlStatus)

        ' Se tiver registro, atribui a variavel "statusAtual", se não continua vazio
        horarioProntidao = ""
        statusAtual = ""

        If Not rsStatus.EOF Then
            statusAtual = rsStatus("status_funcionario")
        End If
        rsStatus.Close

        ' Condição para 
        If statusAtual = "Pronto" Then
            horarioProntidao = "<span class='text-success'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span>"
            botaoProntidao = "<form method='post' action='atualizar_status.asp'>" & _
                "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                "<input type='hidden' name='status' value='" & status & "'>" & _
                "<button type='submit' class='btn btn-success' disabled>Pronto</button></form>"
        ElseIf statusAtual = "Pronto com atraso" Then
            horarioProntidao = "<span class='text-danger'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span>"
            botaoProntidao = "<form method='post' action='atualizar_status.asp'>" & _
                "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                "<input type='hidden' name='status' value='" & status & "'>" & _
                "<button type='submit' class='btn btn-danger' disabled>Pronto</button></form>"
        Else
            If diferencaMinutos <= 15 Then
                icon = "<i class='fas fa-clock text-warning'></i>"
            Else
                icon = "<i class='fas fa-times-circle text-danger'></i>"
            End If
        End If

        Response.Write "<td class='fs-4 fw-bold text-center'>" & botaoProntidao & "</td>"
        Response.Write "<td class='fs-4 fw-bold text-center'>" & horarioProntidao & "</td>"
        Response.Write "</tr>"

        rs.MoveNext
    Loop

    conn.Close
End Function


Function carregarTabelaCCP(torreFiltro)
    Dim conn, rs, sql, turno
    Set conn = getConexao()
    turno = turnoAtual()

    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_apresentacao, ra.supervisao_ra, ra.local_trabalho_ra, ra.data_hora_prontidao_ra " & _
          "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " & _
          "WHERE DateValue(ra.data_hora_apresentacao) = Date() "

    If torreFiltro <> "" Then
        sql = sql & "AND ra.supervisao_ra = '" & torreFiltro & "' "
    End If

    If turno = "manha" Then
        sql = sql & "AND DatePart('h', ra.data_hora_apresentacao) BETWEEN 5 AND 17 "
    Else
        sql = sql & "AND (DatePart('h', ra.data_hora_apresentacao) >= 17 OR DatePart('h', ra.data_hora_apresentacao) < 5) "
    End If

    sql = sql & "ORDER BY ra.data_hora_apresentacao DESC;"

    Set rs = conn.Execute(sql)

    Do While Not rs.EOF
        Dim horarioApresentacao, horarioProntidao, guaritaFormatada, torreFormatada

        horarioApresentacao = TimeValue(rs("data_hora_apresentacao"))
        guaritaFormatada = Replace(rs("local_trabalho_ra"), "_", " ")
        torreFormatada = Replace(rs("supervisao_ra"), "_", " ")

        Response.Write "<tr>"
        Response.Write "<td class='fs-4 fw-bold text-center'>" & rs("nome") & "</td>"
        Response.Write "<td class='fs-4 fw-bold text-center'>" & torreFormatada & " - " & guaritaFormatada & "</td>"
        Response.Write "<td class='fs-4 fw-bold text-center'>" & horarioApresentacao & "</td>"

        Dim rsStatus, sqlStatus, currentStatus, icon, diferencaMinutos, mensagem

        sqlStatus = "SELECT status_funcionario FROM registros_apresentacao WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(data_hora_apresentacao) = Date()"
        Set rsStatus = conn.Execute(sqlStatus)

        diferencaMinutos = DateDiff("n", rs("data_hora_apresentacao"), Now())

        horarioProntidao = ""
        mensagem = ""
        currentStatus = ""
        If Not rsStatus.EOF Then
            currentStatus = rsStatus("status_funcionario")
        End If
        rsStatus.Close

        If currentStatus = "Pronto" Then
            response.Write "<td class='fs-3 fw-bold text-center'><span class='text-success'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span></td>"
            mensagem = "ACIONAR"
        ElseIf currentStatus = "Pronto com atraso" Then
            response.Write "<td class='fs-3 fw-bold text-center'><span class='text-warning'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span></td>"
            mensagem = "ACIONAR"
        Else
            If diferencaMinutos <= 15 Then
                response.write "<td class='fs-4 fw-bold text-center'>AGUARDANDO</td>"
            Else
                response.write "<td class='fs-4 fw-bold text-center'><span class='text-warning'>EXCEDEU</span></td>"
                mensagem = "ACIONAR"
            End If
        End If

        Response.Write "<td class='fs-4 fw-bold text-center'>" & mensagem & "</td>"
        Response.Write "</tr>"

        rs.MoveNext
    Loop

    conn.Close
End Function
%>
