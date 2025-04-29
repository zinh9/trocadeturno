<%
Function getConexao()

    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "DRIVER={Microsoft Access Driver (*.mdb)};DBQ=C:\inetpub\wwwroot\trocadeturno\dssbd.mdb;"
    Set getConexao = conn

End Function
%>
