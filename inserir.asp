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
sql = "SELECT id_funcionario, id_supervisao "&_
"FROM funcionario " &_
"WHERE matricula = '" & matricula & "'"

Set rs = conn.execute(sql)

if not rs.EOF Then
    Dim id_funcionario, id_supervisao
    id_funcionario = rs("id_funcionario")
    id_supervisao = rs("id_supervisao")

    turno = turnoAtual()

    'Verifica se o funcionário já está cadastrado no turno atual

    If turno = "manha" Then
        condicaoHora = "data_hora BETWEEN CURDATE() + INTERVAL 6 HOUR AND CURDATE() + INTERVAL 17 HOUR"
    Else
        condicaoHora = "(data_hora BETWEEN CURDATE() + INTERVAL 18 HOUR AND CURDATE() + INTERVAL 1 DAY - INTERVAL 1 SECOND " &_
                    "OR data_hora BETWEEN CURDATE() AND CURDATE() + INTERVAL 6 HOUR)"
    End If


    sql = "SELECT COUNT(*) AS total "&_
    "FROM registro_apresentacao "&_
    "WHERE id_funcionario = '" & id_funcionario & "' "&_
    "AND " & condicaoHora
    set rs = conn.execute(sql)

    if rs("total") = "0" Then
        
        sql = "SELECT torre "&_
        "FROM supervisao "&_
        "WHERE id_supervisao = '" & id_supervisao & "'"

        conn.execute(sql)
        set rs = conn.execute(sql)

        if torre <> rs("torre") and confirmado <> "1" then
            response.write("confirmar|" & rs("torre"))
        else
            sql = "INSERT INTO registro_apresentacao (id_funcionario, data_hora, supervisao, guarita) " & _
                "VALUES ('" & id_funcionario & "', NOW(), '" & torre & "', '" & guarita & "')"
            conn.execute(sql)
            response.write("ok")
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