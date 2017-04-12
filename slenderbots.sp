#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <tf2attributes>

public Plugin:myinfo = {
    name = "SlenderBots",
    author = "TehPlayer14",
    description = "Allows TFbots to play sf2",
    version = "1.0",
    url = ""
};
new ICarrier;

new bool:IsBotReadyToPickUpPage[MAXPLAYERS];

new bool:IsBotReadyToHitButton[MAXPLAYERS];

new bool:bDebugEnabled = false; //debug for flag visiblity

new bool:bEscape;

new bool:IsPickable[2049];

new bool:IsTargetedPage[2049];

new bool:IsTargetedPage2[2049];

new bool:UnderGround;

new bool:BsetupComp;

new iPageCounter = -1;

//pages are prop_dynamic_override

//Flag (Bot1) WithFlag(Bot2)

//sf2_escape_trigger (trigger_multiple)

//add counter for max pages and if is valid targeted page

public OnPluginStart()
{
	HookEvent( "teamplay_round_win", OnRoundWin );
	HookEvent("teamplay_round_start", RoundStart);
	HookEvent("teamplay_flag_event", EventHook_FlagStuff);
//	HookEscapeEvent()
}
public OnMapStart()
{
	UnderGround = false;
	decl String:map[42];
	GetCurrentMap(map,sizeof(map));
	if (StrEqual(map, "slender_underground_r1"))
	{
		UnderGround = true;
	}
}
public EventHook_FlagStuff(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetEventInt(event, "eventtype") == TF_FLAGEVENT_PICKEDUP )
	{
		new client = GetEventInt(event, "player");
		ICarrier = client;
		//new i3 = -1;
		//while ((i3 = FindEntityByClassname(i3, "item_teamflag")) != -1)
		//	if(!IsFakeClient(client))
		//		AcceptEntityInput( i3, "ForceDrop" );
	}
	if (GetEventInt(event, "eventtype") == TF_FLAGEVENT_DROPPED )
	{
		ICarrier = -1;
		//new client = GetClientOfUserId(GetEventInt(event, "userid"));
		//new i3 = -1;
		//while ((i3 = FindEntityByClassname(i3, "item_teamflag")) != -1)
		//{
		//	if(IsPickable[i3])
		//		AcceptEntityInput(i3, "Disable");
		//}
		//new client = GetClientUserId(GetEventInt(event, "player"));
		if(bDebugEnabled)
			PrintToChatAll("flag dropped");
		
		if(!bEscape)
			CreateTimer(1.0, Timer_d2);
		
	}
}
public Action:Timer_d2(Handle:timer)
{
	TeleportDroppedFlagToBot();
}
stock FindPickableFlag()
{
	new i3 = -1;
	while ((i3 = FindEntityByClassname(i3, "item_teamflag")) != -1)
	{
		if(IsPickable[i3])
			return i3;
	}
	return -1;		
}
stock TeleportDroppedFlagToBot()//
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
			if(IsFakeClient(i) && GetClientTeam(i) == _:TFTeam_Red)
			{
				new iflag = FindPickableFlag();
				new Float:Position[3];
				GetClientAbsOrigin(i, Position);
				TeleportEntity(iflag, Position, NULL_VECTOR, NULL_VECTOR);
				return;
				//PrintToChatAll("flag teleported");
			}
	}

}

stock HookEscapeEventUnder()
{
	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "func_button")) != -1)
	{
		decl String:strName[50];
		GetEntPropString(i5, Prop_Data, "m_iName", strName, sizeof(strName));
		if(strcmp(strName, "escape_button") == 0)
		{
			HookSingleEntityOutput(i5, "OnDamaged", LogicEscapeOnUnder);
		}
	}
}
stock HookEscapeEvent()
{
	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "info_target")) != -1)
	{
		decl String:strName[50];
		GetEntPropString(i5, Prop_Data, "m_iName", strName, sizeof(strName));
		if(strcmp(strName, "sf2_logic_escape") == 0)
		{
			HookSingleEntityOutput(i5, "OnUser1", LogicEscapeOn);
		}
	}
}
stock bool:IsValidSF2Page(page)
{
	decl Float:pos[3]={0.0,0.0,0.0}
	
	new Float:flPos5[3];
	GetEntPropVector( page, Prop_Send, "m_vecOrigin", flPos5 );
	new Float:flDistance2 = GetVectorDistance(pos, flPos5);
	if(flDistance2 < 10)
		return false;
	if(!IsValidEntity(page))
		return false;
	decl String:strName[50];
	GetEntPropString(page, Prop_Data, "m_iName", strName, sizeof(strName));
	if(StrContains(strName, "sf2_page", false) != -1 && strcmp(strName, "sf2_page_model") != 0)
		return true;
	else
		return false;
}

