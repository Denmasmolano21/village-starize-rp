// Village Story Roleplay Gamemode
// Version 1.0.4

#pragma tabsize 0

#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#include <streamer>
#include <Pawn.CMD>
#include <Pawn.Regex>
#include <samp_bcrypt>
#include <crashdetect>

#define YSI_NO_HEAP_MALLOC
#include <YSI_Coding\y_timers>
#include <YSI_Data\y_iterate>

// ==================== CONFIGURATION ====================
#define SERVER_NAME         "Village Story Roleplay"
#define SERVER_NAME_TAG     "{00A6FB}VS:RP{FFFFFF}"
#define SERVER_VERSION      "1.0.4"
#define SERVER_MODE         "VS:RP v1.0.4"

// MySQL Configuration
#define MYSQL_HOST          "localhost"
#define MYSQL_USER          "root"
#define MYSQL_PASSWORD      ""
#define MYSQL_DATABASE      "vsrp"

// Base Colors (0xRRGGBBAA)
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

// HEX Colors
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
#define COLOR_HEX_SUCCESS   "{D1F2D1}"
#define COLOR_HEX_WARNING   "{FFF4CC}"
#define COLOR_HEX_DANGER    "{FAD4D4}"
#define COLOR_HEX_INFO      "{D9ECFA}"
#define COLOR_HEX_MUTED     "{F2F2F2}"

#if !defined IsValidVehicle
    native IsValidVehicle(vehicleid);
#endif

// Fixed spawn coordinates
#define SPAWN_X             226.53
#define SPAWN_Y             -303.74
#define SPAWN_Z             1.92
#define SPAWN_A             273.56

// ==================== INCLUDES - MODULAR SYSTEM ====================
#include "systems/core/messages.pwn"
#include "systems/accounts/enums.pwn"
#include "systems/accounts/variables.pwn"
#include "systems/accounts/forwards.pwn"
#include "systems/vehicles/enums.pwn"
#include "systems/vehicles/variables.pwn"
#include "systems/vehicles/forwards.pwn"
#include "systems/hud/variables.pwn"
#include "systems/hud/functions.pwn"
#include "systems/accounts/functions.pwn"
#include "systems/vehicles/functions.pwn"
#include "systems/core/timers.pwn"
#include "systems/core/callbacks.pwn"
#include "systems/commands/player.pwn"
#include "systems/commands/vehicle.pwn"
#include "systems/commands/admin.pwn"

main() {}

public OnGameModeInit()
{
    printf("%s v%s", SERVER_NAME, SERVER_VERSION);
    print("Loading gamemode...");
    
    SetGameModeText(SERVER_MODE);

    // Server Settings
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    ShowNameTags(0);
    SetNameTagDrawDistance(20.0);
    EnableStuntBonusForAll(0);
    DisableInteriorEnterExits();
    ManualVehicleEngineAndLights();
    Streamer_SetTickRate(1);
    Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT, 1000);
    Streamer_MaxItems(STREAMER_TYPE_OBJECT, MAX_OBJECTS);

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

    printf("[MySQL] Connected successfully! Handle: %d", _:g_SQL);

    // Create Tables
    CreateDatabaseTables();

    // Dynamic Objects
    CreateDynamic3DTextLabel(
        "{00A6FB}[Village Story]\n{FFFFFF}Selamat Datang!\nKetik {00FF00}/help {FFFFFF}untuk bantuan.", 
        COLOR_GRAY, 229.39, -304.55, 1.57, 10.0);

    // Start core timers
    SetTimer("UpdatePlayerTime", 1000, true);
    SetTimer("UpdateHungerThirst", 10000, true);

    printf("%s loaded successfully!", SERVER_NAME);
    return 1;
}

public OnGameModeExit()
{
    print("[Server] Saving all player data...");
    
    foreach(new i : Player)
    {
        if (PlayerData[i][pLoggedIn])
        {
            SavePlayerData(i);
        }
    }

    DestroyGlobalTextdraws();
    mysql_close(g_SQL);
    
    print("[Server] Gamemode exited successfully");
    return 1;
}