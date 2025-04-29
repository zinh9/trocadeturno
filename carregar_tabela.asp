<!--#include file='conexao.asp' -->
<!--#include file='utils.asp' -->
<%

Response.Charset = "UTF-8"
Response.ContentType = "text/html"

Dim conn, turno, sql, rs, torre, guarita

Set conn = getConexao()
turno = turnoAtual()

torre = Request.form("torre")
guarita = Request.form("guarita")

response.write torre & " - " & guarita

if turno = "manha" and torre <> "" and guarita <> "" Then
    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra " &_
    "FROM registros_apresentacao AS ra " &_
    "INNER JOIN login_dss AS ld ON ra.usuario_dss = ld.usuario_dss " &_
    "WHERE ra.local_trabalho_ra = '" & guarita & "' AND ra.supervisao_ra = '" & torre & "' " &_
    "GROUP BY ld.detalhe, ld.usuario_dss, ra.data_hora_ra, DatePart('h',[ra].[data_hora_ra]), DateValue([ra].[data_hora_ra]) " &_
    "HAVING (((DatePart('h',[ra].[data_hora_ra])) Between 6 And 17) AND ((DateValue([ra].[data_hora_ra]))=Date())) " &_
    "ORDER BY ra.data_hora_ra DESC;"
ElseIf turno = "noite" and torre <> "" then
    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra " &_
    "FROM registros_apresentacao AS ra " &_
    "INNER JOIN login_dss AS ld ON ra.usuario_dss = ld.usuario_dss " &_
    "WHERE ra.supervisao_ra = '" & torre & "' " &_
    "WHERE (DatePart('h', ra.data_hora_ra) >= 18 OR DatePart('h', ra.data_hora_ra) < 6) AND DateValue(ra.data_hora_ra) = Date() " &_
    "ORDER BY ra.data_hora_ra DESC;"
ElseIf turno = "manha" then 
    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra " &_
    "FROM registros_apresentacao AS ra " &_
    "INNER JOIN login_dss AS ld ON ra.usuario_dss = ld.usuario_dss " &_
    "GROUP BY ld.detalhe, ld.usuario_dss, ra.data_hora_ra, DatePart('h',[ra].[data_hora_ra]), DateValue([ra].[data_hora_ra]) " &_
    "HAVING (((DatePart('h',[ra].[data_hora_ra])) Between 6 And 17) AND ((DateValue([ra].[data_hora_ra]))=Date())) " &_
    "ORDER BY ra.data_hora_ra DESC;"
else 
    sql = "SELECT ld.detalhe AS nome, ld.usuario_dss AS matricula, ra.data_hora_ra " &_
    "FROM registros_apresentacao AS ra " &_
    "INNER JOIN login_dss AS ld ON ra.usuario_dss = ld.usuario_dss " &_
    "WHERE (DatePart('h', ra.data_hora_ra) >= 18 OR DatePart('h', ra.data_hora_ra) < 6) AND DateValue(ra.data_hora_ra) = Date() " &_
    "ORDER BY ra.data_hora_ra DESC;"
end if

Set rs = conn.execute(sql)

do while not rs.EOF
    Response.Write "<tr>"
        Response.Write "<td class='fs-3 fw-bold'>" & rs("nome") & "</td>"
        Response.Write "<td class='fs-3 fw-bold'>" & rs("matricula") & "</td>"
        Response.Write "<td class='fs-3 fw-bold'>" & rs("data_hora_ra") & "</td>"
        Response.Write "<td class='fs-3 fw-bold'>DSS</td>"
    Response.Write "</tr>"
    rs.MoveNext
loop

conn.close
set conn = Nothing

%>
