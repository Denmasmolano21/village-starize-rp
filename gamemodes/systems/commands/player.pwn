// Player Commands
// VS:RP v1.0.4 - IMPROVED

CMD:stats(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");

    new jobname[32];
    switch (PlayerData[playerid][pJob])
    {
        case JOB_NONE: jobname = "Pengangguran";
        case JOB_FARMER: jobname = "Petani";
        case JOB_FISHERMAN: jobname = "Nelayan";
        case JOB_MINER: jobname = "Penambang";
        case JOB_LUMBERJACK: jobname = "Penebang Kayu";
        default: jobname = "Unknown";
    }

    new gender_text[16];
    format(gender_text, sizeof(gender_text), "%s", 
        (PlayerData[playerid][pGender] == 1) ? "Laki-laki" : "Perempuan");
    
    new required_exp = PlayerData[playerid][pLevel] * 10;

    new string[1024];
    format(string, sizeof(string),
        "Kategori\tData\n\
        Nama\t: %s\n\
        Level\t: %d\n\
        Exp\t: %d / %d\n\
        Umur\t: %d tahun\n\
        Jenis Kelamin\t: %s\n\
        Asal Daerah\t: %s\n\
        Uang Tunai\t: "COLOR_HEX_GREEN"$%s\n\
        Uang Bank\t: "COLOR_HEX_GREEN"$%s\n\
        Pekerjaan\t: %s\n\
        Total Online\t: %d jam %d menit\n\
        Kills / Deaths\t: %d / %d",
        PlayerData[playerid][pName],
        PlayerData[playerid][pLevel],
        PlayerData[playerid][pExp], required_exp,
        PlayerData[playerid][pAge],
        gender_text,
        PlayerData[playerid][pOrigin],
        FormatNumber(PlayerData[playerid][pMoney]),
        FormatNumber(PlayerData[playerid][pBankMoney]),
        jobname,
        PlayerData[playerid][pHours], PlayerData[playerid][pMinutes],
        PlayerData[playerid][pKills], PlayerData[playerid][pDeaths]);

    ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_TABLIST_HEADERS, ""SERVER_NAME_TAG" - Informasi Karakter", string, "Tutup", "");
    return 1;
}

CMD:help(playerid, params[])
{
    new helpText[1200];
    format(helpText, sizeof(helpText),
        "Kategori\tPerintah\n\
        "COLOR_HEX_BLUE"[DASAR]\n\
        Informasi\t/stats, /mypos, /time\n\
        Interface\t/hud, /help\n\n\
        "COLOR_HEX_GREEN"[SURVIVAL]\n\
        Kebutuhan\t/eat, /drink\n\
        Status\t/hunger, /thirst\n\n\
        "COLOR_HEX_PURPLE"[SOSIAL]\n\
        Roleplay\t/me, /do, /ame, /ado\n\
        Chat\t/ooc, /b, /s, /w\n\n\
        "COLOR_HEX_ORANGE"[KENDARAAN]\n\
        Kontrol\t/engine, /lock, /unlock\n\
        Info\t/carhelp\n\n\
        "COLOR_HEX_CYAN"[EKONOMI]\n\
        ATM\t/atm, /transfer, /balance\n\n\
        "COLOR_HEX_YELLOW"[INFO]\n\
        Server\tKetik /credits untuk info server");

    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_TABLIST_HEADERS, ""SERVER_NAME_TAG" - Bantuan", helpText, "Tutup", "");
    return 1;
}

CMD:time(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");

    new hour, minute, second;
    gettime(hour, minute, second);
    
    InfoMsg(playerid, "Waktu Server: %02d:%02d:%02d", hour, minute, second);
    InfoMsg(playerid, "Total Online: %d jam %d menit %d detik", PlayerData[playerid][pHours], PlayerData[playerid][pMinutes], PlayerData[playerid][pSeconds]);
    return 1;
}

CMD:balance(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");

    InfoMsg(playerid, "Uang Tunai: $%s | Uang Bank: $%s", FormatNumber(PlayerData[playerid][pMoney]), FormatNumber(PlayerData[playerid][pBankMoney]));
    return 1;
}

CMD:ooc(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if (isnull(params)) 
        return UsageMsg(playerid, "/ooc [pesan]");

    new string[144];
    format(string, sizeof(string), "(( [OOC] %s: %s ))", PlayerData[playerid][pName], params);
    SendClientMessageToAll(COLOR_GRAY, string);
    return 1;
}

