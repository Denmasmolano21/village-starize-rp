// Admin Commands
// VS:RP v1.0.4 - IMPROVED

CMD:veh(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new modelid, color1 = -1, color2 = -1;
    if (sscanf(params, "d|dd", modelid, color1, color2))
        return UsageMsg(playerid, "/veh [modelid] [optional: color1] [optional: color2]");

    if(modelid < 400 || modelid > 611)
        return ErrorMsg(playerid, "Model ID tidak valid! (400-611)");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new vehid = CreateVehicle(modelid, x, y, z + 1.0, a, color1, color2, -1);

    if (vehid != INVALID_VEHICLE_ID)
    {
        InitializeVehicleData(vehid);
        VehicleData[vehid][vModel] = modelid;
        VehicleData[vehid][vColor1] = color1;
        VehicleData[vehid][vColor2] = color2;
        
        LinkVehicleToInterior(vehid, GetPlayerInterior(playerid));
        SetVehicleVirtualWorld(vehid, GetPlayerVirtualWorld(playerid));
        
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
    
    new interior = GetPlayerInterior(targetid);
    new vw = GetPlayerVirtualWorld(targetid);
    
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        SetVehiclePos(vehicleid, x + 2, y, z);
        LinkVehicleToInterior(vehicleid, interior);
        SetVehicleVirtualWorld(vehicleid, vw);
    }
    else
    {
        SetPlayerPos(playerid, x + 1, y, z);
    }
    
    SetPlayerInterior(playerid, interior);
    SetPlayerVirtualWorld(playerid, vw);

    SuccessMsg(playerid, "Teleport ke %s (Interior: %d, VW: %d)", PlayerData[targetid][pName], interior, vw);
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
    
    new interior = GetPlayerInterior(playerid);
    new vw = GetPlayerVirtualWorld(playerid);
    
    if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(targetid);
        SetVehiclePos(vehicleid, x + 2, y, z);
        LinkVehicleToInterior(vehicleid, interior);
        SetVehicleVirtualWorld(vehicleid, vw);
    }
    else
    {
        SetPlayerPos(targetid, x + 1, y, z);
    }
    
    SetPlayerInterior(targetid, interior);
    SetPlayerVirtualWorld(targetid, vw);

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
    
    if(PlayerData[targetid][pAdmin] >= PlayerData[playerid][pAdmin])
        return ErrorMsg(playerid, "Anda tidak bisa kick admin yang level sama atau lebih tinggi!");

    new string[128];
    format(string, sizeof(string), "[ADMIN] %s telah mengeluarkan %s dari server. Alasan: %s", 
        PlayerData[playerid][pName], PlayerData[targetid][pName], reason);
    SendClientMessageToAll(COLOR_RED, string);

    SetTimerEx("KickPlayer", 500, false, "d", targetid);
    return 1;
}

CMD:ban(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 2) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid, reason[64];
    if(sscanf(params, "us[64]", targetid, reason))
        return UsageMsg(playerid, "/ban [playerid/name] [reason]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    if(targetid == playerid)
        return ErrorMsg(playerid, "Anda tidak bisa ban diri sendiri!");
    
    if(PlayerData[targetid][pAdmin] >= PlayerData[playerid][pAdmin])
        return ErrorMsg(playerid, "Anda tidak bisa ban admin yang level sama atau lebih tinggi!");

    new string[128];
    format(string, sizeof(string), "[ADMIN] %s telah membanned %s dari server. Alasan: %s", 
        PlayerData[playerid][pName], PlayerData[targetid][pName], reason);
    SendClientMessageToAll(COLOR_RED, string);
    
    // Save ban to database
    new query[256];
    mysql_format(g_SQL, query, sizeof(query), 
        "INSERT INTO `bans` (`username`, `admin`, `reason`, `date`) VALUES ('%e', '%e', '%e', %d)",
        PlayerData[targetid][pName], PlayerData[playerid][pName], reason, gettime());
    mysql_tquery(g_SQL, query);

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
    PlayerData[targetid][pHealth] = health;
    
    SuccessMsg(playerid, "Health %s telah diset menjadi %.1f", PlayerData[targetid][pName], health);
    InfoMsg(targetid, "Admin %s telah mengubah health Anda menjadi %.1f", PlayerData[playerid][pName], health);
    return 1;
}

