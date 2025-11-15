// ==================== UTILITIES ====================
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

#define ServerMsg(%0,%1) SendClientMessageEx(%0, COLOR_BLUE, "[SERVER]:"COLOR_HEX_WHITE" "%1)
#define AdminMsg(%0,%1) SendClientMessageEx(%0, COLOR_DANGER, "[ADMIN]:"COLOR_HEX_WHITE" "%1)
#define SyntaxMsg(%0,%1) SendClientMessageEx(%0, COLOR_MUTED, "[SYNTAX]:"COLOR_HEX_WHITE" "%1)
#define InfoMsg(%0,%1) SendClientMessageEx(%0, COLOR_INFO, "[INFO]:"COLOR_HEX_WHITE" "%1)
#define UsageMsg(%0,%1) SendClientMessageEx(%0, COLOR_SUCCESS, "[USAGE]:"COLOR_HEX_WHITE" "%1)
#define SuccessMsg(%0,%1) SendClientMessageEx(%0, COLOR_SUCCESS, "[SUCCESS]:"COLOR_HEX_WHITE" "%1)
#define WarningMsg(%0,%1) SendClientMessageEx(%0, COLOR_WARNING, "[WARNING]:"COLOR_HEX_WHITE" "%1)
#define ErrorMsg(%0,%1) SendClientMessageEx(%0, COLOR_DANGER, "[ERROR]:"COLOR_HEX_WHITE" "%1)
