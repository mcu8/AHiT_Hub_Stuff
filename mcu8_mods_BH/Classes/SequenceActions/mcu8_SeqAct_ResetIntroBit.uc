class mcu8_SeqAct_ResetIntroBit extends SequenceAction;

event Activated()
{
    local GameModInfo currentModInfo;
	
    currentModInfo = class'mcu8_mods_BetterHubMain'.static.GetCurrModInfo();
    if (currentModInfo.IntroductionMap != "") {
        class'Hat_SaveBitHelper'.static.RemoveLevelBit("Mods_" $ currentModInfo.PackageName $ "." $ currentModInfo.IntroductionMap $ "_PlayedIntroOnce", 1, `GameManager.HubMapName);
    }
}

defaultproperties
{
	ObjName="[BH] Reset intro bit"
	ObjCategory="BetterHub"
}
