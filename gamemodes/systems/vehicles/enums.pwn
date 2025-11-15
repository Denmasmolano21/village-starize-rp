// Vehicle System - Enums (Enhanced)
// VS:RP v1.0.4

enum E_VEHICLE_DATA
{
    vID,
    vModel,
    Float:vX,
    Float:vY,
    Float:vZ,
    Float:vA,
    vColor1,
    vColor2,
    vFuel,
    Float:vHealth,
    Float:vMaxFuel,
    Float:vFuelConsumption,
    vOwner,
    vOwnerName[MAX_PLAYER_NAME],
    vPrice,
    vPlate[32],
    bool:vLocked,
    bool:vEngine,
    bool:vLights,
    bool:vAlarm,
    bool:vDoors,
    bool:vBonnet,
    bool:vBoot,
    vVirtualWorld,
    vInterior,
    vParkX,
    vParkY,
    vParkZ,
    vParkA,
    vInsurance,
    vMileage,
    Text3D:vLabel,
    vLastUsed
}

// Vehicle Types
enum
{
    VEHICLE_TYPE_NONE,
    VEHICLE_TYPE_PERSONAL,
    VEHICLE_TYPE_FACTION,
    VEHICLE_TYPE_JOB,
    VEHICLE_TYPE_RENTAL,
    VEHICLE_TYPE_DEALER
}

// Fuel System
#define MAX_FUEL 100.0
#define FUEL_CONSUMPTION_RATE 0.1 // per second when engine on

// Vehicle Colors
#define VEHICLE_COLOR_RANDOM -1