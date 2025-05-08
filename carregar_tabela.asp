<!--#include file="conexao.asp" -->
<!--#include file="utils.asp" -->
<%
Response.Charset = "UTF-8"

Function carregarTabela(torreFiltro, guaritaFiltro)
    Dim conn, rs, sql, turno
    On Error Resume Next

    ' 1) Tenta conectar
    Set conn = getConexao()
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red'>[Erro CONEXÃO] " & Err.Number & " - " & Err.Description & "</div><br>"
        Err.Clear
        Exit Function
    Else
        Response.Write "<div style='color:green'>[DEBUG] Conexão aberta com sucesso</div><br>"
    End If

    turno = turnoAtual()
    Response.Write "<div>[DEBUG] turnoAtual = " & turno & "</div><br>"

    ' 2) Monta a SQL
    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_apresentacao, " & _
          "ra.supervisao_ra, ra.local_trabalho_ra, ra.data_hora_prontidao_ra " & _
          "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " & _
          "WHERE DateValue(ra.data_hora_apresentacao) = Date() "

    If torreFiltro <> "" Then
        sql = sql & "AND ra.supervisao_ra = '" & Replace(torreFiltro,"'","''") & "' "
    End If
    If guaritaFiltro <> "" Then
        sql = sql & "AND ra.local_trabalho_ra = '" & Replace(guaritaFiltro,"'","''") & "' "
    End If

    If turno = "manha" Then
        sql = sql & "AND DatePart('h', ra.data_hora_apresentacao) BETWEEN 5 AND 17 "
    Else
        sql = sql & "AND (DatePart('h', ra.data_hora_apresentacao) >= 17 OR DatePart('h', ra.data_hora_apresentacao) < 5) "
    End If

    sql = sql & "ORDER BY ra.data_hora_apresentacao DESC;"
    Response.Write "<pre style='background:#f0f0f0;padding:5px'>[DEBUG] SQL carregarTabela: " & sql & "</pre><br>"

    ' 3) Executa a SQL
    Set rs = conn.Execute(sql)
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red'>[Erro EXECUTE] " & Err.Number & " - " & Err.Description & "</div><br>"
        Err.Clear
        conn.Close
        Exit Function
    End If

    ' 4) Verifica se retornou algo
    If rs.EOF Then
        Response.Write "<div style='color:orange'>[DEBUG] Nenhum registro encontrado para estes filtros.</div><br>"
    End If

    ' 5) Loop de leitura
    Do While Not rs.EOF
        Dim horarioApresentacao, diffMinutes
        horarioApresentacao = TimeValue(rs("data_hora_apresentacao"))
        diffMinutes = DateDiff("n", rs("data_hora_apresentacao"), Now())

        Response.Write "<div>[DEBUG] Lendo matricula=" & rs("matricula") & " diffMinutes=" & diffMinutes & "</div>"

        Response.Write "<tr>"
        Response.Write "  <td class='fs-4 fw-bold text-center w-25'>" & Server.HTMLEncode(rs("nome")) & "</td>"
        Response.Write "  <td class='fs-4 fw-bold text-center w-25'>" & Server.HTMLEncode(rs("supervisao_ra")) & " - " & Server.HTMLEncode(rs("local_trabalho_ra")) & "</td>"
        Response.Write "  <td class='fs-4 fw-bold text-center w-25'>" & horarioApresentacao & "</td>"

        ' 6) Verifica assinatura DSS
        Dim rsAss, sqlAss, assinatura
        sqlAss = "SELECT COUNT(*) AS total FROM ASSINATURA_DSS WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(DATA_INSERT) = Date()"
        Response.Write "<div>[DEBUG] SQL assinatura: " & sqlAss & "</div>"
        Set rsAss = conn.Execute(sqlAss)
        assinatura = 0
        If Not rsAss.EOF Then assinatura = rsAss("total")
        rsAss.Close
        Response.Write "<div>[DEBUG] assinatura count = " & assinatura & "</div>"

        Dim desiredStatus, buttonClass, formButton
        If assinatura > 0 Then
            If diffMinutes <= 15 Then
                desiredStatus = "Pronto": buttonClass = "btn btn-success"
            Else
                desiredStatus = "Pronto com atraso": buttonClass = "btn btn-success"
            End If
            formButton = "<form method='post' action='atualizar_status.asp'>" & _
                         "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                         "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                         "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                         "<input type='hidden' name='status' value='" & desiredStatus & "'>" & _
                         "<button type='submit' class='" & buttonClass & "'>Pronto</button></form>"
        Else
            If diffMinutes <= 15 Then
                formButton = "<button class='btn btn-aguardando' disabled>Aguardando DSS...</button>"
            Else
                desiredStatus = "Pronto com atraso": buttonClass = "btn btn-danger"
                formButton = "<form method='post' action='atualizar_status.asp'>" & _
                             "<input type='hidden' name='matricula' value='" & rs("matricula") & "'>" & _
                             "<input type='hidden' name='supervisao_ra' value='" & rs("supervisao_ra") & "'>" & _
                             "<input type='hidden' name='local_trabalho_ra' value='" & rs("local_trabalho_ra") & "'>" & _
                             "<input type='hidden' name='status' value='" & desiredStatus & "'>" & _
                             "<button type='submit' class='" & buttonClass & "'>Pronto</button></form>"
            End If
        End If

        Response.Write "  <td class='fs-4 fw-bold text-center w-10'>" & formButton & "</td>"

        ' 7) Busca status_funcionario
        Dim rsStatus, sqlStatus, currentStatus, horarioProntidao, icon
        sqlStatus = "SELECT TOP 1 status_funcionario FROM registros_apresentacao " & _
                    "WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(data_hora_apresentacao)=Date() " & _
                    "ORDER BY data_hora_apresentacao DESC"
        Response.Write "<div>[DEBUG] SQL status: " & sqlStatus & "</div>"
        Set rsStatus = conn.Execute(sqlStatus)
        currentStatus = ""
        If Not rsStatus.EOF Then
            If Not IsNull(rsStatus("status_funcionario")) Then
                currentStatus = rsStatus("status_funcionario")
            End If
        End If
        rsStatus.Close
        Response.Write "<div>[DEBUG] currentStatus = " & currentStatus & "</div>"

        horarioProntidao = ""
        If currentStatus = "Pronto" Then
            If Not IsNull(rs("data_hora_prontidao_ra")) Then
                horarioProntidao = "<span class='text-success'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span>"
            Else
                horarioProntidao = "<span class='text-success'>--</span>"
            End If
        ElseIf currentStatus = "Pronto com atraso" Then
            If Not IsNull(rs("data_hora_prontidao_ra")) Then
                horarioProntidao = "<span class='text-danger'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span>"
            Else
                horarioProntidao = "<span class='text-danger'>--</span>"
            End If
        Else
            If diffMinutes <= 15 Then
                icon = "<i class='fas fa-clock text-warning'></i>"
            Else
                icon = "<i class='fas fa-times-circle text-danger'></i>"
            End If
            horarioProntidao = icon
        End If

        Response.Write "  <td class='fs-4 fw-bold text-center w-25'>" & horarioProntidao & "</td>"
        Response.Write "</tr>"

        rs.MoveNext
    Loop

    rs.Close
    conn.Close
