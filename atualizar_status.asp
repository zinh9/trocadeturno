<%@ Language = "VBScript" %>
<!--#include file='conexao.asp' -->
<%

Dim matricula, status_ra, sql, rs, conn
matricula = Request.form("matricula")
status_ra = Request.form("status")
supervisao = Request.form("supervisao_ra")
local_trabalho_ra = Request.form("local_trabalho_ra")
Set conn = getConexao()

if status_ra = "Pronto" Then
    sql = "UPDATE registros_apresentacao "&_
    "SET status_tempo_ra = 'Pronto' "&_
    "WHERE usuario_dss = '" & matricula & "' "&_
    "AND DateValue(data_hora_ra) = Date()"
    conn.execute(sql)
else
    sql = "UPDATE registros_apresentacao "&_
    "SET status_tempo_ra = 'Atrasado' "&_
    "WHERE usuario_dss = '" & matricula & "' "&_
    "AND DateValue(data_hora_ra) = Date()"
    conn.execute(sql)
end if

conn.close

Response.Redirect "index.asp?torre=" & supervisao & "&guarita=" & local_trabalho_ra


%>