// Core System - Callbacks
// VS:RP v1.0.4

public OnPlayerConnect(playerid)
{
    g_MysqlRaceCheck[playerid]++;
    ResetPlayerData(playerid);

    TogglePlayerSpectating(playerid, true);
    SetPlayerColor(playerid, COLOR_MUTED);

    GetPlayerName(playerid, PlayerData[playerid][pName], MAX_PLAYER_NAME);

    ShowTextdrawsForPlayer(playerid);
    CreatePlayerHUD(playerid);

    new query[128];
    mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `username` = '%e' LIMIT 1", PlayerData[playerid][pName]);
    mysql_tquery(g_SQL, query, "OnPlayerDataLoaded", "dd", playerid, g_MysqlRaceCheck[playerid]);
    
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if (PlayerData[playerid][pLoggedIn])
    {
        GetPlayerPos(playerid, PlayerData[playerid][pPosX], PlayerData[playerid][pPosY], PlayerData[playerid][pPosZ]);
        GetPlayerFacingAngle(playerid, PlayerData[playerid][pPosA]);
        SavePlayerData(playerid);
        
        new Float:x, Float:y, Float:z;
        new labeltext[128], reasontext[32];
        GetPlayerPos(playerid, x, y, z);
        
        switch(reason)
        {
            case 0: reasontext = "Timeout/Crash";
            case 1: reasontext = "Leaving";
            case 2: reasontext = "Kicked/Banned";
        }
        
        format(labeltext, sizeof(labeltext), "{FF6B6B}%s telah disconnect\n{FFFFFF}Alasan: %s", PlayerData[playerid][pName], reasontext);
        PlayerData[playerid][pDisconnectLabel] = CreateDynamic3DTextLabel(labeltext, COLOR_RED, x, y, z + 0.5, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 30.0);
        
        SetTimerEx("DeleteDisconnectLabel", 30000, false, "d", _:PlayerData[playerid][pDisconnectLabel]);
    }

    DestroyPlayerHUD(playerid);
    HideTextdrawsForPlayer(playerid);

    KillTimer(PlayerSpeedometerTimer[playerid]);
    PlayerSpeedometerTimer[playerid] = 0;

    g_MysqlRaceCheck[playerid]++;
    ResetPlayerData(playerid);
    return 1;
}