End Function


'— Agora faça igual na carregarTabelaCCP, inserindo logs em cada etapa —
Function carregarTabelaCCP(torreFiltro)
    Dim conn, rs, sql, turno
    On Error Resume Next

    Set conn = getConexao()
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red'>[CCP Erro CONEXÃO] " & Err.Description & "</div><br>"
        Err.Clear: Exit Function
    End If

    turno = turnoAtual()
    Response.Write "[CCP DEBUG] turnoAtual = " & turno & "<br>"

    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_apresentacao, " & _
          "ra.supervisao_ra, ra.local_trabalho_ra, ra.data_hora_prontidao_ra, ra.status_funcionario " & _
          "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " & _
          "WHERE DateValue(ra.data_hora_apresentacao)=Date() "

    If torreFiltro <> "" Then sql = sql & "AND ra.supervisao_ra='" & Replace(torreFiltro,"'","''") & "' "
    If turno="manha" Then
        sql=sql & "AND DatePart('h',ra.data_hora_apresentacao) BETWEEN 5 AND 17 "
    Else
        sql=sql & "AND (DatePart('h',ra.data_hora_apresentacao)>=18 OR DatePart('h',ra.data_hora_apresentacao)<5) "
    End If
    sql=sql & "ORDER BY ra.data_hora_apresentacao DESC;"
    Response.Write "<pre>[CCP DEBUG] SQL: " & sql & "</pre><br>"

    Set rs=conn.Execute(sql)
    If Err.Number<>0 Then
        Response.Write "<div style='color:red'>[CCP Erro EXECUTE] " & Err.Description & "</div><br>"
        Err.Clear: conn.Close: Exit Function
    End If

    If rs.EOF Then
        Response.Write "<div style='color:orange'>[CCP DEBUG] nenhum registro</div><br>"
    End If

    Do While Not rs.EOF
        Dim horario, diffMin, st
        horario=TimeValue(rs("data_hora_apresentacao"))
        diffMin=DateDiff("n",rs("data_hora_apresentacao"),Now())
        st = rs("status_funcionario")

        Response.Write "<div>[CCP DEBUG] matricula=" & rs("matricula") & " status=" & st & " diffMin=" & diffMin & "</div>"

        Response.Write "<tr><td>" & rs("nome") & "</td><td>" & rs("supervisao_ra") & " - " & rs("local_trabalho_ra") & "</td><td>" & horario & "</td>"

        Select Case st
            Case "Pronto"
                Response.Write "<td><span class='text-success'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span></td><td>PODE ACIONAR</td>"
            Case "Pronto com atraso"
                Response.Write "<td><span class='text-danger'>" & TimeValue(rs("data_hora_prontidao_ra")) & "</span></td><td>PODE ACIONAR</td>"
            Case Else
                If diffMin<=15 Then
                    Response.Write "<td><i class='fas fa-clock text-warning'></i></td><td>NO PRAZO</td>"
                Else
                    Response.Write "<td><i class='fas fa-times-circle text-danger'></i></td><td>ATRASADO</td>"
                End If
        End Select

        Response.Write "</tr>"
        rs.MoveNext
    Loop

    rs.Close
    conn.Close
End Function
%>
