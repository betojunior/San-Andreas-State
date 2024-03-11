// includes

#include 	<a_samp>
#include 	<a_mysql>
#include 	<crashdetect>
#include 	<bcrypt>
#include 	<util>

// enum's

enum // dialogs
{
	DIALOG_UNUSED, 
	
	DIALOG_REGISTER,
	DIALOG_LOGIN
}

// player defines

#define 	MAX_PLAYER_PASS 	(64)
forward		bool:IsPlayerLogged(playerid);

// server variables

new MySQL:DBConn; 

// player variables

enum E_PLAYER_DATA
{
	ORM:pORMID,
	pID,

	pName[MAX_PLAYER_NAME],
	pPass[MAX_PLAYER_PASS],

	bool:pLogged,

	pForcingSpawn,
	pLoginTentatives
}

new PlayerInfo[MAX_PLAYERS][E_PLAYER_DATA];

main() 
{}

// callback

public OnGameModeInit()
{
	CleanServerTerminal(); 
	DatabaseInit();
	return 1;
}

public OnGameModeExit()
{
	DatabaseClose();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	CleanPlayerChat(playerid);
	ResetPlayerInfo(playerid);
	
	GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);
	PlayerInfo[playerid][pORMID] = orm_create("player", DBConn);

	orm_addvar_int(PlayerInfo[playerid][pORMID], PlayerInfo[playerid][pID], "id");
	orm_addvar_string(PlayerInfo[playerid][pORMID], PlayerInfo[playerid][pName], MAX_PLAYER_NAME, "name");
	orm_addvar_string(PlayerInfo[playerid][pORMID], PlayerInfo[playerid][pPass], MAX_PLAYER_PASS, "pass");

	orm_setkey(PlayerInfo[playerid][pORMID], "name");
	orm_load(PlayerInfo[playerid][pORMID], "OnPlayerDataLoaded", "d", playerid);
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	SendErrorMessage(playerid, "Você não pode spawnar por aqui.");

	PlayerInfo[playerid][pForcingSpawn]++;
	if(PlayerInfo[playerid][pForcingSpawn] == 3)
	{
		KickWithDelay(playerid);
		SendInfoMessage(playerid, "Você foi kickado por tentar spawnar da forma errada três vezes.");
	}
	return 0;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerLogged(playerid) == false)
	{
		SendInfoMessage(playerid, "Você foi kickado por spawn sem estar logado.");
		KickWithDelay(playerid);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(IsPlayerLogged(playerid))
	{
		orm_save(PlayerInfo[playerid][pORMID]);
	}
	orm_destroy(PlayerInfo[playerid][pORMID]);
	ResetPlayerInfo(playerid);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_LOGIN: 
		{
			if(response)
			{
				bcrypt_check(inputtext, PlayerInfo[playerid][pPass], "OnPlayerVerifyPassword", "d", playerid);
			}
			else
			{
				Kick(playerid);
			}
		}

		case DIALOG_REGISTER:
		{
			if(response)
			{
				if(strlen(inputtext) < 8 || strlen(inputtext) > 16)
				{
					SendErrorMessage(playerid, "A senha deve ter de 8 - 16 caracteres.");
					ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registro", "Bem vindo(a) ao servidor!\n\nDigite uma senha para se registrar:", "Registrar", "Sair");
				}
				else
				{
					bcrypt_hash(inputtext, 12, "OnPlayerAreRegistered", "d", playerid);
				}
			}
			else
			{
				Kick(playerid);
			}
		}
	}
	return 1;
}

forward OnPlayerDataLoaded(playerid);
public OnPlayerDataLoaded(playerid)
{
	orm_setkey(PlayerInfo[playerid][pORMID], "id");

	switch(orm_errno(PlayerInfo[playerid][pORMID]))
	{
		case ERROR_OK:
		{
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Bem vindo(a) ao servidor!\n\nDigite sua senha para entrar:", "Entrar", "Sair");
		}

		case ERROR_NO_DATA:
		{
			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registro", "Bem vindo(a) ao servidor!\n\nDigite uma senha para se registrar:", "Registrar", "Sair");
		}
	}
	return 1;
}

