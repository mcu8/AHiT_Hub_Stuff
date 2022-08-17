class mcu8_HUDElementActTitleCard extends Hat_HUDElementActTitleCard;

var() bool HubIsLoading;
var() GameModInfo currMod;
var() GameModInfo loadMod;
var() bool VerboseOut;

var transient private Hat_MusicNodeBlend_Dynamic SilentMusicNodeB;
var transient private Hat_MusicNodeBlend_Dynamic LoadingMusicNodeB; // Only used for IsNonMapChangeTitlecard

function OnOpenHUD(HUD H, optional String command)
{
	local String hubName;
	hubName = `GameManager.HubMapName;

	IsExit = (command == "exit");

	currMod = class'mcu8_mods_BetterHubMain'.static.GetCurrModInfo();
	loadMod = currMod;//= class'mcu8_mods_BetterHubMain'.static.GetCurrModInfo(); todo

	VerboseOut = class'mcu8_mods_BetterHubMain'.static.IsTitlecardVerboseOutput();
	
	if (class'mcu8_Compat_LoadingMusic'.static.IsInstalled())
		TryGetModCardMusic(Locs(command));

    if (Locs(command) == class'mcu8_mods_BetterHubMain'.static.GetHubMapName() || Locs(command) == Locs(hubName)) {
		HubIsLoading = true;
		//command = class'mcu8_mods_BetterHubMain'.static.GetHubMapName();
	}
	else if (command != "exit" && command != "") {
		HubIsLoading = false;
	}

	if (IsExit && IsNonMapChangeTitlecard)
	{
		class'Engine'.static.GetAudioDevice().TransientSoundEffectVolume = 1;
		if (SilentMusicNodeB != None)
		{
			SilentMusicNodeB.Stop();
			SilentMusicNodeB = None;
		}
		if (LoadingMusicNodeB != None)
		{
			LoadingMusicNodeB.Stop();
			LoadingMusicNodeB = None;
		}
	}
	
	Super.OnOpenHUD(H, command);
}

function bool Tick(HUD H, float d)
{
	local float prev;
	local InterpCurveFloat Curve;
	local float MusicVolume, scale;
	local Texture2D CurrentDLCLogo;
	//if (!Super.Tick(H, d)) return false;
	
    // If the world was loaded this tick, the time delta will include the loading screen time,
    // causing our animation to go super fast. Just don't tick in this case.
    if (WasWorldLoadedThisTick()) return false;

	prev = CurrentTime;
	
	if (IsExit)
		CurrentTime -= d*1.5625;
	else
		CurrentTime += d;
		
	if (!IsExit)
	{
		if (prev == 0.0 && CurrentTime > 0.0 && PlayLoadingScreenMusic)
		{
			MusicVolume = `MusicManager.default.MusicVolume;
			if (IsNonMapChangeTitlecard)
			{
				LoadingMusicNodeB = new class'Hat_MusicNodeBlend_Dynamic';
				LoadingMusicNodeB.Music = LoadingMusic2;
				LoadingMusicNodeB.BlendTimes[1] = 0.0; // no fade in
				LoadingMusicNodeB.BlendTimes[0] = 0.1; // Very little fadeout
				LoadingMusicNodeB.Priority = 501;
				`PushMusicNode(LoadingMusicNodeB);
			}
			else
			{
				class'Hat_GlobalDataInfo'.static.StartLevelTransitionMusic(UseActSelectLoadingMusic ? (IsDeathWish ? LoadingMusic_DW : LoadingMusic) : LoadingMusic2, MusicVolume);
			}
		}
		
		if (CurrentTime < 0.1f)
		{
			class'Engine'.static.GetAudioDevice().TransientSoundEffectVolume -= d/0.1f;
		}
		
		if (prev < 0.1 && CurrentTime >= 0.1)
		{
			if (Titlecard_Sound != None) PlayOwnerSound(H, Titlecard_Sound);
			if (!IsNonMapChangeTitlecard)
			{
				SilentMusicNodeB = new class'Hat_MusicNodeBlend_Dynamic';
				SilentMusicNodeB.Music = None;
				SilentMusicNodeB.Priority = 500;
				`PushMusicNode(SilentMusicNodeB);
			}
			//Hat_PlayerController(H.PlayerOwner).GetMusicManager().PushActionMusicLayer(None, 500, false);
			class'Engine'.static.GetAudioDevice().TransientSoundEffectVolume = 0;
		}
		
		if (prev < 0.7 && CurrentTime >= 0.7)
		{
			if (TitleMatInst != None)
			{
				Curve = class'Hat_HUD'.static.GenerateCurveFloat(0.2, 1.3, 0.8);
				TitleMatInst.SetScalarCurveParameterValue('Progress', Curve);
				TitleMatInst.SetScalarStartTime('Progress', 0.0);
			}
		}
		
		if (prev < 1.5 && CurrentTime >= 1.5)
		{
			if (TitleMatInst != None)
			{
				Curve = class'Hat_HUD'.static.GenerateCurveFloat(1.3, 1.3, 0.8);
				TitleMatInst.SetScalarCurveParameterValue('Progress', Curve);
				TitleMatInst.SetScalarStartTime('Progress', 0.0);
				TitleMatInst.SetScalarParameterValue('Progress', 1.3);
			}
		}
		
		if (prev < 1.6 && CurrentTime >= 1.6 && !IsNonMapChangeTitlecard)
		{
			CurrentDLCLogo = GetDLCLogo(scale);
			class'Hat_GlobalDataInfo'.static.SetLevelTransitionData_Act(TitleCardTexture,None,TitleMatInst);
			class'Hat_GlobalDataInfo'.static.SetLevelTransitionData(ChapterText, ChapterText, ActText, ActText);
			class'Hat_GlobalDataInfo'.static.SetLevelTransitionData_Common(
				Texture2D'HatInTime_Hud_LoadingScreen.Logo.Textures.logo_loop_0',
				Texture2D'HatInTime_Hud_LoadingScreen.Logo.Textures.logo_loop_1',
				Texture2D'HatInTime_Hud_LoadingScreen.Logo.Textures.logo_loop_2',
				CurrentDLCLogo,
				scale
			);

			class'Hat_GlobalDataInfo'.static.CreateLoadingScreen(2);
			if (MapName == "")
				class'mcu8_GameManager'.static.RestartCurrentMap();
			else
				class'mcu8_GameManager'.static.ChangeLevel(name(MapName));
			return true;
		}
	}
		
	else if (prev > 0.0 && CurrentTime <= 0.0)
	{
		CurrentTime = 0;
		if (!IsNonMapChangeTitlecard)
		{
			`GameManager.LoadingScreenFinished();
			class'Hat_GlobalDataInfo'.static.StopLevelTransitionMusic();
		}
		CloseHUD(H, Class);
		return true;
	}
	
	return true;
}

function bool TryGetModCardMusic(String strMapName) 
{
	local GameMod lMod;
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'GameMod', lMod)
	{
		Hat_GameEventsInterface(lMod).OnMiniMissionGenericEvent(Self, "CardMusic_" $ strMapName);		
	}
	return true;
}

function bool Render(HUD H)
{
	Super.Render(H);
	RenderStateCanvas(H.Canvas);
	return true;
}

function RenderStateCanvas(Canvas C)
{
	class'mcu8_LoadingHelper'.static.DrawBHStuff(self, C, currMod, loadMod, VerboseOut);
}

function CleanUp()
{
	Super.CleanUp();

	if (SilentMusicNodeB != None)
		SilentMusicNodeB = None;
	if (LoadingMusicNodeB != None)
		LoadingMusicNodeB = None;
}
