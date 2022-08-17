class mcu8_SeqAct_RecheckSpawnpoint extends SequenceAction;

var() bool RespawnPlayers;

event Activated()
{
    local Actor p1, p2;
    p1 = class'Engine'.static.GetEngine().GamePlayers[0].Actor;
	
    if (Hat_GameManager(class'WorldInfo'.static.GetWorldInfo().game).IsCoop())
 	{
		p2 = class'Engine'.static.GetEngine().GamePlayers[1].Actor; 
		MoveToCheckpointLocation(p1, false);
		MoveToCheckpointLocation(p2, true);
	}
	else 
	{
		MoveToCheckpointLocation(p1, true);
	}
}

function MoveToCheckpointLocation(Actor srcActor, bool reInitMods)
{
	local Controller C;
	local GameMod lMod;
	local GameModInfo gmi;
	local mcu8_mods_BetterHubMain Mod;
	local bool fastBoot;
	local GameModInfo currentGM;

	Mod = class'mcu8_mods_BetterHubMain'.static.GetMod();
	currentGM = class'mcu8_mods_BetterHubMain'.static.GetCurrModInfo();
	fastBoot = class'mcu8_HubConfig'.static.Load().FastBoot;

	C = Controller(srcActor);
	RespawnPlayer(C);

	if(C != None && C.Pawn != None)
	{
		srcActor = C.Pawn;
	}

	if (RespawnPlayers)
    	Hat_Player(srcActor).MoveToCheckpointLocation();	

	// We don't need to reload all mods again!
	if (reInitMods == false) 
		return;
	
	// Force all mods to reload! (it may be very unsafe, needs more testing)
	// it may break compatibility with other HUB replacement mods and cause loading-loop!!!
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'GameMod', lMod)
	{
		// Don't touch myself!
		if (lMod.Class == class'mcu8_mods_BetterHubMain') continue;

		// Fastboot feature
		if (!fastBoot || lMod.class == currentGM.ModClass)
		{
			gmi = FindModInfoForClass(lMod.Class);
			Mod.ReportStatus("Re-initializing game mod: " $ gmi.Name);

			// Trigger "OnModLoaded" in mod class
			Mod.Log("OnModLoaded: " $ lMod.Class);
			lMod.OnModLoaded();

			// Trigger "OnPostInitGame" in mod class
			//Mod.Log("OnPostInitGame: " $ lMod.Class);
			//Hat_GameEventsInterface(lMod).OnPostInitGame();
		}
		// I using OnMiniMissionGenericEvent because it's only safe way to send strings to other mods
		// because we cannot implement cross-mod interfaces :<
		Mod.Log((fastBoot ? "[F] " : "") $ "Informing mod " $ lMod.Class $ " that BH is ready...");
		Hat_GameEventsInterface(lMod).OnMiniMissionGenericEvent(None, "bhinitialized");	
	}
}

function GameModInfo FindModInfoForClass(class cl) {
	local Array<GameModInfo> infos;
	local GameModInfo i;
	infos = class'GameMod'.static.GetModList();
	foreach infos(i)
	{
		if (i.ModClass == cl) {
			return i;
		}
	}
}

// Destroy and respawn player (from Arg_PlayerSwapper)
function RespawnPlayer(Controller pc) {
	local Pawn NewPawn;
	local Rotator SavedRot;
    SavedRot = pc.Rotation;
	NewPawn = pc.Spawn(pc.Pawn.class,,,pc.Pawn.Location,pc.Pawn.Rotation,,true);
	NewPawn.Health = pc.Pawn.Health;
	if (pc.Pawn.bHidden) 
		NewPawn.SetHidden(true);
	pc.Pawn.Destroy();
	pc.Pawn = None;
	pc.Possess(NewPawn, false);
	pc.SetRotation(SavedRot);
}

defaultproperties
{
	ObjName="[BH] Teleport player to the default spawnpoint"
	ObjCategory="BetterHub"
	RespawnPlayers = true
}