stock bool:WasValidSF2Page(page)
{
	if(!IsValidEntity(page))
		return false;
	decl String:strName[50];
	GetEntPropString(page, Prop_Data, "m_iName", strName, sizeof(strName));
	if(StrContains(strName, "sf2_page", false) != -1 && strcmp(strName, "sf2_page_model") != 0)
		return true;
	else
		return false;
}
stock TeleportFlagsToGenerator()
{
	new FLAGT = FindEntityByClassname(-1,"item_teamflag");
	new FLAGT2 = FindEntityByClassname(-1,"func_capturezone");
	decl Float:position[3];
	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "func_button")) != -1)
	{
		decl String:strName[50];
		GetEntPropString(i5, Prop_Data, "m_iName", strName, sizeof(strName));
		if(strcmp(strName, "escape_button") == 0)
		{
			GetEntPropVector(i5, Prop_Send, "m_vecOrigin", position);
			TeleportEntity(FLAGT, position, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(FLAGT2, position, NULL_VECTOR, NULL_VECTOR);
		}
	}
}
public LogicEscapeOnUnder(const char[] output,int iEnt,int activator, float delay)
{
	//bEscape = true;
	TeleportFlagToExit();
	TeleportFuncToExit();
	MakeBotsSprint();
	
	//add case for underground
}
public LogicEscapeOn(const char[] output,int iEnt,int activator, float delay)
{
	bEscape = true;
	MakeBotsSprint();
	if(UnderGround)
		TeleportFlagsToGenerator();
	else
	{
		TeleportFlagToExit();
		TeleportFuncToExit();
	}
}
stock MakeBotsSprint()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
			if(IsFakeClient(i) && GetClientTeam(i) == _:TFTeam_Red)
			{
					CreateTimer(0.01, Timer_SSprint, i);
					CreateTimer(8.0, Timer_StopSprint, i);
			}
	}
}
public Action:OnRoundWin(Handle:event, const String:name[], bool: dontBroadcast)
{
	new i3 = -1;
	while ((i3 = FindEntityByClassname(i3, "item_teamflag")) != -1)
		if(IsPickable[i3])
			IsPickable[i3] = false	
}
public Action:RoundStart(Handle:event, const String:name[], bool: dontBroadcast)
{	
	ICarrier = -1;
	BsetupComp = false;
	CreatePointInter();
	HookEscapeEvent();
	if(UnderGround)
		HookEscapeEventUnder();
	
	bEscape = false;

	CreateTimer(1.5, Timer_SetUP);
	CreateTimer(5.7, Timer_CheckPageExistance,_ ,TIMER_REPEAT);
}
stock SlayBots()
{
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			if(IsFakeClient(i) && GetClientTeam(i) == _:TFTeam_Red)
				SDKHooks_TakeDamage(i, 0, 0, 99999.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
}
public Action:Timer_CheckPageExistance(Handle:timer)
{
	if(bEscape)
	{
		TeleportFlagToExit();
		return Plugin_Stop;
	}
	if(GameRules_GetRoundState() == RoundState_TeamWin)
		return Plugin_Stop;
	if(!bEscape)
		TeleportFlagToPage();	
	return Plugin_Continue;
}

stock TeleportFlagToExit()
{
	new FLAGT = FindEntityByClassname(-1,"item_teamflag");
	if(UnderGround)
	{
		TeleportEntity(FLAGT, Float:{4317.869628, -872.420410, 468.927185}, NULL_VECTOR, NULL_VECTOR); 
		return;
	}
	else
	{

		decl Float:position[3];
		new i5 = -1;
		while((i5 = FindEntityByClassname(i5, "trigger_multiple")) != -1)
		{
			decl String:strName[50];
			GetEntPropString(i5, Prop_Data, "m_iName", strName, sizeof(strName));
			if(StrContains(strName, "sf2_escape_trigge", false) != -1)
			{
				GetEntPropVector(i5, Prop_Send, "m_vecOrigin", position);
				TeleportEntity(FLAGT, position, NULL_VECTOR, NULL_VECTOR);
				break;
			}
		}
	}
}

stock TeleportFuncToExit()
{
	new FLAGT = FindEntityByClassname(-1,"func_capturezone");
	if(UnderGround)
	{
		TeleportEntity(FLAGT, Float:{4317.869628, -872.420410, 468.927185}, NULL_VECTOR, NULL_VECTOR); 
		return;
	}
	else
	{
		decl Float:position[3];
		new i5 = -1;
		while((i5 = FindEntityByClassname(i5, "trigger_multiple")) != -1)
		{
			decl String:strName[50];
			GetEntPropString(i5, Prop_Data, "m_iName", strName, sizeof(strName));
			if(StrContains(strName, "sf2_escape_trigge", false) != -1)
			{
				GetEntPropVector(i5, Prop_Send, "m_vecOrigin", position);
				TeleportEntity(FLAGT, position, NULL_VECTOR, NULL_VECTOR);
				break;
			}
		}
	}
}


/*public Action:Timer_CheckPageExistance(Handle:timer)
{
	PrintToChatAll("timer chk runned");
	new FLAGT = FindEntityByClassname(-1,"item_teamflag");

	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "prop_dynamic")) != -1)
	{
		//decl String:strName[50];
		//GetEntPropString(i5, Prop_Data, "m_iName", strName, sizeof(strName));
		if(IsValidSF2Page(i5))
		{
			new Float:flPos12[3];
			GetEntPropVector( FLAGT, Prop_Send, "m_vecOrigin", flPos12 );
			//PrintToChatAll("got flagt pos");
			
			new Float:flPos22[3];
			GetEntPropVector( i5, Prop_Send, "m_vecOrigin", flPos22 );
			new Float:flDistance2 = GetVectorDistance(flPos12, flPos22);
			PrintToChatAll("Dist: %0.0f ", flDistance2);
			if(flDistance2 == 0)
			{
				PrintToChatAll("passed the dist");
				TargetedPages += 1;
				PrintToChatAll("Createtimar");
				//CreateTimer(1.0, Timer_CheckTargetedPageCount);
			}
			CreateTimer(0.5, Timer_CheckTargetedPageCount);
		}
	}
}*/
/*public Action:Timer_CheckTargetedPageCount(Handle:timer)
{
	PrintToChatAll("Timarpassed");
//	PrintToChatAll("Pages %i, TargetedPages");
	if(TargetedPages < 1)
	{
		TeleportFlagToPage();
	}
	if(TargetedPages >= 1)
		TargetedPages = 0;
	return Plugin_Continue;
}*/

public Action:Timer_SetUP(Handle:timer)
{
	BsetupComp = true;
	SpawnNonPickableFlag();
	
	SpawnPickableFlag();
	SpawnFuncCapturezone();
	
	TeleportFlagToPage();
	TeleportFuncToPage();
	
	FindPlayingBots();
}

stock FindPlayingBots()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
			if(IsFakeClient(i) && GetClientTeam(i) == _:TFTeam_Red)
			{
				SDKHooks_TakeDamage(i, 0, 0, 99999.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
				//if(UnderGround)
				if(GetRandomInt(0,4) > 3)
				{
					//FakeClientCommand( i, "+sprint" );
					CreateTimer(6.0, Timer_BotStartSprint, i);
				}
				TF2Attrib_SetByName(i, "melee range multiplier", 2.6);// patch
				CreateTimer(0.2, Timer_BotStatus, i, TIMER_REPEAT);
				CreateTimer(0.5, Timer_BotSafety, i, TIMER_REPEAT);
				//PrintToChatAll("Found a bot");
			}
			else if(!IsFakeClient(i) && GetClientTeam(i) == _:TFTeam_Red)
				TF2Attrib_SetByName(i, "cannot pick up intelligence", 1.0);
	}
}
public Action:Timer_BotStartSprint(Handle:timer, any:Bot)
{
	CreateTimer(4.0, Timer_BotStopSprint, Bot);
	FakeClientCommand( Bot, "+sprint" );
}
public Action:Timer_BotStopSprint(Handle:timer, any:Bot)
{
	FakeClientCommand( Bot, "-sprint" );
}
//public OnEntityCreated( iEntity, const String:strClassname[] )
//{
//	CreateTimer(0.1, Timer_OnEntCreated, iEntity);
//}
stock Entity_GetClassName(entity, String:buffer[], size)
{
	GetEntPropString(entity, Prop_Data, "m_iClassname", buffer, size);
	
	if (buffer[0] == '\0') 	
	{
		return false;
	}
	
	return true;
}
stock BotSlenderHint(Slenderhitbox)
{
	SpawnBlockBrush(Slenderhitbox);
	//UpdateBlockers();
}
stock UpdateBlockers()
{
	new pointinter = FindEntityByClassname(-1,"tf_point_nav_interface");
	AcceptEntityInput(  pointinter, "RecomputeBlockers" );
	
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			if(IsFakeClient(i) && GetClientTeam(i) == _:TFTeam_Red)
			{
				new i5 = -1;
				while((i5 = FindEntityByClassname(i5, "item_teamflag")) != -1)
				{
					new Float:Position[3];
					GetClientAbsOrigin(i, Position);
					//GetEntPropVector(Slenderhitbox, Prop_Send, "m_vecOrigin", Position);
					TeleportEntity(i5, Position, NULL_VECTOR, NULL_VECTOR);
				}
			}
	
}
stock CreatePointInter()
{
	new teamflags = CreateEntityByName("tf_point_nav_interface");
	if(IsValidEntity(teamflags))
	{
		DispatchKeyValue(teamflags, "targetname", "Interface444");
		DispatchSpawn(teamflags);
	}
}
stock SpawnBlockBrush(Slenderhitbox)//fix this
{
	new entindex = CreateEntityByName("func_brush");
	if (entindex != -1) //dispatch ent properites
	{
		DispatchKeyValue(entindex, "StartDisabled", "0");
		//DispatchKeyValue(entindex, "TeamNum", "2");
		DispatchKeyValue(entindex, "spawnflags", "2");
		DispatchKeyValue(entindex, "targetname", "FuncBrushTest");
	}

	DispatchSpawn(entindex);
	ActivateEntity(entindex);

	PrecacheModel("models/player/items/pyro/drg_pyro_fueltank.mdl");
	SetEntityModel(entindex, "models/player/items/pyro/drg_pyro_fueltank.mdl");

	new Float:minbounds[3] = {-300.0, -300.0, -100.0};
	new Float:maxbounds[3] = {300.0, 300.0, 200.0};
	SetEntPropVector(entindex, Prop_Send, "m_vecMins", minbounds);
	SetEntPropVector(entindex, Prop_Send, "m_vecMaxs", maxbounds);
    
	//new String:strBuffer[60];
	//GetCmdArg(2, strBuffer, sizeof(strBuffer)); //solidity type
	
	SetEntProp(entindex, Prop_Send, "m_nSolidType", 2)
	//SetEntProp(entindex, Prop_Send, "m_nSolidType", StringToInt(strBuffer));//

	new enteffects = GetEntProp(entindex, Prop_Send, "m_fEffects");
	enteffects |= 32;
	SetEntProp(entindex, Prop_Send, "m_fEffects", enteffects);
	
	new Float:Position[3];
	//GetClientAbsOrigin(client, Position);
	GetEntPropVector(Slenderhitbox, Prop_Send, "m_vecOrigin", Position);
	TeleportEntity(entindex, Position, NULL_VECTOR, NULL_VECTOR);
	PrintToChatAll("Created the blocker %f %f %f",Position[0],Position[1],Position[2]);
	UpdateBlockers();
	CreateTimer(0.1, Timer_KillBrush, entindex);
	//SetVariantString("!activator");
	//AcceptEntityInput(entindex, "SetParent", Slenderhitbox);

	//PrintToChatAll("Created the blocker %f %f %f",Position[0],Position[1],Position[2]);
}
public Action:Timer_KillBrush(Handle:timer, any:ient)
{
	AcceptEntityInput(ient, "Kill");
}
public Action:Timer_OnEntCreated(Handle:timer, any:ient)
{
	if(IsValidEntity(ient) && BsetupComp)
	{
		new String:sEnt[255];
		Entity_GetClassName(ient,sEnt,sizeof(sEnt));
		//PrintToChatAll("CLassname %s",sEnt);
		if (StrEqual(sEnt, "monster_generic"))
			BotSlenderHint(ient);
	}
		
}
public Action:Timer_BotSafety(Handle:timer, any:Bot)
{
	if(GetClientTeam(Bot) != _:TFTeam_Red)
		return Plugin_Stop;
	checkbossdist(Bot);
	//UpdateBlockers();
		
	return Plugin_Continue;
}
stock checkbossdist(client)
{
	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "monster_generic")) != -1)//base boss just no
	{
		if(IsValidEntity(i5))
		{
			new Float:flPos1[3];
			GetClientAbsOrigin(client, flPos1);
			
			new Float:flPos2[3];
			GetEntPropVector( i5, Prop_Send, "m_vecOrigin", flPos2 );
			new Float:flDistance = GetVectorDistance(flPos1, flPos2);
			if(flDistance < 700)
			{
				FakeClientCommand( client, "+sprint" );
				CreateTimer(6.0, Timer_StopSprint, client);
			}
		}
	}
	
}
		
