<%
' Criar conexão com MySQL
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Driver={MySQL ODBC 9.2 Unicode Driver};Server=localhost;Database=teste_vale;UID=root;PWD=admin;"

' Executar SELECT
Set rs = conn.Execute("SELECT * FROM funcionario")

' Mostrar os nomes
Do Until rs.EOF
    Response.Write rs("nome") & "<br>"
    rs.MoveNext
Loop

' Fechar tudo certinho
rs.Close
Set rs = Nothing
conn.Close
Set conn = Nothing
%>
