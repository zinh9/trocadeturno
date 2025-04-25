<!--#include file='conexao.asp' -->
<!--#include file='utils.asp' -->
<%

Dim conn, turno, sql, rs

Set conn = getConexao()
turno = turnoAtual()

if turno = "manha" Then
    sql = "SELECT f.nome, f.matricula, ra.data_hora " &_
    "FROM registro_apresentacao ra " &_
    "INNER JOIN funcionario f ON ra.id_funcionario = f.id_funcionario " &_
    "WHERE HOUR(ra.data_hora) BETWEEN 6 AND 17 AND DATE(ra.data_hora) = CURDATE()"
Else
    sql = "SELECT f.nome, f.matricula, ra.data_hora " &_
    "FROM registro_apresentacao ra " &_
    "INNER JOIN funcionario f ON ra.id_funcionario = f.id_funcionario " &_
    "WHERE (HOUR(ra.data_hora) >= 18 OR HOUR(ra.data_hora) < 6) AND DATE(ra.data_hora) = CURDATE()"

end if

Set rs = conn.execute(sql)

do while not rs.EOF
    Response.Write "<tr>"
    Response.Write "<td>" & rs("nome") & "</td>"
    Response.Write "<td>" & rs("matricula") & "</td>"
    Response.Write "<td>" & rs("data_hora") & "</td>"
    Response.Write "</tr>"
    rs.MoveNext
Loop

conn.close
set conn = Nothing

%>