public Action:Timer_BotStatus(Handle:timer, any:Bot)
{
	if(GetClientTeam(Bot) != _:TFTeam_Red)
		return Plugin_Stop;
		
	if(!bEscape)
		CheckFlagDist(Bot);
	else
		CheckButtonDist(Bot)
		//return Plugin_Stop;
	
	return Plugin_Continue;
}
FindNearestPage(client)
{
	new Float:pVec[3];
	new Float:nVec[3];
	GetClientEyePosition(client, pVec); 
	new found = -1;
	new Float:MAX_DIST = 10000.0;
	new Float:found_dist = MAX_DIST;
	new Float:aux_dist;
	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "prop_dynamic")) != -1)
	{
		//PrintToChatAll("PAG FND");
		if(IsValidSF2Page(i5)) // && !IsTargetedPage2[i5]
		{
			GetEntPropVector(i5, Prop_Send, "m_vecOrigin", nVec);
			//GetClientEyePosition(i, nVec);
			aux_dist = GetVectorDistance(pVec, nVec, false);
			if(aux_dist < found_dist)
			{
					found = i5;
					found_dist = aux_dist;
			}
		}
	}
	return found;
}
stock TeleportFuncToPage()
{
	new FUNCT = FindEntityByClassname(-1,"func_capturezone");
	decl Float:position[3];
	new i5 = -1;
	//PrintToChatAll("Before while");
	while((i5 = FindEntityByClassname(i5, "prop_dynamic")) != -1)
	{
		//PrintToChatAll("PAG FND");
		if(IsValidSF2Page(i5))
		{
			if(!IsTargetedPage[i5])
			{
				GetEntPropVector(i5, Prop_Send, "m_vecOrigin", position);
				TeleportEntity(FUNCT, position, NULL_VECTOR, NULL_VECTOR);
				//PrintToChatAll("teleported funccap");
				IsTargetedPage2[i5] = true;
				break;
			}
			if(!IsThereAny1stBot())
			{
				new client = GetRandomPlayer(2);
				new i6 = FindNearestPage(client);
				GetEntPropVector(i6, Prop_Send, "m_vecOrigin", position);
				TeleportEntity(FUNCT, position, NULL_VECTOR, NULL_VECTOR);
				//PrintToChatAll("teleported funccap");
				break;
			}
			if(IsThereAny1stBot())
			{
				GetEntPropVector(i5, Prop_Send, "m_vecOrigin", position);
				TeleportEntity(FUNCT, position, NULL_VECTOR, NULL_VECTOR);
				//PrintToChatAll("teleported funccap");
				break;
			}
		}	
	}
}

