class mcu8_mods_BetterHubMain extends GameMod
    config(Mods);

var() String CurrentState;
var() bool GEIAdded;

var config int UseManholeInsteadTeleporter;
var config int IsHubLoadingEnabled;
var config int TitlecardVerbose;
var config int FastBoot;
var config int IgnoreIcons;

var GameModInfo DummyGMI;

var() bool IsSwapperSpawned;

const ModDebug = false; // TODO: set to "false" before release
//const DefaultMapName = "mcu8_maps_bhtest";

var bool EnableLoadingMusicCompatLayer;

static function name GetEntryMap()
{
    return name(GetHubMapName());
}

// Replace hub_spaceship map when it's loaded
event OnModLoaded()
{
    local Array<Name> Maps;
    local string cuMap;

    class'mcu8_HubConfig'.static.CreateConfigIfNeeded();

    cuMap = Locs(`GameManager.GetCurrentMapFilename());

    if (IsExHubMap(cuMap))
    {
        Maps.AddItem(name(`GameManager.HubMapName));
        Maps.AddItem(name(cuMap)); 
        ReportStatus("Loading HubSwapper... [stage 2] Map: " $ Maps[1]);
        class'WorldInfo'.static.GetWorldInfo().PrepareMapChange(Maps);
        class'WorldInfo'.static.GetWorldInfo().CommitMapChange();
    }
    else if (cuMap == Locs(`GameManager.HubMapName) && ShouldReplaceHub())
    {
        GoToHUB();
    }
}


static function bool IsExHubMap(string cm)
{
    local Array<string> splitList;
    local Array<mcu8_HubAddon> addons;
    local mcu8_HubAddon a;
    //if (Locs(cm) == Locs(class'mcu8_mods_BetterHubMain'.const.DefaultMapName)) return true;

    splitList = SplitString(Locs(cm), "_");
    if (splitList[0] == "hubexmap")
    {
        addons = GetAllAddons();
        foreach addons(a)
        {
            if (Locs(a.MapName) == Locs(cm)) return true;
        }   
    }    
    return false;
}

event OnPostInitGame() {  
    if (`GameManager.GetCurrentMapFilename() ~= `GameManager.HubMapName)
    {
        if (!HubEnabled()) 
        {
            ReportStatus("HubSwapper is disabled! Loading vanilla map...");
        }
        else
        {
            ReportStatus("Loading HubSwapper... [stage 3] Post-Load...");
        }
        RunHUBEvents();
    }
}

function RunHUBEvents()
{
    local GameModInfo i;
    local GameMod mod;
    SetTimer(0.01, false, NameOf(SpawnHUBSwapper));

    if (!HubEnabled()) return;
    i = GetCurrModInfo();
    if (i.Name != default.DummyGMI.Name && i.ModClass != None)
    {
        Log("Calling OnPostLoadHUB...");
        mod = GetModByClass(class<GameMod>(i.ModClass));
        mod.SetTimer(0.01, false, 'OnPostLoadHUB');   
    }
    SetTimer(0.01, false, NameOf(OnPostPostLoadHUB));   
}

function OnPostLoadHUB()
{
    Log("OnPostLoadHUB called!");
    CauseEvent('bhloadnext');
}

function OnPostPostLoadHUB()
{
    CauseEvent('bhloadnext');
}

function SpawnHUBSwapper()
{
    if (IsSwapperSpawned) return;
    SpawnActor(class'mcu8_HubSwapper', -528.216309, -267.782867, 254.323273, 0, 0, -16383);
    IsSwapperSpawned = true;
}

function CauseEvent(Name EventName)
{
	local array<SequenceObject> AllConsoleEvents;
	local SeqEvent_Console ConsoleEvt;
	local Sequence GameSeq;
	local int Idx;
	local bool bFoundEvt;
	// Get the gameplay sequence.
	GameSeq = class'WorldInfo'.static.GetWorldInfo().GetGameSequence();
	if ( (GameSeq != None) && (EventName != '') )
	{
		// Find all SeqEvent_Console objects anywhere.
		GameSeq.FindSeqObjectsByClass(class'SeqEvent_Console', TRUE, AllConsoleEvents);

		// Iterate over them, seeing if the name is the one we typed in.
		for( Idx=0; Idx < AllConsoleEvents.Length; Idx++ )
		{
			ConsoleEvt = SeqEvent_Console(AllConsoleEvents[Idx]);
			if (ConsoleEvt != None &&
				EventName == ConsoleEvt.ConsoleEventName)
			{
				bFoundEvt = TRUE;
				Log("Activate event " $ EventName);
				ConsoleEvt.CheckActivate(GetPC(), GetPC().Pawn);
			}
		}
	}
	if (!bFoundEvt)
	{
		Log("Event not found!!!");
	}
}

static function Log(String v) {
    local PlayerController pc;
    if (ModDebug)
    {

        pc = GetPC();
        if (pc != None)
            pc.ClientMessage("[Debug] => " $ v);
        else
            `broadcast("[Debug] => " $ v);
    }      
}

