class mcu8_HUDElementLoadingScreen extends Hat_HUDElementLoadingScreen_Base;

var() bool HubIsLoading;
var() GameModInfo currMod;
var() GameModInfo loadMod;
var() bool VerboseOut;

var ScriptedTexture StateCanvas;

defaultproperties
{
	LogoIntro = Texture2D'HatInTime_Hud_LoadingScreenNoS.Logo.Textures.logo_intro'
	LogoOutro = Texture2D'HatInTime_Hud_LoadingScreenNoS.Logo.Textures.logo_outro'
	Background = Texture2D'HatInTime_Hud_LoadingScreen.Logo.Textures.spotlight_bg'
	MuMissionClass = class'Hat_HUDElementLoadingScreen_MuMission';
}

function OnOpenHUD(HUD H, optional String command)
{
	local Hat_MusicNodeBlend_Dynamic DynamicMusicNode;
	local String hubName;
	hubName = `GameManager.HubMapName;

	currMod = class'mcu8_mods_BetterHubMain'.static.GetCurrModInfo();
	loadMod = currMod;//class'mcu8_mods_BetterHubMain'.static.GetCurrModInfo(false); todo

	VerboseOut = class'mcu8_mods_BetterHubMain'.static.IsTitlecardVerboseOutput();

    if (Locs(command) == class'mcu8_mods_BetterHubMain'.static.GetHubMapName() || Locs(command) == Locs(hubName)) {
		HubIsLoading = true;
		//command = class'mcu8_mods_BetterHubMain'.static.GetHubMapName();
	}
	else if (command != "exit" && command != "") {
		HubIsLoading = false;
	}
        
	MapName = command;
	TransitionToMuMission = false;
	RealTime = !IsReverse();
	
	if (IsReverse())
	{
		Progress = 2.0;
		class'Hat_GlobalDataInfo'.static.DestroyLoadingScreen();
	}
	else
	{
		// Add silence
		DynamicMusicNode = new class'Hat_MusicNodeBlend_Dynamic';
		DynamicMusicNode.Music = None;
		DynamicMusicNode.BlendTimes[1] = 0.3; // 0.3s fadein
		DynamicMusicNode.Priority = 500;
		`PushMusicNode(DynamicMusicNode);
	}

	Hat_GameManager(GetWorldInfo().Game).IsMidMapTransition = true;
}

function bool Tick(HUD H, float d)
{
	local float prev_val, triggertime;
	local Texture2D CurrentDLCLogo;
	local float DLCScale;
	
	//if (!Super.Tick(H, d)) return false;
	prev_val = Progress;
	NumberOfFramesSinceStart++;
	
	triggertime = 1.0 + ExtraIdleDelayTime;
	if (MuMissionClass != None && TransitionToMuMission)
		triggertime += MuMissionDelayTime;
	
	if (Progress < triggertime && !IsReverse())
	{
		Progress += d*1.3;
		Progress = FMin(Progress,triggertime);
		class'Engine'.static.GetAudioDevice().TransientSoundEffectVolume = 1-FMin(Progress/0.2f,1.f);
	}
	if (Progress > 0.0 && IsReverse() && NumberOfFramesSinceStart >= 10)
	{
		Progress -= d*2;
		Progress = FMax(Progress,0.0);
	}
	
	if (Progress >= triggertime && prev_val < triggertime && MapName != "" && !IsReverse())
	{
		if (MuMissionClass != None && TransitionToMuMission)
		{
			OpenHUD(H, MuMissionClass, MapName);
			CloseHUD(H);
		}
		else
		{
			CurrentDLCLogo = class'Hat_HUDElementActTitleCard'.static.GetDLCLogo(DLCScale);
			class'Hat_GlobalDataInfo'.static.SetLevelTransitionData_Act(Background,None,None);
			class'Hat_GlobalDataInfo'.static.SetLevelTransitionData_Common(
				Texture2D'HatInTime_Hud_LoadingScreen.Logo.Textures.logo_loop_0',
				Texture2D'HatInTime_Hud_LoadingScreen.Logo.Textures.logo_loop_1',
				Texture2D'HatInTime_Hud_LoadingScreen.Logo.Textures.logo_loop_2',
				CurrentDLCLogo,
				DLCScale);
			class'Hat_GlobalDataInfo'.static.CreateLoadingScreen(0);
			class'mcu8_GameManager'.static.ChangeLevel(name(MapName));
		}
	}
	else if (Progress <= 0.0 && prev_val > 0.0 && IsReverse())
	{
		Hat_GameManager(GetWorldInfo().Game).LoadingScreenFinished();
		CloseHUD(H);
	}
		
	
	return true;
}

function bool Render(HUD H) {
	RenderNewLoading(H, H.Canvas, FClamp(Progress,0,1));
	RenderStateCanvas(H.Canvas);
    return true;
}

function RenderStateCanvas(Canvas C)
{
	class'mcu8_LoadingHelper'.static.DrawBHStuff(self, C, currMod, loadMod, VerboseOut);
}