forward DeleteDisconnectLabel(Text3D:labelid);
public DeleteDisconnectLabel(Text3D:labelid)
{
    if(labelid != Text3D:INVALID_3DTEXT_ID)
    {
        DestroyDynamic3DTextLabel(labelid);
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if (!PlayerData[playerid][pLoggedIn])
    {
        Kick(playerid);
        return 1;
    }

    SetPlayerSkin(playerid, PlayerData[playerid][pSkin]);
    SetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
    SetPlayerArmour(playerid, PlayerData[playerid][pArmour]);
    SetPlayerInterior(playerid, PlayerData[playerid][pInterior]);
    SetPlayerVirtualWorld(playerid, PlayerData[playerid][pVirtualWorld]);
    SetPlayerColor(playerid, COLOR_WHITE);

    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerFacingAngle(playerid, SPAWN_A);

    SetCameraBehindPlayer(playerid);
    ShowPlayerHUD(playerid);

    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);

    PlayerData[playerid][pSpawned] = true;

    InfoMsg(playerid, "Ketik /help untuk melihat perintah yang tersedia");

    return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if (!PlayerData[playerid][pLoggedIn]) return 0;
    if(PlayerData[playerid][pAdmin] < 1) return ErrorMsg(playerid, "Anda tidak memiliki akses untuk teleport!");
    
    SetPlayerPos(playerid, fX, fY, fZ);
    InfoMsg(playerid, "Teleported to X: %.2f | Y: %.2f | Z: %.2f", fX, fY, fZ);
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    if (result == -1)
    {
        ErrorMsg(playerid, "Perintah tidak dikenali. Ketik /help untuk bantuan.");
    }
    return 1;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if (!PlayerData[playerid][pLoggedIn]) 
    {
        ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
        return 0;
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_REGISTER:
        {
            if (!response) return Kick(playerid);

            if (strlen(inputtext) < MIN_PASSWORD_LENGTH || strlen(inputtext) > MAX_PASSWORD_LENGTH)
            {
                new dialog_text[512];
                format(dialog_text, sizeof(dialog_text), 
                    "{FFFFFF}Selamat datang di {00A6FB}Village Story Roleplay{FFFFFF}!\n\n\
                    {FFFF00}Username:{FFFFFF} %s\n\
                    {FF0000}ERROR:{FFFFFF} Password harus 6-32 karakter!\n\n\
                    {FFFFFF}Buat password untuk memulai petualangan:\n\
                    {D8E2DC}- Password harus 6-32 karakter\n\
                    - Gunakan kombinasi huruf dan angka",
                    PlayerData[playerid][pName]);

                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, 
                    ""SERVER_NAME_TAG" - Daftar Akun", dialog_text, "Daftar", "Keluar");
                return 1;
            }

            bcrypt_hash(playerid, "OnPasswordHashed", inputtext, BCRYPT_COST);
        }

        case DIALOG_LOGIN:
        {
            if (!response) return Kick(playerid);
            bcrypt_verify(playerid, "OnPasswordChecked", inputtext, PlayerData[playerid][pPassword]);
        }

        case DIALOG_AGE:
        {
            if (!response)
            {
                new dialog_text[512];
                format(dialog_text, sizeof(dialog_text), 
                    "{FFFFFF}Selamat datang di {00A6FB}Village Story Roleplay{FFFFFF}!\n\n\
                    {FFFF00}Username:{FFFFFF} %s\n\
                    {FFFF00}Status:{FFFFFF} Belum terdaftar\n\n\
                    {FFFFFF}Buat password untuk memulai petualangan:\n\
                    {D8E2DC}- Password harus 6-32 karakter",
                    PlayerData[playerid][pName]);

                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, 
                    ""SERVER_NAME_TAG" - Daftar Akun", dialog_text, "Daftar", "Keluar");
                return 1;
            }

            new age = strval(inputtext);
            if (age < MIN_AGE || age > MAX_AGE)
            {
                new dialog_text[256];
                format(dialog_text, sizeof(dialog_text),
                    "{FFFFFF}Tentukan umur karakter Anda:\n\n\
                    {FF0000}ERROR:{FFFFFF} Umur harus antara {FFFF00}15-80 tahun{FFFFFF}!\n\n\
                    Masukkan umur karakter:");

                ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, 
                    ""SERVER_NAME_TAG" - Umur Karakter", dialog_text, "Lanjut", "Kembali");
                return 1;
            }

            PlayerData[playerid][pAge] = age;

            new dialog_text[256];
            format(dialog_text, sizeof(dialog_text),
                "{FFFFFF}Pilih jenis kelamin karakter Anda:");

            ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_MSGBOX, 
                ""SERVER_NAME_TAG" - Jenis Kelamin", dialog_text, "Laki-laki", "Perempuan");
        }

        case DIALOG_GENDER:
        {
            PlayerData[playerid][pGender] = response ? 1 : 2;

            new dialog_text[512];
            format(dialog_text, sizeof(dialog_text),
                "{FFFFFF}Los Santos\n\
                {FFFFFF}San Fiero\n\
                {FFFFFF}Las Venturas");

            ShowPlayerDialog(playerid, DIALOG_ORIGIN, DIALOG_STYLE_LIST, 
                ""SERVER_NAME_TAG" - Asal Daerah", dialog_text, "Pilih", "");
        }

        case DIALOG_ORIGIN:
        {
            new origins[][32] = {"Los Santos", "San Fiero", "Las Venturas"};
            format(PlayerData[playerid][pOrigin], 32, "%s", origins[listitem]);
            RegisterPlayer(playerid);
        }
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(!PlayerData[playerid][pLoggedIn]) return 1;
    
    if(newstate == PLAYER_STATE_DRIVER)
    {
        SetTimerEx("DelayedShowSpeedometer", 200, false, "d", playerid);
        KillTimer(PlayerSpeedometerTimer[playerid]);
        PlayerSpeedometerTimer[playerid] = SetTimerEx("UpdateSpeedometer", 50, true, "d", playerid);
    }
    else if(oldstate == PLAYER_STATE_DRIVER)
    {
        HideSpeedometer(playerid);
        KillTimer(PlayerSpeedometerTimer[playerid]);
        PlayerSpeedometerTimer[playerid] = 0;
    }
    
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & KEY_UP)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
            
            if(doors == 1)
            {
                SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
                ErrorMsg(playerid, "Kendaraan terkunci! Buka kunci terlebih dahulu dengan /unlock");
                return 1;
            }
        }
    }
    
    return 1;
}