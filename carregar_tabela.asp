<!--#include file='conexao.asp' -->
<!--#include file='utils.asp' -->
<%

Dim conn, turno, sql, rs

Set conn = getConexao()
turno = turnoAtual()

if turno = "manha" Then
    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra " &_
    "FROM registros_apresentacao AS ra " &_
    "INNER JOIN login_dss AS ld ON ra.usuario_dss = ld.usuario_dss " &_
    "GROUP BY ld.detalhe, ld.usuario_dss, ra.data_hora_ra, DatePart('h',[ra].[data_hora_ra]), DateValue([ra].[data_hora_ra]) " &_
    "HAVING (((DatePart('h',[ra].[data_hora_ra])) Between 6 And 17) AND ((DateValue([ra].[data_hora_ra]))=Date())) "&_
    "ORDER BY ra.data_hora_ra DESC"
Else
    sql = "SELECT ld.detalhe, ld.usuario_dss, ra.data_hora_ra " & _
    "FROM registros_apresentacao AS ra " & _
    "INNER JOIN login_dss AS ld ON ra.usuario_dss = ld.usuario_dss " & _
    "WHERE (DatePart('h', ra.data_hora_ra) >= 18 OR DatePart('h', ra.data_hora_ra) < 6) AND DateValue(ra.data_hora_ra) = Date() " & _
    "ORDER BY ra.data_hora_ra DESC;"

end if

Set rs = conn.execute(sql)

do while not rs.EOF
    Response.Write "<tr>"
        Response.Write "<td class='fs-3 fw-bold'>" & rs("nome") & "</td>"
        Response.Write "<td class='fs-3 fw-bold'>" & rs("matricula") & "</td>"
        Response.Write "<td class='fs-3 fw-bold'>" & rs("data_hora_ra") & "</td>"
    Response.Write "</tr>"
    rs.MoveNext
Loop

conn.close
set conn = Nothing

%>
