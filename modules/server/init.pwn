#include    <YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    for(new i = 0; i < 30; i++)
    {
        print(" ");
    }
    print("SERVER: Iniciando serviços.");
    return 1;
}