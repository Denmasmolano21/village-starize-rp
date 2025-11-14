Gamemode update for v1.0.4

Speedometer mph, HP not updating (fix)

When the player quits/disconnects, save the last coordinates (add&fix)

When the player quits/disconnects/kicks, provide a reason and use CreateDynamic3DTextLabel (add)

Provide only the essential debugging or monitor looping (add&fix)

Make it modular and store its own data. For example, accounts would have enums.pwn, forward.pwn, variables.pwn, etc. files, as would other systems. This ensures consistency and structure, making it easier to add new features. Minimize loops or unnecessary functions.

I want the complete code!
// Village Story Roleplay Gamemode
// Version 1.0.3

#pragma tabsize 0

#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#include <streamer>
#include <Pawn.CMD>
#include <Pawn.Regex>
#include <samp_bcrypt>
#include <crashdetect>
// #include <EVF2>
// #include <fixes>

#define YSI_NO_HEAP_MALLOC
#include <YSI_Coding\y_timers>
#include <YSI_Data\y_iterate>

// ==================== CONFIGURATION ====================
#define SERVER_NAME         "Village Story Roleplay"
#define SERVER_NAME_TAG     "{00A6FB}VS:RP{FFFFFF}"
#define SERVER_VERSION      "1.0.3"
#define SERVER_MODE         "VS:RP v1.0.3"

// MySQL Configuration
#define MYSQL_HOST          "localhost"
#define MYSQL_USER          "root"
#define MYSQL_PASSWORD      ""
#define MYSQL_DATABASE      "vsrp"

// Base Colors (0xRRGGBBAA) - Updated to Soft Palette
#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_BLACK     0x000000FF
#define COLOR_BLUE      0x00A6FBFF
#define COLOR_GREEN     0x08CB00FF
#define COLOR_RED       0xFF6B6BFF
#define COLOR_YELLOW    0xFFD93DFF
#define COLOR_ORANGE    0xFFB347FF
#define COLOR_CYAN      0x40E0D0FF
#define COLOR_PINK      0xFFB6C1FF
#define COLOR_PURPLE    0xB19CD9FF
#define COLOR_GRAY      0xD8E2DCFF

// Soft Status Colors
#define COLOR_SUCCESS   0xD1F2D1FF
#define COLOR_WARNING   0xFFF4CCFF
#define COLOR_DANGER    0xFAD4D4FF
#define COLOR_INFO      0xD9ECFAFF
#define COLOR_MUTED     0xF2F2F2FF

// HEX Colors (untuk GameText / Dialog) - Updated to Soft Palette
#define COLOR_HEX_WHITE     "{FFFFFF}"
#define COLOR_HEX_BLACK     "{000000}"
#define COLOR_HEX_BLUE      "{00A6FB}"
#define COLOR_HEX_GREEN     "{08CB00}"
#define COLOR_HEX_RED       "{FF6B6B}"
#define COLOR_HEX_YELLOW    "{FFD93D}"
#define COLOR_HEX_ORANGE    "{FFB347}"
#define COLOR_HEX_CYAN      "{40E0D0}"
#define COLOR_HEX_PINK      "{FFB6C1}"
#define COLOR_HEX_PURPLE    "{B19CD9}"
#define COLOR_HEX_GRAY      "{D8E2DC}"

// Soft Status Colors
#define COLOR_HEX_SUCCESS   "{D1F2D1}"
#define COLOR_HEX_WARNING   "{FFF4CC}"
#define COLOR_HEX_DANGER    "{FAD4D4}"
#define COLOR_HEX_INFO      "{D9ECFA}"
#define COLOR_HEX_MUTED     "{F2F2F2}"

#if !defined IsValidVehicle
    native IsValidVehicle(vehicleid);
#endif

stock SendClientMessageEx(playerid, color, const text[], {Float, _} : ...)
{
    static args, str[144];

    if ((args = numargs()) == 3)
    {
        SendClientMessage(playerid, color, text);
    }
    else
    {
        while (--args >= 3)
        {
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
        }
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        SendClientMessage(playerid, color, str);

		#emit RETN
    }
    return 1;
}

#define ServerMsg(%0,%1) \
    SendClientMessageEx(%0, COLOR_BLUE, "[SERVER]:"COLOR_HEX_WHITE" "%1)

#define AdminMsg(%0,%1) \
    SendClientMessageEx(%0, COLOR_DANGER, "[ADMIN]:"COLOR_HEX_WHITE" "%1)

#define SyntaxMsg(%0,%1) \
    SendClientMessageEx(%0, COLOR_MUTED, "[SYNTAX]:"COLOR_HEX_WHITE" "%1)

#define InfoMsg(%0,%1) \
    SendClientMessageEx(%0, COLOR_INFO, "[INFO]:"COLOR_HEX_WHITE" "%1)

#define UsageMsg(%0,%1) \
    SendClientMessageEx(%0, COLOR_SUCCESS, "[USAGE]:"COLOR_HEX_WHITE" "%1)

#define SuccessMsg(%0,%1) \
    SendClientMessageEx(%0, COLOR_SUCCESS, "[SUCCESS]:"COLOR_HEX_WHITE" "%1)

#define WarningMsg(%0,%1) \
    SendClientMessageEx(%0, COLOR_WARNING, "[WARNING]:"COLOR_HEX_WHITE" "%1)

#define ErrorMsg(%0,%1) \
    SendClientMessageEx(%0, COLOR_DANGER, "[ERROR]:"COLOR_HEX_WHITE" "%1)

// Dialog IDs
enum
{
    DIALOG_UNUSED,
    DIALOG_REGISTER,
    DIALOG_LOGIN,
    DIALOG_AGE,
    DIALOG_GENDER,
    DIALOG_ORIGIN,
    DIALOG_STATS
};

// Player Limits
#define MAX_PASSWORD_LENGTH 65
#define MIN_PASSWORD_LENGTH 6
#define MIN_AGE             15
#define MAX_AGE             80

// Fixed spawn coordinates
#define SPAWN_X             226.53
#define SPAWN_Y             -303.74
#define SPAWN_Z             1.92
#define SPAWN_A             273.56

// Rural Jobs
enum
{
    JOB_NONE
};

// ==================== VARIABLES ====================
new MySQL:g_SQL;
new g_MysqlRaceCheck[MAX_PLAYERS];

new PlayerSpeedometerTimer[MAX_PLAYERS];
new bool:VehicleLocked[MAX_VEHICLES];

// ==================== PLAYER DATA ====================
enum E_PLAYER_DATA
{
    pID,
    pName[MAX_PLAYER_NAME],
    pPassword[BCRYPT_HASH_LENGTH],
    pAdmin,
    pHelper,
    pLevel,
    pExp,
    pMoney,
    pBankMoney,
    pSkin,
    pHunger,
    pThirst,
    Float:pHealth,
    Float:pArmour,
    Float:pPosX,
    Float:pPosY,
    Float:pPosZ,
    Float:pPosA,
    pInterior,
    pVirtualWorld,
    pAge,
    pGender,
    pOrigin[32],
    pPhone,
    pPhoneCredit,
    pHours,
    pMinutes,
    pSeconds,
    pJob,
    pFaction,
    pRank,
    pWantedLevel,
    pJailTime,
    pMuted,
    pMutedTime,
    pWarns,
    pKills,
    pDeaths,
    pLastLogin,
    pRegisterDate,
    bool:pLoggedIn,
    bool:pSpawned,
    pLoginAttempts,
    pLoginTimer,
    bool:pHudVisible
};
new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];

// ==================== FORWARDS ====================
forward OnPlayerDataLoaded(playerid, race_check);
forward OnPlayerRegister(playerid);
forward KickPlayer(playerid);
forward SavePlayerData(playerid);
forward UpdatePlayerTime();
forward ClearChat(playerid, lines);
forward SpawnPlayerProper(playerid);

forward UpdateHungerThirst();
forward UpdateSpeedometer(playerid);
forward OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
forward OnPlayerExitVehicle(playerid, vehicleid);

// ==================== TEXTDRAW VARIABLES ====================