stock bool:IsThereAny1stBot()
{
	for( new i = 1; i <= MaxClients; i++ )
		if(IsClientInGame(i))
			if(IsFakeClient( i ))
				return true;
	return false;
}
stock CheckPageCount()
{
	iPageCounter = -1;
	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "prop_dynamic")) != -1)
	{
		//decl String:strName[50];
		//GetEntPropString(i5, Prop_Data, "m_iName", strName, sizeof(strName));
		if(IsValidSF2Page(i5))
		{
			iPageCounter++;
		}
	}
	//PrintToChatAll("Pagenum %i",iPageCounter);
	//return iCounter;

}
public OnEntityDestroyed(ent)
{	
		decl String:cls[20];
		GetEntityClassname(ent, cls, sizeof(cls));
		if (StrEqual(cls, "prop_dynamic", false))
			if(ent != -1)
				if(WasValidSF2Page(ent))	
					CheckPageCount();
		if (ent != -1 && StrEqual(cls, "monster_generic", false))
			UpdateBlockers();
	//if(WasValidSF2Page(ent))
	//{
		if(IsTargetedPage[ent])
			IsTargetedPage[ent] = false;
		if(IsTargetedPage2[ent])
			IsTargetedPage2[ent] = false;
		//PrintToChatAll("page down");
	
	/*	PrintToChatAll("page down");
		new i5 = -1;
		
		new Float:flPos1[3];
		GetEntPropVector( ent, Prop_Send, "m_vecOrigin", flPos1 );
		
		while((i5 = FindEntityByClassname(i5, "item_teamflag")) != -1)
		{
			new Float:flPos2[3];
			GetEntPropVector( i5, Prop_Send, "m_vecOrigin", flPos2 );
			new Float:flDistance = GetVectorDistance(flPos1, flPos2);
			if(flDistance < 190 && IsPickable[i5])
			{
				TeleportFuncToPage();
			}
		}*/		
	//}
}

