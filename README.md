# Village Story Roleplay - v1.0.4

## 📋 Changelog v1.0.4

### ✅ Fixed Issues
1. **Speedometer MPH Display** - Fixed real-time speed updates (50ms timer)
2. **Vehicle HP Display** - Now updates in real-time with proper color coding
3. **Last Coordinates** - Automatically saves player position on disconnect
4. **Disconnect 3D Label** - Shows player name and disconnect reason for 30 seconds

### ✨ New Features
- **Modular Structure** - Organized into separate system folders
- **Essential Debugging** - Only critical logs, removed excessive debug messages
- **Optimized Loops** - Minimized unnecessary iterations
- **Better Code Structure** - Each system has its own enums, variables, forwards, and functions

## 📁 File Structure

```
gamemodes/
├── vsrp.pwn (Main file)
└── systems/
    ├── accounts/
    │   ├── enums.pwn
    │   ├── variables.pwn
    │   ├── forwards.pwn
    │   └── functions.pwn
    ├── vehicles/
    │   ├── enums.pwn
    │   ├── variables.pwn
    │   ├── forwards.pwn
    │   └── functions.pwn
    ├── hud/
    │   ├── variables.pwn
    │   └── functions.pwn
    ├── core/
    │   ├── timers.pwn
    │   └── callbacks.pwn
    └── commands/
        ├── player.pwn
        ├── vehicle.pwn
        └── admin.pwn
```

## 🚀 Installation

1. **Create the folder structure** as shown above in your `gamemodes` directory

2. **Copy all files** to their respective locations:
   - Main file: `vsrp.pwn`
   - System files in `systems/` folder

3. **Configure MySQL** in `vsrp.pwn`:
   ```pawn
   #define MYSQL_HOST          "localhost"
   #define MYSQL_USER          "root"
   #define MYSQL_PASSWORD      ""
   #define MYSQL_DATABASE      "vsrp"
   ```

4. **Compile** the gamemode using your PAWN compiler

5. **Update server.cfg**:
   ```
   gamemode0 vsrp 1
   ```

## 🎮 Player Commands

### Basic Commands
- `/stats` - View character statistics
- `/help` - Command list
- `/mypos` - Show current position
- `/hud` - Toggle HUD visibility

### Survival Commands
- `/eat` - Eat food (restores hunger)
- `/drink` - Drink water (restores thirst)

### Social Commands
- `/me [action]` - Roleplay action
- `/do [description]` - Environment description
- `/ooc [message]` - Out of character chat

### Vehicle Commands
- `/engine` - Toggle vehicle engine
- `/lock` - Lock nearby vehicle
- `/unlock` - Unlock nearby vehicle

## 👮 Admin Commands (Level 1+)

- `/veh [modelid]` - Spawn a vehicle
- `/goto [playerid]` - Teleport to player
- `/gethere [playerid]` - Bring player to you
- `/kick [playerid] [reason]` - Kick player
- `/sethp [playerid] [amount]` - Set player health
- `/repair` - Repair vehicle
- `/flip` - Flip vehicle
- `/a [message]` - Admin chat
- `/ann [message]` - Server announcement

## 🔧 Admin Commands (Level 2+)

- `/setmoney [playerid] [amount]` - Set player money

## 📊 Features

### Account System
- Secure bcrypt password hashing
- Character customization (age, gender, origin)
- Automatic data saving
- Login attempts protection

### HUD System
- Player name display
- Hunger and thirst bars with color indicators
- Dynamic speedometer (shows only when driving)
- Real-time vehicle health display
- Vehicle lock status indicator
- Fuel system (placeholder - ready for expansion)

### Vehicle System
- Manual engine control
- Lock/unlock system
- Real-time speedometer updates (50ms)
- Vehicle health color coding:
  - Green: 51-100%
  - Yellow: 26-50%
  - Red: 0-25%

### Survival System
- Hunger and thirst mechanics
- Health effects when starving/dehydrated
- Warning messages at critical levels
- Color-coded status bars

### Disconnect System
- Saves last player position
- Creates 3D text label showing:
  - Player name
  - Disconnect reason (Timeout/Leaving/Kicked)
  - Auto-removes after 30 seconds

## 🔨 Database

The gamemode automatically creates the required tables on first run. No manual database setup needed!

**Table:** `players`
- Stores all player data
- Auto-incremented ID
- Secure password storage
- Position tracking
- Statistics and playtime

## ⚙️ Configuration

### Spawn Location
Edit in main file if needed:
```pawn
#define SPAWN_X    226.53
#define SPAWN_Y    -303.74
#define SPAWN_Z    1.92
#define SPAWN_A    273.56
```

### Hunger/Thirst Settings
Located in `systems/core/timers.pwn`:
- Default decrease: Every 10 seconds
- Health damage when depleted
- Warning thresholds: 20% and below

### Timer Intervals
- Player time update: 1000ms (1 second)
- Hunger/thirst update: 10000ms (10 seconds)
- Speedometer update: 50ms (real-time)

## 🐛 Debugging

Essential debugging is enabled only for:
- MySQL connection status
- Player login/registration
- Critical errors

To add more debugging, use:
```pawn
printf("[DEBUG] Your message here");
```

## 📝 Adding New Systems

To add a new system (e.g., "jobs"):

1. Create folder: `systems/jobs/`
2. Create files:
   - `enums.pwn` - Data structures
   - `variables.pwn` - Variables
   - `forwards.pwn` - Function forwards
   - `functions.pwn` - Main logic
3. Include in main file:
   ```pawn
   #include "systems/jobs/enums.pwn"
   #include "systems/jobs/variables.pwn"
   #include "systems/jobs/forwards.pwn"
   #include "systems/jobs/functions.pwn"
   ```

## 💡 Tips

1. **Keep systems modular** - Don't mix different system codes
2. **Use forward declarations** - Always declare functions in forwards.pwn
3. **Minimize loops** - Use foreach with y_iterate for player loops
4. **Essential logging only** - Remove debug messages in production

## 🆘 Support

If you encounter issues:
1. Check console for error messages
2. Verify MySQL connection
3. Ensure all files are in correct folders
4. Check PAWN compiler output

## 📄 License

Free to use and modify for your SA-MP server.

---

**Version:** 1.0.4  
**Last Updated:** 2024  
**Author:** Village Story Team