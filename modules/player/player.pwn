#include    <YSI_Coding\y_hooks>

#define     MAX_PLAYER_PASS     (64)

enum E_PLAYER_DATA
{
    ORM:pORMID,
    pID,

    pName[MAX_PLAYER_NAME],
    pPass[MAX_PLAYER_PASS],

    bool:pLogged
}

new PlayerInfo[MAX_PLAYERS][E_PLAYER_DATA];

SetPlayerLogged(playerid, bool:logged)
{
    PlayerInfo[playerid][pLogged] = logged;
    return 1;
}

bool:IsPlayerLogged(playerid)
{
    return PlayerInfo[playerid][pLogged];
}

ResetPlayerInfo(playerid)
{
    new reset[E_PLAYER_DATA];
    PlayerInfo[playerid] = reset;
    return 1;
}

hook OnPlayerSpawn(playerid)
{
    if(IsPlayerLogged(playerid) == false)
    {
        SendErrorMessage(playerid, "Você não está logado e foi kickado por segurança.");
        return KickWithDelay(playerid, 500);
    }
    return 1;
}

hook OnPlayerRequestSpawn(playerid)
{
    SendErrorMessage(playerid, "Você não pode spawnar por aqui.");
    return 0;
}

hook OnPlayerDisconnect(playerid, reason)
{
    if(IsPlayerLogged(playerid))
    {
        orm_save(PlayerInfo[playerid][pORMID]);
    }
    orm_destroy(PlayerInfo[playerid][pORMID]);
    ResetPlayerInfo(playerid);
    return 1;
}

