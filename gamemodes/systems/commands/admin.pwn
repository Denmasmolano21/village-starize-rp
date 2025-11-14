// Admin Commands
// VS:RP v1.0.4

CMD:veh(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new modelid;
    if (sscanf(params, "d", modelid))
        return UsageMsg(playerid, "/veh [modelid]");

    if(modelid < 400 || modelid > 611)
        return ErrorMsg(playerid, "Model ID tidak valid! (400-611)");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new vehid = CreateVehicle(modelid, x, y, z + 1.0, a, -1, -1, -1);

    if (vehid != INVALID_VEHICLE_ID)
    {
        SuccessMsg(playerid, "Kendaraan ID %d (Model %d) berhasil dibuat!", vehid, modelid);
        PutPlayerInVehicle(playerid, vehid, 0);
    }
    else
    {
        ErrorMsg(playerid, "Gagal membuat kendaraan!");
    }
    return 1;
}

CMD:goto(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid;
    if(sscanf(params, "u", targetid))
        return UsageMsg(playerid, "/goto [playerid/name]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    if(targetid == playerid)
        return ErrorMsg(playerid, "Anda tidak bisa goto ke diri sendiri!");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        SetVehiclePos(vehicleid, x + 2, y, z);
    }
    else
    {
        SetPlayerPos(playerid, x + 1, y, z);
    }

    SuccessMsg(playerid, "Teleport ke %s", PlayerData[targetid][pName]);
    InfoMsg(targetid, "Admin %s telah teleport ke lokasi Anda", PlayerData[playerid][pName]);
    return 1;
}

CMD:gethere(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid;
    if(sscanf(params, "u", targetid))
        return UsageMsg(playerid, "/gethere [playerid/name]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    if(targetid == playerid)
        return ErrorMsg(playerid, "Anda tidak bisa gethere diri sendiri!");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(targetid);
        SetVehiclePos(vehicleid, x + 2, y, z);
    }
    else
    {
        SetPlayerPos(targetid, x + 1, y, z);
    }

    SuccessMsg(playerid, "Anda telah membawa %s ke lokasi Anda", PlayerData[targetid][pName]);
    InfoMsg(targetid, "Anda telah di teleport oleh admin %s", PlayerData[playerid][pName]);
    return 1;
}

CMD:kick(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid, reason[64];
    if(sscanf(params, "us[64]", targetid, reason))
        return UsageMsg(playerid, "/kick [playerid/name] [reason]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    if(targetid == playerid)
        return ErrorMsg(playerid, "Anda tidak bisa kick diri sendiri!");

    new string[128];
    format(string, sizeof(string), "Admin %s telah mengeluarkan %s dari server. Alasan: %s", PlayerData[playerid][pName], PlayerData[targetid][pName], reason);
    SendClientMessageToAll(COLOR_RED, string);

    SetTimerEx("KickPlayer", 500, false, "d", targetid);
    return 1;
}

CMD:sethp(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid, Float:health;
    if(sscanf(params, "uf", targetid, health))
        return UsageMsg(playerid, "/sethp [playerid/name] [amount]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    if(health < 0.0 || health > 100.0)
        return ErrorMsg(playerid, "Health harus antara 0-100!");

    SetPlayerHealth(targetid, health);
    SuccessMsg(playerid, "Health %s telah diset menjadi %.1f", PlayerData[targetid][pName], health);
    InfoMsg(targetid, "Admin %s telah mengubah health Anda menjadi %.1f", PlayerData[playerid][pName], health);
    return 1;
}

CMD:setmoney(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 2) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid, amount;
    if(sscanf(params, "ud", targetid, amount))
        return UsageMsg(playerid, "/setmoney [playerid/name] [amount]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    PlayerData[targetid][pMoney] = amount;
    ResetPlayerMoney(targetid);
    GivePlayerMoney(targetid, amount);

    SuccessMsg(playerid, "Uang %s telah diset menjadi $%d", PlayerData[targetid][pName], amount);
    InfoMsg(targetid, "Admin %s telah mengubah uang Anda menjadi $%d", PlayerData[playerid][pName], amount);
    return 1;
}

CMD:a(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    if(isnull(params))
        return UsageMsg(playerid, "/a [message]");

    new string[144];
    format(string, sizeof(string), "[ADMIN] %s: %s", PlayerData[playerid][pName], params);
    
    foreach(new i : Player)
    {
        if(PlayerData[i][pAdmin] >= 1)
        {
            SendClientMessage(i, COLOR_RED, string);
        }
    }
    return 1;
}

CMD:ann(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    if(isnull(params))
        return UsageMsg(playerid, "/ann [message]");

    new string[144];
    format(string, sizeof(string), "~r~ANNOUNCEMENT~n~~w~%s", params);
    
    foreach(new i : Player)
    {
        GameTextForPlayer(i, string, 5000, 3);
    }
    
    SuccessMsg(playerid, "Pengumuman telah dikirim ke semua player");
    return 1;
}

CMD:repair(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return ErrorMsg(playerid, "Anda harus menjadi driver!");

    new vehicleid = GetPlayerVehicleID(playerid);
    RepairVehicle(vehicleid);
    SetVehicleHealth(vehicleid, 1000.0);
    
    SuccessMsg(playerid, "Kendaraan telah diperbaiki!");
    return 1;
}

CMD:flip(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new vehicleid = GetPlayerVehicleID(playerid);
    if(!vehicleid)
    {
        vehicleid = GetClosestVehicle(playerid, 5.0);
        if(vehicleid == INVALID_VEHICLE_ID)
            return ErrorMsg(playerid, "Tidak ada kendaraan di sekitar Anda!");
    }

    new Float:x, Float:y, Float:z, Float:a;
    GetVehiclePos(vehicleid, x, y, z);
    GetVehicleZAngle(vehicleid, a);
    SetVehiclePos(vehicleid, x, y, z + 0.5);
    SetVehicleZAngle(vehicleid, a);
    
    SuccessMsg(playerid, "Kendaraan telah dibalik!");
    return 1;
}