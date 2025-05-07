<!--#include file="conexao.asp" -->
<!--#include file="utils.asp" -->
<%

Function carregarTabela(torreFiltro, guaritaFiltro)
    Dim conn, rs, sql, turno
    Set conn = getConexao()
    turno = turnoAtual()

    ' Monta a query base
    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra, ra.supervisao_ra, ra.local_trabalho_ra " & _
          "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " & _
          "WHERE DateValue(ra.data_hora_ra) = Date() "

    If torreFiltro <> "" Then
        sql = sql & "AND ra.supervisao_ra = '" & torreFiltro & "' "
    End If
    If guaritaFiltro <> "" Then
        sql = sql & "AND ra.local_trabalho_ra = '" & guaritaFiltro & "' "
    End If

    If turno = "manha" Then
        sql = sql & "AND DatePart('h', ra.data_hora_ra) BETWEEN 6 AND 17 "
    Else
        sql = sql & "AND (DatePart('h', ra.data_hora_ra) >= 18 OR DatePart('h', ra.data_hora_ra) < 6) "
    End If

    sql = sql & "ORDER BY ra.data_hora_ra DESC;"
    
    Set rs = conn.Execute(sql)

    Do While Not rs.EOF
        Dim horario, diffMinutes
        horario = TimeValue(rs("data_hora_ra"))
        diffMinutes = DateDiff("n", rs("data_hora_ra"), Now())

        Response.Write "<tr>"
        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & rs("nome") & "</td>"
        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & rs("matricula") & "</td>"
        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & rs("supervisao_ra") & " - " & rs("local_trabalho_ra") & "</td>"
        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & horario & "</td>"

        ' --- Lógica do botão de prontidão ---
        Dim desiredStatus, buttonClass, formButton
        Dim rsAss, sqlAss, assinatura
        sqlAss = "SELECT COUNT(*) AS total FROM ASSINATURAS_DSS WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(DATA_INSERT) = Date()"
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
                buttonClass = "btn btn-success"  ' Verde
            Else
                desiredStatus = "Pronto com atraso"
                buttonClass = "btn btn-warning"  ' Laranja
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
                formButton = "<button class='btn btn-aguardando' disabled>Aguardando...</button>"
            Else
                desiredStatus = "Pronto com atraso"
                buttonClass = "btn btn-warning"
                formButton = "<form method='post' action='atualizar_status.asp'>" & _
                             "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                             "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                             "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                             "<input type='hidden' name='status' value='" & desiredStatus & "'>" & _
                             "<button type='submit' class='" & buttonClass & "'>Pronto</button></form>"
            End If
        End If

        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & formButton & "</td>"

        ' --- Lógica do ícone de status ---
        Dim rsStatus, sqlStatus, currentStatus, icon
        sqlStatus = "SELECT status_tempo_ra FROM registros_apresentacao WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(data_hora_ra) = Date()"
        Set rsStatus = conn.Execute(sqlStatus)
        currentStatus = ""
        If Not rsStatus.EOF Then
            currentStatus = rsStatus("status_tempo_ra")
        End If
        rsStatus.Close

        If currentStatus = "Pronto" Then
            icon = "<i class='fas fa-check-circle text-success'></i>"
        ElseIf currentStatus = "Pronto com atraso" Then
            icon = "<i class='fas fa-check-circle text-warning'></i>"
        Else
            If diffMinutes <= 15 Then
                icon = "<i class='fas fa-clock text-warning'></i>"
            Else
                icon = "<i class='fas fa-times-circle text-danger'></i>"
            End If
        End If

        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & icon & "</td>"
        Response.Write "</tr>"

        rs.MoveNext
    Loop

    conn.Close
End Function


Function carregarTabelaCCP(torreFiltro)
    Dim conn, rs, sql, turno
    Set conn = getConexao()
    turno = turnoAtual()

    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra, ra.supervisao_ra, ra.local_trabalho_ra, ra.status_tempo_ra " & _
          "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " & _
          "WHERE DateValue(ra.data_hora_ra) = Date() "

    If torreFiltro <> "" Then
        sql = sql & "AND ra.supervisao_ra = '" & torreFiltro & "' "
    End If

    If turno = "manha" Then
        sql = sql & "AND DatePart('h', ra.data_hora_ra) BETWEEN 6 AND 17 "
    Else
        sql = sql & "AND (DatePart('h', ra.data_hora_ra) >= 18 OR DatePart('h', ra.data_hora_ra) < 6) "
    End If

    sql = sql & "ORDER BY ra.data_hora_ra DESC;"

    Set rs = conn.Execute(sql)

    Do While Not rs.EOF
        Dim horario
        horario = TimeValue(rs("data_hora_ra"))

        Response.Write "<tr>"
        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & rs("nome") & "</td>"
        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & rs("matricula") & "</td>"
        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & rs("supervisao_ra") & " - " & rs("local_trabalho_ra") & "</td>"
        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & horario & "</td>"

        Dim iconInfo
        Select Case rs("status_tempo_ra")
            Case "Pronto"
                iconInfo = "<i class='fas fa-check-circle text-success'></i>"
            Case "Pronto com atraso"
                iconInfo = "<i class='fas fa-check-circle text-warning'></i>"
            Case "Atrasado"
                iconInfo = "<i class='fas fa-times-circle text-danger'></i>"
            Case Else
                iconInfo = "<i class='fas fa-clock text-warning'></i>"
        End Select

        Response.Write "  <td class='fs-3 fw-bold text-center w-25'>" & iconInfo & "</td>"
        Response.Write "</tr>"

        rs.MoveNext
    Loop

    conn.Close
End Function
%>