CMD:b(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if (isnull(params)) 
        return UsageMsg(playerid, "/b [pesan]");

    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "%s (( %s ))", PlayerData[playerid][pName], params);
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 10.0, x, y, z))
        {
            SendClientMessage(i, COLOR_GRAY, string);
        }
    }
    return 1;
}

CMD:s(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if (isnull(params)) 
        return UsageMsg(playerid, "/s [pesan]");

    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "%s berteriak: %s!!", PlayerData[playerid][pName], params);
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 50.0, x, y, z))
        {
            SendClientMessage(i, COLOR_YELLOW, string);
        }
    }
    return 1;
}

CMD:w(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    new targetid, message[90];
    if (sscanf(params, "us[90]", targetid, message)) 
        return UsageMsg(playerid, "/w [playerid/name] [pesan]");
    
    if(!IsPlayerConnected(targetid))
        return ErrorMsg(playerid, "Player tidak online!");
    
    if(targetid == playerid)
        return ErrorMsg(playerid, "Anda tidak bisa whisper ke diri sendiri!");
    
    if(!IsPlayerInRangeOfPlayer(playerid, targetid, 5.0))
        return ErrorMsg(playerid, "Player terlalu jauh!");

    new string[144];
    format(string, sizeof(string), "%s berbisik: %s", PlayerData[playerid][pName], message);
    SendClientMessage(targetid, COLOR_YELLOW, string);
    
    format(string, sizeof(string), "Whisper ke %s: %s", PlayerData[targetid][pName], message);
    SendClientMessage(playerid, COLOR_YELLOW, string);
    return 1;
}

CMD:me(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if (isnull(params)) 
        return UsageMsg(playerid, "/me [aksi]");

    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "* %s %s", PlayerData[playerid][pName], params);
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    return 1;
}

CMD:do(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if (isnull(params)) 
        return UsageMsg(playerid, "/do [deskripsi]");

    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "* %s (( %s ))", params, PlayerData[playerid][pName]);
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    return 1;
}

CMD:ame(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if (isnull(params)) 
        return UsageMsg(playerid, "/ame [aksi]");

    new string[128];
    format(string, sizeof(string), "* %s %s", PlayerData[playerid][pName], params);
    
    if(PlayerData[playerid][pDisconnectLabel] != Text3D:INVALID_3DTEXT_ID)
    {
        DestroyDynamic3DTextLabel(PlayerData[playerid][pDisconnectLabel]);
    }
    
    PlayerData[playerid][pDisconnectLabel] = CreateDynamic3DTextLabel(string, COLOR_PURPLE, 0.0, 0.0, 0.3, 20.0, playerid);
    SetTimerEx("DeleteDisconnectLabel", 5000, false, "d", _:PlayerData[playerid][pDisconnectLabel]);
    
    return 1;
}

CMD:ado(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if (isnull(params)) 
        return UsageMsg(playerid, "/ado [deskripsi]");

    new string[128];
    format(string, sizeof(string), "* %s (( %s ))", params, PlayerData[playerid][pName]);
    
    if(PlayerData[playerid][pDisconnectLabel] != Text3D:INVALID_3DTEXT_ID)
    {
        DestroyDynamic3DTextLabel(PlayerData[playerid][pDisconnectLabel]);
    }
    
    PlayerData[playerid][pDisconnectLabel] = CreateDynamic3DTextLabel(string, COLOR_PURPLE, 0.0, 0.0, 0.3, 20.0, playerid);
    SetTimerEx("DeleteDisconnectLabel", 5000, false, "d", _:PlayerData[playerid][pDisconnectLabel]);
    
    return 1;
}

CMD:mypos(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    new interior = GetPlayerInterior(playerid);
    new vw = GetPlayerVirtualWorld(playerid);
    
    InfoMsg(playerid, "Posisi: X: %.2f | Y: %.2f | Z: %.2f | Angle: %.2f", x, y, z, a);
    InfoMsg(playerid, "Interior: %d | Virtual World: %d", interior, vw);
    return 1;
}

CMD:eat(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if(PlayerData[playerid][pHunger] >= 100)
        return ErrorMsg(playerid, "Anda sudah kenyang!");
    
    // Check if player has food item (implement inventory later)
    PlayerData[playerid][pHunger] += 25;
    if(PlayerData[playerid][pHunger] > 100) PlayerData[playerid][pHunger] = 100;
    
    UpdateHungerThirstHUD(playerid);
    
    // Heal player slightly
    new Float:health;
    GetPlayerHealth(playerid, health);
    if(health < 100.0)
    {
        SetPlayerHealth(playerid, health + 5.0);
    }
    
    ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
    
    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "* %s memakan sesuatu", PlayerData[playerid][pName]);
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    
    SuccessMsg(playerid, "Anda telah makan. Rasa lapar: %d/100 (+25)", PlayerData[playerid][pHunger]);
    return 1;
}

