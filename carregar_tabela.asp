<!--#include file="conexao.asp" -->
<!--#include file="utils.asp" -->
<%
Response.Charset = "UTF-8"

Function carregarTabela(torreFiltro, guaritaFiltro)
    Dim conn, rs, sql, turno
    Set conn = getConexao()
    turno = turnoAtual()

    ' Monta a query base
    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_apresentacao, ra.supervisao_ra, ra.local_trabalho_ra, ra.data_hora_prontidao_ra " & _
          "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " & _
          "WHERE DateValue(ra.data_hora_apresentacao) = Date() "

    If torreFiltro <> "" Then
        sql = sql & "AND ra.supervisao_ra = '" & torreFiltro & "' "
    End If
    
    If guaritaFiltro <> "" Then
        sql = sql & "AND ra.local_trabalho_ra = '" & guaritaFiltro & "' "
    End If

    If turno = "manha" Then
        sql = sql & "AND DatePart('h', ra.data_hora_apresentacao) BETWEEN 6 AND 17 "
    Else
        sql = sql & "AND (DatePart('h', ra.data_hora_apresentacao) >= 18 OR DatePart('h', ra.data_hora_apresentacao) < 6) "
    End If

    sql = sql & "ORDER BY ra.data_hora_apresentacao DESC;"
    
    Set rs = conn.Execute(sql)

    Do While Not rs.EOF
        Dim horarioApresentacao, diffMinutes, horarioProntidao
        horarioApresentacao = TimeValue(rs("data_hora_apresentacao"))
        diffMinutes = DateDiff("n", rs("data_hora_apresentacao"), Now())

        Response.Write "<tr>"
        Response.Write "  <td class='fs-4 fw-bold text-center w-25'>" & rs("nome") & "</td>"
        Response.Write "  <td class='fs-4 fw-bold text-center w-25'>" & rs("supervisao_ra") & " - " & rs("local_trabalho_ra") & "</td>"
        Response.Write "  <td class='fs-4 fw-bold text-center w-25'>" & horarioApresentacao & "</td>"

        Dim desiredStatus, buttonClass, formButton
        Dim rsAss, sqlAss, assinatura
        sqlAss = "SELECT COUNT(*) AS total FROM ASSINATURA_DSS WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(DATA_INSERT) = Date()"
        Set rsAss = conn.Execute(sqlAss)
        assinatura = 0
        If Not rsAss.EOF Then
            assinatura = rsAss("total")
        End If
        rsAss.Close

        If assinatura > 0 Then
            ' O funcionário assinou o DSS
            If diffMinutes <= 15 Then
                desiredStatus = "Pronto"
                buttonClass = "btn btn-success" 
            Else
                desiredStatus = "Pronto com atraso"
                buttonClass = "btn btn-success" 
            End If
            formButton = "<form method='post' action='atualizar_status.asp'>" & _
                         "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                         "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                         "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                         "<input type='hidden' name='status' value='" & desiredStatus & "'>" & _
                         "<button type='submit' class='" & buttonClass & "'>Pronto</button></form>"
        Else
            ' Não há assinatura
            If diffMinutes <= 15 Then
                formButton = "<button class='btn btn-aguardando' disabled>Aguardando DSS...</button>"
            Else
                desiredStatus = "Pronto com atraso"
                buttonClass = "btn btn-danger"
                formButton = "<form method='post' action='atualizar_status.asp'>" & _
                             "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                             "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                             "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                             "<input type='hidden' name='status' value='" & desiredStatus & "'>" & _
                             "<button type='submit' class='" & buttonClass & "'>Pronto</button></form>"
            End If
        End If

        Response.Write "  <td class='fs-4 fw-bold text-center w-10'>" & formButton & "</td>"

        ' --- Lógica do ícone de status ---
        Dim rsStatus, sqlStatus, currentStatus
        
        sqlStatus = "SELECT status_funcionario FROM registros_apresentacao WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(data_hora_apresentacao) = Date()"
        Set rsStatus = conn.Execute(sqlStatus)

        horarioProntidao = ""
        currentStatus = ""
        If Not rsStatus.EOF Then
            currentStatus = rsStatus("status_funcionario")
        End If
        rsStatus.Close

        If currentStatus = "Pronto" Then
            horarioProntidao = "<span class='text-success'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span>"
        ElseIf currentStatus = "Pronto com atraso" Then
            horarioProntidao = "<span class='text-danger'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span>"
        Else
            If diffMinutes <= 15 Then
                icon = "<i class='fas fa-clock text-warning'></i>"
            Else
                icon = "<i class='fas fa-times-circle text-danger'></i>"
            End If
        End If

        Response.Write "  <td class='fs-4 fw-bold text-center w-25'>" & horarioProntidao & "</td>"
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
        sql = sql & "AND DatePart('h', ra.data_hora_apresentacao) BETWEEN 6 AND 17 "
    Else
        sql = sql & "AND (DatePart('h', ra.data_hora_apresentacao) >= 18 OR DatePart('h', ra.data_hora_apresentacao) < 6) "
    End If

    sql = sql & "ORDER BY ra.data_hora_apresentacao DESC;"

    Set rs = conn.Execute(sql)

    Do While Not rs.EOF
        Dim horarioApresentacao, horarioProntidao
        horarioApresentacao = TimeValue(rs("data_hora_apresentacao"))

        Response.Write "<tr>"
        Response.Write "  <td class='fs-4 fw-bold text-center'>" & rs("nome") & "</td>"
        Response.Write "  <td class='fs-4 fw-bold text-center'>" & rs("supervisao_ra") & " - " & rs("local_trabalho_ra") & "</td>"
        Response.Write "<td class='fs-4 fw-bold text-center'>" & horarioApresentacao & "</td>"

        Dim rsStatus, sqlStatus, currentStatus, icon, diffMinutes, mensagem

        sqlStatus = "SELECT status_funcionario FROM registros_apresentacao WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(data_hora_apresentacao) = Date()"
        Set rsStatus = conn.Execute(sqlStatus)

        diffMinutes = DateDiff("n", rs("data_hora_apresentacao"), Now())

        horarioProntidao = ""
        mensagem = ""
        currentStatus = ""
        If Not rsStatus.EOF Then
            currentStatus = rsStatus("status_funcionario")
        End If
        rsStatus.Close

        If currentStatus = "Pronto" Then
            response.Write "<td class='fs-3 fw-bold text-center'><span class='text-success'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span></td>"
            mensagem = "PODE ACIONAR"
        ElseIf currentStatus = "Pronto com atraso" Then
            response.Write "<td class='fs-3 fw-bold text-center'><span class='text-danger'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span></td>"
            mensagem = "PODE ACIONAR"
        Else
            If diffMinutes <= 15 Then
                response.write "<td class='fs-4 fw-bold text-center'><span class='text-warning'>NO PRAZO</span></td>"
            Else
                response.write "<td class='fs-4 fw-bold text-center'><span class='text-danger'>ATRASADO</span></td>"
                mensagem = "PODE ACIONAR"
            End If
        End If

        Response.Write "<td class='fs-4 fw-bold text-center'>" & mensagem & "</td>"
        Response.Write "</tr>"

        rs.MoveNext
    Loop

    conn.Close
End Function
%>
