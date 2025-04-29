<!--#include file='conexao.asp' -->
<!--#include file='utils.asp' -->
<%

Dim matricula, torre, guarita, conn, rs, turno, sql, confirmado

Set conn = getConexao()

matricula = Request.form("matricula")
torre = Request.form("torre")
guarita = Request.form("guarita")

if Request.form("confirmado") = "" then
    confirmado = "0"
else
    confirmado = Request.form("confirmado")
end if

'Verifica se o funcionário já está cadastrado
sql = "SELECT usuario_dss, supervisao "&_
"FROM login_dss " &_
"WHERE usuario_dss = '" & matricula & "'"

Set rs = conn.execute(sql)

if not rs.EOF Then
    Dim usuario_dss, supervisao, horaAtual, dataHoje, dataAmanha

    usuario_dss = rs("usuario_dss")
    supervisao = rs("supervisao")

    turno = turnoAtual()

    'Verifica se o funcionário já está cadastrado no turno atual

    horaAtual = Hour(Now())
    dataHoje = Date()
    dataAmanha = DateAdd("d", 1, dataHoje)

    If turno = "manha" Then
        condicaoHora = "(data_hora_ra >= #" & FormatDateTime(dataHoje, 2) & " 06:00:00# AND data_hora_ra <= #" & FormatDateTime(dataHoje, 2) & " 17:59:59#)"
    Else
        condicaoHora = "((data_hora_ra >= #" & FormatDateTime(dataHoje, 2) & " 18:00:00#) AND (data_hora_ra <= #" & FormatDateTime(dataAmanha, 2) & " 05:59:59#))"
    End If

    sql = "SELECT COUNT(*) AS total "&_
    "FROM registros_apresentacao "&_
    "WHERE usuario_dss = '" & usuario_dss & "' "&_
    "AND " & condicaoHora
    set rs = conn.execute(sql)

    if rs("total") = "0" Then

        if torre <> supervisao and confirmado <> "1" then
            response.write("confirmar|" & supervisao)
        else
            sql = "INSERT INTO registros_apresentacao (usuario_dss, data_hora_ra, supervisao_ra, local_trabalho_ra) " & _
                "VALUES ('" & usuario_dss & "', Now(), '" & torre & "', '" & guarita & "')"
            conn.execute(sql)
            
            response.write "ok"
        end if
    Else
        response.write("Funcionário já cadastrado no turno atual.")
    end if
Else
    response.write("Funcionário não encontrado.")
end if

conn.close
Set conn = Nothing

%>
