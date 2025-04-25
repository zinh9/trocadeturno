<%
Function getConexao()
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "Driver={MySQL ODBC 9.2 Unicode Driver};Server=localhost;Database=teste_vale;UID=root;PWD=admin;"
    Set getConexao = conn
End Function
%>
