class mcu8_HubSwapperNotify extends Hat_HUDMenuConfirmationBox;

function OnOpenHUD(HUD H, optional string command)
{
    Super.OnOpenHUD(H, command);
	ConfirmationText.Length = 0;
	OptionTexts.Length = 0;

	if (command == "hs_msg_1")
	{
		ConfirmationText.AddItem("You installed custom hub...");
		OptionTexts[0] = "...and?";
		CurrentIndex = 0;
		AllowCancelOut = false;

	}
	else if (command == "hs_msg_2")
	{
		ConfirmationText.AddItem("...but you forgot about Hub Swapper!");
		OptionTexts[0] = "oh!";
		CurrentIndex = 0;
		AllowCancelOut = false;

	}
	else if (command == "hs_msg_3")
	{
		ConfirmationText.AddItem("Subscribe it from the Steam Workshop page!");
		OptionTexts[0] = "Open Workshop page";
		OptionTexts[1] = "Don't show again";
		CurrentIndex = 0;
		AllowCancelOut = false;
	}
}