static function Hat_PlayerController GetPC() {
    if (class'Engine'.static.GetEngine() != None && class'Engine'.static.GetEngine().GamePlayers.Length > 0)
        return Hat_PlayerController(class'Engine'.static.GetEngine().GamePlayers[0].Actor);
    return None;
}

// Restarting hub should be a lot faaaaaster with this
function OnPreRestartMap(out String OutMapName) {
    if (Locs(OutMapName) ~= `GameManager.HubMapName) {
        Log("Overriding map in restartlevel!");
        OutMapName = GetHubMapName();
    }
}

function OnPreOpenHUD(HUD InHUD, out class<Object> InHUDElement)
{
    if (InHUDElement == class'Hat_HUDElementLoadingScreen' || InHUDElement == class'Hat_HUDElementLoadingScreen_Base' ) {
        Log("OVERRIDE LOADING SCREEN!");
        InHUDElement = class'mcu8_HUDElementLoadingScreen';
        return;
    }

    if (InHUDElement == class'Hat_HUDMenuMainMenu') {
        Log("OVERRIDE MAIN MENU");
        InHUDElement = class'mcu8_HUDMenuMainMenu';
        return;
    }
    
    if (InHUDElement == class'Hat_HUDElementActTitleCard') {
		Log("OVERRIDE TITLE CARD");
		InHUDElement = class'mcu8_HUDElementActTitleCard';
		return;
    }
}

static function String GetStatus() {
    return GetMod().CurrentState;
}

static function ReportStatus(String text) {
    local mcu8_mods_BetterHubMain _mod;
    _mod = GetMod();
    if (_mod != None)
        _mod.CurrentState = text;
    Log("State -> " $ text);
}

static function mcu8_mods_BetterHubMain GetMod()
{
    return mcu8_mods_BetterHubMain(GetModByClass(class'mcu8_mods_BetterHubMain'));
}

static function GameMod GetModByClass(class<GameMod> mod)
{
	local Actor lMod;
    local WorldInfo wi;
    wi = class'WorldInfo'.static.GetWorldInfo();
    if (wi != None)
        foreach wi.AllActors(mod, lMod)
            return GameMod(lMod);
}

static function bool ShouldReplaceHub(bool checkForHUBEnabled = true) {
    //local mcu8_mods_BetterHubMain mod;
    //mod = GetMod();

    if (!HubEnabled() && checkForHUBEnabled)
        return false;

    //if (mod != None && mod.Loaded)
    //    return false;

    // TODO: MAYBE ADD SOME MORE CHECKS HERE!!!
    // Check if is Mu mission - streaming at this moment may break some things so don't do that
    if (class'Hat_SeqCond_IsMuMission'.static.IsFinaleMuMission()) {
        return false;
    }

    // same as Mu mission, but for ending cutscene
    if (class'Hat_IntruderInfo_CookingCat'.static.IsEndingPlaying()) {
        return false;
    }

    // activate only if player has one or more timepieces
    if (Hat_GameManager(class'WorldInfo'.static.GetWorldInfo().game).GetTimeObjects() < 1) {
        return false;
    }

    return true;
}

function OnMiniMissionGenericEvent(Object object, String id)
{
  if (id ~= "EnableLoadingMusicCompatLayer")
    EnableLoadingMusicCompatLayer = true;
}

function Actor SpawnActor(class<Actor> C, float X, float Y, float Z, float Roll, float Pitch, float Yaw)
{
	local Actor act;
	local Vector vt;
	local Rotator rt;
	vt.X = X;
	vt.Y = Y;
	vt.Z = Z;
	rt.Roll = Roll;
	rt.Pitch = Pitch;
	rt.Yaw = Yaw;
	act = Spawn(C,self,,vt,rt);
	return act;
}

// Proxy for loading other hub maps
static function string GetHubMapName() {
    local mcu8_HubAddon Addon;
    local Array<mcu8_HubAddon> Addons;
    local string _tmpMap;
    local string _cfgMap;

    if (!ShouldReplaceHub()) return `GameManager.HubMapName;

    //_Map = Locs(DefaultMapName);
    _cfgMap = Locs(class'mcu8_HubConfig'.static.Load().LastMap);

    //if (_cfgMap == _Map) return _Map;

    Addons = GetAllAddons();
    foreach Addons(Addon)
    {
        _tmpMap = Locs(Addon.MapName);
        if (_tmpMap == _cfgMap) return Locs(_tmpMap);
    }

    return `GameManager.HubMapName; 
}

static function SoftGoToHub(class<Object> context) {
    Log("SoftGoToHub => " $ context);
    GetMod().SetTimer(1,false,NameOf(GoToHUB));
}

function GoToHUB() {
    ReportStatus("Loading HubSwapper...");
	`GameManager.SoftChangeLevel(HubEnabled() ? string(GetEntryMap()) : `GameManager.HubMapName);
}

// Unused for now, detection method works but streaming addon maps unfortunely not... :<
// 31.05.2020 - ok, let's use that for find the map to override... 
//              It basically searching for the maps with prefix "hubexmap_"
static function Array<mcu8_HubAddon> GetAllAddons()
{
    local GameModInfo mod;
    local Array<mcu8_HubAddon> result;
    local string _mapName;
    local Array<string> splitList;
    local mcu8_HubAddon proto;
    local Array<GameModInfo> modList;

    modList = class'GameMod'.static.GetModList();

    foreach modList(mod)
    {
        if (mod.IsEnabled) 
         {
            foreach mod.MapNames(_mapName) 
            {
                // Check if map contains prefix
                splitList = SplitString(Locs(_mapName), "_");
                if (splitList[0] == "hubexmap") 
                {
                    proto = new class'mcu8_HubAddon';
                    proto.MapName = _mapName;
                    proto.AddonName = mod.Name;
                    result.AddItem(proto);
                }
            }
        }
    }

    return result;
}

static function GameModInfo GetCurrModInfo()
{
    local GameModInfo mod;
    local string _mapName;
    local string currentMap;
    local Array<GameModInfo> modList;

    currentMap = GetHubMapName();

    modList = class'GameMod'.static.GetModList();

    foreach modList(mod)
    {
        if (mod.IsEnabled) 
        {
            foreach mod.MapNames(_mapName) 
            {
                if (Locs(_mapName) == currentMap)
                    return mod;
            }
        }
    }

    return default.DummyGMI;
}

static function bool ShouldUseManholeInsteadTeleporter() {
    return class'mcu8_HubConfig'.static.Load().UseManholeInsteadTeleporter;
}

static function bool HubEnabled() {
    return class'mcu8_HubConfig'.static.Load().IsHubLoadingEnabled;
}

static function bool IsTitlecardVerboseOutput() {
    return class'mcu8_HubConfig'.static.Load().TitlecardVerbose;
}

static function bool ShouldIgnoreIcons() {
    return class'mcu8_HubConfig'.static.Load().IgnoreIcons;
}

event OnConfigChanged(Name ConfigName) {
    local mcu8_HubConfig cfg;
    if (ConfigName == 'UseManholeInsteadTeleporter') 
    {
        cfg = class'mcu8_HubConfig'.static.Load();
        cfg.UseManholeInsteadTeleporter = UseManholeInsteadTeleporter > 0;
        cfg.Save();
    }
    else if (ConfigName == 'IsHubLoadingEnabled') 
    {
        cfg = class'mcu8_HubConfig'.static.Load();
        cfg.IsHubLoadingEnabled = IsHubLoadingEnabled == 0;
        cfg.Save();
    }
    else if (ConfigName == 'TitlecardVerbose') 
    {
        cfg = class'mcu8_HubConfig'.static.Load();
        cfg.TitlecardVerbose = TitlecardVerbose == 0;
        cfg.Save();
    }
    else if (ConfigName == 'FastBoot')
    {
        cfg = class'mcu8_HubConfig'.static.Load();
        cfg.FastBoot = FastBoot > 0;
        cfg.Save();
    }
    else if (ConfigName == 'IgnoreIcons')
    {
        cfg = class'mcu8_HubConfig'.static.Load();
        cfg.IgnoreIcons = IgnoreIcons > 0;
        cfg.Save();
    }
}

defaultproperties {
    CurrentState = "..."
    GEIAdded = false
    UseManholeInsteadTeleporter = 0
    TitlecardVerbose = 0
    IsHubLoadingEnabled = 0
    FastBoot = 0
    IsSwapperSpawned = true

    DummyGMI=(
        Name='DummyModName_DoNotUse'
    )
}
