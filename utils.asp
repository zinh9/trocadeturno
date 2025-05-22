<!--#include file='conexao.asp' -->
<%

Function turnoAtual()

    Dim hora, minutos
    hora = Hour(Now())
    minutos = Minute(Now())
    
    If hora >= 5 And hora < 17 Then
        turnoAtual = "manha"
    Else
        turnoAtual = "noite"
    End If

end Function

Function formatDataHoraUSA(data, hora)

    formatDataHoraUSA = "#" & Month(data) & "/" & Day(data) & "/" & Year(data) & " " & hora & "#"

End Function

Function ultimaAtualizacao(torreFiltro)

    Dim conn, data_ultima_atualizacao, sql
    Set conn = getConexao()

    If torreFiltro <> "" Then
        sql = "SELECT TOP 1 data_hora_apresentacao " & _
              "FROM registros_apresentacao " & _
              "WHERE supervisao_ra = '" & torreFiltro & "' AND (" & _
              "(DATEPART('h', data_hora_apresentacao) >= 5 AND DATEPART('h', data_hora_apresentacao) < 17) " & _
              "OR " & _
              "(DATEPART('h', data_hora_apresentacao) >= 17 OR DATEPART('h', data_hora_apresentacao) < 5)" & _
              ") " & _
              "ORDER BY data_hora_apresentacao DESC"
    Else
        sql = "SELECT TOP 1 data_hora_apresentacao " & _
              "FROM registros_apresentacao " & _
              "ORDER BY data_hora_apresentacao DESC"
    End If

    Set data_ultima_atualizacao = conn.Execute(sql)

    If Not data_ultima_atualizacao.EOF Then
        Response.Write FormatDateTime(data_ultima_atualizacao("data_hora_apresentacao"), vbShortDate) & " " & FormatDateTime(data_ultima_atualizacao("data_hora_apresentacao"), vbLongTime)
    Else
        Response.Write "--/--/-- --:--:--"
    End If

End Function

%>