CMD:setarmour(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid, Float:armour;
    if(sscanf(params, "uf", targetid, armour))
        return UsageMsg(playerid, "/setarmour [playerid/name] [amount]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    if(armour < 0.0 || armour > 100.0)
        return ErrorMsg(playerid, "Armour harus antara 0-100!");

    SetPlayerArmour(targetid, armour);
    PlayerData[targetid][pArmour] = armour;
    
    SuccessMsg(playerid, "Armour %s telah diset menjadi %.1f", PlayerData[targetid][pName], armour);
    InfoMsg(targetid, "Admin %s telah mengubah armour Anda menjadi %.1f", PlayerData[playerid][pName], armour);
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
    
    if(amount < 0)
        return ErrorMsg(playerid, "Jumlah tidak boleh negatif!");

    PlayerData[targetid][pMoney] = amount;
    ResetPlayerMoney(targetid);
    GivePlayerMoney(targetid, amount);

    SuccessMsg(playerid, "Uang %s telah diset menjadi $%d", PlayerData[targetid][pName], amount);
    InfoMsg(targetid, "Admin %s telah mengubah uang Anda menjadi $%d", PlayerData[playerid][pName], amount);
    return 1;
}

CMD:givemoney(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 2) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid, amount;
    if(sscanf(params, "ud", targetid, amount))
        return UsageMsg(playerid, "/givemoney [playerid/name] [amount]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");
    
    if(amount == 0)
        return ErrorMsg(playerid, "Jumlah tidak boleh 0!");

    GivePlayerMoneyEx(targetid, amount);

    SuccessMsg(playerid, "Anda telah memberikan $%d kepada %s", amount, PlayerData[targetid][pName]);
    InfoMsg(targetid, "Admin %s telah memberikan $%d kepada Anda", PlayerData[playerid][pName], amount);
    return 1;
}

CMD:setlevel(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 3) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid, level;
    if(sscanf(params, "ud", targetid, level))
        return UsageMsg(playerid, "/setlevel [playerid/name] [level]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");
    
    if(level < 1 || level > 999)
        return ErrorMsg(playerid, "Level harus antara 1-999!");

    PlayerData[targetid][pLevel] = level;

    SuccessMsg(playerid, "Level %s telah diset menjadi %d", PlayerData[targetid][pName], level);
    InfoMsg(targetid, "Admin %s telah mengubah level Anda menjadi %d", PlayerData[playerid][pName], level);
    return 1;
}

CMD:makeadmin(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 5) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid, level;
    if(sscanf(params, "ud", targetid, level))
        return UsageMsg(playerid, "/makeadmin [playerid/name] [level 0-5]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");
    
    if(level < 0 || level > 5)
        return ErrorMsg(playerid, "Level admin harus antara 0-5!");

    PlayerData[targetid][pAdmin] = level;

    new string[128];
    format(string, sizeof(string), "[ADMIN] %s telah menjadikan %s sebagai admin level %d", 
        PlayerData[playerid][pName], PlayerData[targetid][pName], level);
    SendClientMessageToAll(COLOR_RED, string);
    return 1;
}

CMD:a(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    if(isnull(params))
        return UsageMsg(playerid, "/a [message]");

    new string[144];
    format(string, sizeof(string), "[ADMIN CHAT] %s (Level %d): %s", 
        PlayerData[playerid][pName], PlayerData[playerid][pAdmin], params);
    
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
    
    format(string, sizeof(string), "[ANNOUNCEMENT] %s", params);
    SendClientMessageToAll(COLOR_YELLOW, string);
    
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
    VehicleData[vehicleid][vHealth] = 1000.0;
    
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

CMD:freeze(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid;
    if(sscanf(params, "u", targetid))
        return UsageMsg(playerid, "/freeze [playerid/name]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    TogglePlayerControllable(targetid, false);
    
    SuccessMsg(playerid, "Anda telah freeze %s", PlayerData[targetid][pName]);
    InfoMsg(targetid, "Anda telah di freeze oleh admin %s", PlayerData[playerid][pName]);
    return 1;
}

CMD:unfreeze(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid;
    if(sscanf(params, "u", targetid))
        return UsageMsg(playerid, "/unfreeze [playerid/name]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    TogglePlayerControllable(targetid, true);
    
    SuccessMsg(playerid, "Anda telah unfreeze %s", PlayerData[targetid][pName]);
    InfoMsg(targetid, "Anda telah di unfreeze oleh admin %s", PlayerData[playerid][pName]);
    return 1;
}

CMD:slap(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid;
    if(sscanf(params, "u", targetid))
        return UsageMsg(playerid, "/slap [playerid/name]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    SetPlayerPos(targetid, x, y, z + 5.0);
    PlayerPlaySound(targetid, 1130, 0.0, 0.0, 0.0);
    
    new string[128];
    format(string, sizeof(string), "[ADMIN] %s telah meslap %s", 
        PlayerData[playerid][pName], PlayerData[targetid][pName]);
    SendClientMessageToAll(COLOR_YELLOW, string);
    return 1;
}

CMD:spec(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    new targetid;
    if(sscanf(params, "u", targetid))
        return UsageMsg(playerid, "/spec [playerid/name]");

    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");

    if(targetid == playerid)
        return ErrorMsg(playerid, "Anda tidak bisa spectate diri sendiri!");

    TogglePlayerSpectating(playerid, true);
    
    if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER || GetPlayerState(targetid) == PLAYER_STATE_PASSENGER)
    {
        PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));
    }
    else
    {
        PlayerSpectatePlayer(playerid, targetid);
    }
    
    InfoMsg(playerid, "Spectating %s - Ketik /specoff untuk berhenti", PlayerData[targetid][pName]);
    return 1;
}

CMD:specoff(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1) 
        return ErrorMsg(playerid, "Anda tidak memiliki akses ke command ini!");

    TogglePlayerSpectating(playerid, false);
    SpawnPlayer(playerid);
    
    InfoMsg(playerid, "Spectate mode dimatikan");
    return 1;
}