forward OnPlayerVerifyPassword(playerid);
public OnPlayerVerifyPassword(playerid)
{
	if(bcrypt_is_equal() == true)
	{
		SetPlayerInfo(playerid);
	}
	else
	{
		PlayerInfo[playerid][pLoginTentatives]++;
		if(PlayerInfo[playerid][pLoginTentatives] == 3)
		{
			KickWithDelay(playerid);
			return SendInfoMessage(playerid, "Você foi kickado por errar sua senha três vezes.");	
		}

		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Bem vindo(a) ao servidor!\n\nDigite sua senha para entrar:", "Entrar", "Sair");
		SendErrorMessage(playerid, "Senha incorreta.");
	}
	return 1;
}

forward OnPlayerAreKicked(playerid);
public OnPlayerAreKicked(playerid)
{
	Kick(playerid);
	return 1;
}

forward OnPlayerAreRegistered(playerid);
public OnPlayerAreRegistered(playerid)
{
	bcrypt_get_hash(PlayerInfo[playerid][pPass]);
	orm_update(PlayerInfo[playerid][pORMID]);
	SendInfoMessage(playerid, "Você foi registrado.");
	SetPlayerInfo(playerid);
	return 1;
}

// database functions

DatabaseInit()
{
	DBConn = mysql_connect_file();
	if(DBConn == MYSQL_INVALID_HANDLE || mysql_errno(DBConn) != 0)
	{
		print("MySQL: Erro em se conectar com o banco de dados, servidor desligado.");
		SendRconCommand("exit");
	}
	else
	{
		print("MySQL: Conexao com o banco de dados estabilizada.");
		VerifyDatabaseTables();
	}
	return 1;
}

DatabaseClose()
{
	if(DBConn != MYSQL_INVALID_HANDLE || mysql_errno(DBConn) == 0)
	{
		mysql_close(DBConn);
		print("MySQL: Conexao com o banco de dados finalizada.");
	}
	return 1;
}

VerifyDatabaseTables()
{
	print("MySQL: Verificando tabelas do servidor."); 

	mysql_query(DBConn, 
	"CREATE TABLE IF NOT EXISTS `player`(\
		`id` INT AUTO_INCREMENT,\
		`name` VARCHAR(24) NOT NULL,\
		`pass` VARCHAR(64) NOT NULL,\
		PRIMARY KEY(`id`));",
	false);
	print("MySQL: Tabela \"player\" verificada com sucesso.");

	print("MySQL: Tabelas verificadas com sucesso.");
	return 1;
}

// player functions

SendErrorMessage(playerid, const message[])
{
	new str[128];
	format(str, sizeof str, ""COLOR_RED"ERRO: "COLOR_WHITE"%s", message);
	SendClientMessage(playerid, -1, str);
	return 1;
}

SendInfoMessage(playerid, const message[])
{
	new str[128];
	format(str, sizeof str, "INFO: %s", message);
	SendClientMessage(playerid, -1, str);
	return 1;
}

ResetPlayerInfo(playerid)
{
	new reset[E_PLAYER_DATA];
	PlayerInfo[playerid] = reset;
	SetSpawnInfo(playerid, NO_TEAM, 0, 0.0, 0.0, 3.0, 0.0, 0, 0, 0, 0, 0, 0);
	return 1;
}

bool:IsPlayerLogged(playerid)
{
	return PlayerInfo[playerid][pLogged];
}

SetPlayerLogged(playerid, bool:logged)
{
	return PlayerInfo[playerid][pLogged] = logged;
}

SetPlayerInfo(playerid)
{
	SetPlayerLogged(playerid, true);
	SpawnPlayer(playerid);
	SendInfoMessage(playerid, "Você foi logado com sucesso.");
	return 1;
}

KickWithDelay(playerid, time = 200)
{
	SetTimerEx("OnPlayerAreKicked", time, false, "d", playerid);
	return 1;
}