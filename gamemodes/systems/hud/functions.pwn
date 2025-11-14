// HUD System - Functions
// VS:RP v1.0.4

CreateGlobalTextdraws()
{
    ServerNameTD[0] = TextDrawCreate(291.000, 3.000, "V");
    TextDrawLetterSize(ServerNameTD[0], 0.569, 2.400);
    TextDrawAlignment(ServerNameTD[0], 1);
    TextDrawColor(ServerNameTD[0], COLOR_BLUE);
    TextDrawSetShadow(ServerNameTD[0], 0);
    TextDrawSetOutline(ServerNameTD[0], 1);
    TextDrawBackgroundColor(ServerNameTD[0], 255);
    TextDrawFont(ServerNameTD[0], 3);
    TextDrawSetProportional(ServerNameTD[0], 1);

    ServerNameTD[1] = TextDrawCreate(305.000, 3.000, "S");
    TextDrawLetterSize(ServerNameTD[1], 0.569, 2.400);
    TextDrawAlignment(ServerNameTD[1], 1);
    TextDrawColor(ServerNameTD[1], COLOR_BLUE);
    TextDrawSetShadow(ServerNameTD[1], 0);
    TextDrawSetOutline(ServerNameTD[1], 1);
    TextDrawBackgroundColor(ServerNameTD[1], 255);
    TextDrawFont(ServerNameTD[1], 3);
    TextDrawSetProportional(ServerNameTD[1], 1);

    ServerNameTD[2] = TextDrawCreate(317.000, 3.000, "R");
    TextDrawLetterSize(ServerNameTD[2], 0.569, 2.400);
    TextDrawAlignment(ServerNameTD[2], 1);
    TextDrawColor(ServerNameTD[2], -1);
    TextDrawSetShadow(ServerNameTD[2], 0);
    TextDrawSetOutline(ServerNameTD[2], 1);
    TextDrawBackgroundColor(ServerNameTD[2], 255);
    TextDrawFont(ServerNameTD[2], 3);
    TextDrawSetProportional(ServerNameTD[2], 1);

    ServerNameTD[3] = TextDrawCreate(330.000, 3.000, "P");
    TextDrawLetterSize(ServerNameTD[3], 0.569, 2.400);
    TextDrawAlignment(ServerNameTD[3], 1);
    TextDrawColor(ServerNameTD[3], -1);
    TextDrawSetShadow(ServerNameTD[3], 0);
    TextDrawSetOutline(ServerNameTD[3], 1);
    TextDrawBackgroundColor(ServerNameTD[3], 255);
    TextDrawFont(ServerNameTD[3], 3);
    TextDrawSetProportional(ServerNameTD[3], 1);

    ServerNameTD[4] = TextDrawCreate(274.000, 15.000, "Village Story Roleplay");
    TextDrawLetterSize(ServerNameTD[4], 0.300, 1.500);
    TextDrawAlignment(ServerNameTD[4], 1);
    TextDrawColor(ServerNameTD[4], -26);
    TextDrawSetShadow(ServerNameTD[4], 0);
    TextDrawSetOutline(ServerNameTD[4], 1);
    TextDrawBackgroundColor(ServerNameTD[4], 255);
    TextDrawFont(ServerNameTD[4], 0);
    TextDrawSetProportional(ServerNameTD[4], 1);
}

DestroyGlobalTextdraws()
{
    for(new i = 0; i < sizeof(ServerNameTD); i++)
    {
        TextDrawDestroy(ServerNameTD[i]);
    }
}

ShowTextdrawsForPlayer(playerid)
{
    for(new i = 0; i < sizeof(ServerNameTD); i++)
    {
        TextDrawShowForPlayer(playerid, ServerNameTD[i]);
    }
}

HideTextdrawsForPlayer(playerid)
{
    for(new i = 0; i < sizeof(ServerNameTD); i++)
    {
        TextDrawHideForPlayer(playerid, ServerNameTD[i]);
    }
}

