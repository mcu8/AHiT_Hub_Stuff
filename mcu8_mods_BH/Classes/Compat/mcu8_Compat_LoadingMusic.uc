class mcu8_Compat_LoadingMusic extends object;

var() string ModMainClass;
var() string ModPackage;

static function bool IsInstalled() {
    return class'Hat_ClassHelper'.static.ActorClassFromName(default.ModMainClass, default.ModPackage) != None;
}

defaultproperties 
{
    ModMainClass = "mcu8_mods_LoadingMusicMain";
    ModPackage = "mcu8_mods_LoadingMusic";
}