/*stock TeleportFuncToPage()
{
	new FUNCT = FindEntityByClassname(-1,"func_capturezone");
	decl Float:position[3];
	
	new iEnt = FindRandomSpawnPointPage(iEnt);
	
	PrintToChatAll("ent id is %i", iEnt);
	
	new String:strClassname[64];
	GetEdictClassname( iEnt, strClassname, sizeof(strClassname) );

	PrintToChatAll("classname is %s",strClassname)
	if(!IsValidSF2Page(iEnt))
		PrintToChatAll("This isn't a page!")
	
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);
	
	PrintToChatAll("x %0.0f y %0.0f z %0.0f", position[0], position[1], position[2]);
	TeleportEntity(FUNCT, position, NULL_VECTOR, NULL_VECTOR);

	PrintToChatAll("teleported funccap");
}*/

stock FindRandomSpawnPointPage( iType )
{
	new Handle:hSpawnPoint = CreateArray();

	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "prop_dynamic")) != -1)
	{
		if(IsValidSF2Page(i5))
			PushArrayCell( hSpawnPoint, i5 );
	}
	if( GetArraySize(hSpawnPoint) > 0 )
	return GetArrayCell( hSpawnPoint, GetRandomInt(0,GetArraySize(hSpawnPoint)-1) );
	
	return -1;
}
/*stock TeleportFlagToPage()
{
	new FLAGT = FindEntityByClassname(-1,"item_teamflag");
	//new FLAGT = FindEntityByClassname(-1,"item_teamflag");
	decl Float:position[3];
	new i5 = -1;
	//PrintToChatAll("Before while");
	while((i5 = FindEntityByClassname(i5, "prop_dynamic")) != -1)
	{
		//PrintToChatAll("PAG FND");
		if(IsValidSF2Page(i5))
		{
			//if(!IsTargetedPage2[i5])
			//{
				GetEntPropVector(i5, Prop_Send, "m_vecOrigin", position);
				//position[2] += 5; 
				TeleportEntity(FLAGT, position, NULL_VECTOR, NULL_VECTOR);
			
				IsTargetedPage[i5] = true;
			
				//PrintToChatAll("Flag was teleported");
				break;
			//}
		}
	}
}*/
GetRandomPlayer(team)
{
    new clients[MaxClients+1], clientCount;
    for (new i = 1; i <= MaxClients; i++)
	{
        if (IsClientInGame(i) && GetClientTeam(i) == team)
		{
			if(!IsThereAny1stBot())
			{
				clients[clientCount++] = i;
			}
			if(!Is2ndBot(i))
			{
				clients[clientCount++] = i;
			}
		}
	}
    return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}
