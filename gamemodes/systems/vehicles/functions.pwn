// Vehicle System - Functions
// VS:RP v1.0.4 - IMPROVED

public UpdateSpeedometer(playerid)
{
    if(!PlayerData[playerid][pLoggedIn]) return 0;
    
    new vehicleid = GetPlayerVehicleID(playerid);
    
    // Improved validation - check vehicle state first
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || !vehicleid || vehicleid == INVALID_VEHICLE_ID) 
    {
        if(PlayerData[playerid][pHudVisible])
        {
            HideSpeedometer(playerid);
        }
        return 0;
    }
    
    // Show speedometer if hidden
    if(!IsSpeedometerVisible(playerid))
    {
        ShowSpeedometer(playerid);
    }
    
    // Get vehicle parameters
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    
    // Calculate speed only if engine is on
    new Float:speed = 0.0;
    if(engine == 1)
    {
        new Float:vx, Float:vy, Float:vz;
        GetVehicleVelocity(vehicleid, vx, vy, vz);
        speed = floatsqroot(vx*vx + vy*vy + vz*vz) * 180.0;
    }
    
    // Update speed display
    new speed_string[16];
    format(speed_string, sizeof(speed_string), "%.0f", speed);
    PlayerTextDrawSetString(playerid, SPEED[playerid], speed_string);
    PlayerTextDrawShow(playerid, SPEED[playerid]);
    
    // Calculate vehicle health percentage
    new Float:health;
    GetVehicleHealth(vehicleid, health);
    new health_percent = floatround((health / 1000.0) * 100.0); // Fixed: proper percentage calculation
    
    // Clamp health between 0-100
    if(health_percent > 100) health_percent = 100;
    if(health_percent < 0) health_percent = 0;
    
    // Update health display with color coding
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
    
    // Update fuel display (placeholder - implement fuel system later)
    new fuel_percent = VehicleData[vehicleid][vFuel];
    new fuel_string[8];
    format(fuel_string, sizeof(fuel_string), "%d", fuel_percent);
    PlayerTextDrawSetString(playerid, FUEL[playerid], fuel_string);
    
    if(fuel_percent <= 10)
        PlayerTextDrawColor(playerid, FUEL[playerid], COLOR_RED);
    else if(fuel_percent <= 30)
        PlayerTextDrawColor(playerid, FUEL[playerid], COLOR_YELLOW);
    else
        PlayerTextDrawColor(playerid, FUEL[playerid], COLOR_WHITE);
        
    PlayerTextDrawShow(playerid, FUEL[playerid]);
    
    // Update lock status
    UpdateVehicleLockStatus(playerid, vehicleid);
    
    return 1;
}

UpdateVehicleLockStatus(playerid, vehicleid)
{
    if(!IsValidVehicle(vehicleid)) return 0;
    
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
    return 1;
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
    
    new closestVehicle = INVALID_VEHICLE_ID;
    new Float:closestDistance = range;
    
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(IsValidVehicle(i))
        {
            new Float:vx, Float:vy, Float:vz;
            GetVehiclePos(i, vx, vy, vz);
            
            new Float:distance = GetPlayerDistanceFromPoint(playerid, vx, vy, vz);
            
            // Find the closest vehicle within range
            if(distance <= closestDistance)
            {
                closestDistance = distance;
                closestVehicle = i;
            }
        }
    }
    return closestVehicle;
}

// Initialize vehicle data when created
InitializeVehicleData(vehicleid)
{
    if(vehicleid < 1 || vehicleid >= MAX_VEHICLES) return 0;
    
    VehicleData[vehicleid][vID] = vehicleid;
    VehicleData[vehicleid][vFuel] = 100;
    VehicleData[vehicleid][vHealth] = 1000.0;
    VehicleData[vehicleid][vLocked] = false;
    VehicleData[vehicleid][vEngine] = false;
    VehicleLocked[vehicleid] = false;
    
    return 1;
}

// Reset vehicle data
ResetVehicleData(vehicleid)
{
    if(vehicleid < 1 || vehicleid >= MAX_VEHICLES) return 0;
    
    VehicleData[vehicleid][vID] = 0;
    VehicleData[vehicleid][vModel] = 0;
    VehicleData[vehicleid][vX] = 0.0;
    VehicleData[vehicleid][vY] = 0.0;
    VehicleData[vehicleid][vZ] = 0.0;
    VehicleData[vehicleid][vA] = 0.0;
    VehicleData[vehicleid][vColor1] = -1;
    VehicleData[vehicleid][vColor2] = -1;
    VehicleData[vehicleid][vFuel] = 100;
    VehicleData[vehicleid][vHealth] = 1000.0;
    VehicleData[vehicleid][vLocked] = false;
    VehicleData[vehicleid][vEngine] = false;
    VehicleLocked[vehicleid] = false;
    
    return 1;
}

public CheckVehicleLockStatus()
{
    foreach(new i : Player)
    {
        if(PlayerData[i][pLoggedIn] && GetPlayerState(i) == PLAYER_STATE_DRIVER)
        {
            new vehicleid = GetPlayerVehicleID(i);
            if(vehicleid && IsValidVehicle(vehicleid))
            {
                new engine, lights, alarm, doors, bonnet, boot, objective;
                GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
                
                // Prevent engine from running when locked
                if(doors == 1 && engine == 1)
                {
                    SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
                    ErrorMsg(i, "Mesin mati karena kendaraan terkunci!");
                }
            }
        }
    }
    return 1;
}