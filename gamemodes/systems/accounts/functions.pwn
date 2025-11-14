// Account System - Functions
// VS:RP v1.0.4

CreateDatabaseTables()
{
    mysql_tquery(g_SQL,
        "CREATE TABLE IF NOT EXISTS `players` (\
        `id` int(11) NOT NULL AUTO_INCREMENT,\
        `username` varchar(24) NOT NULL,\
        `password` varchar(65) NOT NULL,\
        `admin` int(2) DEFAULT '0',\
        `helper` int(2) DEFAULT '0',\
        `level` int(3) DEFAULT '1',\
        `exp` int(5) DEFAULT '0',\
        `money` int(11) DEFAULT '500',\
        `bank_money` int(11) DEFAULT '1000',\
        `skin` int(3) DEFAULT '0',\
        `hunger` int(3) DEFAULT '100',\
        `thirst` int(3) DEFAULT '100',\
        `health` float DEFAULT '100',\
        `armour` float DEFAULT '0',\
        `pos_x` float DEFAULT '0',\
        `pos_y` float DEFAULT '0',\
        `pos_z` float DEFAULT '0',\
        `pos_a` float DEFAULT '0',\
        `interior` int(3) DEFAULT '0',\
        `virtual_world` int(5) DEFAULT '0',\
        `age` int(2) DEFAULT '18',\
        `gender` int(1) DEFAULT '1',\
        `origin` varchar(32) DEFAULT 'Los Santos',\
        `phone` int(8) DEFAULT '0',\
        `phone_credit` int(6) DEFAULT '0',\
        `hours` int(5) DEFAULT '0',\
        `minutes` int(2) DEFAULT '0',\
        `seconds` int(2) DEFAULT '0',\
        `job` int(2) DEFAULT '0',\
        `faction` int(2) DEFAULT '0',\
        `rank` int(2) DEFAULT '0',\
        `wanted_level` int(2) DEFAULT '0',\
        `jail_time` int(5) DEFAULT '0',\
        `muted` int(1) DEFAULT '0',\
        `muted_time` int(5) DEFAULT '0',\
        `warns` int(2) DEFAULT '0',\
        `kills` int(5) DEFAULT '0',\
        `deaths` int(5) DEFAULT '0',\
        `last_login` int(11) DEFAULT '0',\
        `register_date` int(11) DEFAULT '0',\
        PRIMARY KEY (`id`),\
        UNIQUE KEY `username` (`username`)\
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1");
}

public OnPlayerDataLoaded(playerid, race_check)
{
    if (race_check != g_MysqlRaceCheck[playerid]) return 1;

    new rows;
    cache_get_row_count(rows);

    if (rows)
    {
        cache_get_value_name(0, "password", PlayerData[playerid][pPassword], BCRYPT_HASH_LENGTH);
        cache_get_value_name_int(0, "id", PlayerData[playerid][pID]);

        new dialog_text[512];
        format(dialog_text, sizeof(dialog_text), 
            "{FFFFFF}Selamat datang kembali di {00A6FB}Village Story Roleplay{FFFFFF}!\n\n\
            {FFFF00}Username:{FFFFFF} %s\n\
            {FFFF00}Status:{FFFFFF} Akun terdaftar\n\n\
            {FFFFFF}Masukkan password untuk melanjutkan:",
            PlayerData[playerid][pName]);

        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, 
            ""SERVER_NAME_TAG" - Login", dialog_text, "Masuk", "Keluar");
    }
    else
    {
        new dialog_text[512];
        format(dialog_text, sizeof(dialog_text), 
            "{FFFFFF}Selamat datang di {00A6FB}Village Story Roleplay{FFFFFF}!\n\n\
            {FFFF00}Username:{FFFFFF} %s\n\
            {FFFF00}Status:{FFFFFF} Belum terdaftar\n\n\
            {FFFFFF}Buat password untuk memulai petualangan:\n\
            {D8E2DC}- Password harus 6-32 karakter\n\
            - Gunakan kombinasi huruf dan angka",
            PlayerData[playerid][pName]);

        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, 
            ""SERVER_NAME_TAG" - Daftar Akun", dialog_text, "Daftar", "Keluar");
    }
    return 1;
}

RegisterPlayer(playerid)
{
    if (PlayerData[playerid][pGender] == 1)
        PlayerData[playerid][pSkin] = 158;
    else
        PlayerData[playerid][pSkin] = 157;
    
    new query[512];
    mysql_format(g_SQL, query, sizeof(query), 
        "INSERT INTO `players` (`username`, `password`, `age`, `gender`, `origin`, `skin`, `register_date`) \
        VALUES ('%e', '%e', %d, %d, '%e', %d, %d)", 
        PlayerData[playerid][pName], 
        PlayerData[playerid][pPassword], 
        PlayerData[playerid][pAge], 
        PlayerData[playerid][pGender], 
        PlayerData[playerid][pOrigin],
        PlayerData[playerid][pSkin],
        gettime());

    mysql_tquery(g_SQL, query, "OnPlayerRegister", "d", playerid);
    return 1;
}

