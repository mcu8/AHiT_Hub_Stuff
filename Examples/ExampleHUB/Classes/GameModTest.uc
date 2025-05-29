class GameModTest extends GameMod;

event OnModLoaded()
{
    SetTimer(0.01, false, NameOf(DelayedHubSwapperHelperCall));
}

function DelayedHubSwapperHelperCall()
{
    Spawn(class'mcu8_HubSwapperHelper',self,,,);
}
