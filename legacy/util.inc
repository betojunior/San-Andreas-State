#define     publicex%0(%1)      forward %0(%1);     public %0(%1)

#define     COLOR_RED       "{FF0000}"
#define     COLOR_WHITE     "{FFFFFF}"

publicex KickEx(playerid)
{
    Kick(playerid);
    return 1;
}

KickWithDelay(playerid, time)
{
    SetTimerEx("KickEx", time, false, "d", playerid);
    return 1;
}

SendErrorMessage(playerid, const message[])
{
    SendClientMessage(playerid, -1, ""COLOR_RED"ERRO: "COLOR_WHITE"%s", message);
    return 1;
}

SendInfoMessage(playerid, const message[])
{
    SendClientMessage(playerid, -1, "INFO: %s", message);
    return 1;
}