public OnPlayerRegister(playerid)
{
    PlayerData[playerid][pID] = cache_insert_id();

    ServerMsg(playerid, "Pendaftaran berhasil! Selamat datang di Village Story!");
    ServerMsg(playerid, "Anda mendapat uang awal $500 tunai dan $1000 di bank.");

    PlayerData[playerid][pLevel] = 1;
    PlayerData[playerid][pMoney] = 500;
    PlayerData[playerid][pBankMoney] = 1000;
    PlayerData[playerid][pHealth] = 100.0;
    PlayerData[playerid][pPosX] = SPAWN_X;
    PlayerData[playerid][pPosY] = SPAWN_Y;
    PlayerData[playerid][pPosZ] = SPAWN_Z;
    PlayerData[playerid][pPosA] = SPAWN_A;
    PlayerData[playerid][pLoggedIn] = true;

    TogglePlayerSpectating(playerid, false);
    SetTimerEx("SpawnPlayerProper", 100, false, "i", playerid);
    return 1;
}

public SpawnPlayerProper(playerid)
{
    SpawnPlayer(playerid);
    return 1;
}

LoadPlayerData(playerid)
{
    new query[128];
    mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `id` = %d LIMIT 1", PlayerData[playerid][pID]);
    mysql_tquery(g_SQL, query, "OnPlayerDataLoad", "d", playerid);
    return 1;
}

public OnPlayerDataLoad(playerid)
{
    cache_get_value_name_int(0, "admin", PlayerData[playerid][pAdmin]);
    cache_get_value_name_int(0, "helper", PlayerData[playerid][pHelper]);
    cache_get_value_name_int(0, "level", PlayerData[playerid][pLevel]);
    cache_get_value_name_int(0, "exp", PlayerData[playerid][pExp]);
    cache_get_value_name_int(0, "money", PlayerData[playerid][pMoney]);
    cache_get_value_name_int(0, "bank_money", PlayerData[playerid][pBankMoney]);
    cache_get_value_name_int(0, "skin", PlayerData[playerid][pSkin]);
    cache_get_value_name_int(0, "hunger", PlayerData[playerid][pHunger]);
    cache_get_value_name_int(0, "thirst", PlayerData[playerid][pThirst]);
    cache_get_value_name_float(0, "health", PlayerData[playerid][pHealth]);
    cache_get_value_name_float(0, "armour", PlayerData[playerid][pArmour]);
    cache_get_value_name_float(0, "pos_x", PlayerData[playerid][pPosX]);
    cache_get_value_name_float(0, "pos_y", PlayerData[playerid][pPosY]);
    cache_get_value_name_float(0, "pos_z", PlayerData[playerid][pPosZ]);
    cache_get_value_name_float(0, "pos_a", PlayerData[playerid][pPosA]);
    cache_get_value_name_int(0, "interior", PlayerData[playerid][pInterior]);
    cache_get_value_name_int(0, "virtual_world", PlayerData[playerid][pVirtualWorld]);
    cache_get_value_name_int(0, "age", PlayerData[playerid][pAge]);
    cache_get_value_name_int(0, "gender", PlayerData[playerid][pGender]);
    cache_get_value_name(0, "origin", PlayerData[playerid][pOrigin], 32);
    cache_get_value_name_int(0, "hours", PlayerData[playerid][pHours]);
    cache_get_value_name_int(0, "minutes", PlayerData[playerid][pMinutes]);
    cache_get_value_name_int(0, "seconds", PlayerData[playerid][pSeconds]);
    cache_get_value_name_int(0, "job", PlayerData[playerid][pJob]);

    new query[256];
    mysql_format(g_SQL, query, sizeof(query), "UPDATE `players` SET `last_login` = %d WHERE `id` = %d", gettime(), PlayerData[playerid][pID]);
    mysql_tquery(g_SQL, query);

    PlayerData[playerid][pLoggedIn] = true;

    ServerMsg(playerid, "Selamat datang kembali di Village Story Roleplay!");
    ServerMsg(playerid, "Selalu ikuti peraturan yang sudah tertera, %s!", PlayerData[playerid][pName]);

    TogglePlayerSpectating(playerid, false);
    SetTimerEx("SpawnPlayerProper", 100, false, "i", playerid);
    return 1;
}

