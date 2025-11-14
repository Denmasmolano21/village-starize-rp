// Vehicle System - Functions
// VS:RP v1.0.4

public UpdateSpeedometer(playerid)
{
    if(!PlayerData[playerid][pLoggedIn]) return 0;
    
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) 
    {
        if(PlayerData[playerid][pHudVisible])
        {
            HideSpeedometer(playerid);
        }
        return 0;
    }
    
    new vehicleid = GetPlayerVehicleID(playerid);
    if(!vehicleid || vehicleid == INVALID_VEHICLE_ID) return 0;
    
    if(!IsSpeedometerVisible(playerid))
    {
        ShowSpeedometer(playerid);
    }
    
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    
    new Float:speed = 0.0;
    
    if(engine == 1)
    {
        new Float:vx, Float:vy, Float:vz;
        GetVehicleVelocity(vehicleid, vx, vy, vz);
        speed = floatsqroot(vx*vx + vy*vy + vz*vz) * 180.0;
    }
    
    new speed_string[16];
    format(speed_string, sizeof(speed_string), "%.0f", speed);
    PlayerTextDrawSetString(playerid, SPEED[playerid], speed_string);
    PlayerTextDrawShow(playerid, SPEED[playerid]);
    
    new Float:health;
    GetVehicleHealth(vehicleid, health);
    new health_percent = floatround(health/10.0);
    if(health_percent > 100) health_percent = 100;
    if(health_percent < 0) health_percent = 0;
    
    new health_string[8];
    format(health_string, sizeof(health_string), "%d", health_percent);
    PlayerTextDrawSetString(playerid, HP[playerid], health_string);
    
    if(health_percent <= 25)
        PlayerTextDrawColor(playerid, HP[playerid], COLOR_RED);
    else if(health_percent <= 50)
        PlayerTextDrawColor(playerid, HP[playerid], COLOR_YELLOW);
    else
        PlayerTextDrawColor(playerid, HP[playerid], COLOR_WHITE);
        
    PlayerTextDrawShow(playerid, HP[playerid]);
    
    PlayerTextDrawSetString(playerid, FUEL[playerid], "100");
    PlayerTextDrawShow(playerid, FUEL[playerid]);
    
    UpdateVehicleLockStatus(playerid, vehicleid);
    
    return 1;
}

UpdateVehicleLockStatus(playerid, vehicleid)
{
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    
    if(doors == 1)
    {
        PlayerTextDrawSetString(playerid, LOCK[playerid], "LOCKED");
        PlayerTextDrawColor(playerid, LOCK[playerid], COLOR_RED);
        VehicleLocked[vehicleid] = true;
    }
    else
    {
        PlayerTextDrawSetString(playerid, LOCK[playerid], "UNLOCKED");
        PlayerTextDrawColor(playerid, LOCK[playerid], COLOR_GREEN);
        VehicleLocked[vehicleid] = false;
    }
    PlayerTextDrawShow(playerid, LOCK[playerid]);
}

IsSpeedometerVisible(playerid)
{
    return (PlayerData[playerid][pHudVisible] && GetPlayerState(playerid) == PLAYER_STATE_DRIVER);
}

ShowSpeedometer(playerid)
{
    if(!PlayerData[playerid][pLoggedIn]) return 0;
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 0;
    
    PlayerTextDrawShow(playerid, BG_SPEEDOMETER[playerid]);
    PlayerTextDrawShow(playerid, HUD_SPEED[playerid]);
    PlayerTextDrawShow(playerid, HUD_FUEL[playerid]);
    PlayerTextDrawShow(playerid, HUD_HP[playerid]);
    PlayerTextDrawShow(playerid, HUD_LOCK[playerid]);
    PlayerTextDrawShow(playerid, SPEED[playerid]);
    PlayerTextDrawShow(playerid, SPEED_MPH[playerid]);
    PlayerTextDrawShow(playerid, FUEL[playerid]);
    PlayerTextDrawShow(playerid, HP[playerid]);
    PlayerTextDrawShow(playerid, LOCK[playerid]);
    PlayerTextDrawShow(playerid, PERSEN_1[playerid]);
    PlayerTextDrawShow(playerid, PERSEN_2[playerid]);
    PlayerTextDrawShow(playerid, PERSEN_3[playerid]);
    PlayerTextDrawShow(playerid, PERSEN_4[playerid]);
    PlayerTextDrawShow(playerid, PERSEN_5[playerid]);
    PlayerTextDrawShow(playerid, PERSEN_6[playerid]);
    
    return 1;
}

HideSpeedometer(playerid)
{
    PlayerTextDrawHide(playerid, BG_SPEEDOMETER[playerid]);
    PlayerTextDrawHide(playerid, HUD_SPEED[playerid]);
    PlayerTextDrawHide(playerid, HUD_FUEL[playerid]);
    PlayerTextDrawHide(playerid, HUD_HP[playerid]);
    PlayerTextDrawHide(playerid, HUD_LOCK[playerid]);
    PlayerTextDrawHide(playerid, SPEED[playerid]);
    PlayerTextDrawHide(playerid, SPEED_MPH[playerid]);
    PlayerTextDrawHide(playerid, FUEL[playerid]);
    PlayerTextDrawHide(playerid, HP[playerid]);
    PlayerTextDrawHide(playerid, LOCK[playerid]);
    PlayerTextDrawHide(playerid, PERSEN_1[playerid]);
    PlayerTextDrawHide(playerid, PERSEN_2[playerid]);
    PlayerTextDrawHide(playerid, PERSEN_3[playerid]);
    PlayerTextDrawHide(playerid, PERSEN_4[playerid]);
    PlayerTextDrawHide(playerid, PERSEN_5[playerid]);
    PlayerTextDrawHide(playerid, PERSEN_6[playerid]);
    
    return 1;
}

public DelayedShowSpeedometer(playerid)
{
    if(PlayerData[playerid][pLoggedIn] && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        ShowSpeedometer(playerid);
        UpdateSpeedometer(playerid);
    }
    return 1;
}

GetClosestVehicle(playerid, Float:range)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(IsValidVehicle(i))
        {
            new Float:vx, Float:vy, Float:vz;
            GetVehiclePos(i, vx, vy, vz);
            
            if(GetPlayerDistanceFromPoint(playerid, vx, vy, vz) <= range)
            {
                return i;
            }
        }
    }
    return INVALID_VEHICLE_ID;
}

public CheckVehicleLockStatus()
{
    foreach(new i : Player)
    {
        if(PlayerData[i][pLoggedIn] && GetPlayerState(i) == PLAYER_STATE_DRIVER)
        {
            new vehicleid = GetPlayerVehicleID(i);
            if(vehicleid)
            {
                new engine, lights, alarm, doors, bonnet, boot, objective;
                GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
                
                if(doors == 1 && engine == 1)
                {
                    SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
                }
            }
        }
    }
    return 1;
}