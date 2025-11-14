// Vehicle Commands
// VS:RP v1.0.4

CMD:engine(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);
    if(!vehicleid)
        return ErrorMsg(playerid, "Anda harus berada di dalam kendaraan!");
        
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return ErrorMsg(playerid, "Anda harus menjadi driver!");
    
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    
    if(doors == 1)
    {
        return ErrorMsg(playerid, "Tidak bisa menyalakan mesin! Kendaraan terkunci. Gunakan /unlock terlebih dahulu.");
    }
    
    if(engine == 1)
    {
        SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
        InfoMsg(playerid, "Mesin kendaraan dimatikan!");
        
        new string[128], Float:x, Float:y, Float:z;
        format(string, sizeof(string), "* %s mematikan mesin kendaraan", PlayerData[playerid][pName]);
        GetPlayerPos(playerid, x, y, z);
        
        foreach(new i : Player)
        {
            if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z) && i != playerid)
            {
                SendClientMessage(i, COLOR_PURPLE, string);
            }
        }
    }
    else
    {
        SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
        SuccessMsg(playerid, "Mesin kendaraan dinyalakan!");
        
        new string[128], Float:x, Float:y, Float:z;
        format(string, sizeof(string), "* %s menyalakan mesin kendaraan", PlayerData[playerid][pName]);
        GetPlayerPos(playerid, x, y, z);
        
        foreach(new i : Player)
        {
            if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z) && i != playerid)
            {
                SendClientMessage(i, COLOR_PURPLE, string);
            }
        }
    }
    return 1;
}

CMD:lock(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    new vehicleid = GetClosestVehicle(playerid, 5.0);
    if(vehicleid == INVALID_VEHICLE_ID)
        return ErrorMsg(playerid, "Tidak ada kendaraan di sekitar Anda!");
    
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    
    if(doors == 1)
        return ErrorMsg(playerid, "Kendaraan sudah terkunci!");
    
    SetVehicleParamsEx(vehicleid, engine, lights, alarm, 1, bonnet, boot, objective);
    VehicleLocked[vehicleid] = true;
    
    if(GetPlayerVehicleID(playerid) == vehicleid && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        UpdateVehicleLockStatus(playerid, vehicleid);
    }
    
    SuccessMsg(playerid, "Kendaraan berhasil dikunci!");
    
    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "* %s mengunci kendaraan", PlayerData[playerid][pName]);
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z) && i != playerid)
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    
    return 1;
}

CMD:unlock(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    new vehicleid = GetClosestVehicle(playerid, 5.0);
    if(vehicleid == INVALID_VEHICLE_ID)
        return ErrorMsg(playerid, "Tidak ada kendaraan di sekitar Anda!");
    
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    
    if(doors == 0)
        return ErrorMsg(playerid, "Kendaraan sudah tidak terkunci!");
    
    SetVehicleParamsEx(vehicleid, engine, lights, alarm, 0, bonnet, boot, objective);
    VehicleLocked[vehicleid] = false;
    
    if(GetPlayerVehicleID(playerid) == vehicleid && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        UpdateVehicleLockStatus(playerid, vehicleid);
    }
    
    SuccessMsg(playerid, "Kendaraan berhasil dibuka kuncinya!");
    
    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "* %s membuka kunci kendaraan", PlayerData[playerid][pName]);
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z) && i != playerid)
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    
    return 1;
}