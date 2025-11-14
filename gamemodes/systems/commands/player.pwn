// Player Commands
// VS:RP v1.0.4

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
    }

    new gender_text[16];
    format(gender_text, sizeof(gender_text), "%s", 
        (PlayerData[playerid][pGender] == 1) ? "Laki-laki" : "Perempuan");

    new string[1024];
    format(string, sizeof(string),
        "Kategori\tData\n\
        Nama\t: %s\n\
        Exp\t: %d\n\
        Level\t: %d\n\
        Umur\t: %d tahun\n\
        Jenis Kelamin\t: %s\n\
        Asal Daerah\t: %s\n\
        Uang Tunai\t: "COLOR_HEX_GREEN"$%d\n\
        Uang Bank\t: "COLOR_HEX_GREEN"$%d\n\
        Pekerjaan\t: %s\n\
        Total Online\t: %d jam %d menit",
        PlayerData[playerid][pName],
        PlayerData[playerid][pExp],
        PlayerData[playerid][pLevel],
        PlayerData[playerid][pAge],
        gender_text,
        PlayerData[playerid][pOrigin],
        PlayerData[playerid][pMoney],
        PlayerData[playerid][pBankMoney],
        jobname,
        PlayerData[playerid][pHours], PlayerData[playerid][pMinutes]);

    ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_TABLIST_HEADERS, ""SERVER_NAME_TAG" - Informasi Karakter", string, "Tutup", "");
    return 1;
}

CMD:help(playerid, params[])
{
    new helpText[800];
    format(helpText, sizeof(helpText),
        "Kategori\tPerintah\n\
        Dasar\t/stats, /mypos, /help, /hud\n\
        Survival\t/eat, /drink\n\
        Sosial\t/me, /do, /ooc");

    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_TABLIST_HEADERS, ""SERVER_NAME_TAG" - Bantuan", helpText, "Tutup", "");
    return 1;
}

CMD:ooc(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    if (isnull(params)) return UsageMsg(playerid, "/ooc [pesan]");

    new string[128];
    format(string, sizeof(string), "[OOC] %s: %s", PlayerData[playerid][pName], params);
    SendClientMessage(playerid, COLOR_GRAY, string);
    return 1;
}

CMD:me(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    if (isnull(params)) return UsageMsg(playerid, "/me [aksi]");

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
    if (!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    if (isnull(params)) return UsageMsg(playerid, "/do [deskripsi]");

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

CMD:mypos(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    SendClientMessageEx(playerid, COLOR_WHITE, "Posisi: X: %.2f | Y: %.2f | Z: %.2f | Angle: %.2f", x, y, z, a);
    return 1;
}

CMD:eat(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if(PlayerData[playerid][pHunger] >= 100)
        return ErrorMsg(playerid, "Anda sudah kenyang!");
    
    PlayerData[playerid][pHunger] += 25;
    if(PlayerData[playerid][pHunger] > 100) PlayerData[playerid][pHunger] = 100;
    
    UpdateHungerThirstHUD(playerid);
    
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
    
    SuccessMsg(playerid, "Anda telah makan. Rasa lapar berkurang!");
    return 1;
}

CMD:drink(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if(PlayerData[playerid][pThirst] >= 100)
        return ErrorMsg(playerid, "Anda sudah tidak haus!");
    
    PlayerData[playerid][pThirst] += 30;
    if(PlayerData[playerid][pThirst] > 100) PlayerData[playerid][pThirst] = 100;
    
    UpdateHungerThirstHUD(playerid);
    
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
    
    SuccessMsg(playerid, "Anda telah minum. Rasa haus berkurang!");
    return 1;
}

CMD:hud(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
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