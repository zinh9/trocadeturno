<%

Function turnoAtual()
    Dim hora
    hora = Hour(Now())
    If hora >= 6 And hora < 18 Then
        turnoAtual = "manha"
    Else
        turnoAtual = "noite"
    End If
End Function
    
Function dentroDoTempo(registro)
    If DateDiff("n", registro, now()) <= 15 Then
        dentroDoTempo = "Concluído no prazo"
    Else
        dentroDoTempo = "Atrasado"
    End If
End Function

Function formatDataHoraUSA(data, hora)
    formatDataHoraUSA = "#" & Month(data) & "/" & Day(data) & "/" & Year(data) & " " & hora & "#"
End Function

%>