CMD:drink(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if(PlayerData[playerid][pThirst] >= 100)
        return ErrorMsg(playerid, "Anda sudah tidak haus!");
    
    PlayerData[playerid][pThirst] += 30;
    if(PlayerData[playerid][pThirst] > 100) PlayerData[playerid][pThirst] = 100;
    
    UpdateHungerThirstHUD(playerid);
    
    ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 4.1, 0, 0, 0, 0, 0, 1);
    
    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "* %s meminum sesuatu", PlayerData[playerid][pName]);
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    
    SuccessMsg(playerid, "Anda telah minum. Rasa haus: %d/100 (+30)", PlayerData[playerid][pThirst]);
    return 1;
}

CMD:hunger(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    new color = COLOR_WHITE;
    if(PlayerData[playerid][pHunger] <= 20) color = COLOR_RED;
    else if(PlayerData[playerid][pHunger] <= 50) color = COLOR_YELLOW;
    
    SendClientMessageEx(playerid, color, "[HUNGER] Level: %d/100", PlayerData[playerid][pHunger]);
    return 1;
}

CMD:thirst(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    new color = COLOR_WHITE;
    if(PlayerData[playerid][pThirst] <= 20) color = COLOR_RED;
    else if(PlayerData[playerid][pThirst] <= 50) color = COLOR_YELLOW;
    
    SendClientMessageEx(playerid, color, "[THIRST] Level: %d/100", PlayerData[playerid][pThirst]);
    return 1;
}

CMD:hud(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if(PlayerData[playerid][pHudVisible])
    {
        HidePlayerHUD(playerid);
        InfoMsg(playerid, "HUD telah disembunyikan. Ketik /hud lagi untuk menampilkan.");
    }
    else
    {
        ShowPlayerHUD(playerid);
        InfoMsg(playerid, "HUD telah ditampilkan. Ketik /hud lagi untuk menyembunyikan.");
    }
    return 1;
}

CMD:carhelp(playerid, params[])
{
    new helpText[600];
    format(helpText, sizeof(helpText),
        "{FFFFFF}=== BANTUAN KENDARAAN ===\n\n\
        {FFFF00}/engine{FFFFFF} - Nyalakan/matikan mesin\n\
        {FFFF00}/lock{FFFFFF} - Kunci kendaraan\n\
        {FFFF00}/unlock{FFFFFF} - Buka kunci kendaraan\n\n\
        {00A6FB}INFO:{FFFFFF}\n\
        - Kendaraan harus dibuka kuncinya sebelum menyalakan mesin\n\
        - Speedometer otomatis muncul saat menjadi driver\n\
        - Perhatikan fuel dan health kendaraan");

    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""SERVER_NAME_TAG" - Bantuan Kendaraan", helpText, "Tutup", "");
    return 1;
}

CMD:credits(playerid, params[])
{
    new creditText[600];
    format(creditText, sizeof(creditText),
        "{FFFFFF}=== VILLAGE STORY ROLEPLAY ===\n\n\
        {00A6FB}Version:{FFFFFF} %s\n\
        {00A6FB}Server:{FFFFFF} Village Story RP\n\
        {00A6FB}Mode:{FFFFFF} Roleplay\n\n\
        {FFFF00}Credits:\n\
        {FFFFFF}- SA-MP Team\n\
        - YSI Team\n\
        - Community Contributors\n\n\
        {08CB00}Selamat bermain!",
        SERVER_VERSION);

    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""SERVER_NAME_TAG" - Credits", creditText, "Tutup", "");
    return 1;
}

// Utility Functions
stock FormatNumber(number)
{
    static result[32];

    new str[32], tmp[32];
    format(str, sizeof str, "%d", number);

    new len = strlen(str);
    new idx = 0;
    new count = 0;

    for (new i = len - 1; i >= 0; i--)
    {
        tmp[idx++] = str[i];
        count++;

        if (count == 3 && i > 0)
        {
            tmp[idx++] = '.';
            count = 0;
        }
    }

    tmp[idx] = '\0';

    // Balikkan string (karena kita membangun dari belakang)
    new fidx = 0;
    for (new i = strlen(tmp) - 1; i >= 0; i--)
    {
        result[fidx++] = tmp[i];
    }

    result[fidx] = '\0';
    return result;
}

stock IsPlayerInRangeOfPlayer(playerid, targetid, Float:range)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    return IsPlayerInRangeOfPoint(playerid, range, x, y, z);
}