stock ReturnNonCarrier()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
			if(IsFakeClient(i) && GetClientTeam(i) == _:TFTeam_Red && ICarrier != i)
			{	
				return i;
			}
	}
	return 1;
}

stock TeleportFlagToPage()
{
	if(bEscape)
		return;
	new FLAGT = FindEntityByClassname(-1,"item_teamflag");
	//new client = GetRandomPlayer(2);
	new client = ReturnNonCarrier();
	new i5 = FindNearestPage(client);
	decl Float:position[3];
	
	//PrintToChatAll("PAG FND");
	if(IsValidSF2Page(i5) && IsValidEntity(i5) && client != -1)
	{
		if(!IsTargetedPage2[i5] || iPageCounter == 1)
		{
			GetEntPropVector(i5, Prop_Send, "m_vecOrigin", position);
			//position[2] += 5; 
			if(bEscape)
				return;
			TeleportEntity(FLAGT, position, NULL_VECTOR, NULL_VECTOR);
		
			IsTargetedPage[i5] = true;
		
			//PrintToChatAll("Flag was teleported");
			//break;
		}
	}
}
stock bool:IsThereAny2ndBot()
{
	for( new i = 1; i <= MaxClients; i++ )
		if(IsClientInGame(i))
			if(IsFakeClient( i ))
				if(Is2ndBot(client))
					return true;
	return false;
}
stock CheckButtonDist(client)
{
	if(!UnderGround)
		return;
	new Float:flPos1[3];
	GetClientAbsOrigin(client, flPos1);
	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "func_button")) != -1)
	{
		decl String:strName[50];
		GetEntPropString(i5, Prop_Data, "m_iName", strName, sizeof(strName));
		if(strcmp(strName, "escape_button") == 0)
		{
			new Float:flPos2[3];
			GetEntPropVector( i5, Prop_Send, "m_vecOrigin", flPos2 );
			new Float:flDistance = GetVectorDistance(flPos1, flPos2)
			if(flDistance < 100)
			{
				IsBotReadyToHitButton[client] = true;
				//PrintToChatAll("Bot is near 100 units");
				break;
			}
		}
	}
}

