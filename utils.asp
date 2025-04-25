<%

Function turnoAtual()

    Dim hora
    hora = Hour(Now())
    If hora >= 6 And hora < 18 Then
        turno_atual = "manha"
    Else
        turno_atual = "noite"
    End If

end Function
    
Function dentroDoTempo(registro)

    If DateDiff("n", registro, now()) <= 15 Then
        dentro_do_tempo = "Concluído no prazo"
    Else
        dentro_do_tempo = "Atrasado"
    End If

End Function

%>