class mcu8_HUDMenuMainMenu extends Hat_HUDMenuMainMenu;

function bool TriggerCommandEvent(HUD H, string cmd)
{
	if (Locs(cmd) == "startgame") {
		class'mcu8_mods_BetterHubMain'.static.SoftGoToHub(class'mcu8_HUDMenuMainMenu');
		return true;
	}
	else {
		return Super.TriggerCommandEvent(H, cmd);
	}
}
