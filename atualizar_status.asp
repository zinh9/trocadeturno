<%@ Language = "VBScript" %>
<!--#include file='conexao.asp' -->
<%
Dim matricula, status_ra, sql, conn
matricula = Request.Form("matricula")
status_ra = Request.Form("status")
supervisao = Request.Form("supervisao_ra")
local_trabalho_ra = Request.Form("local_trabalho_ra")
Set conn = getConexao()

If status_ra = "Pronto" Then
    sql = "UPDATE registros_apresentacao " & _
          "SET status_tempo_ra = 'Pronto', data_hora_prontidao_ra = Date() " & _
          "WHERE usuario_dss = '" & matricula & "' " & _
          "AND DateValue(data_hora_ra) = Date()"
Else
    sql = "UPDATE registros_apresentacao " & _
          "SET status_tempo_ra = 'Pronto com atraso', data_hora_prontidao_ra = Date() " & _
          "WHERE usuario_dss = '" & matricula & "' " & _
          "AND DateValue(data_hora_ra) = Date()"
End If

conn.Execute(sql)
conn.Close

Response.Redirect "index.asp?torre=" & Server.URLEncode(supervisao) & "&guarita=" & Server.URLEncode(local_trabalho_ra)
%>
