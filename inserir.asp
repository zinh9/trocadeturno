<%@ Language="VBScript" %>
<!--#include file="conexao.asp" -->
<!--#include file="utils.asp" -->
<%
' Se o formulário foi enviado via POST, processa a inserção
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim matricula, torre, guarita, confirmado, sql, rs, turno, horaAtual, dataHoje, dataAmanha, condicaoHora, supervisao, usuario_dss
    
    ' Obtém os valores do formulário
    matricula = Request.Form("matricula")
    torre = Request.Form("torre")
    guarita = Request.Form("guarita")
    
    ' Verifica se o confirmado para registro em outra supervisão foi enviado (se confirmado = 1, então não pede confirmação)
    If Request.Form("confirmado") = "" Then
        confirmado = "0"
    Else
        confirmado = Request.Form("confirmado")
    End If

    Set conn = getConexao()

    'Verifica se o funcionário está cadastrado em login_dss
    sql = "SELECT usuario_dss, supervisao FROM login_dss WHERE usuario_dss = '" & matricula & "'"
    Set rs = conn.execute(sql)

    If Not rs.EOF Then
        usuario_dss = rs("usuario_dss")
        supervisao = rs("supervisao")
        turno = turnoAtual()

        horaAtual = Hour(Now())
        dataHoje = Date()
        dataAmanha = DateAdd("d", 1, dataHoje)

        If turno = "manha" Then
            condicaoHora = "(data_hora_ra >= " & formatDataHoraUSA(dataHoje, "06:00:00") & " AND data_hora_ra <= " & formatDataHoraUSA(dataHoje, "17:59:59") & ")"
        Else
            condicaoHora = "((data_hora_ra >= " & formatDataHoraUSA(dataHoje, "18:00:00") & ") AND (data_hora_ra <= " & formatDataHoraUSA(dataAmanha, "05:59:59") & "))"
        End If

        ' Verifica se já houve registro neste turno para o funcionário
        sql = "SELECT COUNT(*) AS total FROM registros_apresentacao WHERE usuario_dss = '" & usuario_dss & "' AND " & condicaoHora
        Set rs = conn.execute(sql)

        If rs("total") = "0" Then
            if (torre <> supervisao) And (confirmado <> "1") then
                response.write("confirmar|" & supervisao)
            else    
                sql = "INSERT INTO registros_apresentacao (usuario_dss, data_hora_ra, supervisao_ra, local_trabalho_ra) " & _
                    "VALUES ('" & usuario_dss & "', Now(), '" & torre & "', '" & guarita & "')"
                conn.execute(sql)
                Response.Write "ok"
            end if
            ' Após a inserção, redireciona para a mesma página com os filtros na query string para evitar reenvio
            'Response.Redirect "index.asp?torre=" & Server.URLEncode(torre) & "&guarita=" & Server.URLEncode(guarita)
            Response.End
        Else
            Response.Write "Funcionário já cadastrado no turno atual."
            Response.End
        End If
    Else
        Response.Write "Funcionário não encontrado."
        Response.End
    End If
    conn.close
End If
%>
