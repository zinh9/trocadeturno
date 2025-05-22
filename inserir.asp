<%@ Language="VBScript" %>
<!--#include file="conexao.asp" -->
<!--#include file="utils.asp" -->
<%
' Se o formulário foi enviado via POST, processa a inserção
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim matricula, torre, guarita, confirmado, sql, rs, turno, horaAtual, dataHoje, dataAmanha, condicaoHora, supervisao, usuario_dss, turno_funcionario
    
    ' Obtém os valores do formulário
    matricula = Request.Form("matricula")
    torre = Request.Form("torre")
    guarita = Request.Form("guarita")

    if torre = "TORRE_L" then torre = "Torre_L" End If
    
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
            condicaoHora = "(data_hora_apresentacao >= " & formatDataHoraUSA(dataHoje, "05:00:00") & " AND data_hora_apresentacao <= " & formatDataHoraUSA(dataHoje, "16:59:59") & ")"
            
            if hour(now()) = 5 then
                turno_funcionario = "05x17"
            else
                turno_funcionario = "06x18"
            end if
        Else
            condicaoHora = "((data_hora_apresentacao >= " & formatDataHoraUSA(dataHoje, "17:00:00") & ") AND (data_hora_apresentacao <= " & formatDataHoraUSA(dataAmanha, "04:59:59") & "))"
            
            if hour(now()) = 17 then
                turno_funcionario = "17x05"
            else
                turno_funcionario = "18x06"
            end if
        End If

        ' Verifica se já houve registro neste turno para o funcionário
        sql = "SELECT COUNT(*) AS total FROM registros_apresentacao WHERE usuario_dss = '" & usuario_dss & "' AND " & condicaoHora
        Set rs = conn.execute(sql)

        If rs("total") = "0" Then
            if (torre <> supervisao) And (confirmado <> "1") then
                response.write("confirmar|" & supervisao)
            else    
                sql = "INSERT INTO registros_apresentacao (usuario_dss, data_hora_apresentacao, supervisao_ra, local_trabalho_ra, turno_funcionario, supervisao_original_ra) " & _
                    "VALUES ('" & usuario_dss & "', Now(), '" & torre & "', '" & guarita & "', '" & turno_funcionario & "', '" & supervisao & "')"
                conn.execute(sql)
                Response.Write "ok"
            end if
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
