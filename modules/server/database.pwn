#include    <YSI_Coding\y_hooks>

new MySQL:DBConn, Query;

hook OnGameModeInit()
{
    mysql_log(ALL);
    DBConn = mysql_connect_file();

    if(mysql_errno(DBConn) != 0 || DBConn == MYSQL_INVALID_HANDLE)
    {
        print("MySQL: Erro em se conectar com o banco de dados, servidor desligado.");
        return SendRconCommand("exit");
    }
    else
    {
        print("MySQL: Conexao com o banco de dados estabilizada.");
        VerifyTables();
    }
    return 1;
}

hook OnGameModeExit()
{
    if(mysql_errno(DBConn) == 0 || DBConn != MYSQL_DEFAULT_HANDLE)
    {
        print("MySQL: Conexao com o banco de dados fechada.");
        mysql_close(DBConn);
    }
    return 1;
}

void:VerifyTables()
{
    mysql_query(DBConn, 
    "CREATE TABLE IF NOT EXISTS `player`(\
        `id` INT AUTO_INCREMENT PRIMARY KEY,\
        `name` varchar(24) NOT NULL UNIQUE,\
        `pass` varchar(64) NOT NULL\
    );", false);

    print("MySQL: Tabela \"player\" verificada com sucesso.");
}