stock CheckFlagDist(client)
{
	new i3 = -1;
	if(!Is2ndBot(client))
	{
		//PrintToChatAll("exec thing 2nd");
		while ((i3 = FindEntityByClassname(i3, "item_teamflag")) != -1)
		{
			if(!IsPickable[i3])
			{
				new Float:flPos1[3];
				GetClientAbsOrigin(client, flPos1);
	
				new Float:flPos2[3];
				GetEntPropVector( i3, Prop_Send, "m_vecOrigin", flPos2 );
				new Float:flDistance = GetVectorDistance(flPos1, flPos2);
				if(flDistance < 125)
				{
					IsBotReadyToPickUpPage[client] = true;
					//PrintToChatAll("Bot is near 133 units");
					CreateTimer(1.0, Timer_SSprint, client);
					CreateTimer(3.1, Timer_StopSprint, client);
					break;
				}
			}
		}
	}
	if(Is2ndBot(client))
	{
		//PrintToChatAll("exec thing 2nd");
		i3 = -1;
		while ((i3 = FindEntityByClassname(i3, "func_capturezone")) != -1)
		{
			new Float:flPos1[3];
			GetClientAbsOrigin(client, flPos1);
	
			new Float:flPos2[3];
			GetEntPropVector( i3, Prop_Send, "m_vecOrigin", flPos2 );
			new Float:flDistance = GetVectorDistance(flPos1, flPos2);
			if(flDistance < 125)
			{
				IsBotReadyToPickUpPage[client] = true;
				//PrintToChatAll("Bot is near 133 units");
				CreateTimer(1.0, Timer_SSprint, client);
				CreateTimer(6.0, Timer_StopSprint, client);
				break;
			}
		}
	}
}
public Action:Timer_SSprint(Handle:timer, any:client)
{
	FakeClientCommand( client, "+sprint" );
}
public Action:Timer_StopSprint(Handle:timer, any:client)
{
	FakeClientCommand( client, "-sprint" );
}