CreatePlayerHUD(playerid)
{
    BG_MINUM[playerid] = CreatePlayerTextDraw(playerid, 555.000, 130.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, BG_MINUM[playerid], 53.000, 17.000);
    PlayerTextDrawAlignment(playerid, BG_MINUM[playerid], 1);
    PlayerTextDrawColor(playerid, BG_MINUM[playerid], 200);
    PlayerTextDrawFont(playerid, BG_MINUM[playerid], 4);

    BG_MAKAN[playerid] = CreatePlayerTextDraw(playerid, 498.000, 130.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, BG_MAKAN[playerid], 52.000, 17.000);
    PlayerTextDrawAlignment(playerid, BG_MAKAN[playerid], 1);
    PlayerTextDrawColor(playerid, BG_MAKAN[playerid], 200);
    PlayerTextDrawFont(playerid, BG_MAKAN[playerid], 4);

    ICON_MINUM[playerid] = CreatePlayerTextDraw(playerid, 570.000, 133.000, "HUD:radar_diner");
    PlayerTextDrawTextSize(playerid, ICON_MINUM[playerid], -10.000, 10.000);
    PlayerTextDrawColor(playerid, ICON_MINUM[playerid], -1);
    PlayerTextDrawFont(playerid, ICON_MINUM[playerid], 4);

    ICON_MAKAN[playerid] = CreatePlayerTextDraw(playerid, 514.000, 133.000, "HUD:radar_dateFood");
    PlayerTextDrawTextSize(playerid, ICON_MAKAN[playerid], -11.000, 10.000);
    PlayerTextDrawColor(playerid, ICON_MAKAN[playerid], -1);
    PlayerTextDrawFont(playerid, ICON_MAKAN[playerid], 4);

    BAR_MINUM[playerid] = CreatePlayerTextDraw(playerid, 579.000, 133.000, "100");
    PlayerTextDrawLetterSize(playerid, BAR_MINUM[playerid], 0.200, 1.098);
    PlayerTextDrawColor(playerid, BAR_MINUM[playerid], -56);
    PlayerTextDrawSetOutline(playerid, BAR_MINUM[playerid], -1);
    PlayerTextDrawFont(playerid, BAR_MINUM[playerid], 1);

    BAR_MAKAN[playerid] = CreatePlayerTextDraw(playerid, 522.000, 133.000, "100");
    PlayerTextDrawLetterSize(playerid, BAR_MAKAN[playerid], 0.200, 1.098);
    PlayerTextDrawColor(playerid, BAR_MAKAN[playerid], -56);
    PlayerTextDrawSetOutline(playerid, BAR_MAKAN[playerid], -1);
    PlayerTextDrawFont(playerid, BAR_MAKAN[playerid], 1);

    BG_NAMA[playerid] = CreatePlayerTextDraw(playerid, 498.000, 107.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, BG_NAMA[playerid], 110.000, 21.000);
    PlayerTextDrawColor(playerid, BG_NAMA[playerid], 200);
    PlayerTextDrawFont(playerid, BG_NAMA[playerid], 4);

    NAMA_PLAYER[playerid] = CreatePlayerTextDraw(playerid, 521.000, 109.000, "Player_Name");
    PlayerTextDrawLetterSize(playerid, NAMA_PLAYER[playerid], 0.349, 1.498);
    PlayerTextDrawColor(playerid, NAMA_PLAYER[playerid], -56);
    PlayerTextDrawSetShadow(playerid, NAMA_PLAYER[playerid], 1);
    PlayerTextDrawSetOutline(playerid, NAMA_PLAYER[playerid], 1);
    PlayerTextDrawFont(playerid, NAMA_PLAYER[playerid], 0);

    BG_SPEEDOMETER[playerid] = CreatePlayerTextDraw(playerid, 517.000, 343.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, BG_SPEEDOMETER[playerid], 89.000, 87.000);
    PlayerTextDrawColor(playerid, BG_SPEEDOMETER[playerid], 200);
    PlayerTextDrawFont(playerid, BG_SPEEDOMETER[playerid], 4);

    HUD_SPEED[playerid] = CreatePlayerTextDraw(playerid, 529.000, 344.000, "HUD:radar_impound");
    PlayerTextDrawTextSize(playerid, HUD_SPEED[playerid], 18.000, 18.000);
    PlayerTextDrawColor(playerid, HUD_SPEED[playerid], -1);
    PlayerTextDrawFont(playerid, HUD_SPEED[playerid], 4);

    HUD_FUEL[playerid] = CreatePlayerTextDraw(playerid, 530.000, 367.000, "HUD:radar_spray");
    PlayerTextDrawTextSize(playerid, HUD_FUEL[playerid], 18.000, 18.000);
    PlayerTextDrawColor(playerid, HUD_FUEL[playerid], -1);
    PlayerTextDrawFont(playerid, HUD_FUEL[playerid], 4);

    HUD_HP[playerid] = CreatePlayerTextDraw(playerid, 530.000, 390.000, "HUD:radar_modGarage");
    PlayerTextDrawTextSize(playerid, HUD_HP[playerid], 14.000, 15.000);
    PlayerTextDrawColor(playerid, HUD_HP[playerid], -1);
    PlayerTextDrawFont(playerid, HUD_HP[playerid], 4);

    HUD_LOCK[playerid] = CreatePlayerTextDraw(playerid, 527.000, 409.000, "HUD:radar_light");
    PlayerTextDrawTextSize(playerid, HUD_LOCK[playerid], 19.000, 19.000);
    PlayerTextDrawColor(playerid, HUD_LOCK[playerid], -1);
    PlayerTextDrawFont(playerid, HUD_LOCK[playerid], 4);

    SPEED[playerid] = CreatePlayerTextDraw(playerid, 556.000, 348.000, "0");
    PlayerTextDrawLetterSize(playerid, SPEED[playerid], 0.229, 1.297);
    PlayerTextDrawColor(playerid, SPEED[playerid], -1);
    PlayerTextDrawSetShadow(playerid, SPEED[playerid], 1);
    PlayerTextDrawSetOutline(playerid, SPEED[playerid], 1);
    PlayerTextDrawFont(playerid, SPEED[playerid], 1);

    SPEED_MPH[playerid] = CreatePlayerTextDraw(playerid, 576.000, 348.000, "Km/h");
    PlayerTextDrawLetterSize(playerid, SPEED_MPH[playerid], 0.229, 1.297);
    PlayerTextDrawColor(playerid, SPEED_MPH[playerid], -1);
    PlayerTextDrawSetShadow(playerid, SPEED_MPH[playerid], 1);
    PlayerTextDrawSetOutline(playerid, SPEED_MPH[playerid], 1);
    PlayerTextDrawFont(playerid, SPEED_MPH[playerid], 1);

    FUEL[playerid] = CreatePlayerTextDraw(playerid, 556.000, 368.000, "100");
    PlayerTextDrawLetterSize(playerid, FUEL[playerid], 0.229, 1.297);
    PlayerTextDrawColor(playerid, FUEL[playerid], -1);
    PlayerTextDrawSetShadow(playerid, FUEL[playerid], 1);
    PlayerTextDrawSetOutline(playerid, FUEL[playerid], 1);
    PlayerTextDrawFont(playerid, FUEL[playerid], 1);

    HP[playerid] = CreatePlayerTextDraw(playerid, 556.000, 390.000, "100");
    PlayerTextDrawLetterSize(playerid, HP[playerid], 0.229, 1.297);
    PlayerTextDrawColor(playerid, HP[playerid], -1);
    PlayerTextDrawSetShadow(playerid, HP[playerid], 1);
    PlayerTextDrawSetOutline(playerid, HP[playerid], 1);
    PlayerTextDrawFont(playerid, HP[playerid], 1);

    LOCK[playerid] = CreatePlayerTextDraw(playerid, 556.000, 411.000, "UNLOCKED");
    PlayerTextDrawLetterSize(playerid, LOCK[playerid], 0.229, 1.297);
    PlayerTextDrawColor(playerid, LOCK[playerid], COLOR_GREEN);
    PlayerTextDrawSetShadow(playerid, LOCK[playerid], 1);
    PlayerTextDrawSetOutline(playerid, LOCK[playerid], 1);
    PlayerTextDrawFont(playerid, LOCK[playerid], 1);

    PERSEN_1[playerid] = CreatePlayerTextDraw(playerid, 576.000, 367.000, "0");
    PlayerTextDrawLetterSize(playerid, PERSEN_1[playerid], 0.170, 0.898);
    PlayerTextDrawColor(playerid, PERSEN_1[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_1[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_1[playerid], 1);
    PlayerTextDrawFont(playerid, PERSEN_1[playerid], 1);

    PERSEN_2[playerid] = CreatePlayerTextDraw(playerid, 580.000, 366.000, "/");
    PlayerTextDrawLetterSize(playerid, PERSEN_2[playerid], 0.188, 1.399);
    PlayerTextDrawColor(playerid, PERSEN_2[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_2[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_2[playerid], 1);
    PlayerTextDrawFont(playerid, PERSEN_2[playerid], 1);

    PERSEN_3[playerid] = CreatePlayerTextDraw(playerid, 583.000, 372.000, "0");
    PlayerTextDrawLetterSize(playerid, PERSEN_3[playerid], 0.158, 0.898);
    PlayerTextDrawColor(playerid, PERSEN_3[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_3[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_3[playerid], 1);
    PlayerTextDrawFont(playerid, PERSEN_3[playerid], 1);

    PERSEN_4[playerid] = CreatePlayerTextDraw(playerid, 576.000, 389.000, "0");
    PlayerTextDrawLetterSize(playerid, PERSEN_4[playerid], 0.170, 0.898);
    PlayerTextDrawColor(playerid, PERSEN_4[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_4[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_4[playerid], 1);
    PlayerTextDrawFont(playerid, PERSEN_4[playerid], 1);

    PERSEN_5[playerid] = CreatePlayerTextDraw(playerid, 580.000, 388.000, "/");
    PlayerTextDrawLetterSize(playerid, PERSEN_5[playerid], 0.188, 1.399);
    PlayerTextDrawColor(playerid, PERSEN_5[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_5[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_5[playerid], 1);
    PlayerTextDrawFont(playerid, PERSEN_5[playerid], 1);

    PERSEN_6[playerid] = CreatePlayerTextDraw(playerid, 583.000, 394.000, "0");
    PlayerTextDrawLetterSize(playerid, PERSEN_6[playerid], 0.170, 0.898);
    PlayerTextDrawColor(playerid, PERSEN_6[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_6[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_6[playerid], 1);
    PlayerTextDrawFont(playerid, PERSEN_6[playerid], 1);
}

DestroyPlayerHUD(playerid)
{
    PlayerTextDrawDestroy(playerid, BG_MINUM[playerid]);
    PlayerTextDrawDestroy(playerid, BG_MAKAN[playerid]);
    PlayerTextDrawDestroy(playerid, ICON_MINUM[playerid]);
    PlayerTextDrawDestroy(playerid, ICON_MAKAN[playerid]);
    PlayerTextDrawDestroy(playerid, BAR_MINUM[playerid]);
    PlayerTextDrawDestroy(playerid, BAR_MAKAN[playerid]);
    PlayerTextDrawDestroy(playerid, BG_NAMA[playerid]);
    PlayerTextDrawDestroy(playerid, NAMA_PLAYER[playerid]);
    PlayerTextDrawDestroy(playerid, BG_SPEEDOMETER[playerid]);
    PlayerTextDrawDestroy(playerid, HUD_SPEED[playerid]);
    PlayerTextDrawDestroy(playerid, HUD_FUEL[playerid]);
    PlayerTextDrawDestroy(playerid, HUD_HP[playerid]);
    PlayerTextDrawDestroy(playerid, HUD_LOCK[playerid]);
    PlayerTextDrawDestroy(playerid, SPEED[playerid]);
    PlayerTextDrawDestroy(playerid, SPEED_MPH[playerid]);
    PlayerTextDrawDestroy(playerid, FUEL[playerid]);
    PlayerTextDrawDestroy(playerid, HP[playerid]);
    PlayerTextDrawDestroy(playerid, LOCK[playerid]);
    PlayerTextDrawDestroy(playerid, PERSEN_1[playerid]);
    PlayerTextDrawDestroy(playerid, PERSEN_2[playerid]);
    PlayerTextDrawDestroy(playerid, PERSEN_3[playerid]);
    PlayerTextDrawDestroy(playerid, PERSEN_4[playerid]);
    PlayerTextDrawDestroy(playerid, PERSEN_5[playerid]);
    PlayerTextDrawDestroy(playerid, PERSEN_6[playerid]);
}

ShowPlayerHUD(playerid)
{
    if(!PlayerData[playerid][pLoggedIn]) return 0;
    
    PlayerTextDrawShow(playerid, BG_MINUM[playerid]);
    PlayerTextDrawShow(playerid, BG_MAKAN[playerid]);
    PlayerTextDrawShow(playerid, ICON_MINUM[playerid]);
    PlayerTextDrawShow(playerid, ICON_MAKAN[playerid]);
    PlayerTextDrawShow(playerid, BAR_MINUM[playerid]);
    PlayerTextDrawShow(playerid, BAR_MAKAN[playerid]);
    PlayerTextDrawShow(playerid, BG_NAMA[playerid]);
    PlayerTextDrawShow(playerid, NAMA_PLAYER[playerid]);
    
    new string[32];
    format(string, sizeof(string), "%s", PlayerData[playerid][pName]);
    PlayerTextDrawSetString(playerid, NAMA_PLAYER[playerid], string);
    
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        ShowSpeedometer(playerid);
    }
    
    PlayerData[playerid][pHudVisible] = true;
    UpdateHungerThirstHUD(playerid);
    return 1;
}

HidePlayerHUD(playerid)
{
    PlayerTextDrawHide(playerid, BG_MINUM[playerid]);
    PlayerTextDrawHide(playerid, BG_MAKAN[playerid]);
    PlayerTextDrawHide(playerid, ICON_MINUM[playerid]);
    PlayerTextDrawHide(playerid, ICON_MAKAN[playerid]);
    PlayerTextDrawHide(playerid, BAR_MINUM[playerid]);
    PlayerTextDrawHide(playerid, BAR_MAKAN[playerid]);
    PlayerTextDrawHide(playerid, BG_NAMA[playerid]);
    PlayerTextDrawHide(playerid, NAMA_PLAYER[playerid]);
    HideSpeedometer(playerid);
    
    PlayerData[playerid][pHudVisible] = false;
    return 1;
}

UpdateHungerThirstHUD(playerid)
{
    if(!PlayerData[playerid][pLoggedIn] || !PlayerData[playerid][pHudVisible]) return 0;
    
    new hunger_string[8];
    format(hunger_string, sizeof(hunger_string), "%d", PlayerData[playerid][pHunger]);
    PlayerTextDrawSetString(playerid, BAR_MAKAN[playerid], hunger_string);
    
    if(PlayerData[playerid][pHunger] <= 20)
        PlayerTextDrawColor(playerid, BAR_MAKAN[playerid], COLOR_RED);
    else if(PlayerData[playerid][pHunger] <= 50)
        PlayerTextDrawColor(playerid, BAR_MAKAN[playerid], COLOR_YELLOW);
    else
        PlayerTextDrawColor(playerid, BAR_MAKAN[playerid], COLOR_WHITE);
        
    PlayerTextDrawShow(playerid, BAR_MAKAN[playerid]);
    
    new thirst_string[8];
    format(thirst_string, sizeof(thirst_string), "%d", PlayerData[playerid][pThirst]);
    PlayerTextDrawSetString(playerid, BAR_MINUM[playerid], thirst_string);
    
    if(PlayerData[playerid][pThirst] <= 20)
        PlayerTextDrawColor(playerid, BAR_MINUM[playerid], COLOR_RED);
    else if(PlayerData[playerid][pThirst] <= 50)
        PlayerTextDrawColor(playerid, BAR_MINUM[playerid], COLOR_YELLOW);
    else
        PlayerTextDrawColor(playerid, BAR_MINUM[playerid], COLOR_WHITE);
        
    PlayerTextDrawShow(playerid, BAR_MINUM[playerid]);
    return 1;
}