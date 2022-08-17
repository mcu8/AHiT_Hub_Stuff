/**
 *
 * Copyright 2012-2017 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_HUDMenuRateMod extends Hat_HUDMenu;

const ButtonInterpDuration = 0.1;

// Button Enum
enum EModRateMenuButton
{
	ModRate_None,
	ModRate_ThumbsUp,
	ModRate_ThumbsDown,
	ModRate_ReturnToHub,
	ModRate_NextMap,
	ModRate_ViewInWorkshop
};
var EModRateMenuButton SelectedButton;

var SoundCue SelectionChangedSound;
var SoundCue SelectSound;
var transient float ButtonHoverInterp;

// Info
var transient GameModInfo ModInfo;
var transient Texture2D ModIcon;
var transient GameModInfo NextLevelMod;
var transient bool IsLoadingNextMap;
var transient Array<EModRateMenuButton> MenuButtons;

// UI
var Surface BackgroundBlue;
var Surface BackgroundYellow;
//var Surface ThumbMaterial;
//var Surface ThumbMaterial_Silhouette;
var Texture2D ThumbsUpTextures[3];
var Texture2D ThumbsDownTextures[3];
var Surface PreviewButtonImage;
var Surface PreviewButtonImage_Silhouette;
var Surface WorkshopButton;
var Surface WorkshopButton_Silhouette;
var Surface SelectorTexture;

// Scene Capture
var transient float FadeTime;
var transient float FadeDuration;
var transient float ThinkWait;
var transient vector InitialActorLoc;
var transient vector TargetActorLoc;

var transient Hat_NPC_Player_UIPreview PlayerNPC;
var transient SceneCapture2DActor SceneCapture;
var SoundCue TeaseVoice;

var transient float PostAnimTimer;
var transient EExpressionType PostAnimExpression;

var MaterialInterface SceneCaptureMaterial;
var TextureRenderTarget2D SceneCaptureTexture;

var ParticleSystem UpvoteParticle;
var ParticleSystem DownvoteParticle;
var transient ParticleSystemComponent VoteParticleComponent;
var transient bool VoteParticleIsUpvote;

defaultproperties
{
	RequiresMouse = true;
	SharedInCoop = true;

	SelectedButton = ModRate_None;
	SelectionChangedSound = SoundCue'HatInTime_Hud.SoundCues.CursorMove'
	SelectSound = SoundCue'HatInTime_Hud.SoundCues.MenuNext'
	PostAnimTimer = -1;

	BackgroundBlue = Material'HatinTime_HUD_Settings.GraphicsSettings.MenuBox'
	BackgroundYellow = MaterialInstanceConstant'HatinTime_HUD_Settings.InputSettings.MenuBox'
	//ThumbMaterial = Material'HatinTime_HUD_Modding.Materials.ThumbsUp'
	//ThumbMaterial_Silhouette = MaterialInstanceConstant'HatinTime_HUD_Modding.Materials.ThumbsUp_Silhouette'
	
	//ThumbsUpTextures(0) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsup_idle'
	//ThumbsUpTextures(1) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsup_selected'
	//ThumbsUpTextures(2) = Texture2D'HatinTime_HUD_Modding.Textures.ThumbsUp_Silhouette'
	//ThumbsDownTextures(0) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsdown_idle'
	//ThumbsDownTextures(1) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsdown_selected'
	//ThumbsDownTextures(2) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsdown_silhouette'
	
	PreviewButtonImage = Texture2D'HatinTime_HUD_Modding.Textures.SharpButton'
	PreviewButtonImage_Silhouette = Material'HatinTime_HUD_Modding.Materials.SharpButton_Silhouette'
	WorkshopButton = Material'HatinTime_HUD_Modding.Materials.WorkshopButton'
	WorkshopButton_Silhouette = Material'HatinTime_HUD_Modding.Materials.WorkshopButton_Silhouette'
	SelectorTexture = Material'HatInTime_Hud_Loadout.Main.Selector_Animated'
	SceneCaptureMaterial = Material'HatinTime_Hud_ItemUnlock.Materials.3DPreview'
	SceneCaptureTexture = TextureRenderTarget2D'HatinTime_Hud_ItemUnlock.Textures.RenderTarget'
	TeaseVoice = SoundCue'HatinTime_Voice_HatKidApphia3.SoundCues.HatKid_Blerp1'
	FadeDuration = 0.4;
	ThinkWait = -1;
	UpvoteParticle = ParticleSystem'HatinTime_HUD_Modding.Particles.mod_thumbsUp'
	DownvoteParticle = ParticleSystem'HatinTime_HUD_Modding.Particles.mod_thumbsDown'
}

function GfBPleaseShareNewEditorPackagesLol()
{
	ThumbsUpTextures[0] = Texture2D(DynamicLoadObject("HatinTime_HUD_Modding.Textures.thumbsup_idle", class'Texture2D'));
	ThumbsUpTextures[1] = Texture2D(DynamicLoadObject("HatinTime_HUD_Modding.Textures.thumbsup_selected", class'Texture2D'));
	ThumbsUpTextures[2] = Texture2D(DynamicLoadObject("HatinTime_HUD_Modding.Textures.ThumbsUp_Silhouette", class'Texture2D'));
	ThumbsDownTextures[0] = Texture2D(DynamicLoadObject("HatinTime_HUD_Modding.Textures.thumbsdown_idle", class'Texture2D'));
	ThumbsDownTextures[1] = Texture2D(DynamicLoadObject("HatinTime_HUD_Modding.Textures.thumbsdown_selected", class'Texture2D'));
	ThumbsDownTextures[2] = Texture2D(DynamicLoadObject("HatinTime_HUD_Modding.Textures.thumbsdown_silhouette", class'Texture2D'));
}

function OnCloseHUD(HUD H)
{
	if (VoteParticleComponent != None)
	{
		VoteParticleComponent.DetachFromAny();
		VoteParticleComponent = None;
	}
	Super.OnCloseHUD(H);
}
function OnOpenHUD(HUD H, optional String command)
{
	local Vector v;
	local Rotator rot, ActorRot;

	GfBPleaseShareNewEditorPackagesLol();

	Super.OnOpenHUD(H, command);
	ModInfo = class'mcu8_mods_BetterHubMain'.static.GetCurrModInfo();
	ModIcon = class'GameMod'.static.GetModIcon(ModInfo);

	Hat_HUD(H).FadeIn(FadeDuration, -1);
	//LocalPlayer(H.PlayerOwner.Player).OverridePostProcessSettings( class'Hat_HUDMenuLoadout'.static.GetPostProcessSettings() );
	
	v = vect(-100000,100000,100000);
	rot = rot(0,0,0);

	// Create Player
	TargetActorLoc = v + Vector(rot)*250 + vect(0,0,-75);
	InitialActorLoc = TargetActorLoc + vect(0,0,300);
	ActorRot.Yaw = `HalfRot + (`QuarterRot / 3);
	PlayerNPC = H.PlayerOwner.Spawn(class'Hat_NPC_Player_UIPreview',,, InitialActorLoc, ActorRot,, true);
	LocalPlayer(H.PlayerOwner.Player).AudioListener = PlayerNPC;

	PlayerNPC.SetCollision(false, false, false);
	PlayerNPC.bCollideWorld = false;
	PlayerNPC.SetPhysics(PHYS_None);
	PlayerNPC.SkipForSceneCaptures = false;
	PlayerNPC.SetHidden(false);
	PlayerNPC.Expression.EnableEyeSeek = false;
	
	PlayerNPC.DisableHats = true;
	PlayerNPC.UpdateVisuals();
	PlayerNPC.PlayPreviewAnimation('FallingCycle', true, 1.0f);
	PlayerNPC.CreateInventory(class'Hat_Ability_Help');
	PlayerNPC.SkeletalMeshComponent.ForceSkelUpdate();
	PlayerNPC.SkeletalMeshComponent.SetUseTickOptimization(false);
	PlayerNPC.SkeletalMeshComponent.StreamingDistanceMultiplier = 100000;

	// Create Capture
	SceneCapture = H.PlayerOwner.Spawn(class'SceneCapture2DActorMovable',,, v, rot,, true);
	SceneCapture.SceneCapture.IgnoreWorldGeometry = true;
	SceneCapture.SceneCapture.SetFrameRate(60);
	SceneCapture2DComponent(SceneCapture.SceneCapture).SetView(v, rot);
	SceneCapture2DComponent(SceneCapture.SceneCapture).SetCaptureParameters(SceneCaptureTexture, 30, 0, 1100);
	
	MenuButtons.AddItem(ModRate_ReturnToHub);
	if (NextLevelMod.WorkshopId > 0)
		MenuButtons.AddItem(ModRate_ViewInWorkshop);
}

function bool DisablesMovement(HUD H)
{
	return true;
}

function bool DisablesCameraMovement(HUD H)
{
	return true;
}

function bool Tick(HUD H, float d)
{
	if (!Super.Tick(H, d)) return false;

	// Update NPC player animations
	if (FadeTime < FadeDuration)
	{
		FadeTime = FClamp(FadeTime + d, 0, FadeDuration);
		PlayerNPC.SetLocation( VLerp(InitialActorLoc, TargetActorLoc, FadeTime/FadeDuration) );

		if (FadeTime >= FadeDuration)
		{
			PlayerNPC.PlayAnimation('LandRecoil');
			ThinkWait = 0;
		}
	}
	else if (ThinkWait >= 0)
	{
		ThinkWait = FClamp(ThinkWait + d, 0, 0.8);

		if (ThinkWait >= 0.8)
		{
			ThinkWait = -1;
			PlayerNPC.PlayAnimation('Thinking03', true);
			PlayerNPC.Expression.SetDefaultExpression(EExpressionType_Serious);
		}
	}
	else if (PostAnimTimer >= 0)
	{
		PostAnimTimer -= d;

		if (PostAnimTimer <= 0)
		{
			PostAnimTimer = -1;
			PlayerNPC.PlayAnimation('Idle', true);
			PlayerNPC.Expression.SetDefaultExpression(PostAnimExpression);
		}
	}

	// Update thumb interpolation
	ButtonHoverInterp = FMin(ButtonHoverInterp + d/ButtonInterpDuration,1);

	if (!IsLoadingNextMap)
	{
		ReactivateMouseCheck(H);
	}

	return true;
}

function bool Render(HUD H)
{
	local float Size, PosX, PosY, SizeX, SizeY, Alpha;
    if (!Super.Render(H)) return false;
	
	Alpha = (FadeTime / FadeDuration) * 255;
	H.Canvas.SetDrawColor(255,255,255,Alpha);

	PosX = H.Canvas.ClipX*0.4;
	PosY = H.Canvas.ClipY*0.1;
	SizeX = H.Canvas.ClipX*0.6;
	SizeY = H.Canvas.ClipY*0.15;
	
	// Draw mod info box
	RenderModInfoBox(H, PosX, PosY, SizeX, SizeY);

	// Draw rating box
	PosY = H.Canvas.ClipY*0.5;
	SizeY = H.Canvas.ClipY*0.6;
	RenderRatingBox(H, PosX, PosY, SizeX, SizeY);

	// Draw buttons
	PosY = H.Canvas.ClipY*0.9;
	RenderButtons(H, PosX, PosY, SizeX);

	// Draw Hat Kid scene capture
	H.Canvas.SetDrawColor(255,255,255,255);
	Size = FMax(H.Canvas.ClipX, H.Canvas.ClipY)*0.6;
	DrawCenter(H, H.Canvas.ClipX*0.85f, H.Canvas.ClipY - (Size / 2), Size, Size, SceneCaptureMaterial);
    
    return true;
}

function RenderModInfoBox(HUD H, float PosX, float PosY, float SizeX, float SizeY)
{
	local float TitleFontScale, SmallFontScale, IconSize, TextX;
	local string NameString, VersionString, AuthorString;
	local Color prev;

	prev = H.Canvas.DrawColor;

	// Main background
	DrawCenter(H, PosX, PosY, SizeX, SizeY, BackgroundBlue);
	
	// Mod icon
	IconSize = 0;
	if (ModIcon != None)
	{
		IconSize = FMin(SizeX, SizeY)*0.9;
		DrawCenter(H, PosX - SizeX*0.48 + IconSize*0.5, PosY, IconSize, IconSize, ModIcon);
	}


	// Mod title
	TextX = PosX - SizeX*0.46 + IconSize;
	TitleFontScale = FMin(SizeX, SizeY)*0.007;
	NameString = ModInfo.Name;
	NameString = ElidedString(H, NameString, TitleFontScale, SizeX);
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(NameString);
	class'Hat_HUDMenu'.static.RenderBorderedText(H, self, NameString, TextX, PosY - SizeY*0.28, TitleFontScale, TextAlign_Left);

	// Separation bar

	H.Canvas.SetDrawColor(0,0,0,prev.A);
	DrawCenter(H, PosX + IconSize*0.5, PosY, SizeX*0.95 - IconSize*1.2, SizeY*0.02, H.Canvas.DefaultTexture);
	H.Canvas.DrawColor = prev;


	// Mod details
	SmallFontScale = FMin(SizeX, SizeY)*0.004;
	VersionString = "Version " $ ModInfo.Version;
	VersionString = ElidedString(H, VersionString, SmallFontScale, SizeX);
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(VersionString);
	class'Hat_HUDMenu'.static.RenderBorderedText(H, self, VersionString, TextX, PosY + SizeY*0.1, SmallFontScale, TextAlign_Left);

	AuthorString = "by " $ ModInfo.Author;
	AuthorString = ElidedString(H, AuthorString, SmallFontScale, SizeX);
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(AuthorString);
	class'Hat_HUDMenu'.static.RenderBorderedText(H, self, AuthorString, TextX, PosY + SizeY*0.33, SmallFontScale);
}

function RenderRatingBox(HUD H, float PosX, float PosY, float SizeX, float SizeY)
{
	local float FontScale, ThumbSize;

	FontScale = SizeX*0.0007;

	// Draw main background
	DrawCenter(H, PosX, PosY, SizeX, SizeY, BackgroundBlue);

	// Draw main info text
	DrawLocalizedString(H, "PleaseRate_0", FontScale, SizeX, PosX, PosY-SizeY*0.44, TextAlign_Center);
	DrawLocalizedString(H, "PleaseRate_1", FontScale, SizeX, PosX, PosY-SizeY*0.36, TextAlign_Center);

	// Draw bottom text
	DrawLocalizedString(H, "HowToComment", FontScale, SizeX, PosX, PosY+SizeY*0.44, TextAlign_Center);

	// Draw thumbs up/down icons
	ThumbSize = FMin(SizeX, SizeY)*0.4;
	DrawThumb(H, true, PosX - SizeX*0.2, PosY+SizeY*0.02, ThumbSize);
	DrawThumb(H, false, PosX + SizeX*0.2, PosY+SizeY*0.02, ThumbSize);
}

function DrawThumb(HUD H, bool ThumbsUp, float PosX, float PosY, float Size)
{
	local EModRateMenuButton Button;
	local bool IsScalingUp, IsSelected, AnySelected;
	
	if (VoteParticleComponent != None && VoteParticleIsUpvote == ThumbsUp)
	{
		H.Canvas.SetPos(PosX, PosY);
		VoteParticleComponent.RenderToCanvas(H.Canvas);
	}

	// Handle selection changing
	Button = (ThumbsUp ? ModRate_ThumbsUp : ModRate_ThumbsDown);
	CheckMouseOverButton(H, PosX, PosY, Size, Size, Button);

	// Handle interpolation
	IsScalingUp = (SelectedButton == Button);
	
	IsSelected = ModInfo.VoteStatus == (ThumbsUp ? 1 : 0);
	AnySelected = ModInfo.VoteStatus >= 0;
	if (IsSelected)
	{
		Size *= 1.4;
	}
	else if (AnySelected)
	{
		Size *= 0.9;
	}

	if (IsScalingUp)
		Size = class'Hat_Math'.static.InterpolationOvershoot(Size, Size*1.2, ButtonHoverInterp, 10);
	
	if (IsScalingUp)
	{
		if (ThumbsUp)
			H.Canvas.SetDrawColor(0, 255, 0, 255);
		else
			H.Canvas.SetDrawColor(255, 0, 0, 255);
		class'Hat_HUDMenu_ModLevelSelect'.static.RenderPulse(H, self, ThumbsUp ? ThumbsUpTextures[2] : ThumbsDownTextures[2], PosX, PosY, Size, Size, true);
	}
	if (!IsSelected && AnySelected)
		H.Canvas.SetDrawColor(128, 128, 128, 255);
	else
		H.Canvas.SetDrawColor(255, 255, 255, 255);
	DrawCenter(H, PosX, PosY, Size, Size, ThumbsUp ? ThumbsUpTextures[IsSelected ? 1 : 0] : ThumbsDownTextures[IsSelected ? 1 : 0]);
	H.Canvas.SetDrawColor(255, 255, 255, 255);
}

function RenderButtons(HUD H, float PosX, float PosY, float SizeX)
{
	local EModRateMenuButton CurButton;
	local float ButtonWidth, ButtonSpacing, MyPosX;
	local int ButtonIdx;
	
	ButtonWidth = SizeX * 0.3;
	ButtonSpacing = ButtonWidth*1.3;
	
	for (ButtonIdx = 0; ButtonIdx < MenuButtons.Length; ButtonIdx++)
	{
		MyPosX = PosX;
		MyPosX -= (MenuButtons.Length-1)*ButtonSpacing*0.5f;
		MyPosX += ButtonIdx*ButtonSpacing;
		
		
		CurButton = MenuButtons[ButtonIdx];
		DrawButton(H, MyPosX, PosY, ButtonWidth, ButtonWidth*0.25, CurButton);
	}
}

function DrawButton(HUD H, float PosX, float PosY, float SizeX, float SizeY, EModRateMenuButton Button)
{
	local string StringName;
	local float StringOffsetY, alpha;

	StringName = "";
	StringOffsetY = 0;
	if (Button == ModRate_ReturnToHub)			StringName = "Close";
	else if (Button == ModRate_NextMap)			StringName = "NextMap";
	else if (Button == ModRate_ViewInWorkshop)
	{
		StringName = "PreviewButtonsText_ViewInWorkshop";
		SizeY *= 1.6;
		StringOffsetY = SizeY*-0.33;
	}

	CheckMouseOverButton(H, PosX, PosY, SizeX, SizeY, Button);

	// Draw the button
	if (SelectedButton == Button)
	{
		alpha = class'Hat_Math'.static.InterpolationOvershoot(1, 1.2, ButtonHoverInterp, 10);
		SizeX *= alpha;
		SizeY *= alpha;
		StringOffsetY *= alpha;
		class'Hat_HUDMenu_ModLevelSelect'.static.RenderPulse(H, self, Button == ModRate_ViewInWorkshop ? WorkshopButton_Silhouette : PreviewButtonImage_Silhouette, PosX, PosY, SizeX, SizeY);
	}
	
	DrawCenter(H, PosX, PosY, SizeX, SizeY, Button == ModRate_ViewInWorkshop ? WorkshopButton : PreviewButtonImage);
	if (StringName != "")
		DrawLocalizedString(H, StringName, SizeX*0.0025, SizeX, PosX, PosY+StringOffsetY, TextAlign_Center);
}

function CheckMouseOverButton(HUD H, float PosX, float PosY, float SizeX, float SizeY, EModRateMenuButton Button)
{
	local bool IsSelected;

	// Handle selection changing
	if (!Hat_HUD(H).IsGamepad() && MouseActivated)
	{
		IsSelected = IsMouseInArea(H, PosX, PosY, SizeX, SizeY);

		if (IsSelected && SelectedButton != Button)
		{
			PlayOwnerSound(H, SelectionChangedSound);
			SelectedButton = Button;
			ButtonHoverInterp = 0;
		}
		else if (!IsSelected && SelectedButton == Button)
		{
			SelectedButton = ModRate_None;
		}
	}
}

function DrawLocalizedString(HUD H, string StringName, float TextScale, float SizeX, float PosX, float PosY, TextAlign Alignment = TextAlign_TopLeft)
{
	local string LocalizedText;

	LocalizedText = StringName == "Close" ? "Close" : class'Hat_Localizer'.static.GetMenu("Modding", StringName); //don't break the language packs...
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(LocalizedText);
	class'Hat_HUDMenu'.static.RenderBorderedText(H, self, LocalizedText, PosX, PosY, TextScale, Alignment);
}

function ReturnToHub(HUD H)
{
	Hat_HUD(H).CloseHUD(class'mcu8_HUDMenuRateMod');
    PlayerNPC.Destroy();
    SceneCapture.Destroy();
    LocalPlayer(H.PlayerOwner.Player).AudioListener = None;
}

function ViewInWorkshop()
{
	local string WorkshopURL;
	WorkshopURL = "http://steamcommunity.com/sharedfiles/filedetails/?id=" $ ModInfo.WorkshopId;
	class'Hat_GameManager_Base'.static.OpenBrowserURL(WorkshopURL);
}

function bool OnClick(HUD H, bool release)
{
	if (release) return false;
	if (FadeTime < FadeDuration || ThinkWait >= 0) return false;

	if (SelectedButton == ModRate_ThumbsUp && PostAnimTimer <= 0)
	{
		PlayerNPC.PlayPreviewAnimation('npc_kiss');
		PlayerNPC.Expression.SetExpression(EExpressionType_Surprised, 0.83f);
		PostAnimTimer = 0.83f;
		PostAnimExpression = EExpressionType_Happy;
		class'GameMod'.static.SetModVote(ModInfo.WorkshopId, true);
		ModInfo.VoteStatus = 1;
		CreateVoteParticle(H, true);
		Hat_PlayerController(H.PlayerOwner).UnlockAchievement(39);
		Hat_PlayerController(H.PlayerOwner).UnlockAchievement(40);
	}
	else if (SelectedButton == ModRate_ThumbsDown && PostAnimTimer <= 0)
	{
		PlayerNPC.PlayPreviewAnimation('npc_tease');
		PlayerNPC.Expression.SetExpression(EExpressionType_Smirk, 2.0f);
		PostAnimTimer = 2.0f;
		PostAnimExpression = EExpressionType_Angry;
		PlayOwnerSound(H, TeaseVoice);
		class'GameMod'.static.SetModVote(ModInfo.WorkshopId, false);
		ModInfo.VoteStatus = 0;
		CreateVoteParticle(H, false);
		Hat_PlayerController(H.PlayerOwner).UnlockAchievement(39);
		Hat_PlayerController(H.PlayerOwner).UnlockAchievement(40);
	}
	else if (SelectedButton == ModRate_ReturnToHub)
	{
		ReturnToHUB(H);
	}
	else if (SelectedButton == ModRate_ViewInWorkshop)
	{
		ViewInWorkshop();
	}
	else
	{
		return false;
	}
	
	PlayOwnerSound(H, SelectSound);
	return true;
}

function bool CheckDefaultSelection()
{
	if (SelectedButton == ModRate_None)
	{
		SelectedButton = ModRate_ThumbsUp;
		return true;
	}
	else
		return false;
}

function bool OnPressDown(HUD H, bool menu, bool release)
{
	if (release) return false;

	if (SelectedButton == ModRate_None)
		SelectedButton = ModRate_ThumbsUp;

	else if ((SelectedButton == ModRate_ThumbsUp || SelectedButton == ModRate_ThumbsDown) && MenuButtons.Length > 0)
		SelectedButton = MenuButtons[0];

	else
		return false;
	
	ButtonHoverInterp = 0;
	SetMouseHidden(H,true);
	PlayOwnerSound(H, SelectionChangedSound);
	return true;
}

function bool OnPressUp(HUD H, bool menu, bool release)
{
	if (release) return false;

	if (SelectedButton == ModRate_None || MenuButtons.Find(SelectedButton) != INDEX_NONE)
		SelectedButton = ModRate_ThumbsUp;
	else
		return false;
	
	ButtonHoverInterp = 0;
	SetMouseHidden(H,true);
	PlayOwnerSound(H, SelectionChangedSound);
	return true;
}

function bool OnPressLeft(HUD H, bool menu, bool release)
{
	if (release) return false;

	if (SelectedButton == ModRate_None)
		SelectedButton = ModRate_ThumbsUp;

	else if (SelectedButton == ModRate_ThumbsDown)
		SelectedButton = ModRate_ThumbsUp;

	else if (MenuButtons.Length > 0 && MenuButtons.Find(SelectedButton) > 0)
		SelectedButton = MenuButtons[MenuButtons.Find(SelectedButton)-1];

	else
		return false;
	
	ButtonHoverInterp = 0;
	SetMouseHidden(H,true);
	PlayOwnerSound(H, SelectionChangedSound);
	return true;
}

function bool OnPressRight(HUD H, bool menu, bool release)
{
	if (release) return false;

	if (SelectedButton == ModRate_None)
		SelectedButton = ModRate_ThumbsUp;

	else if (SelectedButton == ModRate_ThumbsUp)
		SelectedButton = ModRate_ThumbsDown;

	else if (MenuButtons.Length > 0 && MenuButtons.Find(SelectedButton) != INDEX_NONE && MenuButtons.Find(SelectedButton) < MenuButtons.Length-1)
		SelectedButton = MenuButtons[MenuButtons.Find(SelectedButton)+1];

	else
		return false;
	
	ButtonHoverInterp = 0;
	SetMouseHidden(H,true);
	PlayOwnerSound(H, SelectionChangedSound);
	return true;
}


function CreateVoteParticle(HUD H, bool Upvote)
{
	local ParticleSystemComponent pc;
	if (UpvoteParticle == None) return;
	if (DownvoteParticle == None) return;
	
	pc = new class'ParticleSystemComponent';
	pc.SetTemplate(Upvote ? UpvoteParticle : DownvoteParticle);
	pc.KillParticlesForced();
	H.PlayerOwner.Pawn.AttachComponent(pc);
	pc.CanvasExclusive();
	pc.SecondsBeforeInactive = 0;
	pc.SetScale(5);
	
	if (VoteParticleComponent != None)
	{
		VoteParticleComponent.DetachFromAny();
	}
	
	VoteParticleComponent = pc;

	VoteParticleIsUpvote = Upvote;
}