public Action:OnFlagTouch(point, client)
{
	for(client=1;client<=MaxClients;client++)
	{
		if(IsClientInGame(client))
		{
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

stock SpawnFuncCapturezone()
{
	new entindex = CreateEntityByName("func_capturezone");
	if (entindex != -1) //dispatch ent properites
	{
		DispatchKeyValue(entindex, "StartDisabled", "0");
		DispatchKeyValue(entindex, "TeamNum", "2");
		DispatchKeyValue(entindex, "spawnflags", "2");
		DispatchKeyValue(entindex, "targetname", "CapZoneFlagN2");
	}

	DispatchSpawn(entindex);
	ActivateEntity(entindex);

	PrecacheModel("models/player/items/pyro/drg_pyro_fueltank.mdl");
	SetEntityModel(entindex, "models/player/items/pyro/drg_pyro_fueltank.mdl");

	new Float:minbounds[3] = {-10.0, -10.0, 0.0};
	new Float:maxbounds[3] = {10.0, 10.0, 20.0};
	SetEntPropVector(entindex, Prop_Send, "m_vecMins", minbounds);
	SetEntPropVector(entindex, Prop_Send, "m_vecMaxs", maxbounds);
    
	SetEntProp(entindex, Prop_Send, "m_nSolidType", 2);

	new enteffects = GetEntProp(entindex, Prop_Send, "m_fEffects");
	enteffects |= 32;
	SetEntProp(entindex, Prop_Send, "m_fEffects", enteffects);
	
	SDKHook(entindex, SDKHook_StartTouch, OnFlagTouch );
	SDKHook(entindex, SDKHook_Touch, OnFlagTouch );
	//PrintToChatAll("Created the func_capzone");
}

stock SpawnNonPickableFlag()
{
	new teamflags = CreateEntityByName("item_teamflag");
	if(IsValidEntity(teamflags))
	{
		DispatchKeyValue(teamflags, "targetname", "FlagN1");
		DispatchKeyValue(teamflags, "trail_effect", "0");
		DispatchKeyValue(teamflags, "ReturnTime", "1");
		if(!bDebugEnabled)
			DispatchKeyValue(teamflags, "flag_model", "models/empty.mdl");
		DispatchSpawn(teamflags);
		SetEntProp(teamflags, Prop_Send, "m_iTeamNum", 3);// 2 red 3 blue
		SetEntProp(teamflags, Prop_Send, "m_bGlowEnabled", 0);
		
		SDKHook(teamflags, SDKHook_StartTouch, OnFlagTouch );
		SDKHook(teamflags, SDKHook_Touch, OnFlagTouch );
	}
}
stock SpawnPickableFlag()
{
	new teamflags = CreateEntityByName("item_teamflag");
	if(IsValidEntity(teamflags))
	{
		IsPickable[teamflags] = true;
		DispatchKeyValue(teamflags, "targetname", "FlagN2");
		DispatchKeyValue(teamflags, "trail_effect", "0");
		DispatchKeyValue(teamflags, "ReturnTime", "60");
		if(!bDebugEnabled)
			DispatchKeyValue(teamflags, "flag_model", "models/empty.mdl");
		DispatchSpawn(teamflags);
		SetEntProp(teamflags, Prop_Send, "m_iTeamNum", 3);// 2 red 3 blue
		SetEntProp(teamflags, Prop_Send, "m_bGlowEnabled", 0);
		for( new i = 1; i <= MaxClients; i++ )
		{
			if(IsClientInGame(i))
			{
			
				if(IsFakeClient( i ))
				{
					new Float:Position[3];
					GetClientAbsOrigin(i, Position);
					TeleportEntity(teamflags, Position, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
	}
}

stock LookAtTarget(any:client, any:target)//
{ 
    new Float:angles[3], Float:clientEyes[3], Float:targetEyes[3], Float:resultant[3]; 
    GetClientEyePosition(client, clientEyes);
    if(target > 0 && target <= MaxClients && IsClientInGame(target)){
    GetClientEyePosition(target, targetEyes);
    }else{
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetEyes);
    }
    MakeVectorFromPoints(targetEyes, clientEyes, resultant); 
    GetVectorAngles(resultant, angles); 
    if(angles[0] >= 270){ 
        angles[0] -= 270; 
        angles[0] = (90-angles[0]); 
    }else{ 
        if(angles[0] <= 90){ 
            angles[0] *= -1; 
        } 
    } 
    angles[1] -= 180; 
    TeleportEntity(client, NULL_VECTOR, angles, NULL_VECTOR); 
}
stock bool:Is2ndBot(client)
{
	//if(bool:GetEntProp(client, Prop_Send, "m_bGlowEnabled") == true)
	if(ICarrier == client)
		return true;
		
	return false;
}

public Action:OnPlayerRunCmd( client, &iButtons, &iImpulse, Float:flVelocity[3], Float:flAngles[3], &iWeapon )//attack stock
{
	if(!IsFakeClient(client) || GetClientTeam(client) != _:TFTeam_Red || !IsPlayerAlive(client))
		return Plugin_Continue;
//	if(IsBotInSetup[client])
//	{
//		PrintToChatAll("Setup triger");
//		FakeClientCommand( client, "sm_flashlight" );
//		IsBotInSetup[client] = false;
//		return Plugin_Changed; 
//	}
//	if( !IsPlayerAlive(client) )
//		return Plugin_Continue;
	if(bEscape && IsBotReadyToHitButton[client])
	{
		new Button = FindUnderButton();
		
		LookAtTarget(client, Button)
		iButtons |= IN_ATTACK;
		IsBotReadyToHitButton[client] = false;
		return Plugin_Changed; 
	}
	if(!bEscape && IsBotReadyToPickUpPage[client] && !Is2ndBot(client))
	{
		//RunAwayFromBoss(client);
		new FLAGT = FindNonPickAbleFlag();
		LookAtTarget(client, FLAGT)
		

		iButtons |= IN_ATTACK;
		IsBotReadyToPickUpPage[client] = false;
		TeleportFlagToPage();
		return Plugin_Changed; 
	}
	if(!bEscape && IsBotReadyToPickUpPage[client] && Is2ndBot(client))
	{
		new FUNCT = FindEntityByClassname(-1,"func_capturezone");
		LookAtTarget(client, FUNCT)

		iButtons |= IN_ATTACK;
		IsBotReadyToPickUpPage[client] = false;
		CreateTimer(1.5, Timer_TeleFuncp);
		TeleportFuncToPage();
		return Plugin_Changed; 
	}
	return Plugin_Continue;
}
FindUnderButton()
{
	new i5 = -1;
	while((i5 = FindEntityByClassname(i5, "func_button")) != -1)
	{
		decl String:strName[50];
		GetEntPropString(i5, Prop_Data, "m_iName", strName, sizeof(strName));
		if(strcmp(strName, "escape_button") == 0)
		{
			return i5;
		}
	}
	return -1;
}
public Action:Timer_TeleFuncp(Handle:timer)
{
	TeleportFuncToPage();
}

stock FindNonPickAbleFlag()
{
	new i3 = -1;
	while ((i3 = FindEntityByClassname(i3, "item_teamflag")) != -1)
	{
		if(!IsPickable[i3])
			return i3;
	}
	return -1;	
}