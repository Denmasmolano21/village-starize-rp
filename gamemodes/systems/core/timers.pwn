// Core System - Timers
// VS:RP v1.0.4

forward UpdatePlayerTime();
forward UpdateHungerThirst();

public UpdatePlayerTime()
{
    foreach(new i : Player)
    {
        if (PlayerData[i][pLoggedIn] && PlayerData[i][pSpawned])
        {
            PlayerData[i][pSeconds]++;
            if (PlayerData[i][pSeconds] >= 60)
            {
                PlayerData[i][pSeconds] = 0;
                PlayerData[i][pMinutes]++;
                if (PlayerData[i][pMinutes] >= 60)
                {
                    PlayerData[i][pMinutes] = 0;
                    PlayerData[i][pHours]++;
                }
            }
        }
    }
    return 1;
}

public UpdateHungerThirst()
{
    foreach(new i : Player)
    {
        if (PlayerData[i][pLoggedIn] && PlayerData[i][pSpawned])
        {
            if(PlayerData[i][pHunger] > 0) PlayerData[i][pHunger]--;
            if(PlayerData[i][pThirst] > 0) PlayerData[i][pThirst]--;
            
            UpdateHungerThirstHUD(i);
            CheckHungerThirstEffects(i);
        }
    }
    return 1;
}

CheckHungerThirstEffects(playerid)
{
    if(PlayerData[playerid][pHunger] <= 0)
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        if(health > 10.0)
        {
            SetPlayerHealth(playerid, health - 5.0);
            if(random(100) < 10)
                ErrorMsg(playerid, "Anda sangat kelaparan! Kesehatan menurun!");
        }
    }
    else if(PlayerData[playerid][pHunger] <= 20)
    {
        if(random(100) < 3)
            WarningMsg(playerid, "Anda merasa sangat lapar. Cari makanan segera!");
    }
    
    if(PlayerData[playerid][pThirst] <= 0)
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        if(health > 10.0)
        {
            SetPlayerHealth(playerid, health - 3.0);
            if(random(100) < 10)
                ErrorMsg(playerid, "Anda sangat kehausan! Kesehatan menurun!");
        }
    }
    else if(PlayerData[playerid][pThirst] <= 20)
    {
        if(random(100) < 3)
            WarningMsg(playerid, "Anda merasa sangat haus. Cari minuman segera!");
    }
    
    return 1;
}