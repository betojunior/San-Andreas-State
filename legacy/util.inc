
#if defined _util_inc
    #endinput
#endif

#define _util_inc

// colors

#define     COLOR_WHITE     "{FFFFFF}"
#define     COLOR_RED       "{FF0000}"

// functions

stock void:CleanPlayerChat(playerid)
{
    for(new i = 0; i < 20; i++)
    {
        SendClientMessage(playerid, -1, " ");
    }
}

stock void:CleanPlayerChatForAll()
{
    for(new i = 0; i < 20; i++)
    {
        SendClientMessageToAll(-1, " ");
    }
}

stock void:CleanServerTerminal()
{
    for(new i = 0; i < 20; i++)
    {
        print(" ");
    }
}