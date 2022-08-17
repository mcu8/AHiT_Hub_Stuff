class mcu8_SeqAct_GetAllHubAddons extends SequenceAction;

event Activated()
{
    local array<SequenceObject> ObjectList;
    local SeqVar_ObjectList SeqVar_ObjectList;
    local Array<mcu8_HubAddon> Addons;
    local mcu8_HubAddon Addon;

    Addons = GetAllAddons();
    GetLinkedObjects(ObjectList, class'SeqVar_ObjectList', false);

    SeqVar_ObjectList = SeqVar_ObjectList(ObjectList[0]);
    if (SeqVar_ObjectList != None)
    {
        SeqVar_ObjectList.ObjList.Length = 0;
        foreach Addons(Addon)
        {
            SeqVar_ObjectList.ObjList.AddItem(Addon);
        }
    }

    ActivateOutputLink(0);
}

function Array<mcu8_HubAddon> GetAllAddons()
{
    local GameModInfo mod;
    local Array<mcu8_HubAddon> result;
    local string mapName;
    local Array<string> splitList;
    local mcu8_HubAddon proto;
    local Array<GameModInfo> modList;

    modList = class'GameMod'.static.GetModList();

    foreach modList(mod)
    {
        if (mod.IsEnabled) 
        {
            foreach mod.MapNames(mapName) 
            {
                // Check if map contains prefix
                splitList = SplitString(mapName, "_");
                if (splitList[0] == "hubexmap") 
                {
                    proto = new class'mcu8_HubAddon';
                    proto.MapName = mapName;
                    proto.AddonName = mod.Name;
                    result.AddItem(proto);
                }
            }
        }
    }

    return result;
}

defaultproperties
{
  ObjName="[BH] Get all hub addons"
  ObjCategory="BetterHub"
  InputLinks(0)=(LinkDesc="In")
  OutputLinks(0)=(LinkDesc="Out")
  VariableLinks.Empty
  VariableLinks(0)=(ExpectedType=class'SeqVar_ObjectList',LinkDesc="Out Objects",bWriteable=true)
}