new Text:ServerNameTD[5];
// Player textdraws for HUD
new PlayerText:BG_MINUM[MAX_PLAYERS];
new PlayerText:BG_MAKAN[MAX_PLAYERS];
new PlayerText:ICON_MINUM[MAX_PLAYERS];
new PlayerText:ICON_MAKAN[MAX_PLAYERS];
new PlayerText:BAR_MINUM[MAX_PLAYERS];
new PlayerText:BAR_MAKAN[MAX_PLAYERS];
new PlayerText:BG_NAMA[MAX_PLAYERS];
new PlayerText:NAMA_PLAYER[MAX_PLAYERS];
new PlayerText:BG_SPEEDOMETER[MAX_PLAYERS];
new PlayerText:HUD_SPEED[MAX_PLAYERS];
new PlayerText:HUD_FUEL[MAX_PLAYERS];
new PlayerText:HUD_HP[MAX_PLAYERS];
new PlayerText:HUD_LOCK[MAX_PLAYERS];
new PlayerText:SPEED[MAX_PLAYERS];
new PlayerText:SPEED_MPH[MAX_PLAYERS];
new PlayerText:FUEL[MAX_PLAYERS];
new PlayerText:HP[MAX_PLAYERS];
new PlayerText:LOCK[MAX_PLAYERS];
new PlayerText:PERSEN_1[MAX_PLAYERS];
new PlayerText:PERSEN_2[MAX_PLAYERS];
new PlayerText:PERSEN_3[MAX_PLAYERS];
new PlayerText:PERSEN_4[MAX_PLAYERS];
new PlayerText:PERSEN_5[MAX_PLAYERS];
new PlayerText:PERSEN_6[MAX_PLAYERS];

// ==================== TEXTDRAW FUNCTIONS ====================

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

    printf("[DEBUG] Global textdraws created");
}

DestroyGlobalTextdraws()
{
    for(new i = 0; i < sizeof(ServerNameTD); i++)
    {
        TextDrawDestroy(ServerNameTD[i]);
    }
    printf("[DEBUG] Global textdraws destroyed");
}

ShowTextdrawsForPlayer(playerid)
{
    for(new i = 0; i < sizeof(ServerNameTD); i++)
    {
        TextDrawShowForPlayer(playerid, ServerNameTD[i]);
    }
    printf("[DEBUG] Textdraws shown for player (ID: %d)", playerid);
}

HideTextdrawsForPlayer(playerid)
{
    for(new i = 0; i < sizeof(ServerNameTD); i++)
    {
        TextDrawHideForPlayer(playerid, ServerNameTD[i]);
    }
    printf("[DEBUG] Textdraws hidden for player (ID: %d)", playerid);
}

