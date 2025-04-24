<%@ Language="VBScript" %>
<%
Response.Charset = "UTF-8"
Dim conn, rs, sql, matricula, torre, guarita, id_supervisao, id_funcionario, id_supervisao_funcionario, msg, confirmado

Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Driver={MySQL ODBC 9.2 Unicode Driver};Server=localhost;Database=teste_vale;UID=root;PWD=admin;"

matricula = Request.Form("matricula")
torre = Request.Form("torre")
guarita = Request.Form("guarita")
confirmado = Request.Form("confirmado")

sql = "SELECT s.torre, s.local_g, s.id_supervisao, f.id_funcionario FROM funcionario f INNER JOIN supervisao s ON f.id_supervisao = s.id_supervisao WHERE f.matricula = '" & matricula & "'"
Set rs = conn.Execute(sql)

If Not rs.EOF Then
    id_supervisao_funcionario = rs("id_supervisao")
    id_funcionario = rs("id_funcionario")
Else
    Response.Write "<div class='text-danger'>Funcionário não encontrado.</div>"
    Response.End
End If

sql = "SELECT id_supervisao FROM supervisao WHERE torre = '" & torre & "' AND local_g = '" & guarita & "'"
Set rs = conn.Execute(sql)

If Not rs.EOF Then
    id_supervisao = rs("id_supervisao")
Else
    Response.Write "<div class='text-danger'>Guarita não encontrada.</div>"
    Response.End
End If

If id_supervisao_funcionario <> id_supervisao AND confirmado <> "sim" Then
    Response.Write "<div class='text-warning'>Supervisão diferente. Deseja continuar?</div><div id='confirmar-supervisao' data-supervisao='" & torre & "' data-guarita='" & guarita & "'></div>"
    Response.End
End If

sql = "INSERT INTO registro_apresentacao (id_funcionario, data_hora, supervisao, local_g) VALUES (" & id_funcionario & ", NOW(), '" & torre & "', '" & guarita & "')"
conn.Execute(sql)

Response.Write "<div class='text-success'>Apresentação registrada com sucesso.</div>"

conn.Close
Set conn = Nothing
%>
