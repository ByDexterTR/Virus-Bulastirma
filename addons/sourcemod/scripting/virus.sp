#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <warden>

bool Gamestart = false, Block = false;
int virus = 0;
bool Hasta[65] = { false, ... };
bool Bulasma = false;

int g_CollisionGroup = -1;

#pragma semicolon 1
#pragma newdecls required

#define LoopClientsValid(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsValidClient(%1))

public Plugin myinfo = 
{
	name = "[JB] Virüs Yayma", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_corona", Command_Virus, "");
	RegConsoleCmd("sm_veba", Command_Virus, "");
	RegConsoleCmd("sm_tifo", Command_Virus, "");
	RegConsoleCmd("sm_virus", Command_Virus, "");
	RegAdminCmd("virusmenu_flag", Flag_Controlmenu, ADMFLAG_ROOT, "");
	HookEvent("player_death", OnClientDead);
	
	g_CollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
}

public void OnMapStart()
{
	char map[256];
	char file[256];
	GetPluginFilename(INVALID_HANDLE, file, 256);
	GetCurrentMap(map, sizeof(map));
	if (strncmp(map, "workshop/", 9, false) == 0)
	{
		if (StrContains(map, "/jb_", false) == -1 && StrContains(map, "/jail_", false) == -1 && StrContains(map, "/ba_jail", false) == -1)
			ServerCommand("sm plugins unload %s", file);
	}
	else if (strncmp(map, "jb_", 3, false) != 0 && strncmp(map, "jail_", 5, false) != 0 && strncmp(map, "ba_jail", 3, false) != 0)
		ServerCommand("sm plugins unload %s", file);
	else
	{
		if (Gamestart)
			GameStop();
		
		Gamestart = false;
		Bulasma = false;
		Block = false;
		virus = 0;
	}
}

public void OnPluginEnd()
{
	if (Gamestart)
		GameStop();
}

public void OnClientPostAdminCheck(int client)
{
	Hasta[client] = false;
}

public Action Flag_Controlmenu(int client, int args)
{
	PrintToChat(client, "[SM] Virüs menüsüne erişiminiz var.");
	return Plugin_Handled;
}

public Action Command_Virus(int client, int args)
{
	if (warden_iswarden(client) || CheckCommandAccess(client, "virusmenu_flag", ADMFLAG_ROOT))
	{
		VirusMenu().Display(client, 0);
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok.");
		return Plugin_Handled;
	}
}

