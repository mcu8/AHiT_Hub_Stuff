class mcu8_SeqAct_StreamMap extends SequenceAction;

var() String MapName;

event Activated()
{
    local Engine LocalEngine;
    local Hat_PlayerController PC;
    local mcu8_mods_BetterHubMain Mod;

    LocalEngine = class'Engine'.static.GetEngine();
    PC = Hat_PlayerController(LocalEngine.GamePlayers[0].Actor);
    if (PC != None) 
    {
        Mod = class'mcu8_mods_BetterHubMain'.static.GetMod();
        Mod.ReportStatus("Loading "$MapName$"...");
	    PC.ClientPrepareMapChange(name(MapName), false, true);
        PC.ClientCommitMapChange();
    }
}

defaultproperties
{
	ObjName="[BH] Stream Map"
	ObjCategory="BetterHub"
}
