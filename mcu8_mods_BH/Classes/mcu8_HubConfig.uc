class mcu8_HubConfig extends Object;

const ConfigPath = "ModConfig/HubConf.cfg";

var string LastMap;
var bool UseManholeInsteadTeleporter;
var bool IsHubLoadingEnabled;
var bool TitlecardVerbose;
var bool FastBoot;
var bool Init;
var bool IgnoreIcons;

static function mcu8_HubConfig Load() {
    local mcu8_HubConfig conf;
    conf = new class'mcu8_HubConfig';

    class'Engine'.static.BasicLoadObject(conf, ConfigPath, false, 1);
    return conf;
}

function Save() {
    class'Engine'.static.BasicSaveObject(Self, ConfigPath, false, 1);
}

defaultproperties 
{
    LastMap = "mcu8_maps_bhtest"
    UseManholeInsteadTeleporter = false
    IsHubLoadingEnabled = true
    TitlecardVerbose = true
    FastBoot = false
    Init = false
    IgnoreIcons = true
}