Menu VirusMenu() // Ağlama quantum hadi ( soru sordum bak SP'e )
{
	Menu menu = new Menu(Menu_CallBack31);
	menu.SetTitle("★ Virüs Hizmetleri ★\n★ ByDexter ★\n ");
	
	
	menu.AddItem("3", Gamestart ? "Herkese Aşı Vur!":"Virüsü Yay!", Block ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	if (virus == 0)
	{
		menu.AddItem("1", "Virüs: Kara Veba\nSunucuda olan biri Fare eti yer ve virüs bulaşır.", Gamestart ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	else if (virus == 1)
	{
		menu.AddItem("1", "Virüs: Tifo\nSunucuda olan biri Kirli yiyecek/içecek yer ve virüs bulaşır.", Gamestart ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	else
	{
		menu.AddItem("1", "Virüs: Covid-19\nSunucuda olan biri Yarasa çorbası içer ve virüs bulaşır.", Gamestart ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	
	menu.AddItem("2", Bulasma ? "Bulaşma: Birbirine dokununca":"Bulaşma: Hasar Vurunca", Gamestart ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	return menu;
}

public int Menu_CallBack31(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char item[8];
		menu.GetItem(position, item, sizeof(item));
		if (StringToInt(item) == 1)
		{
			if (!Gamestart)
			{
				virus++;
				if (virus > 2)
					virus = 0;
				
				VirusMenu().Display(client, 0);
			}
			else
			{
				PrintToChat(client, "[SM] \x07Oyun başladığı için ayarlar yapılmadı...");
			}
		}
		else if (StringToInt(item) == 2)
		{
			if (!Gamestart)
			{
				Bulasma = !Bulasma;
				
				VirusMenu().Display(client, 0);
			}
			else
			{
				PrintToChat(client, "[SM] \x07Oyun başladığı için ayarlar yapılmadı...");
			}
		}
		else if (StringToInt(item) == 3)
		{
			if (!Gamestart)
			{
				int Ta = 0;
				LoopClientsValid(i)
				{
					if (IsPlayerAlive(i) && GetClientTeam(i) == 2)
					{
						Ta++;
					}
				}
				if (Ta >= 2)
				{
					PrintToChatAll("[SM] \x10%N \x01yeni bir pandemi başlattı!", client);
					Gamestart = true;
					LoopClientsValid(i)
					{
						ShowStatusMessage(i, "! Oyun Birazdan Başlayacak !", 4);
						BilgiMenu().Display(i, 5);
					}
					CreateTimer(5.0, Baslat, _, TIMER_FLAG_NO_MAPCHANGE);
					Block = true;
				}
				else
				{
					PrintToChat(client, "[SM] Hastalık oyunu başlaması için 2 kişi veya daha fazlası gerek!");
				}
			}
			else
			{
				PrintToChatAll("[SM] \x10%N \x01herkesi aşıladı!", client);
				GameStop();
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action Baslat(Handle timer, any data)
{
	if (!Gamestart)
		return Plugin_Stop;
	
	Block = false;
	int Sayi = 0;
	int Deger[65] = { 0, ... };
	LoopClientsValid(i)
	{
		if (IsPlayerAlive(i) && GetClientTeam(i) == 2)
		{
			SetEntData(i, g_CollisionGroup, 5, 4, true);
			Sayi++;
			Deger[i] = Sayi;
			Hasta[i] = false;
			SetEntityRenderColor(i, 255, 0, 0, 150);
			SetEntityHealth(i, 100);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			if (!Bulasma)
				SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			else
				SDKHook(i, SDKHook_StartTouch, OnTouch);
		}
	}
	int Kazanan = GetRandomInt(1, Sayi);
	LoopClientsValid(i)
	{
		if (IsPlayerAlive(i) && GetClientTeam(i) == 2 && Deger[i] == Kazanan)
		{
			SetEntData(i, g_CollisionGroup, 2, 4, true);
			PrintToChatAll("[SM] \x10%N \x01hasta herkes kaçsın!", i);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.2);
			Hasta[i] = true;
			SetEntityRenderColor(i, 0, 255, 0, 150);
		}
	}
	SetCvar("mp_solid_teammates", 1);
	BunnyAyarla(false);
	if (virus == 0)
	{
		PrintToChatAll("[SM] \x10Hastalık: \x07Kara Veba");
	}
	else if (virus == 1)
	{
		PrintToChatAll("[SM] \x10Hastalık: \x09Tifo");
	}
	else
	{
		PrintToChatAll("[SM] \x10Hastalık: \x04Covid-19");
	}
	if (!Bulasma)
	{
		PrintToChatAll("[SM] \x10Virüsü yaymak için birbirinize vurmalısınız!");
		SetCvar("mp_teammates_are_enemies", 1);
	}
	else
	{
		PrintToChatAll("[SM] \x10Virüsü yaymak için birbirinize dokunmalısınız!");
	}
	CreateTimer(1.0, Repeat, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

Menu BilgiMenu()
{
	Menu menu = new Menu(Menu_CallBack62);
	menu.SetTitle("★ Pandemi ★\n★ ByDexter ★\n \nHerkes birbirinin arasına mesafe koysun");
	menu.AddItem("X", " ", ITEMDRAW_NOTEXT);
	menu.ExitButton = false;
	menu.ExitBackButton = false;
	return menu;
}

public int Menu_CallBack62(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

void GameStop()
{
	LoopClientsValid(i)
	{
		if (GetClientTeam(i) == 2)
		{
			Hasta[i] = false;
			SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKUnhook(i, SDKHook_StartTouch, OnTouch);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			SetEntData(i, g_CollisionGroup, 2, 4, true);
			SetEntityRenderColor(i, 255, 255, 255, 255);
			SetEntityHealth(i, 100);
			SetEntityGravity(i, 1.0);
			BunnyAyarla(true);
		}
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("mp_solid_teammates", 0);
	}
	Gamestart = false;
	Block = false;
}

public Action OnClientDead(Event event, const char[] name, bool dB)
{
	if (Gamestart)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if (IsValidClient(client) && GetClientTeam(client) == 2)
		{
			Hasta[client] = false;
			int Ta = 0;
			LoopClientsValid(i)
			{
				if (IsPlayerAlive(i) && GetClientTeam(i) == 2)
				{
					Ta++;
				}
			}
			if (Ta == 1)
			{
				GameStop();
				LoopClientsValid(i)
				{
					if (GetClientTeam(i) == 2)
					{
						if (IsPlayerAlive(i))
							PrintToChatAll("[SM] \x10%N \x05sağlıklı kalmayı başardı.", i);
					}
				}
			}
			Ta = 0;
			LoopClientsValid(i)
			{
				if (IsPlayerAlive(i) && GetClientTeam(i) == 2 && Hasta[i])
				{
					Ta++;
				}
			}
			if (Ta == 0)
			{
				GameStop();
				PrintToChatAll("[SM] Virüslü kimse kalmadı, \x05insanlar kazandı.");
			}
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (Gamestart && IsValidClient(victim) && GetClientTeam(victim) == 2 && IsValidClient(attacker) && GetClientTeam(attacker) == 2)
	{
		if (Hasta[attacker] && !Hasta[victim])
		{
			SetEntData(victim, g_CollisionGroup, 2, 4, true);
			Hasta[victim] = true;
			PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x05virüs bulaştırıldı.", victim, attacker);
			SetEntityRenderColor(victim, 0, 255, 0, 150);
			SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", 1.2);
			PrintToChat(attacker, "[SM] \x0AVirüsü bulaştırdığın için \x05+5 Can");
			SetEntityHealth(attacker, GetClientHealth(attacker) + 5);
		}
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action OnTouch(int entity, int other)
{
	if (Gamestart && IsValidClient(other) && GetClientTeam(other) == 2 && IsValidClient(entity) && GetClientTeam(entity) == 2 && Hasta[entity] && !Hasta[other])
	{
		SetEntData(other, g_CollisionGroup, 2, 4, true);
		Hasta[other] = true;
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x05virüs bulaştırıldı.", other, entity);
		SetEntityRenderColor(other, 0, 255, 0, 150);
		SetEntPropFloat(other, Prop_Data, "m_flLaggedMovementValue", 1.2);
		PrintToChat(entity, "[SM] \x0AVirüsü bulaştırdığın için \x05+5 Can");
		SetEntityHealth(entity, GetClientHealth(entity) + 5);
	}
}

public Action Repeat(Handle timer, any data)
{
	if (!Gamestart)
		return Plugin_Stop;
	
	LoopClientsValid(i)
	{
		if (IsPlayerAlive(i) && GetClientTeam(i) == 2 && Hasta[i])
		{
			DealDamage(i, 1, i, DMG_GENERIC, "weapon_ak47");
			if (GetClientHealth(i) == 20)
			{
				PrintToChat(i, "[SM] Hastalığın ilerledi.");
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.4);
				SetEntityGravity(i, 0.86);
			}
		}
	}
	return Plugin_Continue;
}

void DealDamage(int nClientVictim, int nDamage, int nClientAttacker = 0, int nDamageType = DMG_GENERIC, char sWeapon[] = "")
{
	if (nClientVictim > 0 && 
		IsValidEdict(nClientVictim) && 
		IsClientInGame(nClientVictim) && 
		IsPlayerAlive(nClientVictim) && 
		nDamage > 0)
	{
		int EntityPointHurt = CreateEntityByName("point_hurt");
		if (EntityPointHurt != 0)
		{
			char sDamage[16];
			FormatEx(sDamage, sizeof(sDamage), "%d", nDamage);
			
			char sDamageType[32];
			FormatEx(sDamageType, sizeof(sDamageType), "%d", nDamageType);
			
			DispatchKeyValue(nClientVictim, "targetname", "war3_hurtme");
			DispatchKeyValue(EntityPointHurt, "DamageTarget", "war3_hurtme");
			DispatchKeyValue(EntityPointHurt, "Damage", sDamage);
			DispatchKeyValue(EntityPointHurt, "DamageType", sDamageType);
			if (!StrEqual(sWeapon, ""))
				DispatchKeyValue(EntityPointHurt, "classname", sWeapon);
			DispatchSpawn(EntityPointHurt);
			AcceptEntityInput(EntityPointHurt, "Hurt", (nClientAttacker != 0) ? nClientAttacker : -1);
			DispatchKeyValue(EntityPointHurt, "classname", "point_hurt");
			DispatchKeyValue(nClientVictim, "targetname", "war3_donthurtme");
			RemoveEntity(EntityPointHurt);
		}
	}
}

void ShowStatusMessage(int client = -1, const char[] message = NULL_STRING, int hold = 1)
{
	if (!IsFakeClient(client))
	{
		Event show_survival_respawn_status = CreateEvent("show_survival_respawn_status");
		if (show_survival_respawn_status != null)
		{
			show_survival_respawn_status.SetString("loc_token", message);
			show_survival_respawn_status.SetInt("duration", hold);
			show_survival_respawn_status.SetInt("userid", -1);
			show_survival_respawn_status.FireToClient(client);
			show_survival_respawn_status.Cancel();
		}
	}
}

void BunnyAyarla(bool Durum)
{
	if (Durum)
	{
		SetCvar("sv_enablebunnyhopping", 1);
		SetCvar("sv_autobunnyhopping", 1);
		SetCvar("sv_airaccelerate", 2000);
		SetCvar("sv_staminajumpcost", 0);
		SetCvar("sv_staminalandcost", 0);
		SetCvar("sv_staminamax", 0);
		SetCvar("sv_staminarecoveryrate", 60);
	}
	else
	{
		SetCvar("sv_enablebunnyhopping", 0);
		SetCvar("sv_autobunnyhopping", 0);
		SetCvar("sv_airaccelerate", 101);
		SetCvarFloat("sv_staminajumpcost", 0.080);
		SetCvarFloat("sv_staminalandcost", 0.050);
		SetCvar("sv_staminamax", 80);
		SetCvar("sv_staminarecoveryrate", 60);
	}
}

void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

void SetCvarFloat(char[] cvarName, float value)
{
	ConVar FloatCvar = FindConVar(cvarName);
	if (FloatCvar == null)return;
	int flags = FloatCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
	FloatCvar.FloatValue = value;
	flags |= FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 