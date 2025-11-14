// Account System - Enums
// VS:RP v1.0.4

#define MAX_PASSWORD_LENGTH 65
#define MIN_PASSWORD_LENGTH 6
#define MIN_AGE             15
#define MAX_AGE             80

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
}

// Jobs
enum
{
    JOB_NONE,
    JOB_FARMER,
    JOB_FISHERMAN,
    JOB_MINER,
    JOB_LUMBERJACK
}

// Player Data Structure
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
    bool:pHudVisible,
    Text3D:pDisconnectLabel
}