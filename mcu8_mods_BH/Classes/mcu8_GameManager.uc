class mcu8_GameManager extends Object; // What did you expect here, a real GameManager? Pffff... Here's an Object :hueh:

static function RestartCurrentMap() 
{
    if (`GameManager.GetCurrentMapFilename() ~= `GameManager.HubMapName && class'mcu8_mods_BetterHubMain'.static.ShouldReplaceHub())
    {
        // HubSwapper proxy
        `GameManager.ChangeLevel(string(class'mcu8_mods_BetterHubMain'.static.GetEntryMap()));
    }
    else {
        `GameManager.RestartCurrentMap();
    }
}

static function ChangeLevel(name map)
{
    FixLoadedMap(string(map));
    if (string(map) ~= `GameManager.HubMapName && class'mcu8_mods_BetterHubMain'.static.ShouldReplaceHub())
    {
        // HubSwapper proxy
        `GameManager.ChangeLevel(string(class'mcu8_mods_BetterHubMain'.static.GetEntryMap()));
    }
    else
    {
        `GameManager.ChangeLevel(string(map));
    }
}

static function FixLoadedMap(string cm)
{
    local Array<string> splitList;
    local mcu8_HubConfig cfg;
    splitList = SplitString(Locs(cm), "_");
    if (splitList[0] == "hubexmap") 
    {
        cfg = class'mcu8_HubConfig'.static.Load();
        cfg.IsHubLoadingEnabled = true;
        cfg.LastMap = cm;
        cfg.Save();
    }
}


