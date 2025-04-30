<!--#include file='conexao.asp' -->
<!--#include file='utils.asp' -->
<%

Function carregarTabela(torreFiltro, guaritaFiltro)

    Dim rs, sqlT

    ' Se não vier do formulário, tenta pela QueryString (desktop fixo)
    If torreFiltro = "" And qsTorre <> "" Then torreFiltro = qsTorre
    If guaritaFiltro = "" And qsGuarita <> "" Then guaritaFiltro = qsGuarita

    Set conn = getConexao()

    Dim turno
    turno = turnoAtual()
                
    If torreFiltro <> "" And guaritaFiltro <> "" Then
    If turno = "manha" Then
        sqlT = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra, ra.supervisao_ra, ra.local_trabalho_ra " &_ 
                "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " &_ 
                "WHERE ra.local_trabalho_ra = '" & guaritaFiltro & "' AND ra.supervisao_ra = '" & torreFiltro & "' " &_ 
                "AND (DatePart('h',ra.data_hora_ra) Between 6 And 17) AND DateValue(ra.data_hora_ra) = Date() " &_ 
                "ORDER BY ra.data_hora_ra DESC;"
    Else
        sqlT = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra, ra.supervisao_ra, ra.local_trabalho_ra  " &_ 
                "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " &_ 
                "WHERE ra.supervisao_ra = '" & torreFiltro & "' " &_ 
                "AND ((DatePart('h',ra.data_hora_ra) >= 18 OR DatePart('h',ra.data_hora_ra) < 6)) AND DateValue(ra.data_hora_ra) = Date() " &_ 
                "ORDER BY ra.data_hora_ra DESC;"
    End If
    Else
    ' Sem filtro: traz todos os registros do turno atual
    If turno = "manha" Then
        sqlT = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra, ra.supervisao_ra, ra.local_trabalho_ra  " &_ 
                "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " &_ 
                "WHERE (DatePart('h',ra.data_hora_ra) Between 6 And 17) AND DateValue(ra.data_hora_ra) = Date() " &_ 
                "ORDER BY ra.data_hora_ra DESC;"
    Else
        sqlT = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra, ra.supervisao_ra, ra.local_trabalho_ra  " &_ 
                "FROM registros_apresentacao ra INNER JOIN login_dss ld ON ra.usuario_dss = ld.usuario_dss " &_ 
                "WHERE (DatePart('h',ra.data_hora_ra) >= 18 OR DatePart('h',ra.data_hora_ra) < 6) AND DateValue(ra.data_hora_ra) = Date() " &_ 
                "ORDER BY ra.data_hora_ra DESC;"
    End If
    End If
                
    Set rs = conn.execute(sqlT)
                
    Do While Not rs.EOF
    Dim diffMinutes, horario
    horario = TimeValue(rs("data_hora_ra"))

    Response.Write "<tr>"
        Response.Write "<td class='fs-3 fw-bold text-center w-25'>" & rs("nome") & "</td>"
        Response.Write "<td class='fs-3 fw-bold text-center w-25'>" & rs("matricula") & "</td>"
        response.write "<td class='fs-3 fw-bold text-center w-25'>" & rs("supervisao_ra") & " - " & rs("local_trabalho_ra") & "</td>"
        Response.Write "<td class='fs-3 fw-bold text-center w-25'>" & horario & "</td>"
                    
        diffMinutes = DateDiff("n", rs("data_hora_ra"), Now())
        
        ' Verifica na tabela ASSINATURA_DSS se há registro para esse usuário (na data atual)
        Dim sqlAss, rsAss, assinaturaExiste
        sqlAss = "SELECT COUNT(*) AS total FROM ASSINATURA_DSS WHERE usuario_dss = '" & rs("matricula") & "' AND DateValue(DATA_INSERT)=Date()"

        Set rsAss = conn.execute(sqlAss)

        If Not rsAss.EOF Then
            assinaturaExiste = rsAss("total")
        Else
            assinaturaExiste = 0
        End If

        rsAss.close

        Set rsAss = Nothing
                    
        If assinaturaExiste > 0 Then
            ' Se o funcionário já assinou, mostra ícone verde
            Response.Write "<td class='fs-3 fw-bold text-center w-25'><i class='fas fa-check-circle' style='color:green;'></i></td>"
        Else
            ' Se não assinou, segue com a lógica de tempo decorrido:
            If diffMinutes <= 15 Then
                ' Dentro do prazo: ícone laranja
                Response.Write "<td class='fs-3 fw-bold text-center w-25'><i class='fas fa-check-circle' style='color:orange;'></i></td>"
            Else
                ' Ultrapassou 15 minutos: ícone vermelho
                Response.Write "<td class='fs-3 fw-bold text-center w-25'><i class='fas fa-check-circle' style='color:red;'></i></td>"
            End If
        End If
                    
    Response.Write "</tr>"
    rs.MoveNext
    Loop

    conn.close

End Function

%>