public SavePlayerData(playerid)
{
    if (!PlayerData[playerid][pLoggedIn]) return 0;

    new query[2048];
    new Float:x, Float:y, Float:z, Float:a, Float:health, Float:armour;
    
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    GetPlayerHealth(playerid, health);
    GetPlayerArmour(playerid, armour);

    mysql_format(g_SQL, query, sizeof(query), 
        "UPDATE `players` SET \
        `admin` = %d, `helper` = %d, `level` = %d, `exp` = %d, \
        `money` = %d, `bank_money` = %d, `skin` = %d, \
        `hunger` = %d, `thirst` = %d, \
        `health` = %.2f, `armour` = %.2f, \
        `pos_x` = %.4f, `pos_y` = %.4f, `pos_z` = %.4f, `pos_a` = %.4f, \
        `interior` = %d, `virtual_world` = %d, \
        `hours` = %d, `minutes` = %d, `seconds` = %d, \
        `job` = %d \
        WHERE `id` = %d",
        PlayerData[playerid][pAdmin], PlayerData[playerid][pHelper],
        PlayerData[playerid][pLevel], PlayerData[playerid][pExp],
        PlayerData[playerid][pMoney], PlayerData[playerid][pBankMoney],
        PlayerData[playerid][pSkin], PlayerData[playerid][pHunger],
        PlayerData[playerid][pThirst], health, armour, x, y, z, a,
        PlayerData[playerid][pInterior], PlayerData[playerid][pVirtualWorld],
        PlayerData[playerid][pHours], PlayerData[playerid][pMinutes],
        PlayerData[playerid][pSeconds], PlayerData[playerid][pJob],
        PlayerData[playerid][pID]);

    mysql_tquery(g_SQL, query);
    return 1;
}

ResetPlayerData(playerid)
{
    PlayerData[playerid][pID] = 0;
    PlayerData[playerid][pName][0] = EOS;
    PlayerData[playerid][pPassword][0] = EOS;
    PlayerData[playerid][pAdmin] = 0;
    PlayerData[playerid][pLevel] = 1;
    PlayerData[playerid][pMoney] = 0;
    PlayerData[playerid][pBankMoney] = 0;
    PlayerData[playerid][pSkin] = 0;
    PlayerData[playerid][pHunger] = 100;
    PlayerData[playerid][pThirst] = 100;
    PlayerData[playerid][pHealth] = 100.0;
    PlayerData[playerid][pPosX] = 0.0;
    PlayerData[playerid][pPosY] = 0.0;
    PlayerData[playerid][pPosZ] = 0.0;
    PlayerData[playerid][pLoggedIn] = false;
    PlayerData[playerid][pSpawned] = false;
    PlayerData[playerid][pLoginAttempts] = 0;
    PlayerData[playerid][pHudVisible] = false;
    PlayerData[playerid][pDisconnectLabel] = Text3D:INVALID_3DTEXT_ID;
    return 1;
}

public OnPasswordHashed(playerid, hashid)
{
    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash);

    format(PlayerData[playerid][pPassword], BCRYPT_HASH_LENGTH, "%s", hash);

    new dialog_text[256];
    format(dialog_text, sizeof(dialog_text),
        "{FFFFFF}Tentukan umur karakter Anda:\n\n\
        Masukkan umur karakter (15-80 tahun):");

    SuccessMsg(playerid, "Password berhasil dibuat!");

    ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, 
        ""SERVER_NAME_TAG" - Umur Karakter", dialog_text, "Lanjut", "Kembali");
    return 1;
}

public OnPasswordChecked(playerid, bool:success)
{
    if (!success)
    {
        PlayerData[playerid][pLoginAttempts]++;

        if (PlayerData[playerid][pLoginAttempts] >= 3)
        {
            ErrorMsg(playerid, "Terlalu banyak percobaan login gagal. Anda telah dikick.");
            SetTimerEx("KickPlayer", 500, false, "i", playerid);
            return 1;
        }

        new dialog_text[512];
        format(dialog_text, sizeof(dialog_text), 
            "{FFFFFF}Selamat datang kembali di {00A6FB}Village Story Roleplay{FFFFFF}!\n\n\
            {FFFF00}Username:{FFFFFF} %s\n\
            {FF0000}ERROR:{FFFFFF} Password salah!\n\
            {FFFF00}Sisa percobaan:{FFFFFF} %d kali\n\n\
            {FFFFFF}Masukkan password yang benar:",
            PlayerData[playerid][pName], 3 - PlayerData[playerid][pLoginAttempts]);

        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, 
            ""SERVER_NAME_TAG" - Login", dialog_text, "Masuk", "Keluar");
    }
    else
    {
        LoadPlayerData(playerid);
    }
    return 1;
}

public KickPlayer(playerid)
{
    return Kick(playerid);
}