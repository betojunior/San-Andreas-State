#include    <YSI_Coding\y_hooks>

hook OnPlayerRequestClass(playerid, classid)
{
    GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);

    PlayerInfo[playerid][pORMID] = orm_create("player", DBConn);

    orm_addvar_int(PlayerInfo[playerid][pORMID], PlayerInfo[playerid][pID], "id");
    orm_addvar_string(PlayerInfo[playerid][pORMID], PlayerInfo[playerid][pName], MAX_PLAYER_NAME, "name");
    orm_addvar_string(PlayerInfo[playerid][pORMID], PlayerInfo[playerid][pPass], MAX_PLAYER_PASS, "pass");
    orm_setkey(PlayerInfo[playerid][pORMID], "name");

    orm_load(PlayerInfo[playerid][pORMID], "OnPlayerDataLoaded", "d", playerid);
    return 1;
}

publicex OnPlayerDataLoaded(playerid)
{
    orm_setkey(PlayerInfo[playerid][pORMID], "id");

    switch(orm_errno(PlayerInfo[playerid][pORMID]))
    {
        case ERROR_OK: 
        {
            Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Bem vindo(a) ao servidor!\n\nDigite sua senha para entrar:", "Entrar", "Sair");
        }
        case ERROR_NO_DATA:
        {   
            Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registro", "Bem vindo(a) ao servidor!\n\nDigite uma senha para se registrar:", "Registrar", "Sair");
        }
    }
    return 1;
}

publicex VerifyPlayerPassword(playerid)
{
    if(bcrypt_is_equal())
    {
        SetPlayerLogged(playerid, true);
        SpawnPlayer(playerid);
    }
    else
    {
        Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Bem vindo(a) ao servidor!\n\nDigite sua senha para entrar:\n\n"COLOR_RED"ERRO: "COLOR_WHITE"Senha incorreta.", "Entrar", "Sair");
    }
    return 1;
}

publicex RegisterPlayerAccount(playerid)
{
    bcrypt_get_hash(PlayerInfo[playerid][pPass]);
    orm_insert(PlayerInfo[playerid][pORMID], "OnPlayerRegistered", "d", playerid);
    return 1;
}

publicex OnPlayerRegistered(playerid)
{
    orm_save(PlayerInfo[playerid][pORMID]);
    SendInfoMessage(playerid, "Você foi registrado, bem vindo(a).");
    SetPlayerLogged(playerid, true);
    SpawnPlayer(playerid);
    return 1;
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        bcrypt_check(inputtext, PlayerInfo[playerid][pPass], "VerifyPlayerPassword", "d", playerid);
    }
    else
    {
        Kick(playerid);
    }
    return 1;
}

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        if(strlen(inputtext) < 8 || strlen(inputtext) > 16)
        {
            Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registro", "Bem vindo(a) ao servidor!\n\nDigite uma senha para se registrar:\n\n"COLOR_RED"ERRO: "COLOR_WHITE"A senha deve ter de 8 - 16 caracteres.", "Registrar", "Sair");
        }
        else
        {
            bcrypt_hash(inputtext, 12, "RegisterPlayerAccount", "d", playerid);
        }
    }
    else
    {
        Kick(playerid);
    }
    return 1;
}