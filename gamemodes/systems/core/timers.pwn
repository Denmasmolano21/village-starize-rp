// Core System - Timers
// VS:RP v1.0.4 - IMPROVED

forward UpdatePlayerTime();
forward UpdateHungerThirst();
forward AutoSaveAllPlayers();
forward CheckAFKPlayers();

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
                
                // Give experience every minute
                GivePlayerExperience(i, 1);
                
                if (PlayerData[i][pMinutes] >= 60)
                {
                    PlayerData[i][pMinutes] = 0;
                    PlayerData[i][pHours]++;
                    
                    // Hourly rewards
                    new reward = 100 * PlayerData[i][pLevel];
                    GivePlayerMoneyEx(i, reward);
                    InfoMsg(i, "Payday! Anda menerima $%s (1 jam online)", FormatNumber(reward));
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
            // Decrease hunger and thirst
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
    new Float:health;
    GetPlayerHealth(playerid, health);
    
    // Critical hunger (0-10)
    if(PlayerData[playerid][pHunger] <= 0)
    {
        if(health > 10.0)
        {
            SetPlayerHealth(playerid, health - 5.0);
            if(random(100) < 20) // 20% chance per tick
                ErrorMsg(playerid, "Anda sangat kelaparan! Kesehatan menurun drastis!");
        }
    }
    // Low hunger warning (11-20)
    else if(PlayerData[playerid][pHunger] <= 20)
    {
        if(health > 20.0 && random(100) < 5) // 5% chance
        {
            SetPlayerHealth(playerid, health - 2.0);
        }
        
        if(random(100) < 3) // 3% chance for message
            WarningMsg(playerid, "Anda merasa sangat lapar. Cari makanan segera!");
    }
    // Medium hunger (21-50)
    else if(PlayerData[playerid][pHunger] <= 50)
    {
        if(random(100) < 1)
            InfoMsg(playerid, "Anda mulai merasa lapar.");
    }
    
    // Critical thirst (0-10)
    if(PlayerData[playerid][pThirst] <= 0)
    {
        if(health > 10.0)
        {
            SetPlayerHealth(playerid, health - 3.0);
            if(random(100) < 20)
                ErrorMsg(playerid, "Anda sangat kehausan! Kesehatan menurun!");
        }
    }
    // Low thirst warning (11-20)
    else if(PlayerData[playerid][pThirst] <= 20)
    {
        if(health > 20.0 && random(100) < 5)
        {
            SetPlayerHealth(playerid, health - 1.5);
        }
        
        if(random(100) < 3)
            WarningMsg(playerid, "Anda merasa sangat haus. Cari minuman segera!");
    }
    // Medium thirst (21-50)
    else if(PlayerData[playerid][pThirst] <= 50)
    {
        if(random(100) < 1)
            InfoMsg(playerid, "Anda mulai merasa haus.");
    }
    
    return 1;
}

public AutoSaveAllPlayers()
{
    new count = 0;
    foreach(new i : Player)
    {
        if (PlayerData[i][pLoggedIn])
        {
            SavePlayerData(i);
            count++;
        }
    }
    
    if(count > 0)
    {
        printf("[AUTO-SAVE] Saved %d player(s) data", count);
    }
    
    return 1;
}

forward UpdateVehicleFuel();
public UpdateVehicleFuel()
{
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(!IsValidVehicle(i)) continue;
        
        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);
        
        // Decrease fuel if engine is on
        if(engine == 1)
        {
            if(VehicleData[i][vFuel] > 0)
            {
                VehicleData[i][vFuel]--;
                
                // Engine dies when out of fuel
                if(VehicleData[i][vFuel] <= 0)
                {
                    VehicleData[i][vFuel] = 0;
                    SetVehicleParamsEx(i, 0, lights, alarm, doors, bonnet, boot, objective);
                    
                    // Notify driver
                    foreach(new p : Player)
                    {
                        if(GetPlayerVehicleID(p) == i && GetPlayerState(p) == PLAYER_STATE_DRIVER)
                        {
                            ErrorMsg(p, "Kendaraan kehabisan bensin!");
                            GameTextForPlayer(p, "~r~OUT OF FUEL!", 3000, 3);
                        }
                    }
                }
                // Low fuel warning
                else if(VehicleData[i][vFuel] <= 10)
                {
                    if(random(100) < 10) // 10% chance per tick
                    {
                        foreach(new p : Player)
                        {
                            if(GetPlayerVehicleID(p) == i && GetPlayerState(p) == PLAYER_STATE_DRIVER)
                            {
                                WarningMsg(p, "Bensin hampir habis! Fuel: %d%%", VehicleData[i][vFuel]);
                            }
                        }
                    }
                }
            }
        }
    }
    return 1;
}

forward CheckPlayerAnimation();
public CheckPlayerAnimation()
{
    foreach(new i : Player)
    {
        if(!PlayerData[i][pLoggedIn] || !PlayerData[i][pSpawned]) continue;
        
        // Stop animations after some time
        new animlib[32], animname[32];
        GetAnimationName(GetPlayerAnimationIndex(i), animlib, sizeof(animlib), animname, sizeof(animname));
        
        if(strcmp(animlib, "FOOD", true) == 0 || strcmp(animlib, "BAR", true) == 0)
        {
            // Animation will auto-stop
        }
    }
    return 1;
}

public CheckAFKPlayers()
{
    foreach(new i : Player)
    {
        if(!PlayerData[i][pLoggedIn] || !PlayerData[i][pSpawned]) continue;
        
        // Check for AFK players (implement AFK system later)
        // This is placeholder for future AFK detection
    }
    return 1;
}

forward WeatherUpdate();
public WeatherUpdate()
{
    // Random weather changes
    new weather_list[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11};
    new random_weather = weather_list[random(sizeof(weather_list))];
    
    SetWeather(random_weather);
    
    new hour, minute, second;
    gettime(hour, minute, second);
    
    printf("[WEATHER] Changed to ID %d at %02d:%02d", random_weather, hour, minute);
    
    return 1;
}

forward TimeUpdate();
public TimeUpdate()
{
    new hour, minute, second;
    gettime(hour, minute, second);
    
    // Update world time
    SetWorldTime(hour);
    
    return 1;
}
