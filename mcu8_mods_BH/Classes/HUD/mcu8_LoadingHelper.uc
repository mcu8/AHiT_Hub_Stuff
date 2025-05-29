class mcu8_LoadingHelper extends Object;

static function DrawBHStuff(Hat_HUDElement_Base Base, Canvas C, GameModInfo currMod, GameModInfo loadMod, bool VerboseOut) 
{
	local float textScaleWatermark;
	local int lineOffset;
	local Font backupFont;
	
	textScaleWatermark = 0.00036 * 3;
	lineOffset = 15;

	backupFont = C.Font;
	C.Font = Font'enginefonts.TinyFont'; // hopefully it should fix 

	// watermark
	C.SetDrawColor(0,128,128,255);

	if (currMod.Name != class'mcu8_mods_BetterHubMain'.default.DummyGMI.Name)
		Base.DrawTopLeftText(C, currMod.Name $ " by " $ currMod.Author, 0.8, 0.8, textScaleWatermark*C.ClipY, textScaleWatermark*C.ClipY);
	
	if (VerboseOut) {
		if (loadMod.Name != "" && currMod.Name != class'mcu8_mods_BetterHubMain'.default.DummyGMI.Name) Base.DrawTopLeftText(C, "Current HUB map: " $ loadMod.Name $ " (ver. " $ loadMod.Version $ ") by " $ loadMod.Author, 0.8, 0.8 + (lineOffset*(textScaleWatermark*C.ClipY)), textScaleWatermark*C.ClipY, textScaleWatermark*C.ClipY);
		C.SetDrawColor(0,128,0,255);
		Base.DrawTopLeftText(C, class'mcu8_mods_BetterHubMain'.static.GetStatus(), 0.8, 0.8 + ((lineOffset*2)*(textScaleWatermark*C.ClipY)), textScaleWatermark*C.ClipY, textScaleWatermark*C.ClipY);
	}

	C.Font = backupFont;

	// restore old color
	C.SetDrawColor(255,255,255,255);
}