// ==================== HUD CREATION FUNCTIONS ====================
CreatePlayerHUD(playerid)
{
    // Hunger and Thirst bars
    BG_MINUM[playerid] = CreatePlayerTextDraw(playerid, 555.000, 130.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, BG_MINUM[playerid], 53.000, 17.000);
    PlayerTextDrawAlignment(playerid, BG_MINUM[playerid], 1);
    PlayerTextDrawColor(playerid, BG_MINUM[playerid], 200);
    PlayerTextDrawSetShadow(playerid, BG_MINUM[playerid], 0);
    PlayerTextDrawSetOutline(playerid, BG_MINUM[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, BG_MINUM[playerid], 255);
    PlayerTextDrawFont(playerid, BG_MINUM[playerid], 4);
    PlayerTextDrawSetProportional(playerid, BG_MINUM[playerid], 1);

    BG_MAKAN[playerid] = CreatePlayerTextDraw(playerid, 498.000, 130.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, BG_MAKAN[playerid], 52.000, 17.000);
    PlayerTextDrawAlignment(playerid, BG_MAKAN[playerid], 1);
    PlayerTextDrawColor(playerid, BG_MAKAN[playerid], 200);
    PlayerTextDrawSetShadow(playerid, BG_MAKAN[playerid], 0);
    PlayerTextDrawSetOutline(playerid, BG_MAKAN[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, BG_MAKAN[playerid], 255);
    PlayerTextDrawFont(playerid, BG_MAKAN[playerid], 4);
    PlayerTextDrawSetProportional(playerid, BG_MAKAN[playerid], 1);

    ICON_MINUM[playerid] = CreatePlayerTextDraw(playerid, 570.000, 133.000, "HUD:radar_diner");
    PlayerTextDrawTextSize(playerid, ICON_MINUM[playerid], -10.000, 10.000);
    PlayerTextDrawAlignment(playerid, ICON_MINUM[playerid], 1);
    PlayerTextDrawColor(playerid, ICON_MINUM[playerid], -1);
    PlayerTextDrawSetShadow(playerid, ICON_MINUM[playerid], 0);
    PlayerTextDrawSetOutline(playerid, ICON_MINUM[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, ICON_MINUM[playerid], 255);
    PlayerTextDrawFont(playerid, ICON_MINUM[playerid], 4);
    PlayerTextDrawSetProportional(playerid, ICON_MINUM[playerid], 1);

    ICON_MAKAN[playerid] = CreatePlayerTextDraw(playerid, 514.000, 133.000, "HUD:radar_dateFood");
    PlayerTextDrawTextSize(playerid, ICON_MAKAN[playerid], -11.000, 10.000);
    PlayerTextDrawAlignment(playerid, ICON_MAKAN[playerid], 1);
    PlayerTextDrawColor(playerid, ICON_MAKAN[playerid], -1);
    PlayerTextDrawSetShadow(playerid, ICON_MAKAN[playerid], 0);
    PlayerTextDrawSetOutline(playerid, ICON_MAKAN[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, ICON_MAKAN[playerid], 255);
    PlayerTextDrawFont(playerid, ICON_MAKAN[playerid], 4);
    PlayerTextDrawSetProportional(playerid, ICON_MAKAN[playerid], 1);

    BAR_MINUM[playerid] = CreatePlayerTextDraw(playerid, 579.000, 133.000, "100");
    PlayerTextDrawLetterSize(playerid, BAR_MINUM[playerid], 0.200, 1.098);
    PlayerTextDrawAlignment(playerid, BAR_MINUM[playerid], 1);
    PlayerTextDrawColor(playerid, BAR_MINUM[playerid], -56);
    PlayerTextDrawSetShadow(playerid, BAR_MINUM[playerid], 0);
    PlayerTextDrawSetOutline(playerid, BAR_MINUM[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, BAR_MINUM[playerid], 255);
    PlayerTextDrawFont(playerid, BAR_MINUM[playerid], 1);
    PlayerTextDrawSetProportional(playerid, BAR_MINUM[playerid], 1);

    BAR_MAKAN[playerid] = CreatePlayerTextDraw(playerid, 522.000, 133.000, "100");
    PlayerTextDrawLetterSize(playerid, BAR_MAKAN[playerid], 0.200, 1.098);
    PlayerTextDrawAlignment(playerid, BAR_MAKAN[playerid], 1);
    PlayerTextDrawColor(playerid, BAR_MAKAN[playerid], -56);
    PlayerTextDrawSetShadow(playerid, BAR_MAKAN[playerid], 0);
    PlayerTextDrawSetOutline(playerid, BAR_MAKAN[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, BAR_MAKAN[playerid], 255);
    PlayerTextDrawFont(playerid, BAR_MAKAN[playerid], 1);
    PlayerTextDrawSetProportional(playerid, BAR_MAKAN[playerid], 1);

    BG_NAMA[playerid] = CreatePlayerTextDraw(playerid, 498.000, 107.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, BG_NAMA[playerid], 110.000, 21.000);
    PlayerTextDrawAlignment(playerid, BG_NAMA[playerid], 1);
    PlayerTextDrawColor(playerid, BG_NAMA[playerid], 200);
    PlayerTextDrawSetShadow(playerid, BG_NAMA[playerid], 0);
    PlayerTextDrawSetOutline(playerid, BG_NAMA[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, BG_NAMA[playerid], 255);
    PlayerTextDrawFont(playerid, BG_NAMA[playerid], 4);
    PlayerTextDrawSetProportional(playerid, BG_NAMA[playerid], 1);

    NAMA_PLAYER[playerid] = CreatePlayerTextDraw(playerid, 521.000, 109.000, "Jarwo Sutanto");
    PlayerTextDrawLetterSize(playerid, NAMA_PLAYER[playerid], 0.349, 1.498);
    PlayerTextDrawAlignment(playerid, NAMA_PLAYER[playerid], 1);
    PlayerTextDrawColor(playerid, NAMA_PLAYER[playerid], -56);
    PlayerTextDrawSetShadow(playerid, NAMA_PLAYER[playerid], 1);
    PlayerTextDrawSetOutline(playerid, NAMA_PLAYER[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, NAMA_PLAYER[playerid], 150);
    PlayerTextDrawFont(playerid, NAMA_PLAYER[playerid], 0);
    PlayerTextDrawSetProportional(playerid, NAMA_PLAYER[playerid], 1);

    BG_SPEEDOMETER[playerid] = CreatePlayerTextDraw(playerid, 517.000, 343.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, BG_SPEEDOMETER[playerid], 89.000, 87.000);
    PlayerTextDrawAlignment(playerid, BG_SPEEDOMETER[playerid], 1);
    PlayerTextDrawColor(playerid, BG_SPEEDOMETER[playerid], 200);
    PlayerTextDrawSetShadow(playerid, BG_SPEEDOMETER[playerid], 0);
    PlayerTextDrawSetOutline(playerid, BG_SPEEDOMETER[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, BG_SPEEDOMETER[playerid], 255);
    PlayerTextDrawFont(playerid, BG_SPEEDOMETER[playerid], 4);
    PlayerTextDrawSetProportional(playerid, BG_SPEEDOMETER[playerid], 1);

    HUD_SPEED[playerid] = CreatePlayerTextDraw(playerid, 529.000, 344.000, "HUD:radar_impound");
    PlayerTextDrawTextSize(playerid, HUD_SPEED[playerid], 18.000, 18.000);
    PlayerTextDrawAlignment(playerid, HUD_SPEED[playerid], 1);
    PlayerTextDrawColor(playerid, HUD_SPEED[playerid], -1);
    PlayerTextDrawSetShadow(playerid, HUD_SPEED[playerid], 0);
    PlayerTextDrawSetOutline(playerid, HUD_SPEED[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, HUD_SPEED[playerid], 255);
    PlayerTextDrawFont(playerid, HUD_SPEED[playerid], 4);
    PlayerTextDrawSetProportional(playerid, HUD_SPEED[playerid], 1);

    HUD_FUEL[playerid] = CreatePlayerTextDraw(playerid, 530.000, 367.000, "HUD:radar_spray");
    PlayerTextDrawTextSize(playerid, HUD_FUEL[playerid], 18.000, 18.000);
    PlayerTextDrawAlignment(playerid, HUD_FUEL[playerid], 1);
    PlayerTextDrawColor(playerid, HUD_FUEL[playerid], -1);
    PlayerTextDrawSetShadow(playerid, HUD_FUEL[playerid], 0);
    PlayerTextDrawSetOutline(playerid, HUD_FUEL[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, HUD_FUEL[playerid], 255);
    PlayerTextDrawFont(playerid, HUD_FUEL[playerid], 4);
    PlayerTextDrawSetProportional(playerid, HUD_FUEL[playerid], 1);

    HUD_HP[playerid] = CreatePlayerTextDraw(playerid, 530.000, 390.000, "HUD:radar_modGarage");
    PlayerTextDrawTextSize(playerid, HUD_HP[playerid], 14.000, 15.000);
    PlayerTextDrawAlignment(playerid, HUD_HP[playerid], 1);
    PlayerTextDrawColor(playerid, HUD_HP[playerid], -1);
    PlayerTextDrawSetShadow(playerid, HUD_HP[playerid], 0);
    PlayerTextDrawSetOutline(playerid, HUD_HP[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, HUD_HP[playerid], 255);
    PlayerTextDrawFont(playerid, HUD_HP[playerid], 4);
    PlayerTextDrawSetProportional(playerid, HUD_HP[playerid], 1);

    HUD_LOCK[playerid] = CreatePlayerTextDraw(playerid, 527.000, 409.000, "HUD:radar_light");
    PlayerTextDrawTextSize(playerid, HUD_LOCK[playerid], 19.000, 19.000);
    PlayerTextDrawAlignment(playerid, HUD_LOCK[playerid], 1);
    PlayerTextDrawColor(playerid, HUD_LOCK[playerid], -1);
    PlayerTextDrawSetShadow(playerid, HUD_LOCK[playerid], 0);
    PlayerTextDrawSetOutline(playerid, HUD_LOCK[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, HUD_LOCK[playerid], 255);
    PlayerTextDrawFont(playerid, HUD_LOCK[playerid], 4);
    PlayerTextDrawSetProportional(playerid, HUD_LOCK[playerid], 1);

    SPEED[playerid] = CreatePlayerTextDraw(playerid, 556.000, 348.000, "100");
    PlayerTextDrawLetterSize(playerid, SPEED[playerid], 0.229, 1.297);
    PlayerTextDrawAlignment(playerid, SPEED[playerid], 1);
    PlayerTextDrawColor(playerid, SPEED[playerid], -1);
    PlayerTextDrawSetShadow(playerid, SPEED[playerid], 1);
    PlayerTextDrawSetOutline(playerid, SPEED[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, SPEED[playerid], 150);
    PlayerTextDrawFont(playerid, SPEED[playerid], 1);
    PlayerTextDrawSetProportional(playerid, SPEED[playerid], 1);

    SPEED_MPH[playerid] = CreatePlayerTextDraw(playerid, 576.000, 348.000, "Mph");
    PlayerTextDrawLetterSize(playerid, SPEED_MPH[playerid], 0.229, 1.297);
    PlayerTextDrawAlignment(playerid, SPEED_MPH[playerid], 1);
    PlayerTextDrawColor(playerid, SPEED_MPH[playerid], -1);
    PlayerTextDrawSetShadow(playerid, SPEED_MPH[playerid], 1);
    PlayerTextDrawSetOutline(playerid, SPEED_MPH[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, SPEED_MPH[playerid], 150);
    PlayerTextDrawFont(playerid, SPEED_MPH[playerid], 1);
    PlayerTextDrawSetProportional(playerid, SPEED_MPH[playerid], 1);

    FUEL[playerid] = CreatePlayerTextDraw(playerid, 556.000, 368.000, "100");
    PlayerTextDrawLetterSize(playerid, FUEL[playerid], 0.229, 1.297);
    PlayerTextDrawAlignment(playerid, FUEL[playerid], 1);
    PlayerTextDrawColor(playerid, FUEL[playerid], -1);
    PlayerTextDrawSetShadow(playerid, FUEL[playerid], 1);
    PlayerTextDrawSetOutline(playerid, FUEL[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, FUEL[playerid], 150);
    PlayerTextDrawFont(playerid, FUEL[playerid], 1);
    PlayerTextDrawSetProportional(playerid, FUEL[playerid], 1);

    HP[playerid] = CreatePlayerTextDraw(playerid, 556.000, 390.000, "100");
    PlayerTextDrawLetterSize(playerid, HP[playerid], 0.229, 1.297);
    PlayerTextDrawAlignment(playerid, HP[playerid], 1);
    PlayerTextDrawColor(playerid, HP[playerid], -1);
    PlayerTextDrawSetShadow(playerid, HP[playerid], 1);
    PlayerTextDrawSetOutline(playerid, HP[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, HP[playerid], 150);
    PlayerTextDrawFont(playerid, HP[playerid], 1);
    PlayerTextDrawSetProportional(playerid, HP[playerid], 1);

    LOCK[playerid] = CreatePlayerTextDraw(playerid, 556.000, 411.000, "LOCKED");
    PlayerTextDrawLetterSize(playerid, LOCK[playerid], 0.229, 1.297);
    PlayerTextDrawAlignment(playerid, LOCK[playerid], 1);
    PlayerTextDrawColor(playerid, LOCK[playerid], 1018393087);
    PlayerTextDrawSetShadow(playerid, LOCK[playerid], 1);
    PlayerTextDrawSetOutline(playerid, LOCK[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, LOCK[playerid], 150);
    PlayerTextDrawFont(playerid, LOCK[playerid], 1);
    PlayerTextDrawSetProportional(playerid, LOCK[playerid], 1);

    PERSEN_1[playerid] = CreatePlayerTextDraw(playerid, 576.000, 367.000, "0");
    PlayerTextDrawLetterSize(playerid, PERSEN_1[playerid], 0.170, 0.898);
    PlayerTextDrawAlignment(playerid, PERSEN_1[playerid], 1);
    PlayerTextDrawColor(playerid, PERSEN_1[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_1[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_1[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, PERSEN_1[playerid], 150);
    PlayerTextDrawFont(playerid, PERSEN_1[playerid], 1);
    PlayerTextDrawSetProportional(playerid, PERSEN_1[playerid], 1);

    PERSEN_2[playerid] = CreatePlayerTextDraw(playerid, 580.000, 366.000, "/");
    PlayerTextDrawLetterSize(playerid, PERSEN_2[playerid], 0.188, 1.399);
    PlayerTextDrawAlignment(playerid, PERSEN_2[playerid], 1);
    PlayerTextDrawColor(playerid, PERSEN_2[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_2[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_2[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, PERSEN_2[playerid], 150);
    PlayerTextDrawFont(playerid, PERSEN_2[playerid], 1);
    PlayerTextDrawSetProportional(playerid, PERSEN_2[playerid], 1);

    PERSEN_3[playerid] = CreatePlayerTextDraw(playerid, 583.000, 372.000, "0");
    PlayerTextDrawLetterSize(playerid, PERSEN_3[playerid], 0.158, 0.898);
    PlayerTextDrawAlignment(playerid, PERSEN_3[playerid], 1);
    PlayerTextDrawColor(playerid, PERSEN_3[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_3[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_3[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, PERSEN_3[playerid], 150);
    PlayerTextDrawFont(playerid, PERSEN_3[playerid], 1);
    PlayerTextDrawSetProportional(playerid, PERSEN_3[playerid], 1);

    PERSEN_4[playerid] = CreatePlayerTextDraw(playerid, 576.000, 389.000, "0");
    PlayerTextDrawLetterSize(playerid, PERSEN_4[playerid], 0.170, 0.898);
    PlayerTextDrawAlignment(playerid, PERSEN_4[playerid], 1);
    PlayerTextDrawColor(playerid, PERSEN_4[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_4[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_4[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, PERSEN_4[playerid], 150);
    PlayerTextDrawFont(playerid, PERSEN_4[playerid], 1);
    PlayerTextDrawSetProportional(playerid, PERSEN_4[playerid], 1);

    PERSEN_5[playerid] = CreatePlayerTextDraw(playerid, 580.000, 388.000, "/");
    PlayerTextDrawLetterSize(playerid, PERSEN_5[playerid], 0.188, 1.399);
    PlayerTextDrawAlignment(playerid, PERSEN_5[playerid], 1);
    PlayerTextDrawColor(playerid, PERSEN_5[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_5[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_5[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, PERSEN_5[playerid], 150);
    PlayerTextDrawFont(playerid, PERSEN_5[playerid], 1);
    PlayerTextDrawSetProportional(playerid, PERSEN_5[playerid], 1);

    PERSEN_6[playerid] = CreatePlayerTextDraw(playerid, 583.000, 394.000, "0");
    PlayerTextDrawLetterSize(playerid, PERSEN_6[playerid], 0.170, 0.898);
    PlayerTextDrawAlignment(playerid, PERSEN_6[playerid], 1);
    PlayerTextDrawColor(playerid, PERSEN_6[playerid], -1);
    PlayerTextDrawSetShadow(playerid, PERSEN_6[playerid], 1);
    PlayerTextDrawSetOutline(playerid, PERSEN_6[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, PERSEN_6[playerid], 150);
    PlayerTextDrawFont(playerid, PERSEN_6[playerid], 1);
    PlayerTextDrawSetProportional(playerid, PERSEN_6[playerid], 1);
    printf("[DEBUG] HUD created for player (ID: %d)", playerid);
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
    
    printf("[DEBUG] HUD destroyed for player (ID: %d)", playerid);
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
    
    // Update player name
    new string[32];
    format(string, sizeof(string), "%s", PlayerData[playerid][pName]);
    PlayerTextDrawSetString(playerid, NAMA_PLAYER[playerid], string);
    
    // Show speedometer only if in vehicle
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
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
    }
    
    PlayerData[playerid][pHudVisible] = true;
    UpdateHungerThirstHUD(playerid);
    printf("[DEBUG] HUD shown for player (ID: %d)", playerid);
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
    
    PlayerData[playerid][pHudVisible] = false;
    printf("[DEBUG] HUD hidden for player (ID: %d)", playerid);
    return 1;
}

// ==================== MAIN ====================
main() {}

public OnGameModeInit()
{
    printf("[DEBUG] OnGameModeInit called");
    
    SetGameModeText(SERVER_MODE);

    // Server Settings for rural feel
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    ShowNameTags(0);
    SetNameTagDrawDistance(20.0);
    EnableStuntBonusForAll(0);
    DisableInteriorEnterExits();
    ManualVehicleEngineAndLights();
    Streamer_SetTickRate(1);
    Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT, 1000);
    Streamer_MaxItems(STREAMER_TYPE_OBJECT, MAX_OBJECTS);
    
    printf("[DEBUG] Server settings configured");

    // Create Global Textdraws
    CreateGlobalTextdraws();

    // MySQL Connection
    new MySQLOpt:option_id = mysql_init_options();
    mysql_set_option(option_id, AUTO_RECONNECT, true);
    mysql_set_option(option_id, POOL_SIZE, 2);

    g_SQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, option_id);

    if (g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0)
    {
        print("[ERROR] MySQL connection failed! Server shutting down...");
        SendRconCommand("exit");
        return 1;
    }

    printf("[SUCCESS] MySQL connection established! Handle: %d", _:g_SQL);

    // Create Tables
    CreateDatabaseTables();

    // Dynamic Objects and 3D Text Labels
    CreateDynamicPickup(1239, 1, 229.39, -304.55, 1.57);
    CreateDynamic3DTextLabel(
    "{00A6FB}[Village Story]\n\
    {FFFFFF}Selamat Datang!\n\
    Ketik {00FF00}/help {FFFFFF}untuk bantuan.", COLOR_GRAY, 229.39, -304.55, 1.57, 10.0);

    printf("[SUCCESS] %s loaded successfully!", SERVER_NAME);
    return 1;
}

public OnGameModeExit()
{
    printf("[DEBUG] OnGameModeExit called");
    
    foreach(new i : Player)
    {
        if (PlayerData[i][pLoggedIn])
        {
            printf("[DEBUG] Saving data for player (ID: %d) on exit", i);
            SavePlayerData(i);
        }
    }

    // Destroy textdraws
    DestroyGlobalTextdraws();

    mysql_close(g_SQL);
    print("[INFO] Gamemode exited successfully");
    return 1;
}

// ==================== PLAYER CONNECTION ====================
public OnPlayerConnect(playerid)
{
    printf("[DEBUG] OnPlayerConnect - Player %d connecting", playerid);
    
    g_MysqlRaceCheck[playerid]++;

    // Reset player data
    ResetPlayerData(playerid);

    // Pre-load
    TogglePlayerSpectating(playerid, true);
    SetPlayerColor(playerid, COLOR_MUTED);

    GetPlayerName(playerid, PlayerData[playerid][pName], MAX_PLAYER_NAME);
    printf("[DEBUG] Player name: %s", PlayerData[playerid][pName]);

    // Show textdraws for player
    ShowTextdrawsForPlayer(playerid);

    // CREATE PLAYER HUD
    CreatePlayerHUD(playerid);

    // Check if player is registered
    new query[128];
    mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `username` = '%e' LIMIT 1", PlayerData[playerid][pName]);
    mysql_tquery(g_SQL, query, "OnPlayerDataLoaded", "dd", playerid, g_MysqlRaceCheck[playerid]);
    
    printf("[DEBUG] Database query sent for %s", PlayerData[playerid][pName]);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    printf("[DEBUG] OnPlayerDisconnect - Player %d disconnecting (reason: %d)", playerid, reason);
    
    if (PlayerData[playerid][pLoggedIn])
    {
        SavePlayerData(playerid);
    }

    // DESTROY PLAYER HUD
    DestroyPlayerHUD(playerid);

    // Hide textdraws
    HideTextdrawsForPlayer(playerid);

    KillTimer(PlayerSpeedometerTimer[playerid]);
    PlayerSpeedometerTimer[playerid] = 0;

    g_MysqlRaceCheck[playerid]++;
    ResetPlayerData(playerid);
    return 1;
}

// ==================== DATABASE FUNCTIONS ====================
CreateDatabaseTables()
{
    printf("[DEBUG] Creating database tables...");
    
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

    print("[INFO] Database tables checked/created.");
}

public OnPlayerDataLoaded(playerid, race_check)
{
    printf("[DEBUG] OnPlayerDataLoaded called for player (ID: %d) (race_check: %d)", playerid, race_check);
    
    if (race_check != g_MysqlRaceCheck[playerid]) 
    {
        printf("[DEBUG] Race check failed for player (ID: %d)", playerid);
        return 1;
    }

    new rows;
    cache_get_row_count(rows);
    printf("[DEBUG] Database returned %d rows for %s", rows, PlayerData[playerid][pName]);

    if (rows)
    {
        // Player is registered - show login dialog
        cache_get_value_name(0, "password", PlayerData[playerid][pPassword], BCRYPT_HASH_LENGTH);
        cache_get_value_name_int(0, "id", PlayerData[playerid][pID]);
        
        printf("[DEBUG] Player %s is registered (ID: %d)", PlayerData[playerid][pName], PlayerData[playerid][pID]);

        new dialog_text[512];
        format(dialog_text, sizeof(dialog_text), 
            "{FFFFFF}Selamat datang kembali di {00A6FB}Village Story Roleplay{FFFFFF}!\n\n\
            {FFFF00}Username:{FFFFFF} %s\n\
            {FFFF00}Status:{FFFFFF} Akun terdaftar\n\n\
            {FFFFFF}Masukkan password untuk melanjutkan petualangan di desa:",
            PlayerData[playerid][pName]);

        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, 
            ""SERVER_NAME_TAG" - Login", dialog_text, "Masuk", "Keluar");
    }
    else
    {
        // Player is not registered - show register dialog
        printf("[DEBUG] Player %s is not registered, showing register dialog", PlayerData[playerid][pName]);
        
        new dialog_text[512];
        format(dialog_text, sizeof(dialog_text), 
            "{FFFFFF}Selamat datang di {00A6FB}Village Story Roleplay{FFFFFF}!\n\n\
            {FFFF00}Username:{FFFFFF} %s\n\
            {FFFF00}Status:{FFFFFF} Belum terdaftar\n\n\
            {FFFFFF}Buat password untuk memulai petualangan:\n\
            {D8E2DC}- Password harus 6-32 karakter\n\
            - Gunakan kombinasi huruf dan angka\n\
            - Jangan gunakan password yang mudah ditebak",
            PlayerData[playerid][pName]);

        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, 
            ""SERVER_NAME_TAG" - Daftar Akun", dialog_text, "Daftar", "Keluar");
    }
    return 1;
}

// ==================== DIALOG RESPONSES ====================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    printf("[DEBUG] OnDialogResponse - Player %d, Dialog %d, Response %d", playerid, dialogid, response);
    
    switch (dialogid)
    {
        case DIALOG_REGISTER:
        {
            if (!response) 
            {
                printf("[DEBUG] Player %d cancelled registration", playerid);
                return Kick(playerid);
            }

            if (strlen(inputtext) < MIN_PASSWORD_LENGTH || strlen(inputtext) > MAX_PASSWORD_LENGTH)
            {
                printf("[DEBUG] Invalid password length from player %d", playerid);
                
                new dialog_text[512];
                format(dialog_text, sizeof(dialog_text), 
                    "{FFFFFF}Selamat datang di {00A6FB}Village Story Roleplay{FFFFFF}!\n\n\
                    {FFFF00}Username:{FFFFFF} %s\n\
                    {FF0000}ERROR:{FFFFFF} Password harus 6-32 karakter!\n\n\
                    {FFFFFF}Buat password untuk memulai petualangan:\n\
                    {D8E2DC}- Password harus 6-32 karakter\n\
                    - Gunakan kombinasi huruf dan angka\n\
                    - Jangan gunakan password yang mudah ditebak",
                    PlayerData[playerid][pName]);

                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, 
                    ""SERVER_NAME_TAG" - Daftar Akun", dialog_text, "Daftar", "Keluar");
                return 1;
            }

            printf("[DEBUG] Hashing password for player (ID: %d)", playerid);
            bcrypt_hash(playerid, "OnPasswordHashed", inputtext, BCRYPT_COST);
        }

        case DIALOG_LOGIN:
        {
            if (!response) 
            {
                printf("[DEBUG] Player %d cancelled login", playerid);
                return Kick(playerid);
            }

            printf("[DEBUG] Verifying password for player (ID: %d)", playerid);
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
                    {D8E2DC}- Password harus 6-32 karakter\n\
                    - Gunakan kombinasi huruf dan angka\n\
                    - Jangan gunakan password yang mudah ditebak",
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
                    {00A6FB}Note:{FFFFFF} Umur mempengaruhi roleplay karakter Anda");

                ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, 
                    ""SERVER_NAME_TAG" - Umur Karakter", dialog_text, "Lanjut", "Kembali");
                return 1;
            }

            PlayerData[playerid][pAge] = age;
            printf("[DEBUG] Player %d set age to %d", playerid, age);

            new dialog_text[256];
            format(dialog_text, sizeof(dialog_text),
                "{FFFFFF}Pilih jenis kelamin karakter Anda:\n\n\
                {00A6FB}Note:{FFFFFF} Jenis kelamin mempengaruhi penampilan karakter Anda");

            ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_MSGBOX, 
                ""SERVER_NAME_TAG" - Jenis Kelamin", dialog_text, "Laki-laki", "Perempuan");
        }

        case DIALOG_GENDER:
        {
            PlayerData[playerid][pGender] = response ? 1 : 2;
            printf("[DEBUG] Player %d selected gender %d", playerid, PlayerData[playerid][pGender]);

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
            new origins[][32] =
            {
                "Los Santos", "San Fiero", "Las Venturas"
            };

            format(PlayerData[playerid][pOrigin], 32, "%s", origins[listitem]);
            printf("[DEBUG] Player %d selected origin: %s", playerid, PlayerData[playerid][pOrigin]);

            // Complete registration
            RegisterPlayer(playerid);
        }
    }
    return 1;
}

// ==================== BCRYPT CALLBACKS ====================
forward OnPasswordHashed(playerid, hashid);
public OnPasswordHashed(playerid, hashid)
{
    printf("[DEBUG] OnPasswordHashed called for player (ID: %d)", playerid);
    
    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash);

    format(PlayerData[playerid][pPassword], BCRYPT_HASH_LENGTH, "%s", hash);

    // Continue registration process
    new dialog_text[256];
    format(dialog_text, sizeof(dialog_text),
        "{FFFFFF}Tentukan umur karakter Anda:\n\n\
        Masukkan umur karakter (15-80 tahun):\n\n\
        {FFFF00}Note:{FFFFFF} Umur mempengaruhi roleplay karakter Anda");

    SuccessMsg(playerid, "Password berhasil dibuat!");

    ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, 
        ""SERVER_NAME_TAG" - Umur Karakter", dialog_text, "Lanjut", "Kembali");
    return 1;
}

forward OnPasswordChecked(playerid, bool:success);
public OnPasswordChecked(playerid, bool:success)
{
    printf("[DEBUG] OnPasswordChecked - Player %d, Success: %d", playerid, success);
    
    if (!success)
    {
        PlayerData[playerid][pLoginAttempts]++;
        printf("[DEBUG] Failed login attempt %d for player (ID: %d)", PlayerData[playerid][pLoginAttempts], playerid);

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
        printf("[DEBUG] Password verified, loading data for player (ID: %d)", playerid);
        LoadPlayerData(playerid);
    }
    return 1;
}

// ==================== PLAYER FUNCTIONS ====================
RegisterPlayer(playerid)
{
    printf("[DEBUG] RegisterPlayer called for %s", PlayerData[playerid][pName]);
    
    // Select appropriate skin based on gender - no randomization
    if (PlayerData[playerid][pGender] == 1) // Male
    {
        PlayerData[playerid][pSkin] = 158; // Fixed male rural skin
    }
    else // Female
    {
        PlayerData[playerid][pSkin] = 157; // Fixed female rural skin
    }
    
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
    printf("[DEBUG] Player %s registered with ID %d", PlayerData[playerid][pName], PlayerData[playerid][pID]);

    ServerMsg(playerid, "Pendaftaran berhasil! Selamat datang di Village Story!");
    ServerMsg(playerid, "Anda mendapat uang awal $500 tunai dan $1000 di bank.");

    // Set default data
    PlayerData[playerid][pLevel] = 1;
    PlayerData[playerid][pMoney] = 500;
    PlayerData[playerid][pBankMoney] = 1000;
    PlayerData[playerid][pHealth] = 100.0;

    // Set fixed spawn position
    PlayerData[playerid][pPosX] = SPAWN_X;
    PlayerData[playerid][pPosY] = SPAWN_Y;
    PlayerData[playerid][pPosZ] = SPAWN_Z;
    PlayerData[playerid][pPosA] = SPAWN_A;
    
    printf("[DEBUG] Fixed spawn position set: %.2f, %.2f, %.2f, %.2f", 
        PlayerData[playerid][pPosX], 
        PlayerData[playerid][pPosY], 
        PlayerData[playerid][pPosZ],
        PlayerData[playerid][pPosA]);

    PlayerData[playerid][pLoggedIn] = true;

    // IMPORTANT FIX: Disable spectating before spawning
    TogglePlayerSpectating(playerid, false);
    
    printf("[DEBUG] Attempting to spawn player %d", playerid);
    SetTimerEx("SpawnPlayerProper", 100, false, "i", playerid);
    return 1;
}

public SpawnPlayerProper(playerid)
{
    printf("[DEBUG] SpawnPlayerProper called for player (ID: %d)", playerid);
    SpawnPlayer(playerid);
    return 1;
}

LoadPlayerData(playerid)
{
    printf("[DEBUG] LoadPlayerData called for player (ID: %d)", playerid);
    
    new query[128];
    mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `id` = %d LIMIT 1", PlayerData[playerid][pID]);
    mysql_tquery(g_SQL, query, "OnPlayerDataLoad", "d", playerid);
    return 1;
}

forward OnPlayerDataLoad(playerid);
public OnPlayerDataLoad(playerid)
{
    printf("[DEBUG] OnPlayerDataLoad - Loading all data for player (ID: %d)", playerid);
    
    // Load all player data
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
    
    printf("[DEBUG] Player %d data loaded - Money: %d, Level: %d, Hunger: %d, Thirst: %d",
        playerid, PlayerData[playerid][pMoney], PlayerData[playerid][pLevel],
        PlayerData[playerid][pHunger], PlayerData[playerid][pThirst]);

    // Update last login
    new query[256];
    mysql_format(g_SQL, query, sizeof(query), "UPDATE `players` SET `last_login` = %d WHERE `id` = %d", gettime(), PlayerData[playerid][pID]);
    mysql_tquery(g_SQL, query);

    PlayerData[playerid][pLoggedIn] = true;

    ServerMsg(playerid, "Selamat datang kembali di Village Story Roleplay!");
    ServerMsg(playerid, "Selalu ikuti peraturan yang sudah tertera, %s!", PlayerData[playerid][pName]);

    // IMPORTANT FIX: Disable spectating before spawning
    TogglePlayerSpectating(playerid, false);
    
    printf("[DEBUG] Spawning player %d after login", playerid);
    SetTimerEx("SpawnPlayerProper", 100, false, "i", playerid);
    return 1;
}

public SavePlayerData(playerid)
{
    if (!PlayerData[playerid][pLoggedIn]) return 0;
    
    printf("[DEBUG] Saving data for player (ID: %d)", playerid);

    new query[2048];

    GetPlayerPos(playerid, PlayerData[playerid][pPosX], PlayerData[playerid][pPosY], PlayerData[playerid][pPosZ]);
    GetPlayerFacingAngle(playerid, PlayerData[playerid][pPosA]);
    GetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
    GetPlayerArmour(playerid, PlayerData[playerid][pArmour]);

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
        PlayerData[playerid][pThirst], PlayerData[playerid][pHealth],
        PlayerData[playerid][pArmour], PlayerData[playerid][pPosX],
        PlayerData[playerid][pPosY], PlayerData[playerid][pPosZ],
        PlayerData[playerid][pPosA], PlayerData[playerid][pInterior],
        PlayerData[playerid][pVirtualWorld], PlayerData[playerid][pHours],
        PlayerData[playerid][pMinutes], PlayerData[playerid][pSeconds],
        PlayerData[playerid][pJob], PlayerData[playerid][pID]);

    mysql_tquery(g_SQL, query);
    printf("[DEBUG] Save query executed for player (ID: %d)", playerid);
    return 1;
}

// ==================== SPAWN SYSTEM ====================
public OnPlayerSpawn(playerid)
{
    printf("[DEBUG] OnPlayerSpawn called for player (ID: %d)", playerid);
    
    if (!PlayerData[playerid][pLoggedIn])
    {
        printf("[WARNING] Player %d tried to spawn without logging in!", playerid);
        Kick(playerid);
        return 1;
    }

    // Set player data
    SetPlayerSkin(playerid, PlayerData[playerid][pSkin]);
    SetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
    SetPlayerArmour(playerid, PlayerData[playerid][pArmour]);
    SetPlayerInterior(playerid, PlayerData[playerid][pInterior]);
    SetPlayerVirtualWorld(playerid, PlayerData[playerid][pVirtualWorld]);
    SetPlayerColor(playerid, COLOR_WHITE);

    // Always spawn at fixed coordinates for new and existing players
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerFacingAngle(playerid, SPAWN_A);
    
    printf("[DEBUG] Player %d spawned at fixed coordinates: %.2f, %.2f, %.2f", 
        playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);

    // Set camera behind player
    SetCameraBehindPlayer(playerid);

    // SHOW HUD AFTER SPAWN
    ShowPlayerHUD(playerid);

    // Give money
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);

    PlayerData[playerid][pSpawned] = true;

    InfoMsg(playerid, "Ketik /help untuk melihat perintah yang tersedia");

    SetTimer("UpdatePlayerTime", 1000, true);
    SetTimer("UpdateHungerThirst", 10000, true);
    SetTimer("CheckVehicleLockStatus", 1000, true);
    SetTimer("UpdateSpeedometer", 100, true);

    printf("[DEBUG] Player %d spawned successfully", playerid);
    return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if (!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    // Teleport player ke titik klik
    SetPlayerPos(playerid, fX, fY, fZ);

    // Kasih notifikasi ke player
    new msg[64];
    format(msg, sizeof(msg), "Posisi dipindahkan ke: X: %.2f | Y: %.2f | Z: %.2f", fX, fY, fZ);
    SendClientMessage(playerid, COLOR_SUCCESS, msg);

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
    if (!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");

    // Mute check
    // if (AccountInfo[playerid][pMuteTime] > 0)
    // {
    //     ErrorMsg(playerid, "Anda sedang dibisukan. Sisa waktu: %d detik.", AccountInfo[playerid][pMuteTime]);
    //     return 0;
    // }
    // // Command spam check
    return 1;
}

// ==================== COMMANDS ====================
CMD:stats(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) 
        return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");

    new jobname[32];
    switch (PlayerData[playerid][pJob])
    {
        case JOB_NONE: jobname = "Pengangguran";
        // tambahkan case lainnya kalau ada
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

    printf("[DEBUG] Player %d viewed stats", playerid);
    return 1;
}

CMD:help(playerid, params[])
{
    new helpText[800];
    format(helpText, sizeof(helpText),
        "Kategori\tPerintah\n\
        Dasar\t/stats, /mypos, /help\n\
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
    printf("[DEBUG] OOC from %s: %s", PlayerData[playerid][pName], params);
    return 1;
}

CMD:me(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    if (isnull(params)) return UsageMsg(playerid, "/me [aksi]");

    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "* %s %s", PlayerData[playerid][pName], params);
    GetPlayerPos(playerid, x, y, z);
    
    // Send to nearby players with purple color
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    printf("[DEBUG] /me from %s: %s", PlayerData[playerid][pName], params);
    return 1;
}

CMD:do(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    if (isnull(params)) return UsageMsg(playerid, "/do [deskripsi]");

    new string[128], Float:x, Float:y, Float:z;
    format(string, sizeof(string), "* %s (( %s ))", params, PlayerData[playerid][pName]);
    GetPlayerPos(playerid, x, y, z);
    
    // Send to nearby players with purple color
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    printf("[DEBUG] /do from %s: %s", PlayerData[playerid][pName], params);
    return 1;
}

CMD:mypos(playerid, params[])
{
    if (!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    SendClientMessageEx(playerid, COLOR_WHITE, "Posisi: X: %.2f | Y: %.2f | Z: %.2f | Angle: %.2f", x, y, z, a);

    printf("[DEBUG] Posisi: X: %.2f | Y: %.2f | Z: %.2f | Angle: %.2f", x, y, z, a);
    return 1;
}

CMD:veh(playerid, params[])
{
    new modelid;
    if (sscanf(params, "d", modelid))
    {
        SendClientMessage(playerid, -1, "Usage: /veh <modelid>");
        return 1;
    }

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new vehid = CreateVehicle(modelid, x, y, z, a, -1, -1, -1);

    if (vehid != INVALID_VEHICLE_ID)
    {
        new str[64];
        format(str, sizeof(str), "Kendaraan ID %d (Model %d) berhasil dibuat!", vehid, modelid);
        SendClientMessage(playerid, -1, str);
    }
    else
    {
        SendClientMessage(playerid, -1, "Gagal membuat kendaraan!");
    }
    return 1;
}

CMD:engine(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);
    if(!vehicleid)
        return ErrorMsg(playerid, "Anda harus berada di dalam kendaraan!");
        
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return ErrorMsg(playerid, "Anda harus menjadi driver!");
    
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    
    // PERBAIKAN: Cek jika kendaraan terkunci
    if(doors == 1) // Vehicle is locked
    {
        return ErrorMsg(playerid, "Tidak bisa menyalakan mesin! Kendaraan terkunci. Gunakan /unlock terlebih dahulu.");
    }
    
    if(engine == 1)
    {
        // Turn off engine
        SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
        InfoMsg(playerid, "Mesin kendaraan dimatikan!");
        
        // Show action to nearby players
        new string[128];
        format(string, sizeof(string), "* %s mematikan mesin kendaraan", PlayerData[playerid][pName]);
        
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        
        foreach(new i : Player)
        {
            if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
            {
                SendClientMessage(i, COLOR_PURPLE, string);
            }
        }
    }
    else
    {
        // Turn on engine
        SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
        SuccessMsg(playerid, "Mesin kendaraan dinyalakan!");
        
        // Show action to nearby players
        new string[128];
        format(string, sizeof(string), "* %s menyalakan mesin kendaraan", PlayerData[playerid][pName]);
        
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        
        foreach(new i : Player)
        {
            if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
            {
                SendClientMessage(i, COLOR_PURPLE, string);
            }
        }
    }
    return 1;
}

// ==================== COMMANDS ====================
CMD:eat(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if(PlayerData[playerid][pHunger] >= 100)
        return ErrorMsg(playerid, "Anda sudah kenyang!");
    
    // Simple eating system - you can expand this with items
    PlayerData[playerid][pHunger] += 25;
    if(PlayerData[playerid][pHunger] > 100) PlayerData[playerid][pHunger] = 100;
    
    UpdateHungerThirstHUD(playerid);
    
    new string[128];
    format(string, sizeof(string), "* %s memakan sesuatu", PlayerData[playerid][pName]);
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    
    SuccessMsg(playerid, "Anda telah makan. Rasa lapar berkurang!");
    printf("[DEBUG] Player %d used /eat command", playerid);
    return 1;
}

CMD:drink(playerid, params[])
{
    if(!PlayerData[playerid][pLoggedIn]) return ErrorMsg(playerid, "Anda harus login terlebih dahulu.");
    
    if(PlayerData[playerid][pThirst] >= 100)
        return ErrorMsg(playerid, "Anda sudah tidak haus!");
    
    // Simple drinking system - you can expand this with items
    PlayerData[playerid][pThirst] += 30;
    if(PlayerData[playerid][pThirst] > 100) PlayerData[playerid][pThirst] = 100;
    
    UpdateHungerThirstHUD(playerid);
    
    new string[128];
    format(string, sizeof(string), "* %s meminum sesuatu", PlayerData[playerid][pName]);
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
        {
            SendClientMessage(i, COLOR_PURPLE, string);
        }
    }
    
    SuccessMsg(playerid, "Anda telah minum. Rasa haus berkurang!");
    printf("[DEBUG] Player %d used /drink command", playerid);
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

// ==================== UTILITY FUNCTIONS ====================
ResetPlayerData(playerid)
{
    printf("[DEBUG] Resetting data for player (ID: %d)", playerid);
    
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
    return 1;
}

public KickPlayer(playerid)
{
    printf("[DEBUG] Kicking player %d", playerid);
    return Kick(playerid);
}

public UpdatePlayerTime()
{
    foreach(new i : Player)
    {
        if (PlayerData[i][pLoggedIn] && PlayerData[i][pSpawned])
        {
            PlayerData[i][pSeconds]++;
            if (PlayerData[i][pSeconds] >= 60)
            {
                PlayerData[i][pSeconds] = 0;
                PlayerData[i][pMinutes]++;
                if (PlayerData[i][pMinutes] >= 60)
                {
                    PlayerData[i][pMinutes] = 0;
                    PlayerData[i][pHours]++;
                    printf("[DEBUG] Player %d reached %d hours playtime", i, PlayerData[i][pHours]);
                }
            }
        }
    }
    return 1;
}

// ==================== HUNGER & THIRST FUNCTIONS ====================
UpdateHungerThirstHUD(playerid)
{
    if(!PlayerData[playerid][pLoggedIn] || !PlayerData[playerid][pHudVisible]) return 0;
    
    // Update hunger bar
    new hunger_string[8];
    format(hunger_string, sizeof(hunger_string), "%d", PlayerData[playerid][pHunger]);
    PlayerTextDrawSetString(playerid, BAR_MAKAN[playerid], hunger_string);
    
    // Change color based on hunger level
    if(PlayerData[playerid][pHunger] <= 20)
        PlayerTextDrawColor(playerid, BAR_MAKAN[playerid], COLOR_RED); // Red
    else if(PlayerData[playerid][pHunger] <= 50)
        PlayerTextDrawColor(playerid, BAR_MAKAN[playerid], COLOR_YELLOW); // Yellow
    else
        PlayerTextDrawColor(playerid, BAR_MAKAN[playerid], COLOR_WHITE); // White
        
    PlayerTextDrawShow(playerid, BAR_MAKAN[playerid]);
    
    // Update thirst bar
    new thirst_string[8];
    format(thirst_string, sizeof(thirst_string), "%d", PlayerData[playerid][pThirst]);
    PlayerTextDrawSetString(playerid, BAR_MINUM[playerid], thirst_string);
    
    // Change color based on thirst level
    if(PlayerData[playerid][pThirst] <= 20)
        PlayerTextDrawColor(playerid, BAR_MINUM[playerid], COLOR_RED); // Red
    else if(PlayerData[playerid][pThirst] <= 50)
        PlayerTextDrawColor(playerid, BAR_MINUM[playerid], COLOR_YELLOW); // Yellow
    else
        PlayerTextDrawColor(playerid, BAR_MINUM[playerid], COLOR_WHITE); // White
        
    PlayerTextDrawShow(playerid, BAR_MINUM[playerid]);
    return 1;
}

// ==================== SPEEDOMETER FUNCTIONS ====================
UpdateSpeedometer(playerid)
{
    if(!PlayerData[playerid][pLoggedIn]) return 0;
    
    // Check if player is actually in a vehicle as driver
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) 
    {
        // Hide speedometer if not driver
        if(PlayerData[playerid][pHudVisible])
        {
            HideSpeedometer(playerid);
        }
        return 0;
    }
    
    new vehicleid = GetPlayerVehicleID(playerid);
    if(!vehicleid || vehicleid == INVALID_VEHICLE_ID) return 0;
    
    // Show speedometer if not already visible
    if(!IsSpeedometerVisible(playerid))
    {
        ShowSpeedometer(playerid);
    }
    
    // Get engine status to determine if speed should be 0
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    
    new Float:speed = 0.0;
    
    // Only calculate speed if engine is on
    if(engine == 1)
    {
        new Float:vx, Float:vy, Float:vz;
        GetVehicleVelocity(vehicleid, vx, vy, vz);
        speed = floatsqroot(vx*vx + vy*vy + vz*vz) * 180.0; // Convert to KM/H
    }
    // If engine is off, speed remains 0.0
    
    // Update speed display with proper formatting - PERBAIKAN: Update setiap kali
    new speed_string[16];
    format(speed_string, sizeof(speed_string), "%.0f", speed);
    PlayerTextDrawSetString(playerid, SPEED[playerid], speed_string);
    PlayerTextDrawShow(playerid, SPEED[playerid]);
    
    // Update vehicle health - PERBAIKAN: Realtime update
    new Float:health;
    GetVehicleHealth(vehicleid, health);
    new health_percent = floatround(health/10.0);
    if(health_percent > 100) health_percent = 100;
    if(health_percent < 0) health_percent = 0;
    
    new health_string[8];
    format(health_string, sizeof(health_string), "%d", health_percent);
    PlayerTextDrawSetString(playerid, HP[playerid], health_string);
    
    // Change health color based on condition
    if(health_percent <= 25)
        PlayerTextDrawColor(playerid, HP[playerid], COLOR_RED);
    else if(health_percent <= 50)
        PlayerTextDrawColor(playerid, HP[playerid], COLOR_YELLOW);
    else
        PlayerTextDrawColor(playerid, HP[playerid], COLOR_WHITE);
        
    PlayerTextDrawShow(playerid, HP[playerid]);
    
    // Update fuel (dummy system - you can implement real fuel later)
    PlayerTextDrawSetString(playerid, FUEL[playerid], "100");
    PlayerTextDrawShow(playerid, FUEL[playerid]);
    
    // Update lock status properly
    UpdateVehicleLockStatus(playerid, vehicleid);
    
    return 1;
}

UpdateVehicleLockStatus(playerid, vehicleid)
{
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    
    if(doors == 1) // Vehicle is locked
    {
        PlayerTextDrawSetString(playerid, LOCK[playerid], "LOCKED");
        PlayerTextDrawColor(playerid, LOCK[playerid], COLOR_RED);
        VehicleLocked[vehicleid] = true;
    }
    else // Vehicle is unlocked
    {
        PlayerTextDrawSetString(playerid, LOCK[playerid], "UNLOCKED");
        PlayerTextDrawColor(playerid, LOCK[playerid], COLOR_GREEN);
        VehicleLocked[vehicleid] = false;
    }
    PlayerTextDrawShow(playerid, LOCK[playerid]);
}

// Check if speedometer is currently visible
IsSpeedometerVisible(playerid)
{
    return (PlayerData[playerid][pHudVisible] && GetPlayerState(playerid) == PLAYER_STATE_DRIVER);
}

// Fix issue 3: Optimized speedometer showing
ShowSpeedometer(playerid)
{
    if(!PlayerData[playerid][pLoggedIn]) return 0;
    
    // Only show if player is driver
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 0;
    
    // Show all speedometer elements
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
    
    printf("[DEBUG] Speedometer shown for player (ID: %d)", playerid);
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
    
    printf("[DEBUG] Speedometer hidden for player (ID: %d)", playerid);
    return 1;
}

// ==================== TIMER FUNCTIONS ====================
public UpdateHungerThirst()
{
    foreach(new i : Player)
    {
        if (PlayerData[i][pLoggedIn] && PlayerData[i][pSpawned])
        {
            // Decrease hunger and thirst every 10 seconds
            if(PlayerData[i][pHunger] > 0) PlayerData[i][pHunger]--;
            if(PlayerData[i][pThirst] > 0) PlayerData[i][pThirst]--;
            
            // Update HUD
            UpdateHungerThirstHUD(i);
            
            // Health effects
            CheckHungerThirstEffects(i);
        }
    }
    return 1;
}
CheckHungerThirstEffects(playerid)
{
    // Critical hunger effects
    if(PlayerData[playerid][pHunger] <= 0)
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        if(health > 10.0)
        {
            SetPlayerHealth(playerid, health - 5.0);
            ErrorMsg(playerid, "Anda sangat kelaparan! Kesehatan menurun!");
        }
    }
    else if(PlayerData[playerid][pHunger] <= 20)
    {
        if(random(100) < 5) // 5% chance every update
        {
            WarningMsg(playerid, "Anda merasa sangat lapar. Cari makanan segera!");
        }
    }
    
    // Critical thirst effects
    if(PlayerData[playerid][pThirst] <= 0)
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        if(health > 10.0)
        {
            SetPlayerHealth(playerid, health - 3.0);
            ErrorMsg(playerid, "Anda sangat kehausan! Kesehatan menurun!");
        }
    }
    else if(PlayerData[playerid][pThirst] <= 20)
    {
        if(random(100) < 5) // 5% chance every update
        {
            WarningMsg(playerid, "Anda merasa sangat haus. Cari minuman segera!");
        }
    }
    
    return 1;
}

// ==================== VEHICLE CALLBACKS ====================
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if(!ispassenger && PlayerData[playerid][pLoggedIn])
    {
        // Fix issue 3: Add small delay before showing to prevent lag
        SetTimerEx("DelayedShowSpeedometer", 200, false, "d", playerid);
        
        // Fix issue 1: Start real-time timer for speedometer updates
        KillTimer(PlayerSpeedometerTimer[playerid]); // Kill any existing timer
        PlayerSpeedometerTimer[playerid] = SetTimerEx("UpdateSpeedometer", 100, true, "d", playerid);
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if(PlayerData[playerid][pLoggedIn])
    {
        HideSpeedometer(playerid);
        
        // Fix issue 1: Kill the speedometer timer when exiting vehicle
        KillTimer(PlayerSpeedometerTimer[playerid]);
        PlayerSpeedometerTimer[playerid] = 0;
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(!PlayerData[playerid][pLoggedIn]) return 1;
    
    // Player became driver
    if(newstate == PLAYER_STATE_DRIVER)
    {
        SetTimerEx("DelayedShowSpeedometer", 200, false, "d", playerid);
        KillTimer(PlayerSpeedometerTimer[playerid]);
        // PERBAIKAN: Timer yang lebih cepat untuk realtime update (50ms)
        PlayerSpeedometerTimer[playerid] = SetTimerEx("UpdateSpeedometer", 50, true, "d", playerid);
    }
    // Player is no longer driver
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
    // Check if player pressed W (forward key) while in vehicle
    if(newkeys & KEY_UP)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
            
            // PERBAIKAN: Cek jika kendaraan terkunci
            if(doors == 1) // Vehicle is locked
            {
                // Matikan engine jika locked
                SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
                ErrorMsg(playerid, "Kendaraan terkunci! Buka kunci terlebih dahulu dengan /unlock");
                return 1;
            }
        }
    }
    
    // Check if player tries to start engine while vehicle is locked
    if(newkeys & KEY_SECONDARY_ATTACK) // Default engine key
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
            
            if(doors == 1) // Vehicle is locked
            {
                ErrorMsg(playerid, "Tidak bisa menyalakan mesin! Kendaraan terkunci.");
                return 1;
            }
        }
    }
    
    return 1;
}

// Helper function for delayed speedometer showing
forward DelayedShowSpeedometer(playerid);
public DelayedShowSpeedometer(playerid)
{
    if(PlayerData[playerid][pLoggedIn] && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        ShowSpeedometer(playerid);
        UpdateSpeedometer(playerid); // Initial update
    }
    return 1;
}

// ==================== LOCK/UNLOCK COMMANDS ====================
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
    
    // Update speedometer if player is in this vehicle
    if(GetPlayerVehicleID(playerid) == vehicleid && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        UpdateVehicleLockStatus(playerid, vehicleid);
    }
    
    SuccessMsg(playerid, "Kendaraan berhasil dikunci!");
    
    // Show action to nearby players
    new string[128];
    format(string, sizeof(string), "* %s mengunci kendaraan", PlayerData[playerid][pName]);
    
    new Float:x, Float:y, Float:z;
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
    
    // Update speedometer if player is in this vehicle
    if(GetPlayerVehicleID(playerid) == vehicleid && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        UpdateVehicleLockStatus(playerid, vehicleid);
    }
    
    SuccessMsg(playerid, "Kendaraan berhasil dibuka kuncinya!");
    
    // Show action to nearby players
    new string[128];
    format(string, sizeof(string), "* %s membuka kunci kendaraan", PlayerData[playerid][pName]);
    
    new Float:x, Float:y, Float:z;
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

// Helper function to find closest vehicle
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

forward CheckVehicleLockStatus();
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
                
                // Jika kendaraan terkunci dan mesin menyala, matikan mesin
                if(doors == 1 && engine == 1)
                {
                    SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
                    ErrorMsg(i, "Mesin dimatikan karena kendaraan terkunci!");
                }
            }
        }
    }
    return 1;
}