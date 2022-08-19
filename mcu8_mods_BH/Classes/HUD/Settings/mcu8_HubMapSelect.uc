/**
 *
 * Copyright 2012-2021 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_HubMapSelect extends Hat_HUDMenu;

const Debug_BulkTest = 0;
const Debug_AlwaysShowLevelMenu = false;
const Debug_AlwaysShowDLCMenu = false;
const Debug_HideUI = false;
const Debug_ForceDLCScreen = false;

const AllowCategories = true;
const IconSelectAnimationTime = 0.1;
const NumItemsPerRow = 5;
const ShowFeaturedMods = true;
const ShowFeaturedModLevels = true;
const ShowChallengeRoad = true;
const LastDownload_ChallengeRoad = -2;

enum EModLevelPreviewButton
{
	LevelPreview_None,
	LevelPreview_Play,
	LevelPreview_Enable,
	LevelPreview_Config,
	LevelPreview_Workshop,
	LevelPreview_ThumbsUp,
	LevelPreview_ThumbsDown,
	LevelPreview_DownloadMod,
	LevelPreview_DownloadModMap,
	LevelPreview_UnSubscribe,
	LevelPreview_CancelDownload,
	LevelPreview_PlayIntroduction,
	LevelPreview_Credits,
	LevelPreview_Back,
};

struct ModMenuTab
{
	var string TabName;
	var Array<GameModInfo> GameMods;
	var Array<float> InterpList;
	var Array<Texture2D> Icons;
	var string WorkshopURL;
	var Surface Background;
	var float FadeIn;
	var Color TabColor;
	var int EmptyDisplayMode;
	var int SpecialRenderingMode;
	var int BackgroundParticleIndex;
	var Array<Surface> Overlay;
	
	structdefaultproperties
	{
		WorkshopURL = "https://steamcommunity.com/workshop/filedetails/?id=2273080350";
		Background = Material'HatinTime_HUD_Modding.Materials.ModMenuBackground';
		TabColor = (R=142,G=62,B=48);
	}
};

var Array<ModMenuTab> ModMenuTabs;
var int CurrentModMenuIndex;

var transient float IconCooldown;

var int SelectedInTab;
var int PrevMouseSelection;
//var int SelectedIndex;
var int SelectedTab;
var bool SelectedWorkshopBrowse;
var float SelectedWorkshopBrowse_FadeIn;

var transient float MenuFadeIn;

var float ScrollOffset;
var float ScrollTarget;

var bool Preview;
var bool UndoPreview;
var bool IsCredits;
var float PreviewTime;
var bool IsMenuFrozen;
var transient bool IsBuildingTabMenus;
var Array<EModLevelPreviewButton> PreviewButtons;
var transient Array<string> PreviewButtonsText;
var Array<Surface> PreviewButtonsIcon;
var GameModInfo PreviewMod;
var Texture2D PreviewIcon;
var Texture2D ModDisabledIcon;
var Texture2D ModPlayedIcon;
var Surface ModUpdatingIcon;
var Texture2D CheckmarkUncheckedIcon;
var Texture2D MailRoomIcon;

var SoundCue SelectionChangedSound;
var SoundCue SelectSound;
var SoundCue ExitSound;
var SoundCue TabSound;
var SoundCue RateUpSound;
var SoundCue RateDownSound;
var SoundCue WorkshopSound;
var SoundCue DownloadSound;
var SoundCue UnsubscribeSound;
var SoundCue CreatorDLCOpen;
var SoundCue CreatorDLCClose;
var SoundCue CreatorDLCPreview;
var SoundCue CreatorDLCChangeChannel;
var SoundCue CreatorDLCMusic;
var SoundCue CreatorDLCSelectSound;
var SoundCue CreatorDLCSelectionChangedSound;
var transient Hat_MusicNodeBlend_Dynamic DynamicMusicNode;

var Color DefaultTabColor;
var float PreviewButtonsInterp;

var Texture2D RateStar;
var Texture2D UnloadedImage;
var Texture2D ModIconSelectImage[2];
var Texture2D CreatorDLCLogo;
var Surface PreviewButtonImage;
var Surface PreviewButtonImage_Silhouette;
var Surface WorkshopButton;
var Surface WorkshopButton_Silhouette;
var Surface DLCButton;
var Texture2D TabImage;
var Texture2D ThumbsUpTextures[3];
var Texture2D ThumbsDownTextures[3];

var transient float ThumbsUpInterp;
var transient float ThumbsDownInterp;

var transient float ClickDelay;
var transient bool IsLoadingMap;

var bool MouseClear;

var int ModListMode;
var int LScrollbarState;
var bool LScrollbarPress;
var float LScrollbarOutput;
var float LScrollbarDrag;

var int PScrollbarState;
var bool PScrollbarPress;
var float PScrollbarOutput;
var float PScrollbarDrag;
var float TextScrollOffset;
var float TextScrollMax;

var color ScrollbarColorBack;
var color ScrollbarColorButtons;
var color ScrollbarColorHover;
var color ScrollbarColorPressed;

var EModLevelPreviewButton SelectedButton;

var ParticleSystem UpvoteParticle;
var ParticleSystem DownvoteParticle;
var transient ParticleSystemComponent VoteParticleComponent;
var transient bool VoteParticleIsUpvote;

var transient ParticleSystem BackgroundParticle[3];
var transient ParticleSystemComponent BackgroundParticleComponent[2];
var transient string NoModsLocalizedText;
var transient string DownloadingModText;
var transient string ModCreatedByText;
var transient string ModVersionText;
var transient string BrowseWorkshopText;
var transient string BrowseDLCText;
var transient Array<string> HowToAccessLevelModsText;
var transient int LastDownloadedPreview;
var transient MaterialInstanceConstant BackgroundInstance;
var transient MaterialInstanceConstant PreviewInstance;
var Texture2D ItemShadow;
var Texture2D DefaultDisc;
var Texture2D BackgroundRippedPaper;
var transient Texture2D PreviewLogo;
var transient Texture2D PreviewSplashArt;
var transient Texture2D PreviewBackgroundArt;
var transient Texture2D PreviewTitlecard;
var transient array<string> CreditsList;

var transient Array<MaterialInstanceConstant> LineInstances;

defaultproperties
{
	RequiresMouse = true

	SelectionChangedSound = SoundCue'HatInTime_Hud.SoundCues.CursorMove'
	SelectSound = SoundCue'HatInTime_Hud.SoundCues.MenuNext'
	ExitSound = SoundCue'HatInTime_Hud.SoundCues.MenuSkip'
	TabSound = SoundCue'HatinTime_SFX_Photoshooting.SoundCues.Drawing_Cursor_Select_SmallSize'
	RateUpSound = SoundCue'HatinTime_SFX_UI2.SoundCues.QuizCorrect'
	RateDownSound = SoundCue'HatinTime_SFX_UI2.SoundCues.Wrong'
	WorkshopSound = SoundCue'HatInTime_Hud.SoundCues.MenuNext'
	DownloadSound = SoundCue'HatInTime_Hud.SoundCues.MenuNext'
	UnsubscribeSound = SoundCue'HatinTime_SFX_UI2.SoundCues.Wrong'
	UpvoteParticle = ParticleSystem'HatinTime_HUD_Modding.Particles.mod_thumbsUp'
	DownvoteParticle = ParticleSystem'HatinTime_HUD_Modding.Particles.mod_thumbsDown'
	BackgroundParticle(0) = ParticleSystem'HatinTime_HUD_Modding.Particles.ModMenuBackgroundParticles'
	BackgroundParticle(1) = ParticleSystem'HatinTime_HUD_Modding.Particles.ModMenuBackgroundChallengeRoadParticles'
	BackgroundParticle(2) = ParticleSystem'HatinTime_CreatorDLC.Particles.MenuBackgroundCreatorDLCParticles'
	ModDisabledIcon = Texture2D'HatinTime_HUD_Modding.Textures.mod_disabled'
	ModPlayedIcon = Texture2D'HatinTime_HUD_Modding.Textures.playedicon'
	ModUpdatingIcon = Material'HatinTime_HUD_Modding.Materials.Icon_Download'
	CheckmarkUncheckedIcon = Texture2D'HatinTime_HUD_Settings.GameSettings.GameSettings_Checklist_Unchecked'
	MailRoomIcon = Texture2D'HatinTime_HUD_Modding.Textures.MailRoomLocation'
	ItemShadow = Texture2D'HatinTime_Hud_ItemUnlock.Textures.item_unlock_shadow'
	DefaultDisc = Texture2D'HatinTime_CreatorDLC.Textures.DefaultDisc'
	CreatorDLCLogo = Texture2D'HatinTime_CreatorDLC.Textures.CreatorDLC_Logo'
	BackgroundRippedPaper = Texture2D'HatinTime_CreatorDLC.Textures.Preview_Background_RippedPaper'
	CreatorDLCOpen = SoundCue'HatinTime_CreatorDLC.SoundCues.CreatorDLC_TV_TurnOn'
	CreatorDLCPreview = SoundCue'HatinTime_CreatorDLC.SoundCues.CreatorDLC_CDDrive_Read'
	CreatorDLCClose = SoundCue'HatinTime_CreatorDLC.SoundCues.CreatorDLC_TV_TurnOff'
	CreatorDLCChangeChannel = SoundCue'HatinTime_CreatorDLC.SoundCues.CreatorDLC_TV_ChangeChannel'
	CreatorDLCMusic = SoundCue'HatinTime_CreatorDLC.SoundCues.CreatorDLC_Guest_Banner'
	CreatorDLCSelectionChangedSound = SoundCue'HatinTime_CreatorDLC.SoundCues.TV_Button_Hover'
	CreatorDLCSelectSound = SoundCue'HatinTime_CreatorDLC.SoundCues.TV_Button_Click'

	DefaultTabColor = (R=142,G=62,B=48)
	//TabColors(1) = (R=40,G=40,B=255)
	//TabColors(2) = (R=40,G=255,B=40)
	//TabColors(3) = (R=255,G=255,B=40)

	RateStar = Texture2D'HatinTime_HUD_CapsuleOpen.Textures.ItemStar'
	UnloadedImage = Texture2D'HatInTime_HUD_CaveDream.Textures.missing_photo'
	ModIconSelectImage(0) = Texture2D'HatinTime_HUD_Settings.Main.Main_BoxHighlight'
	ModIconSelectImage(1) = Texture2D'HatinTime_HUD_SandTravel.Textures.Circle'
	PreviewButtonImage = Texture2D'HatinTime_HUD_Modding.Textures.SharpButton'
	PreviewButtonImage_Silhouette = Material'HatinTime_HUD_Modding.Materials.SharpButton_Silhouette'
	TabImage = Texture2D'HatinTime_HUD_Modding.Textures.SharpButton'
	WorkshopButton = Material'HatinTime_HUD_Modding.Materials.WorkshopButton'
	WorkshopButton_Silhouette = Material'HatinTime_HUD_Modding.Materials.WorkshopButton_Silhouette'
	DLCButton = Material'HatinTime_CreatorDLC.Materials.DLCButton'
	
	// ThumbsUpTextures(0) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsup_idle'
	// ThumbsUpTextures(1) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsup_selected'
	// ThumbsUpTextures(2) = Texture2D'HatinTime_HUD_Modding.Textures.ThumbsUp_Silhouette'
	// ThumbsDownTextures(0) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsdown_idle'
	// ThumbsDownTextures(1) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsdown_selected'
	// ThumbsDownTextures(2) = Texture2D'HatinTime_HUD_Modding.Textures.thumbsdown_silhouette'

	ScrollbarColorBack = (R=100,G=100,B=100)//100,200,255
	ScrollbarColorButtons = (R=240,G=240,B=240)//80,180,230
	ScrollbarColorHover = (R=200,G=200,B=200)//65,165,215
	ScrollbarColorPressed = (R=150,G=150,B=150)//0,100,200
	
	PreviewButtonsIcon(LevelPreview_Play) = Texture2D'HatinTime_HUD_Modding.Textures.Icon_Play';
	PreviewButtonsIcon(LevelPreview_DownloadMod) = Texture2D'HatinTime_HUD_Modding.Textures.Icon_Play';
	PreviewButtonsIcon(LevelPreview_DownloadModMap) = Texture2D'HatinTime_HUD_Modding.Textures.Icon_Play';
	PreviewButtonsIcon(LevelPreview_Enable) = Texture2D'HatinTime_HUD_Settings.GameSettings.GameSettings_Checkbox_Checked';
	PreviewButtonsIcon(LevelPreview_UnSubscribe) = Texture2D'HatinTime_HUD_Modding.Textures.Trash';
	PreviewButtonsIcon(LevelPreview_CancelDownload) = Texture2D'HatinTime_HUD_Modding.Textures.mod_disabled';
	PreviewButtonsIcon(LevelPreview_Config) = Material'HatinTime_HUD_Modding.Materials.Icon_Config';
	PreviewButtonsIcon(LevelPreview_PlayIntroduction) = Texture2D'HatinTime_HUD_Modding.Textures.Icon_Play';
	PreviewButtonsIcon(LevelPreview_Back) = Texture2D'HatinTime_CreatorDLC.Textures.Icon_Eject';
	PreviewButtonsIcon(LevelPreview_Credits) = Texture2D'HatInTime_PlayerAssets.Textures.Heart';

	CurrentModMenuIndex = 0
	IconCooldown = 0
	SelectedInTab = -1
	SelectedTab = -1
	SelectedWorkshopBrowse = false
	ScrollOffset = 0
	Preview = false
	IsCredits = false
	ClickDelay = 0
	MouseClear = true
	RealTime = true;
	LastDownloadedPreview = -1;
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

function OnOpenHUD(HUD H, optional String command)
{
	GfBPleaseShareNewEditorPackagesLol();
	Super.OnOpenHUD(H, command);
	
	ModListMode = (command == "levels") ? 1 : ((command == "dlc") ? 2 : 0);

	if (!Hat_HUD(H).IsHUDEnabled('Hat_HUDMenuLoadout'))
		LocalPlayer(H.PlayerOwner.Player).OverridePostProcessSettings(class'Hat_HUDMenuLoadout'.static.GetPostProcessSettings());

	BuildModList(H);

	if (SelectedInTab == INDEX_NONE && Hat_HUD(H).IsGamepad() && ModMenuTabs[CurrentModMenuIndex].GameMods.Length > 0)
		SelectedInTab = 0;
	
	CreateBackgroundParticle(H);
	MenuFadeIn = 0;
	NoModsLocalizedText = "No custom HUB maps detected! Install some HUB mods from the Steam Workshop!";
	
	DownloadingModText = class'Hat_Localizer'.static.GetMenu("Modding", "DownloadingMod");
	ModCreatedByText = class'Hat_Localizer'.static.GetMenu("Modding", "ModCreatedBy");
	ModVersionText = class'Hat_Localizer'.static.GetMenu("Modding", "ModVersion");
	HowToAccessLevelModsText = class'Hat_Localizer'.static.SplitStringByLength(class'Hat_Localizer'.static.GetMenu("Modding", "HowToAccessLevelMods"), 50);
	BrowseWorkshopText = class'Hat_Localizer'.static.GetMenu("Modding", "BrowseTheWorkshop");
	BrowseDLCText = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_ViewDLC");

	PreviewButtonsText[LevelPreview_Play] = class'mcu8_mods_BetterHubMain'.static.HubEnabled() ? class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_Play") : "Enable the HubSwapper First!";
	PreviewButtonsText[LevelPreview_DownloadMod] = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_Install");
	PreviewButtonsText[LevelPreview_DownloadModMap] = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_Play");
	PreviewButtonsText[LevelPreview_Enable] = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_Enable");
	PreviewButtonsText[LevelPreview_Config] = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_Config");
	PreviewButtonsText[LevelPreview_Workshop] = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_ViewInWorkshop");
	//PreviewButtonsText[LevelPreview_UnSubscribe] = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_Unsubscribe");
	PreviewButtonsText[LevelPreview_CancelDownload] = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_CancelDownload");
	PreviewButtonsText[LevelPreview_PlayIntroduction] = class'Hat_Localizer'.static.GetMenu("Modding", ModListMode == 2 ? "PreviewButtonsText_Arcade_PlayIntroduction" : "PreviewButtonsText_PlayIntroduction");
	PreviewButtonsText[LevelPreview_Credits] = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_Credits");
	PreviewButtonsText[LevelPreview_Back] = class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_Back");
	
	SwitchTab(0);
	
	`SetMusicParameterInt('MailroomTalk', 1);
	
	if (ModListMode == 2)
	{
		`SetMusicParameterInt('CreatorDLC', 1);
		if (CreatorDLCOpen != None)
		{
			PlayOwnerSound(H, CreatorDLCOpen);
		}
		if (CreatorDLCMusic != None && DynamicMusicNode == None)
		{
			DynamicMusicNode = new class'Hat_MusicNodeBlend_Dynamic';
			DynamicMusicNode.Music = CreatorDLCMusic;
			DynamicMusicNode.Priority = 5;
			DynamicMusicNode.BlendTimes[0] = 1.0; // 1s fade out
			DynamicMusicNode.BlendTimes[1] = 0.05; // 0.05s fade in
			`PushMusicNode(DynamicMusicNode);
		}
	}
}

function BuildModList(HUD H)
{
	local int i;
	
	// OK yeah so in rare cases, BuildModList can be called concurrently, causing BuildModList_GameplayMods to be called twice in a row, resulting in duplicate tabs. Its dumb.
	if (IsBuildingTabMenus) return;
	IsBuildingTabMenus = true;
	
	for (i = 0; i < ModMenuTabs.Length; i++)
		ModMenuTabs[i].InterpList.Length = 0;
	
	ModMenuTabs.Length = 0;
	BuildModList_Levels(H);
	
	// If no tabs, add a dummy tab
	if (ModMenuTabs.Length == 0)
	{
		ModMenuTabs.Add(1);
		ModMenuTabs[ModMenuTabs.Length-1].TabName = "HUBs";
	}
	
	IsBuildingTabMenus = false;
	
	if (CurrentModMenuIndex > 0 && CurrentModMenuIndex >= ModMenuTabs.Length)
		SwitchTab(0);
	
	SelectedInTab = Min(SelectedInTab, ModMenuTabs[CurrentModMenuIndex].GameMods.Length-1);
	SelectedInTab = Max(SelectedInTab,0);
	
	if (Preview)
	{
		RefreshGameModInfos(H, true);
		GetReplacementGameModInfo(PreviewMod);
		UpdatePreviewButtons(H);
	}
	
	for (i = 0; i < ModMenuTabs[CurrentModMenuIndex].GameMods.Length; i++)
		ModMenuTabs[CurrentModMenuIndex].InterpList.AddItem(0);
	ScrollTarget = 0;
	ScrollOffset = 0;
	
	if (Preview && LastDownloadedPreview > 0 && LastDownloadedPreview == PreviewMod.WorkshopId && PreviewButtons.Find(LevelPreview_Play) != INDEX_NONE)
	{
		LoadMap(H);
	}
	
	/*if (Preview && LastDownloadedPreview > 0 && LastDownloadedPreview == PreviewMod.WorkshopId && PreviewButtons.Find(LevelPreview_PlayIntroduction) != INDEX_NONE)
	{
		LoadMap(H, 1);
	}
	
	if (!Preview && LastDownloadedPreview == LastDownload_ChallengeRoad && ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 1)
	{
		StartChallengeRoad(H);
	}*/
}

function OnCloseHUD(HUD H)
{
	local int i;
	Super.OnCloseHUD(H);

	if (DynamicMusicNode != None)
	{
		DynamicMusicNode.Stop();
		DynamicMusicNode = None;
	}

	if (!Hat_HUD(H).IsHUDEnabled('Hat_HUDMenuLoadout'))
		LocalPlayer(H.PlayerOwner.Player).ClearPostProcessSettingsOverride();
	`SetMusicParameterInt('MailroomTalk', 0);
	`SetMusicParameterInt('CreatorDLC', 0);
	
	for (i = 0; i < 2; i++)
	{
		if (BackgroundParticleComponent[i] != None)
		{
			BackgroundParticleComponent[i].DetachFromAny();
			BackgroundParticleComponent[i] = None;
		}
	}
}

function bool Tick(HUD H, float d)
{
	local int i;
	local float ScrollSpeed, FadeInRealTime, prev;
	if (!Super.Tick(H, d)) return false;
	
	MenuFadeIn += d/0.3f;
	
	ModMenuTabs[CurrentModMenuIndex].FadeIn += d;
	
	if (BackgroundInstance != None || PreviewInstance != None)
	{
		FadeInRealTime = ModMenuTabs[CurrentModMenuIndex].FadeIn;
		if (BackgroundInstance != None)
			BackgroundInstance.SetScalarParameterValue('Intro', 1.f - FClamp((FadeInRealTime-0.25f)/5.5, 0, 1));
		if (PreviewInstance != None)
			PreviewInstance.SetScalarParameterValue('Intro', 1.f - FClamp((FadeInRealTime-0.25f)/5.5, 0, 1));
	}

	if (IconCooldown > 0)
	{
		IconCooldown -= d;
	}

	if (ModMenuTabs[CurrentModMenuIndex].InterpList.Length > 0)
	{
		if (SelectedInTab != INDEX_NONE && SelectedInTab < ModMenuTabs[CurrentModMenuIndex].InterpList.Length && ModMenuTabs[CurrentModMenuIndex].InterpList[SelectedInTab] < 1)
			ModMenuTabs[CurrentModMenuIndex].InterpList[SelectedInTab] = FMin(ModMenuTabs[CurrentModMenuIndex].InterpList[SelectedInTab] + d/IconSelectAnimationTime, 1);

		for (i = 0; i < ModMenuTabs[CurrentModMenuIndex].GameMods.Length; i++)
		{
			if (ModMenuTabs[CurrentModMenuIndex].InterpList[i] > 0 && i != SelectedInTab)
				ModMenuTabs[CurrentModMenuIndex].InterpList[i] = FMax(ModMenuTabs[CurrentModMenuIndex].InterpList[i] - (d/IconSelectAnimationTime)*2, 0);
		}
	}
	
	if (SelectedWorkshopBrowse)
		SelectedWorkshopBrowse_FadeIn = FMin(SelectedWorkshopBrowse_FadeIn+d/IconSelectAnimationTime,1);
	else
		SelectedWorkshopBrowse_FadeIn = FMax(SelectedWorkshopBrowse_FadeIn-(d/IconSelectAnimationTime)*2,0);
	
	PreviewButtonsInterp = FMin(PreviewButtonsInterp+d/IconSelectAnimationTime,1);

	if (LScrollbarOutput == -1)
	{
		ScrollSpeed = 6;
		if (Abs(ScrollTarget - ScrollOffset) > 2) ScrollSpeed = 18;
		if (ScrollOffset < ScrollTarget)
			ScrollOffset = FMin(ScrollOffset + d*ScrollSpeed, ScrollTarget);
		if (ScrollOffset > ScrollTarget)
			ScrollOffset = FMax(ScrollOffset - d*ScrollSpeed, ScrollTarget);
	}

	if (ClickDelay > 0)
	{
		ClickDelay -= d;
		if (ClickDelay < 0)
			ClickDelay = 0;
	}

	if (!IsLoadingMap)
		ReactivateMouseCheck(H);
	
	if (Preview)
	{
		if (UndoPreview)
		{
			PreviewTime -= d*5;
			if (PreviewTime <= 0)
			{
				ExitPreview();
			}
		}
		else
		{
			prev = PreviewTime;
			PreviewTime += d;
			if (PreviewTime >= 4.1 && prev < 4.1 && ModListMode == 2)
			{
				PlayOwnerSound(H, CreatorDLCChangeChannel);
				if (PreviewMod.Name ~= "Default HUB" && PreviewMod.Author ~= "Gears for Breakfast")
				{
					// todo: default hub assets
				}
				else
				{
					PreviewLogo = class'GameMod'.static.GetModIcon(PreviewMod, 'Logo');
					PreviewSplashArt = class'GameMod'.static.GetModIcon(PreviewMod, 'SplashArt');
					PreviewBackgroundArt = class'GameMod'.static.GetModIcon(PreviewMod, 'Background');
					PreviewTitlecard = class'GameMod'.static.GetModIcon(PreviewMod, 'Titlecard');
					if (PreviewInstance != None && PreviewBackgroundArt != None)
					{
						PreviewInstance.SetTextureParameterValue('Background', PreviewBackgroundArt);
					}
				}
			}
		}
		
		if (IsCredits && CreditsList.Length > 10)
		{
			TextScrollOffset = (TextScrollOffset + d) % (float(CreditsList.Length));
		}
	}

	return true;
}

function Texture2D GetIcon(int ModMenuTabIndex, int i, optional bool ForceUpdate = false)
{
	local Texture2D r;
	local GameModInfo ModInfo;

	if (i >= ModMenuTabs[ModMenuTabIndex].Icons.Length) ModMenuTabs[ModMenuTabIndex].Icons.Length = i + 1;
	if (ModMenuTabs[ModMenuTabIndex].Icons[i] != None) return ModMenuTabs[ModMenuTabIndex].Icons[i];

	ModInfo = ModMenuTabs[ModMenuTabIndex].GameMods[i];
	if (IconCooldown <= 0 || ForceUpdate)
	{
		r = (ModInfo.Author ~= "Gears for Breakfast" && ModInfo.Name ~= "Default HUB") ? Texture2D'HatInTime_Levels_Titlescreen.Textures.panorama_spaceship' : class'GameMod'.static.GetModIcon(ModInfo);// todo: still creates a lot of little freezes
		if (r == None) r = UnloadedImage;
		IconCooldown = 0.05;// icon loading is staggered because the game freezes if they all load at once.
	}

	ModMenuTabs[ModMenuTabIndex].Icons[i] = r;

	if (r == None) r = UnloadedImage;
	return r;
}

function bool Render(HUD H)
{
	local float Scale, alpha;
	if (!Super.Render(H)) return false;

	Scale = FMin(H.Canvas.ClipX / 1600, H.Canvas.ClipY / 900);
	alpha = FMin(MenuFadeIn,1);
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2 && Preview && PreviewTime >= 4.1)
	{
		alpha = FClamp((PreviewTime - 4.1)/ 0.25f,0,1);
	}
	alpha = 1-((1-alpha)**2);
	// Background
	H.Canvas.SetDrawColor(0,0,0,180*alpha);
	H.Canvas.SetPos(0,0);
	H.Canvas.DrawRect(H.Canvas.ClipX, H.Canvas.ClipY);
		
	H.Canvas.SetDrawColor(255,255,255,255*alpha);
	ApplyFont(H, true);

	MouseClear = true;
	
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
	{
		if (!Preview || PreviewTime < (4.1 + 0.25f))
		{
			RenderGameModTileList(H, scale, PreviewTime >= 4.1 ? 1.f : alpha);
		}
		if (PreviewTime >= 4.1)
		{
			RenderPreviewDLC(H, scale, alpha);
		}
	}
	else
	{
		if (!Preview)
		{
			RenderGameModTileList(H, scale, alpha);
		}
		else if (CanRenderDLCScreenForMod())
		{
			RenderPreviewDLC(H, scale, alpha);
		}
		else
		{
			RenderPreview(H, scale, alpha);
		}
	}

	if (MouseClear && !Hat_HUD(H).IsGamepad() && MouseActivated)
	{
		WipeAllSelections();
	}
	if (IsMenuFrozen)
	{
		H.Canvas.SetDrawColor(0,0,0,180);
		H.Canvas.SetPos(0,0);
		H.Canvas.DrawRect(H.Canvas.ClipX, H.Canvas.ClipY);
	}

	// standard prompt
	//RenderPrompts(H, self);

	return true;
}

function bool CanRenderDLCScreenForMod()
{
	return Debug_ForceDLCScreen || PreviewSplashArt != None || PreviewLogo != None;
}

function RenderGameModTileList(HUD H, float scale, float alpha)
{
	local int i, myindex, TabLength, CurrentPass, indx;
	local float posX, posY, CurrentX, TileSpace, TabSpace, TabSpaceSlim, itemalpha, CurrentY, PrevX, PrevY, Dist, FadeInStartTime, FadeInDuration;
	local MaterialInstanceConstant LineInstance;
	local Vector DeltaVec;
	local Rotator r;
	local bool bIsClear, bIsSelected;
	local string ChallengeRoadID, msg;
	local Surface BackgroundSurface;
	posX = Scale*380;
	posY = Scale*215;
	TileSpace = Scale*210;
	TabSpace = Scale*210;
	TabSpaceSlim = Scale*120;
	posY -= ScrollOffset * TileSpace;

	// tabs
	if (AllowCategories && ModMenuTabs.Length > 1)
	{
		for (CurrentPass = 0; CurrentPass < 2; CurrentPass++)
		{
			for (i = 0; i < ModMenuTabs.Length; i++)
			{
				myindex = (ModMenuTabs.Length-1)-i;
				bIsSelected = (CurrentModMenuIndex != INDEX_NONE && myIndex == CurrentModMenuIndex);
				if (CurrentPass == 0 && bIsSelected) continue;
				if (CurrentPass != 0 && !bIsSelected) continue;
					
				DrawLevelTab(H, ModMenuTabs[myindex].TabName, Scale*1300 - TabSpaceSlim*i, Scale*70, Scale, 0.8, myindex);
			}
		}
	}

	// background
	H.Canvas.DrawColor.A = 255;
	BackgroundSurface = ModMenuTabs[CurrentModMenuIndex].Background;
	if (BackgroundInstance != None)
	{
		BackgroundSurface = BackgroundInstance;
	}
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
		DrawCenter(H, Scale*(200+600+8), Scale*(80+340), Scale*1320, Scale*760*alpha, BackgroundSurface);
	else
		DrawCenter(H, Scale*(200+600), Scale*(80+340), Scale*1200, Scale*680*alpha, BackgroundSurface);
	
	indx = ModMenuTabs[CurrentModMenuIndex].BackgroundParticleIndex;
	if (BackgroundParticleComponent[indx] != None)
	{
		if (!Debug_HideUI)
			H.Canvas.PushMaskRegion(Scale*204, Lerp(H.Canvas.ClipY/2, Scale*84, alpha**4), Scale*(1200-7), Lerp(0, Scale*(680-10), alpha**4), 'ParticleBackground');
		H.Canvas.SetPos(H.Canvas.ClipX/2, H.Canvas.ClipY);
		BackgroundParticleComponent[indx].RenderToCanvas(H.Canvas);
		if (!Debug_HideUI)
			H.Canvas.PopMaskRegion('ParticleBackground');
	}
	
	// Tab name
	H.Canvas.SetDrawColor(255,255,255,255);
	if (!Debug_HideUI)
	{
		if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
		{
			H.Canvas.SetDrawColor(255,255,255,255*alpha);
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(ModMenuTabs[CurrentModMenuIndex].TabName);
			if (Preview)
			{
				H.Canvas.DrawColor.A = lerp(H.Canvas.DrawColor.A, 0, FClamp((PreviewTime-1.5) / 0.5,0,1));
			}
			if (ModMenuTabs[CurrentModMenuIndex].TabName == "" && CreatorDLCLogo != None)
			{
				DrawCenter(H, Scale*800, Scale*(310+Sin(H.WorldInfo.RealTimeSeconds*2)*14), Scale*550, Scale*550*0.5, CreatorDLCLogo);
			}
			else
			{
				DrawCenterText(H.Canvas, ModMenuTabs[CurrentModMenuIndex].TabName, Scale*800, Scale*(310+Sin(H.WorldInfo.RealTimeSeconds*2)*14), Scale*2.0, Scale*2.0);
			}
		}
		else
		{
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(ModMenuTabs[CurrentModMenuIndex].TabName);
			class'Hat_HUDElementItemUnlock'.static.DrawFancyUnlockText(H.Canvas, self, ModMenuTabs[CurrentModMenuIndex].TabName, Scale*220, Scale*120-(1-Alpha)*Scale*40, Scale*1.5, TextAlign_BottomLeft);
		}
	}
	
	// scroll
	TabLength = ModMenuTabs[CurrentModMenuIndex].GameMods.Length;
	if (!MouseActivated)
	{
		ScrollTarget = FFloor(SelectedInTab / NumItemsPerRow) - 1;
		if (SelectedInTab < NumItemsPerRow) ScrollTarget += 1;
		if (FFloor(SelectedInTab / NumItemsPerRow) > 1 && FFloor(SelectedInTab / NumItemsPerRow) + 1 > FFloor((TabLength - 1) / NumItemsPerRow)) ScrollTarget -= 1;
	}
	
	bIsClear = false;
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 1)
	{
		ChallengeRoadID = class'GameMod'.static.GetChallengeRoadID();
		if (ChallengeRoadID != "")
		{
			bIsClear = Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.Find(ChallengeRoadID) != INDEX_NONE;
		}
	}

	// empty message
	if (TabLength <= 1)
	{
		if (ModMenuTabs[CurrentModMenuIndex].EmptyDisplayMode >= 0 && !Debug_HideUI)
		{
			if (ModMenuTabs[CurrentModMenuIndex].EmptyDisplayMode == 1)
			{
				H.Canvas.SetDrawColor(255,255,255,255*alpha);
				DrawCenter(H, Scale*450, Scale*400, Scale*450, Scale*450, MailRoomIcon);
				for (i = 0; i < HowToAccessLevelModsText.Length; i++)
				{
					H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(HowToAccessLevelModsText[i]);
					RenderBorderedText(H, self, HowToAccessLevelModsText[i], Scale*710, Scale*(195 + 60*i), Scale*0.9, TextAlign_Left);
				}
				class'Hat_HUDMenuLoadout_Overview'.static.RenderOverviewCollectibleStat(H, self, Scale*1050 - Scale*70, Scale*450, Scale*90, class'Hat_HUDMenuLoadout_Overview'.default.Overview_TimePiece, 8);
				DrawCenter(H, Scale*1050, Scale*550, Scale*90, Scale*90, class'Hat_Ability_StatueFall'.default.HUDIcon);
			}
			if (ModMenuTabs[CurrentModMenuIndex].EmptyDisplayMode == 2)
			{
				itemalpha = FClamp((ModMenuTabs[CurrentModMenuIndex].FadeIn - 1.5) / 0.5f,0,1);
				itemalpha = 1.f - ((1.f - itemalpha) ** 2);
				if ((ModMenuTabs[CurrentModMenuIndex].FadeIn*2) % 1.f > 0.5f)
					H.Canvas.SetDrawColor(255,255,255,255*itemalpha);
				else
					H.Canvas.SetDrawColor(255,32,32,255*itemalpha);
				class'Hat_HUDMenuLoadout_Overview'.static.RenderOverviewCollectibleStat(H, self, Scale*780, Scale*600, Scale*90, class'Hat_HUDMenuLoadout_Overview'.default.Overview_TimePiece, 1);
			}
			else
			{
				H.Canvas.SetDrawColor(255,255,255,128*alpha);
				H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(NoModsLocalizedText);
				DrawCenterText(H.Canvas, NoModsLocalizedText, Scale*800, Scale*400, Scale*0.45, Scale*0.45);
				H.Canvas.SetDrawColor(255,255,255,255*alpha);
			}
		}
		LScrollbarState = -1;
	}
	// scrollbar
	else
	{
		if (LScrollbarOutput > -1)
		{
			ScrollOffset = LScrollbarOutput*((TabLength-1)/NumItemsPerRow - 2);
			ScrollTarget = Round(ScrollOffset);
		}

		if (float(TabLength)/NumItemsPerRow/3 > 1)
			RenderScrollbar(H, self, Scale*1337, Scale*115, Scale*26, Scale*600, Scale, 3/(FFloor((TabLength-1)/NumItemsPerRow)+1), ScrollOffset/(FFloor((TabLength-1)/NumItemsPerRow)-2), LScrollbarState, LScrollbarPress, LScrollbarDrag, LScrollbarOutput, ScrollbarColorBack, ScrollbarColorButtons, ScrollbarColorHover, ScrollbarColorPressed);
		else
			LScrollbarState = -1;
	}
	
	// button prompts
	if (AllowCategories && ModMenuTabs.Length > 1 && !Debug_HideUI)
	{
		class'Hat_HUDInputButtonRender'.static.Render(H, HatControllerBind_Menu_PageLeft, Scale*1300 - TabSpaceSlim*(ModMenuTabs.Length-1) - TabSpace*Lerp(0.58, 0.65, Abs(Sin(H.WorldInfo.RealTimeSeconds*3))), Scale*65, Hat_HUD(H).IsGamepad() ? Scale*50 : Scale*40);
		class'Hat_HUDInputButtonRender'.static.Render(H, HatControllerBind_Menu_PageRight, Scale*1300 + TabSpace*Lerp(0.58, 0.65, Abs(Sin(H.WorldInfo.RealTimeSeconds*3))), Scale*65, Hat_HUD(H).IsGamepad() ? Scale*50 : Scale*40);
	}
	
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 1 && !Debug_HideUI)
	{
		for (i = 0; i < Min(Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.Length,20); i++)
		{
			DrawCenter(H, PosX-140*Scale+i*Scale*50, PosY+Scale*480, Scale*80, Scale*80, Texture2D'HatInTime_HUD_ConvBubbles.Textures.Trophy');
		}
	}
	
	// tiles
	for (CurrentPass = 0; CurrentPass < 3; CurrentPass++)
	{
		PrevX = 0;
		PrevY = 0;
		CurrentX = PosX;
		CurrentY = posY;
		H.Canvas.PushMaskRegion(0, Scale*115, Scale*1600, Scale*655, 'Tiles');
		
		for (i = 0; i < ModMenuTabs[CurrentModMenuIndex].GameMods.Length; i++)
		{
			if (CurrentY > 0)
			{
				FadeInStartTime = 0.65;
				FadeInDuration = 0.3;
				if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 1)
				{
					CurrentY = PosY+Scale*250;
					// Offset every 2nd
					CurrentY += ((i%2)-0.5f)*Scale*30;
					CurrentX = Scale*800 + (float(i)-(float(ModMenuTabs[CurrentModMenuIndex].GameMods.Length-1)/2.f))*TileSpace;
				}
				if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
				{
					CurrentY = PosY+Scale*380;
					// ocean wobble
					CurrentY += Sin(H.WorldInfo.RealTimeSeconds*1.5 + i*0.5)*7;
					CurrentX = Scale*800 + (float(i)-(float(ModMenuTabs[CurrentModMenuIndex].GameMods.Length-1)/2.f))*TileSpace;
					FadeInStartTime = 4.5;
					FadeInDuration = 0.5;
				}
				
				if (CurrentY < Scale*800)
				{
					itemalpha = (ModMenuTabs[CurrentModMenuIndex].FadeIn-FadeInStartTime-i*(FadeInDuration*0.5f))/FadeInDuration;
					itemalpha = FClamp(itemalpha, 0, 1);
					itemalpha = 1-((1-itemalpha)**3);

					H.Canvas.SetDrawColor(255,255,255,255*itemalpha);
					
					if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 1 && CurrentPass == 0 && i > 0)
					{
						while (LineInstances.Length < i)
						{
							LineInstance = new class'MaterialInstanceConstant';
							LineInstance.SetParent(class'Hat_DeathWishIcon'.default.DeathWishParentLine);
							LineInstances.AddItem(LineInstance);
						}
						LineInstance = LineInstances[i-1];
						
						DeltaVec = (vect(1,0,0)*CurrentX+vect(0,1,0)*CurrentY) - (vect(1,0,0)*PrevX+vect(0,1,0)*PrevY);
						Dist = VSize2D(DeltaVec);
						r = Rotator(DeltaVec);
						LineInstance.SetScalarParameterValue('ScaleX', Dist/(Scale*8));
						DrawCenterLeft(H, PrevX, PrevY, Dist, Scale*8, LineInstance, float(r.Yaw)/65536.f);
					}
					if ((CurrentPass == 1 && SelectedInTab != i) || (CurrentPass == 2 && SelectedInTab == i))
					{
						//bIsClear = ModMenuTabs[CurrentModMenuIndex].ClearProgress > i;
						//bIsClear = false;
						//if (bIsClear) H.Canvas.SetDrawColor(64,64,64,255*itemalpha);
						
						RenderGameModTile(H, i, CurrentX, CurrentY-(1-itemalpha)*Scale*70, Scale, itemalpha >= 1.f && !Preview);
						//if (bIsClear)
						if (false)
						{
							H.Canvas.SetDrawColor(64,255,64,255*itemalpha);
							DrawCenter(H, CurrentX, CurrentY-(1-itemalpha)*Scale*70, Scale*60, Scale*60, ModDisabledIcon);
						}
					}
					H.Canvas.SetDrawColor(255,255,255,255*alpha);
				}
			}
			PrevX = CurrentX;
			PrevY = CurrentY;
			if ((i+1)%NumItemsPerRow == 0)
			{
				CurrentX -= TileSpace * 4;
				CurrentY += TileSpace;
			} 
			else
			{
				CurrentX += TileSpace;
			}
		}
		
		H.Canvas.PopMaskRegion('Tiles');
	}
	
	// Back option
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2 && !Debug_HideUI)
	{
		itemalpha = FClamp((ModMenuTabs[CurrentModMenuIndex].FadeIn - 0.5) / 0.5f,0,1);
		itemalpha = 1.f - ((1.f - itemalpha) ** 2);
		H.Canvas.SetDrawColor(255,255,255,255*itemalpha);
		posx = Scale*280;
		DrawPreviewButton(H, PreviewButtonsText[LevelPreview_Back], posx, Scale*670, Scale, PreviewButtonsIcon[LevelPreview_Back], LevelPreview_Back);
	}
	
	for (i = 0; i < ModMenuTabs[CurrentModMenuIndex].Overlay.Length; i++)
	{
		H.Canvas.DrawColor.A = 255;
		DrawCenter(H, Scale*(200+600+8), Scale*(80+340), Scale*1320, Scale*760*alpha, ModMenuTabs[CurrentModMenuIndex].Overlay[i]);
	}
	
	// workshop button
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 1)
	{
		DrawPreviewButton(H, bIsClear ? class'Hat_Localizer'.static.GetMenu("Modding", "PreviewButtonsText_RePlay") : PreviewButtonsText[LevelPreview_DownloadModMap], H.Canvas.ClipX/2, Scale*800, Scale, PreviewButtonsIcon[LevelPreview_DownloadModMap], LevelPreview_DownloadModMap);
		
		H.Canvas.SetDrawColor(255,255,255,255*alpha);
		
		msg = bIsClear ? class'Hat_Localizer'.static.GetMenu("Modding", "Category_ChallengeRoad_Clear0") : class'Hat_Localizer'.static.GetMenu("Modding", "Category_ChallengeRoad_Description");
		H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(msg);
		RenderBorderedText(H, self, msg, Scale*800, Scale*200, Scale*1.1, TextAlign_Center);
		if (bIsClear)
		{
			msg = class'Hat_Localizer'.static.GetMenu("Modding", "Category_ChallengeRoad_Clear1");
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(msg);
			RenderBorderedText(H, self, msg, Scale*800, Scale*290, Scale*0.6, TextAlign_Center);
		}
	}
	else if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
	{
		if (class'Hat_GlobalDataInfo'.static.IsWithSteamWorks() && !Preview && PreviewTime <= 0 && !Debug_HideUI)
		{
			itemalpha = FClamp((ModMenuTabs[CurrentModMenuIndex].FadeIn - 4.5) / 0.5f,0,1);
			itemalpha = 1.f - ((1.f - itemalpha) ** 2);
			H.Canvas.SetDrawColor(255,255,255,255*itemalpha);
			if (TabLength > 0 || ModMenuTabs[CurrentModMenuIndex].EmptyDisplayMode != 2)
			{
				DrawWorkshopButton(H, BrowseDLCText, H.Canvas.ClipX/2, Scale*((ModMenuTabs[CurrentModMenuIndex].GameMods.Length <= 0 ? 600 : 800) + (1.f - itemalpha)*25), Scale * itemalpha * (Sin(GetWorldInfo().TimeSeconds*5) * 0.03 + 1.03));
			}
		}
	}
	else
	{
		if (class'Hat_GlobalDataInfo'.static.IsWithSteamWorks())
		{
			H.Canvas.SetDrawColor(255,255,255,255*alpha);
			DrawWorkshopButton(H, BrowseWorkshopText, H.Canvas.ClipX/2, Scale*800, TabLength != 0 ? Scale : Scale * (Sin(GetWorldInfo().TimeSeconds*5) * 0.03 + 1.03));
		}
	}
}


function RenderPreview(HUD H, float scale, float alpha)
{
	local array<string> Desc;
	local int i, indx;
	local float posx, width, progress, buttonscale;
	local string DownloadText;
	local GameModInfo ReplacementGameModInfo;
	local Surface BackgroundSurface;
	local string RenderString;
	
	// background
	BackgroundSurface = ModMenuTabs[CurrentModMenuIndex].Background;
	if (PreviewInstance != None)
	{
		BackgroundSurface = PreviewInstance;
	}
	else if (BackgroundInstance != None)
	{
		BackgroundSurface = BackgroundInstance;
	}
	
	H.Canvas.DrawColor.A = 255;
	DrawCenter(H, Scale*800, Scale*395, Scale*1040, Scale*670, BackgroundSurface);
	H.Canvas.DrawColor.A = 255;
	
	indx = ModMenuTabs[CurrentModMenuIndex].BackgroundParticleIndex;
	if (BackgroundParticleComponent[indx] != None)
	{
		H.Canvas.PushMaskRegion(Scale*284, Scale*64, Scale*(1040-7), Scale*(670-10), 'BackgroundParticle');
		H.Canvas.SetPos(H.Canvas.ClipX/2, H.Canvas.ClipY);
		BackgroundParticleComponent[indx].RenderToCanvas(H.Canvas);
		H.Canvas.PopMaskRegion('BackgroundParticle');
	}
	
	ReplacementGameModInfo = PreviewMod;
	GetReplacementGameModInfo(ReplacementGameModInfo);

	if (IsCredits)
	{
		RenderCredits(H, Scale, Alpha);
	}
	else
	{
		// icon
		if (PreviewIcon != None)
		{
			if (ReplacementGameModInfo.IsDownloading)
				H.Canvas.SetDrawColor(128,128,128,255*alpha);
			else
				H.Canvas.SetDrawColor(255,255,255,255*alpha);
				
			DrawTopLeft(H, Scale*320, Scale*110, Scale*270, Scale*270, PreviewIcon);
		}
		if (ReplacementGameModInfo.IsDownloading && ReplacementGameModInfo.WorkshopId > 0)
		{
			H.Canvas.SetDrawColor(128,128,128,255*alpha);
			DrawCenter(H, Scale*455, Scale*245, Scale*80, Scale*80, ModUpdatingIcon);
			
			progress = class'GameMod'.static.GetModDownloadPercent(ReplacementGameModInfo.WorkshopId);
			
			H.Canvas.SetDrawColor(255,255,255,255*alpha);
			DownloadText = DownloadingModText $ "...";
			if (progress >= 0)
				DownloadText = DownloadText $ " " $ int(progress*100) $ "%";
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(DownloadText);
			RenderBorderedText(H, self, DownloadText, Scale*455, Scale*280, Scale*0.5, TextAlign_Center);
		}

		// title
		H.Canvas.SetDrawColor(255,255,255,255*alpha);
		H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(PreviewMod.Name);
		RenderBorderedText(H, self, PreviewMod.Name, Scale*615, Scale*130, Scale*0.7, TextAlign_Left);

		// subtitle
		H.Canvas.SetDrawColor(255,255,255,128*alpha);
		if (CreditsList.Length <= 0 && PreviewMod.Author != "" && PreviewMod.Author != "Me" && PreviewMod.Author != "Unknown Author")
		{
			RenderString = ModCreatedByText $ ": "$PreviewMod.Author$"    " $ ModVersionText@PreviewMod.Version;
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(RenderString);
			DrawTopLeftText(H.Canvas, RenderString, Scale*635, Scale*160, Scale*0.45, Scale*0.45);
		}
		else
		{
			// Don't display credits if we have a full-blown credits list.
			RenderString = ModVersionText@PreviewMod.Version;
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(RenderString);
			DrawTopLeftText(H.Canvas, ModVersionText@PreviewMod.Version, Scale*635, Scale*160, Scale*0.45, Scale*0.45);
		}
		H.Canvas.SetDrawColor(255,255,255,255*alpha);

		// description
		H.Canvas.PushMaskRegion(Scale*610, Scale*200, Scale*750, Scale*400, 'Description');
		Desc = class'Hat_Localizer'.static.SplitStringByLength(PreviewMod.Description, 82);
		for (i = 0; i < Desc.Length; i++)
		{
			Desc[i] = Repl(Desc[i], "[*]", " * ");
			Desc[i] = Repl(Desc[i], "[list]", "");
			Desc[i] = Repl(Desc[i], "[/list]", "");
			Desc[i] = Repl(Desc[i], "[h1]", "= ");
			Desc[i] = Repl(Desc[i], "[/h1]", " =");
			Desc[i] = Repl(Desc[i], "[b]", "");
			Desc[i] = Repl(Desc[i], "[/b]", "");
			Desc[i] = Repl(Desc[i], "[i]", "");
			Desc[i] = Repl(Desc[i], "[/i]", "");
			Desc[i] = Repl(Desc[i], "[u]", "");
			Desc[i] = Repl(Desc[i], "[/u]", "");
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(Desc[i]);
			DrawTopLeftText(H.Canvas, Desc[i], Scale*620, Scale*210 + Scale*25*i - TextScrollOffset*Scale*25, Scale*0.37, Scale*0.37);
		}
		H.Canvas.PopMaskRegion('Description');

		if (Desc.Length > 15)
		{
			TextScrollMax = Desc.Length - 15.5;

			// scrollbar
			if (PScrollbarOutput > -1)
				TextScrollOffset = PScrollbarOutput*TextScrollMax;
			
			RenderScrollbar(H, self, Scale*1250, Scale*200, Scale*26, Scale*400, Scale, 15.5/Desc.Length, TextScrollOffset/TextScrollMax, PScrollbarState, PScrollbarPress, PScrollbarDrag, PScrollbarOutput, ScrollbarColorBack, ScrollbarColorButtons, ScrollbarColorHover, ScrollbarColorPressed);
		}
		else
			PScrollbarState = -1;
		
		// Back option
		if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
		{
			posx = Scale*280;
			DrawPreviewButton(H, PreviewButtonsText[LevelPreview_Back], posx, Scale*670, Scale, PreviewButtonsIcon[LevelPreview_Back], LevelPreview_Back);
		}

		// level options
		buttonscale = 1;
		if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2 && PreviewButtons.Length > 1)
		{
			ButtonScale = 0.5;
			width = scale * 300 * buttonscale;
		}
		else
			width = scale * 330 * buttonscale;
		for (i = 0; i < PreviewButtons.Length; i++)
		{
			posx = Scale*800;
			
			posx -= (PreviewButtons.Length-1)*width*0.5f;
			posx += i*width;
			
			DrawPreviewButton(H, PreviewButtonsText[PreviewButtons[i]], posx, Scale*660, Scale*buttonscale, PreviewButtons[i] < PreviewButtonsIcon.Length ? PreviewButtonsIcon[PreviewButtons[i]] : None, PreviewButtons[i]);
		}

		// rating thumbs
		if (PreviewMod.WorkshopId > 0)
		{
			DrawThumb(H, true, Scale*380, Scale*510, Scale*100, Scale*110);
			DrawThumb(H, false, Scale*520, Scale*510, Scale*100, Scale*110);
		}
	}
}

function RenderPreviewDLC(HUD H, float scale, float alpha)
{
	local int i, DescLimit;
	local float posx, posy, width;
	local GameModInfo ReplacementGameModInfo;
	local Surface BackgroundSurface;
	local array<string> Desc;
	local float SlowAlpha;
	
	SlowAlpha = FClamp((alpha-0.3f)/0.7f,0,1) ** 2;
	
	// background
	BackgroundSurface = ModMenuTabs[CurrentModMenuIndex].Background;
	if (PreviewInstance != None)
	{
		BackgroundSurface = PreviewInstance;
	}
	else if (BackgroundInstance != None)
	{
		BackgroundSurface = BackgroundInstance;
	}
	
	H.Canvas.DrawColor.A = 255;
	DrawCenter(H, Scale*(200+600+8), Scale*(80+340), Scale*1320, Scale*760*alpha, BackgroundSurface);
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
	{
		DrawCenter(H, Scale*(200+600), Scale*(80+340), Scale*1196, Scale*680*alpha, BackgroundRippedPaper);
	}
	
	ReplacementGameModInfo = PreviewMod;
	GetReplacementGameModInfo(ReplacementGameModInfo);
	
	if (IsCredits)
	{
		RenderCredits(H, Scale, Alpha);
	}
	else
	{
		// icon
		if (PreviewIcon != None || PreviewSplashArt != None)
		{
			if (ReplacementGameModInfo.IsDownloading)
				H.Canvas.SetDrawColor(128,128,128,255*SlowAlpha);
			else
				H.Canvas.SetDrawColor(255,255,255,255*SlowAlpha);
				
			posy = Scale*420 + Sin(H.WorldInfo.RealTimeSeconds)*10;
			DrawCenter(H, Scale*530, posy, Scale*675, Scale*675*SlowAlpha, PreviewSplashArt != None ? PreviewSplashArt : PreviewIcon);
		}

		// title
		H.Canvas.SetDrawColor(255,255,255,255*SlowAlpha);
		H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(PreviewMod.Name);
		if (PreviewLogo != None)
		{
			DrawCenter(H, Scale*1130, Scale*350, Scale*500, Scale*500*SlowAlpha, PreviewLogo);
		}
		else
		{
			RenderBorderedText(H, self, PreviewMod.Name, Scale*1130, Scale*350, Scale*1.25*SlowAlpha, TextAlign_Center);
		}
		// description
		DescLimit = ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2 ? 3 : 4;
		H.Canvas.PushMaskRegion(Scale*610, Scale*490, Scale*750, Scale*25*(DescLimit+1.15f), 'Description');
		Desc = class'Hat_Localizer'.static.SplitStringByLength(PreviewMod.Description, 50);
		for (i = 0; i < Desc.Length; i++)
		{
			Desc[i] = Repl(Desc[i], "[*]", " * ");
			Desc[i] = Repl(Desc[i], "[list]", "");
			Desc[i] = Repl(Desc[i], "[/list]", "");
			Desc[i] = Repl(Desc[i], "[h1]", "= ");
			Desc[i] = Repl(Desc[i], "[/h1]", " =");
			Desc[i] = Repl(Desc[i], "[b]", "");
			Desc[i] = Repl(Desc[i], "[/b]", "");
			Desc[i] = Repl(Desc[i], "[i]", "");
			Desc[i] = Repl(Desc[i], "[/i]", "");
			Desc[i] = Repl(Desc[i], "[u]", "");
			Desc[i] = Repl(Desc[i], "[/u]", "");
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(Desc[i]);
			
			if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
			{
				DrawCenterText(H.Canvas, Desc[i], Scale*1130, Scale*525 + Scale*25*i - TextScrollOffset*Scale*25, Scale*0.43, Scale*0.43);
			}
			else
			{
				RenderBorderedText(H, self, Desc[i], Scale*1130, Scale*525 + Scale*25*i - TextScrollOffset*Scale*25, Scale*0.43, TextAlign_Center);
			}
			
		}
		H.Canvas.PopMaskRegion('Description');
		
		if (Desc.Length > DescLimit)
		{
			TextScrollMax = Desc.Length - (DescLimit - 0.5f);

			// scrollbar
			if (PScrollbarOutput > -1)
				TextScrollOffset = PScrollbarOutput*TextScrollMax;
			
			RenderScrollbar(H, self, Scale*1400, Scale*515, Scale*15, Scale*85, Scale, (DescLimit - 0.5f)/Desc.Length, TextScrollOffset/TextScrollMax, PScrollbarState, PScrollbarPress, PScrollbarDrag, PScrollbarOutput, ScrollbarColorBack, ScrollbarColorButtons, ScrollbarColorHover, ScrollbarColorPressed);
		}
		else
			PScrollbarState = -1;

		posy = (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2) ? Scale*670 : Scale*735;
		
		// Back option
		posx = Scale*180;
		if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
		{
			posx += Scale*100;
			DrawPreviewButton(H, PreviewButtonsText[LevelPreview_Back], posx, posy, Scale, PreviewButtonsIcon[LevelPreview_Back], LevelPreview_Back);
		}
		// Credits option
		if (CreditsList.Length > 0)
		{
			posx += Scale*100;
			DrawPreviewButton(H, PreviewButtonsText[LevelPreview_Credits], posx, posy, Scale, PreviewButtonsIcon[LevelPreview_Credits], LevelPreview_Credits);
		}
		// rating thumbs
		if (PreviewMod.WorkshopId > 0)
		{
			posx += Scale*100;
			DrawThumb(H, true, posx, posy, Scale*70, Scale*80);
			posx += Scale*100;
			DrawThumb(H, false, posx, posy, Scale*70, Scale*80);
		}
		
		posy -= Scale*35;
		// level options
		width = scale*330*0.7f;
		for (i = 0; i < PreviewButtons.Length; i++)
		{
			posx = Scale*1130;
			
			posx -= (PreviewButtons.Length-1)*width*0.5f;
			posx += i*width;
			
			DrawPreviewButton(H, PreviewButtonsText[PreviewButtons[i]], posx, posy, Scale*0.7f, PreviewButtons[i] < PreviewButtonsIcon.Length ? PreviewButtonsIcon[PreviewButtons[i]] : None, PreviewButtons[i]);
		}
	}
	for (i = 0; i < ModMenuTabs[CurrentModMenuIndex].Overlay.Length; i++)
	{
		H.Canvas.DrawColor.A = 255;
		DrawCenter(H, Scale*(200+600+8), Scale*(80+340), Scale*1320, Scale*760*alpha, ModMenuTabs[CurrentModMenuIndex].Overlay[i]);
	}
}


function RenderCredits(HUD H, float scale, float alpha)
{
	local int i;
	local float posy, posy_it;
	if (CreditsList.Length == 0)
		return;
	
	H.Canvas.PushMaskRegion(Scale*200, Scale*100, Scale*1600, Scale*650, 'Credits');
	// credits
	posy = Scale*400;
	if (CreditsList.Length > 6)
		posy -= Scale*50*3;
	else if (CreditsList.Length > 4)
		posy -= Scale*50*2;
	else if (CreditsList.Length > 2)
		posy -= Scale*50*1;
	posy -= TextScrollOffset*Scale*50;
	for (i = 0; i < Min(CreditsList.Length, 200); i++)
	{
		if (CreditsList[i] == "")
			continue;
		H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(CreditsList[i]);
		posy_it = posy + Scale*50*i;
		RenderBorderedText(H, self, CreditsList[i], Scale*800, posy_it, Scale*0.8, TextAlign_Center);
	}
	TextScrollMax = CreditsList.Length;
	H.Canvas.PopMaskRegion('Credits');
}

static function RenderPulse(HUD H, Hat_HUDElement el, Surface Texture, float PosX, float PosY, float SizeX, float SizeY, optional bool UseOriginalDrawColors)
{
	local float alpha, ScaleMulti;
	local Color originalC;
	local int i;
	
	originalC = H.Canvas.DrawColor;
	
	for (i = 0; i < 2; i++)
	{
		alpha = (class'WorldInfo'.static.GetWorldInfo().RealTimeSeconds+(i == 1 ? 0.5 : 0.0))%1;
		ScaleMulti = Lerp(1, 1.3, alpha);
		H.Canvas.DrawColor.A = originalC.A*Lerp(0.8f,0,alpha**2);
		if (!UseOriginalDrawColors)
			H.Canvas.SetDrawColor(255,0,0,H.Canvas.DrawColor.A);
		DrawCenter(H, posX, posY, SizeX*ScaleMulti, SizeY*ScaleMulti, Texture);
	}
	H.Canvas.DrawColor = OriginalC;
}

function RenderGameModTile(HUD H, int IndexInTab, float posX, float posY, float Scale, optional bool CanBeSelected = true)
{
	local int i, pulseindex;
	local Array<String> Title;
	local GameModInfo ReplacementGameModInfo, ModInfo;
	local Texture2D ModIcon;
	local float SelectScale, progress, rotation, ShadowScale, PulseScale;
	local Color originalC, IconColor;
	local string ModName;
	local bool selected, previewed, HasPushedMaskedRegion;

	selected = IndexInTab != INDEX_NONE && SelectedInTab == IndexInTab;
	pulseindex = 0;
	PulseScale = 1;
	HasPushedMaskedRegion = false;

	if (IndexInTab != INDEX_NONE && CanBeSelected && MouseActivated && CheckMouseHover(H, posX, posY, Scale*160, Scale*160))
	{
		if (!selected)
		{
			selected = true;
			SelectedTab = INDEX_NONE;
			SelectedInTab = IndexInTab;
			PrevMouseSelection = IndexInTab;
			PlaySelectionChangedSound(H);
		}
	}

	ModInfo = ModMenuTabs[CurrentModMenuIndex].GameMods[IndexInTab];
	ModIcon = GetIcon(CurrentModMenuIndex, IndexInTab, selected);
	ModName = ModInfo.Name;
	SelectScale = 1.2;
	rotation = 0;
	originalC = H.Canvas.DrawColor;
	IconColor = originalC;
	previewed = Preview && PreviewMod == ModInfo;
	
	ReplacementGameModInfo = ModInfo;
	GetReplacementGameModInfo(ReplacementGameModInfo);

	if (ModMenuTabs[CurrentModMenuIndex].InterpList.Length > 0 && IndexInTab != INDEX_NONE)
	{
		if (selected)
			Scale *= class'Hat_Math'.static.InterpolationOvershoot(1, SelectScale, ModMenuTabs[CurrentModMenuIndex].InterpList[IndexInTab], 10);
		else
			Scale *= Lerp(1, SelectScale, ModMenuTabs[CurrentModMenuIndex].InterpList[IndexInTab]);
	}
	
	
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
	{
		pulseindex = 1;
		PulseScale = 0.8;
		if (Preview)
		{
			if (previewed)
			{
				ShadowScale = Scale*300;
				ShadowScale = lerp(0, ShadowScale, FClamp((PreviewTime-2.8f) / 0.15f,0,1));
				ShadowScale = lerp(ShadowScale, 0, FClamp((PreviewTime-3.8) / 0.15f,0,1));
				H.Canvas.SetDrawColor(0,0,0,IconColor.A);
				DrawCenter(H, posX, PosY + Scale*130, ShadowScale, Scale*7, ItemShadow);
				
				H.Canvas.PushMaskRegion(0, 0, H.Canvas.ClipX, PosY + Scale * 130, 'Previewed');
				HasPushedMaskedRegion = true;
				
				rotation = PreviewTime*1 + (FClamp(PreviewTime / 4.f, 0, 1) ** 3)*15;
				posY += Scale * 300 * (FClamp((PreviewTime-3.f)/0.6f,0,1) ** 6);
				
			}
			else
			{
				// Fade out item not selected
				IconColor.A = lerp(IconColor.A, 0, FMin(PreviewTime / 0.4f,1.f));
				posY -= Scale * 100 * (FMin(PreviewTime/0.4f,1.f) ** 3);
			}
		}
	}
	
	if (selected || previewed)
	{
		RenderPulse(H, self, ModIconSelectImage[pulseindex], PosX, PosY, Scale*PulseScale*180, Scale*PulseScale*180);
	}

	H.Canvas.DrawColor = IconColor;
	if (!selected) H.Canvas.SetDrawColor(0,0,0,IconColor.A);
	
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode != 2)
		DrawCenter(H, posX, posY, Scale*185, Scale*185, ModIconSelectImage[pulseindex], rotation);
	if (ModIcon != None)
	{
		H.Canvas.DrawColor = IconColor;
		if ((!ModInfo.IsEnabled && ModInfo.IsSubscribed) || ReplacementGameModInfo.IsDownloading)
			H.Canvas.SetDrawColor(32,32,32,IconColor.A);
		DrawCenter(H, posX, posY, Scale*160, Scale*160, ModIcon, rotation);

		if (ReplacementGameModInfo.IsDownloading)
		{
			H.Canvas.SetDrawColor(128,128,128,IconColor.A);
			DrawCenter(H, posX, posY, Scale*60, Scale*60, ModUpdatingIcon, rotation);
			progress = class'GameMod'.static.GetModDownloadPercent(ReplacementGameModInfo.WorkshopId);
			ModName = DownloadingModText $ "...";
			if (progress >= 0)
				ModName = ModName $ " " $ int(progress*100) $ "%";
		}
		else if (!ModInfo.IsEnabled && ModInfo.IsSubscribed)
		{
			H.Canvas.SetDrawColor(128,128,128,IconColor.A);
			DrawCenter(H, posX, posY, Scale*60, Scale*60, ModDisabledIcon, rotation);
		}
	}
	
	// We assume if player has voted, player has played
	if (ModInfo.VoteStatus != INDEX_NONE && ModInfo.IsSubscribed && ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode != 2)
	{
		H.Canvas.SetDrawColor(255,255,255,IconColor.A);
		DrawCenter(H, posX+Scale*60, posY+Scale*60, Scale*30, Scale*30, ModPlayedIcon);
	}
	
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
	{
		if (selected)
		{
			H.Canvas.DrawColor = IconColor;
			Title = class'Hat_Localizer'.static.SplitStringByLength(ModName, 25);
			for (i = 0; i < Title.Length; i++)
			{
				H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(Title[i]);
				RenderBorderedText(H, self, Title[i], posX, posY - Scale*120 + Scale*44*i, Scale*0.8, TextAlign_Center,,,,, 1.0);
			}
		}
	}
	else
	{
		H.Canvas.DrawColor = IconColor;
		Title = class'Hat_Localizer'.static.SplitStringByLength(ModName, 25);
		for (i = 0; i < Title.Length; i++)
		{
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(Title[i]);
			RenderBorderedText(H, self, Title[i], posX, posY + Scale*85 + Scale*22*i, Scale*0.4, TextAlign_Center,,,,, selected ? 0.5 : 0.125);
		}
	}
	
	if (HasPushedMaskedRegion)
	{
		// If a Push Mask Region call was made earlier in this function, make sure we pop it
		H.Canvas.PopMaskRegion('Previewed');
	}
	
	H.Canvas.DrawColor = originalC;
}

function WipeAllSelections()
{
	WipeTileSelection();
	SelectedTab = -1;
	SelectedButton = LevelPreview_None;
	SelectedWorkshopBrowse = false;
}

function WipeTileSelection()
{
	//SelectedIndex = -1;
	SelectedInTab = -1;
}

function DrawLevelTab(HUD H, string text, float posX, float posY, float Scale, optional float TabWidth = 1.f, optional int TabIndex = INDEX_NONE)
{
	local Color originalC;
	local bool selected;
	local bool opened;
	originalC = H.Canvas.DrawColor;

	selected = TabIndex != -1 && SelectedTab == TabIndex;
	opened = CurrentModMenuIndex == TabIndex;

	if (MouseActivated && CheckMouseHover(H, posX, posY, Scale*100*TabWidth, Scale*55))
	{
		if (!selected)
		{
			selected = true;
			SelectedTab = TabIndex;
			WipeTileSelection();
			if (!opened)
				PlaySelectionChangedSound(H);
		}
	}
	
	posy -= (selected || opened) ? Scale*10 : 0.f;

	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(text);

	H.Canvas.DrawColor = TabIndex != INDEX_NONE ? ModMenuTabs[TabIndex].TabColor : DefaultTabColor;
	H.Canvas.DrawColor.A = originalC.A;
	DrawCenter(H, posX, posY, Scale*230*TabWidth, Scale*55, TabImage);
	H.Canvas.DrawColor = originalC;
	DrawCenterText(H.Canvas, text, posX, posY - Scale*5, Scale*0.42, Scale*0.42);
}

function DrawPreviewButton(HUD H, string text, float posX, float posY, float Scale, optional Surface Icon, optional EModLevelPreviewButton Button = LevelPreview_None)
{
	local Color originalC;
	local bool selected;
	local float sizex, sizey, textsize, scalealpha, TextOffsetY, TextBorderSize, ShadowAlpha;
	local Surface MyPreviewButtonImage, MyPreviewButtonImage_Silhouette;
	originalC = H.Canvas.DrawColor;

	selected = Button != LevelPreview_None && SelectedButton == Button;
	sizex = Scale*275;
	sizey = Scale*75;
	textsize = Scale*0.8;
	TextOffsetY = 0;
	TextBorderSize = 2;
	ShadowAlpha = 1;
	
	MyPreviewButtonImage = PreviewButtonImage;
	MyPreviewButtonImage_Silhouette = PreviewButtonImage_Silhouette;
	
	if (Button == LevelPreview_Enable && IsConfigModDisabled(H, PreviewMod))
	{
		Icon = CheckmarkUncheckedIcon;
	}
	
	if (Button == LevelPreview_Workshop)
	{
		sizex *= 0.8;
		sizey *= 1.1;
		textsize *= 0.7;
		MyPreviewButtonImage = WorkshopButton;
		MyPreviewButtonImage_Silhouette = WorkshopButton_Silhouette;
	}
	else if (Button == LevelPreview_UnSubscribe)
	{
		sizex = sizey;
	}
	else if (Button == LevelPreview_Back || Button == LevelPreview_Credits || Button == LevelPreview_Enable)
	{
		sizex = sizey;
		MyPreviewButtonImage = Icon;
		MyPreviewButtonImage_Silhouette = Icon;
		Icon = None;
		if (Button != LevelPreview_Enable)
		{
			TextSize *= 0.5f;
			TextBorderSize = 1;
			ShadowAlpha = 0.5;
		}
	}
		

	if (CheckMouseHover(H, posX, posY, sizex, sizey))
	{
		if (!selected)
		{
			selected = true;
			SelectedButton = Button;
			PlaySelectionChangedSound(H);
			PreviewButtonsInterp = 0;
		}
	}
	
	if (selected)
	{
		scalealpha = class'Hat_Math'.static.InterpolationOvershoot(1, 1.1, PreviewButtonsInterp, 10);
		SizeX *= scalealpha;
		SizeY *= scalealpha;
		TextSize *= scalealpha;
		
		RenderPulse(H, self, MyPreviewButtonImage_Silhouette, PosX, PosY, sizex, sizey);
	}

	if (Button == LevelPreview_Credits) H.Canvas.SetDrawColor(255,255,255,originalC.A);
	else if (selected) H.Canvas.SetDrawColor(128,230,255,originalC.A);
	else if (Button == LevelPreview_Play || Button == LevelPreview_DownloadMod || Button == LevelPreview_DownloadModMap || Button == LevelPreview_CancelDownload) H.Canvas.SetDrawColor(255,128,128,originalC.A);
	else if (Button == LevelPreview_UnSubscribe) H.Canvas.SetDrawColor(255,32,32,originalC.A);
	else if (Button == LevelPreview_PlayIntroduction) H.Canvas.SetDrawColor(128,255,128,originalC.A);
	//else if (Button == LevelPreview_Credits) H.Canvas.SetDrawColor(128,128,255,originalC.A);
	else if (Button == LevelPreview_Back) H.Canvas.SetDrawColor(255,255,255,originalC.A);
	else H.Canvas.SetDrawColor(128,128,128,originalC.A);
	
	TextOffsetY = SizeY*-0.05;
	if (Button == LevelPreview_Workshop)
		TextOffsetY = SizeY*-0.4;
	else if (Button == LevelPreview_Back || Button == LevelPreview_Enable)
		TextOffsetY = SizeY*0.65;
	
	DrawCenter(H, posX, posY, sizex, sizey, MyPreviewButtonImage);
	H.Canvas.SetDrawColor(0,0,0,originalC.A);
	if (Icon != None)
	{
		DrawCenter(H, posX - (text != "" ? sizex*0.3 : 0.0), posY, sizey*0.75, sizey*0.75, Icon);
		posx += sizex*0.1;
	}
	
	H.Canvas.DrawColor = originalC;
	if (text != "")
	{
		H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(text);
		RenderBorderedText(H, self, text, posX, posY+TextOffsetY, TextSize, TextAlign_Center, TextBorderSize, MakeColor(0,0,0, 255), -1, ShadowAlpha);
	}
}

function DrawWorkshopButton(HUD H, string text, float posX, float posY, float Scale)
{
	local Color originalC;
	local bool selected;
	local float SizeX, SizeY, TextSize, scalealpha;
	originalC = H.Canvas.DrawColor;

	selected = SelectedWorkshopBrowse;
	
	SizeX = Scale*280;
	SizeY = Scale*110;
	TextSize = Scale*0.5;

	if (MouseActivated)
	{
		if (CheckMouseHover(H, posX, posY, SizeX, SizeY))
		{
			if (!selected)
			{
				selected = true;
				SelectedTab = -1;
				SelectedWorkshopBrowse = true;
				WipeTileSelection();
				PlaySelectionChangedSound(H);
			}
		}
		else
		{
			selected = false;
			SelectedWorkshopBrowse = false;
		}
	}

	H.Canvas.SetDrawColor(0,0,0,128);
	DrawCenter(H, posX+Scale*3, posY+Scale*3, SizeX, SizeY, WorkshopButton_Silhouette);
	H.Canvas.SetDrawColor(255,255,255,255);
	
	if (selected)
	{
		scalealpha = class'Hat_Math'.static.InterpolationOvershoot(1, 1.1, SelectedWorkshopBrowse_FadeIn, 10);
		SizeX *= scalealpha;
		SizeY *= scalealpha;
		TextSize *= scalealpha;
		RenderPulse(H, self, WorkshopButton_Silhouette, PosX, PosY,SizeX, SizeY);
	}
	
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(text);
	DrawCenter(H, posX, posY, SizeX, SizeY, ModListMode == 2 ? DLCButton : WorkshopButton);
	if (ModListMode == 2)
	{
		RenderBorderedText(H, self, text, posX, posY, TextSize*1.75f, TextAlign_Center);
	}
	else
	{
		RenderBorderedText(H, self, text, posX, posY-SizeY*0.4, TextSize, TextAlign_Center);
	}
	H.Canvas.DrawColor = originalC;

	if (Hat_HUD(H).IsGamepad())
		class'Hat_HUDInputButtonRender'.static.Render(H, HatControllerBind_Player_FocusLookUp, posX - Scale*140, posY, Scale*45);
}

function DrawThumb(HUD H, bool ThumbsUp, float PosX, float PosY, float Size, float SizeMax)
{
	local EModLevelPreviewButton Button;
	local bool IsScalingUp, IsSelected, AnySelected;
	local Color originalC;
	originalC = H.Canvas.DrawColor;

	// Handle selection changing
	Button = ThumbsUp ? LevelPreview_ThumbsUp : LevelPreview_ThumbsDown;

	if (CheckMouseHover(H, posX, posY, Size, Size))
	{
		if (SelectedButton != Button)
		{
			SelectedButton = Button;
			PlaySelectionChangedSound(H);
			PreviewButtonsInterp = 0;
		}
	}
	
	IsSelected = PreviewMod.VoteStatus == (ThumbsUp ? 1 : 0);
	AnySelected = PreviewMod.VoteStatus >= 0;
	if (IsSelected)
	{
		Size *= 1.1;
		SizeMax *= 1.1;
	}
	else if (AnySelected)
	{
		Size *= 0.6;
	}
	// Handle interpolation
	IsScalingUp = (SelectedButton == Button);
	
	if (IsScalingUp)
		Size = class'Hat_Math'.static.InterpolationOvershoot(Size, SizeMax, PreviewButtonsInterp, 10);
	
	if (IsScalingUp && !IsSelected)
	{
		if (ThumbsUp)
			H.Canvas.SetDrawColor(0, 255, 0, originalC.A);
		else
			H.Canvas.SetDrawColor(255, 0, 0, originalC.A);
		RenderPulse(H, self, ThumbsUp ? ThumbsUpTextures[2] : ThumbsDownTextures[2], PosX, PosY, Size, Size, true);
	}
	
	if (VoteParticleComponent != None && VoteParticleIsUpvote == ThumbsUp)
	{
		H.Canvas.SetDrawColor(255,255,255,255);
		H.Canvas.SetPos(PosX, PosY);
		VoteParticleComponent.RenderToCanvas(H.Canvas);
		H.Canvas.DrawColor = originalC;
	}
	
	if (!IsSelected && AnySelected)
		H.Canvas.SetDrawColor(128, 128, 128, originalC.A);
	else
		H.Canvas.SetDrawColor(255, 255, 255, originalC.A);
	DrawCenter(H, PosX, PosY, Size, Size, ThumbsUp ? ThumbsUpTextures[IsSelected ? 1 : 0] : ThumbsDownTextures[IsSelected ? 1 : 0]);
	H.Canvas.DrawColor = originalC;
}

function RenderPrompts(HUD H, Hat_HUDElement e)
{
	local float MaxScale, MyScale, y, x;
	MaxScale = FMax(H.Canvas.ClipX, H.Canvas.ClipY);
	
	y = MaxScale*0.505;
	MyScale = MaxScale*0.052;

	x = MaxScale*0.539;
	class'Hat_HUDMenuSettings_Toolbar'.static.RenderCancelButton(H, e, x, y, MyScale, class'Hat_Localizer'.static.GetMenu("systemsettings.global", "SystemSetting_Back"));
	
	x = MaxScale*0.467;
	class'Hat_HUDMenuSettings_Toolbar'.static.RenderConfirmButton(H, e, x, y, MyScale, class'Hat_Localizer'.static.GetMenu("systemsettings.global", "SystemSetting_Confirm"));
}

static function RenderScrollbar(HUD H, Hat_HUDMenu e, float x, float y, float bw, float bh, float Scale, float PageSize, float PagePosition, out int BarHover, bool BarPress, out float BarStart, out float BarOutput, color ColorBack, color ColorButtons, color ColorHover, color ColorPressed)
{
	local float oldX, oldY, oldZ, barY, trackHeight;
	local Color originalC;

	// note: PageSize, PagePosition, and BarOutput are 0-1 floats

	oldX = H.Canvas.CurX;
	oldY = H.Canvas.CurY;
	oldZ = H.Canvas.CurZ;
	originalC = H.Canvas.DrawColor;

	trackHeight = bh - bw*2 - Scale*8;
	barY = y + bw + Scale*4 + trackHeight*PagePosition*(1-PageSize);

	if (BarPress && BarHover == 0 && BarStart == -1 && !Hat_HUD(H).IsGamepad() && e.MouseActivated)
		BarStart = e.GetMousePosY(H) - trackHeight*PagePosition*(1-PageSize);

	if (!BarPress)
	{
		BarStart = -1;
		BarOutput = -1;
	}

	if (BarStart == -1)
	{
		BarHover = -1;// nothing
		if (!Hat_HUD(H).IsGamepad() && e.MouseActivated)
		{
			if (e.IsMouseInArea(H, x + bw/2, barY + trackHeight*PageSize/2, bw, trackHeight*PageSize))
				BarHover = 0;// handle
			else if (e.IsMouseInArea(H, x + bw/2, y + bw/2, bw, bw))
				BarHover = 1;// top
			else if (e.IsMouseInArea(H, x + bw/2, y + bh - bw/2, bw, bw))
				BarHover = 2;// bottom
		}
	}
	else
	{
		BarOutput = FMin((trackHeight - trackHeight*PageSize),FMax(0, e.GetMousePosY(H) - BarStart)) / (trackHeight - trackHeight*PageSize);
	}
	
	// draw track
	H.Canvas.SetPos(x - Scale*4,y - Scale*4);
	H.Canvas.DrawColor = ColorBack;
	H.Canvas.DrawColor.A = originalC.A;
	H.Canvas.DrawRect(bw + Scale*8, bh + Scale*8);

	// draw handle
	H.Canvas.SetPos(x, barY);
	H.Canvas.DrawColor = BarHover == 0 ? (BarPress ? ColorPressed : ColorHover) : ColorButtons;
	H.Canvas.DrawColor.A = originalC.A;
	H.Canvas.DrawRect(bw, trackHeight*PageSize);
	
	// draw top arrow
	H.Canvas.SetPos(x, y);
	H.Canvas.DrawColor = BarHover == 1 ? (BarPress ? ColorPressed : ColorHover) : ColorButtons;
	H.Canvas.DrawColor.A = originalC.A;
	H.Canvas.DrawRect(bw, bw);
	
	// draw bottom arrow
	H.Canvas.SetPos(x, y + bh - bw);
	H.Canvas.DrawColor = BarHover == 2 ? (BarPress ? ColorPressed : ColorHover) : ColorButtons;
	H.Canvas.DrawColor.A = originalC.A;
	H.Canvas.DrawRect(bw, bw);
	
	H.Canvas.DrawColor = originalC;
	H.Canvas.SetPos(oldX, oldY, oldZ);
}

function ApplyFont(HUD H, bool Big)
{
	class'Hat_BubbleTalker_Render'.static.GetStandardFont(H.Canvas, Big);
}

function SwitchTab(int tab)
{
	local int i;

	CurrentModMenuIndex = tab;
	SelectedWorkshopBrowse = false;
	SelectedButton = LevelPreview_None;
	BackgroundInstance = None;
	
	for (i = 0; i < ModMenuTabs.Length; i++)
		ModMenuTabs[i].InterpList.Length = 0;
	
	// Get 15 first icons for tab
	for (i = 0; i < Min(15, ModMenuTabs[CurrentModMenuIndex].GameMods.Length); i++)
		GetIcon(CurrentModMenuIndex, i);
	
	ScrollOffset = 0;
	ScrollTarget = 0;
	PrevMouseSelection = 0;
	if (SelectedInTab != -1) SelectedInTab = 0;
	ModMenuTabs[CurrentModMenuIndex].FadeIn = 0;

	for (i = 0; i < ModMenuTabs[CurrentModMenuIndex].GameMods.Length; i++)
		ModMenuTabs[CurrentModMenuIndex].InterpList.AddItem(0);
	
	`SetMusicParameterInt('ChallengeRoad', ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode > 0 ? 1 : 0);
	
	if (BackgroundInstance == None && MaterialInterface(ModMenuTabs[CurrentModMenuIndex].Background) != None)
	{
		BackgroundInstance = new class'MaterialInstanceConstant';
		BackgroundInstance.SetParent(MaterialInterface(ModMenuTabs[CurrentModMenuIndex].Background));
	}
}

function bool GetReplacementGameModInfo(out GameModInfo InGameModInfo)
{
	local int i;
	local Array<GameModInfo> ModList;
	
	if (InGameModInfo.IsSubscribed) return false;
	if (!InGameModInfo.IsFeatured && !InGameModInfo.Tag_IsChallengeRoad) return false;
	if (InGameModInfo.WorkshopId <= 0) return false;
	
	ModList = class'GameMod'.static.GetModList();
	
	for (i = 0; i < ModList.Length; i++)
	{
		if (!ModList[i].IsSubscribed) continue;
		if (ModList[i].IsFeatured) continue;
		if (ModList[i].WorkshopId != InGameModInfo.WorkshopId) continue;
		
		InGameModInfo = ModList[i];
		return true;
	}
	return false;
}	

function bool PreviewSelected(HUD H)
{
	local Array<string> Split;
	local int i;
	if (SelectedInTab == INDEX_NONE) return false;
	if (ModMenuTabs[CurrentModMenuIndex].GameMods[SelectedInTab].IsDownloading) return false;
	Preview = true;
	IsCredits = false;
	PreviewMod = ModMenuTabs[CurrentModMenuIndex].GameMods[SelectedInTab];
	GetReplacementGameModInfo(PreviewMod);
	
	PreviewIcon = GetIcon(CurrentModMenuIndex, SelectedInTab);
	SelectedButton = LevelPreview_None;
	ClickDelay = 0.3;
	PreviewButtonsInterp = 0;
	PreviewTime = 0;
	PScrollbarState = -1;
	TextScrollOffset = 0;
	PreviewInstance = None;
	
	// Credits
	CreditsList.Length = 0;
	// Only display author here if its multi-line or ModListMode 2
	if (PreviewMod.Author != "" && (ModListMode == 2 || InStr(PreviewMod.Author, ";") != INDEX_NONE))
	{
		ParseStringIntoArray(PreviewMod.Author, Split, ";", true);
		if (Split.Length > 1 || PreviewMod.SpecialThanks != "")
		{
			CreditsList.AddItem("= " $ Caps(PreviewMod.Name) $ " = ");
			for (i = 0; i < Split.Length; i++)
				CreditsList.AddItem(Split[i]);
		}
	}
	if (PreviewMod.SpecialThanks != "")
	{
		ParseStringIntoArray(PreviewMod.SpecialThanks, Split, ";", true);
		if (CreditsList.Length > 0)
		{
			CreditsList.AddItem("");
			CreditsList.AddItem("");
		}
		CreditsList.AddItem("= SPECIAL THANKS = ");
		for (i = 0; i < Split.Length; i++)
			CreditsList.AddItem(Split[i]);
	}
	for (i = 0; i < Min(CreditsList.Length, 200); i++)
	{
		CreditsList[i] = Repl(CreditsList[i], "[*]", " * ");
		CreditsList[i] = Repl(CreditsList[i], "[list]", "");
		CreditsList[i] = Repl(CreditsList[i], "[/list]", "");
		CreditsList[i] = Repl(CreditsList[i], "[h1]", "= ");
		CreditsList[i] = Repl(CreditsList[i], "[/h1]", " =");
		CreditsList[i] = Repl(CreditsList[i], "[b]", "");
		CreditsList[i] = Repl(CreditsList[i], "[/b]", "");
		CreditsList[i] = Repl(CreditsList[i], "[i]", "");
		CreditsList[i] = Repl(CreditsList[i], "[/i]", "");
		CreditsList[i] = Repl(CreditsList[i], "[u]", "");
		CreditsList[i] = Repl(CreditsList[i], "[/u]", "");
	}
	
	
	if (ModListMode == 2 && CreatorDLCPreview != None)
	{
		PlayOwnerSound(H, CreatorDLCPreview);
	}
	
	PreviewLogo = None;
	PreviewSplashArt = None;
	PreviewBackgroundArt = None;
	PreviewTitlecard = None;
	
	if (ModListMode == 2)
	{
		class'GameMod'.static.PreloadModIcon(PreviewMod, 'Logo');
		class'GameMod'.static.PreloadModIcon(PreviewMod, 'SplashArt');
		class'GameMod'.static.PreloadModIcon(PreviewMod, 'Background');
		class'GameMod'.static.PreloadModIcon(PreviewMod, 'Titlecard');
	}
	else
	{
		PreviewLogo = class'GameMod'.static.GetModIcon(PreviewMod, 'Logo');
		PreviewSplashArt = class'GameMod'.static.GetModIcon(PreviewMod, 'SplashArt');
		PreviewBackgroundArt = class'GameMod'.static.GetModIcon(PreviewMod, 'Background');
		PreviewTitlecard = class'GameMod'.static.GetModIcon(PreviewMod, 'Titlecard');
	}

	if (PreviewInstance == None && MaterialInterface(ModMenuTabs[CurrentModMenuIndex].Background) != None)
	{
		PreviewInstance = new class'MaterialInstanceConstant';
		PreviewInstance.SetParent(MaterialInterface(ModMenuTabs[CurrentModMenuIndex].Background));
		PreviewInstance.SetScalarParameterValue('Ocean', 0);
		if (PreviewInstance != None && PreviewBackgroundArt != None)
		{
			PreviewInstance.SetTextureParameterValue('Background', PreviewBackgroundArt);
			PreviewInstance.SetScalarParameterValue('RawColor', 1.0f);
		}
	}
	UpdatePreviewButtons(H);

	if (Hat_HUD(H).IsGamepad() || !MouseActivated) SelectedButton = PreviewButtons.Length > 0 ? PreviewButtons[0] : LevelPreview_ThumbsUp;
	return true;
}

function UpdatePreviewButtons(HUD H)
{
	local bool AllowPlay;

	AllowPlay = PreviewMod.IsSubscribed && !PreviewMod.IsDownloading && ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode != 1;
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
	{
		AllowPlay = true;
	}

	PreviewButtons.Length = 0;
	
	if (AllowPlay)
	{
		// If intro map present, needs to have played intro once
		if (PreviewMod.IntroductionMap == "" || class'Hat_SaveBitHelper'.static.HasLevelBit("Mods_" $ PreviewMod.PackageName $ "_PlayedIntroOnce", 1, `GameManager.HubMapName))
		{
			PreviewButtons.AddItem(LevelPreview_Play);
		}
		
		if (PreviewMod.IntroductionMap != "")
		{
			PreviewButtons.AddItem(LevelPreview_PlayIntroduction);
		}
	}
	else if (!AllowPlay && !PreviewMod.IsSubscribed && !PreviewMod.IsDownloading && PreviewMod.IsFeatured && ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode != 1)
		PreviewButtons.AddItem(PreviewMod.IsMap ? LevelPreview_DownloadModMap : LevelPreview_DownloadMod);
		
	if (CreditsList.Length > 0 && ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode != 2 && !CanRenderDLCScreenForMod())
	{
		PreviewButtons.AddItem(LevelPreview_Credits);
	}
		
	if (PreviewMod.ModClass != None && PreviewMod.IsSubscribed && !PreviewMod.IsDownloading && !PreviewMod.Tag_IsDLC)
	{
		PreviewButtons.AddItem(LevelPreview_Enable);
		// If there's more options than just "Enable"
		if (PreviewMod.Configs.Length > 1 && PreviewMod.IsEnabled)
			PreviewButtons.AddItem(LevelPreview_Config);
	}
	if (PreviewMod.IsSubscribed && PreviewMod.IsDownloading && PreviewMod.WorkshopID > 0)
	{
		PreviewButtons.AddItem(LevelPreview_CancelDownload);
	}
	if (PreviewMod.WorkshopId > 0)
		PreviewButtons.AddItem(LevelPreview_Workshop);
	
	if ((!PreviewMod.IsEnabled || PreviewButtons.Find(LevelPreview_Enable) == INDEX_NONE) && PreviewMod.IsSubscribed && !PreviewMod.IsDownloading && PreviewMod.WorkshopID > 0)
	{
		PreviewButtons.AddItem(LevelPreview_UnSubscribe);
	}
}

function ExitPreview()
{
	IsCredits = false;
	Preview = false;
	UndoPreview = false;
	PreviewTime = 0;
	PScrollbarState = -1;
	TextScrollOffset = 0;
	SelectedButton = LevelPreview_None;
	ClickDelay = 0.3;
	PreviewButtonsInterp = 0;
	LastDownloadedPreview = -1;
}

function LoadMap(HUD H)
{
	local bool found;
	local string MapName;
	local mcu8_HubConfig cfg;
	local string _mapName;
	local Array<string> splitList;
	
	if (!Preview) return;
	if (IsLoadingMap) return;

	found = false;
	foreach PreviewMod.MapNames(_mapName) 
    {
        // Check if map contains prefix
        splitList = SplitString(Locs(_mapName), "_");
        if (splitList[0] == "hubexmap" || _mapName ~= `GameManager.HubMapName) 
        {
			found = true;
			MapName = Locs(_mapName);
			break;
        }
    }
	
	if (!found) {
		`broadcast("Hub map doesn't found!");
		CloseHUD(H);
		return;
	}

	IsLoadingMap = true;
	SetMouseHidden(H, true);
	`GameManager.LoadNewAct(99);

	LocalPlayer(H.PlayerOwner.Player).AudioListener = None;

	cfg = class'mcu8_HubConfig'.static.Load();
	cfg.LastMap = `GameManager.HubMapName ~= MapName ? "" : MapName;
	cfg.Save();

	`GameManager.SoftChangeLevel(MapName);
	if (PreviewMod.PackageName != "")
		class'GameMod'.static.SetActiveLevelMod(PreviewMod.PackageName);
}

delegate OnCloseConfigMenu(HUD H, Hat_HUDElement e)
{
	IsMenuFrozen = false;
	RefreshGameModInfos(H);
}

function GoToConfig(HUD H)
{
	local Hat_HUDMenuSettings Settings;
	
	if (!PreviewMod.IsSubscribed) return;
	
	IsMenuFrozen = true;
	
	Settings = Hat_HUDMenuSettings(Hat_HUD(H).OpenHUD(class'Hat_HUDMenuSettings'));
	Settings.OpenModsSettings(H, PreviewMod);
	Settings.PushOnHUDElementClosedDelegate(OnCloseConfigMenu);
}

function bool IsConfigModDisabled(HUD H, GameModInfo InMod)
{
	return class'GameMod'.static.GetConfigValue(InMod.ModClass, 'mod_disabled') > 0;
}

function TogglePreviewModEnabled(HUD H)
{
	local int result;
	if (!PreviewMod.IsSubscribed) return;
	
	result = IsConfigModDisabled(H, PreviewMod) ? 1 : 0;
	class'GameMod'.static.SaveConfigValue(PreviewMod.ModClass, 'mod_disabled', 1-result);
	RefreshGameModInfos(H);
	UpdatePreviewButtons(H);
}

function TogglePreviewCredits(HUD H, bool bEnabled)
{
	IsCredits = bEnabled;
	TextScrollOffset = 0;
}

function ViewInWorkshop(HUD H)
{
	if (!Preview) return;
	class'GameMod'.static.ViewInWorkshop(PreviewMod.WorkshopId);
}

function OpenWorkshop(HUD H)
{
	local string WorkshopURL;

	WorkshopURL = ModMenuTabs[CurrentModMenuIndex].WorkshopURL;
	if (WorkshopURL == "") return;
	class'Hat_GameManager_Base'.static.OpenBrowserURL(WorkshopURL);
	PlayOwnerSound(H, WorkshopSound);
}


// True if a click sound should be played
function bool StartChallengeRoad(HUD H)
{
	local Array<GameModInfo> ModList;
	local int i,j;
	local bool HasModInstalled, IsMissingInstalledMod;
	local string FirstMapName;
	`if(`isdefined(WITH_GHOSTPARTY))
	local Hat_HUDElementGhostPartyJoinAct JoinHUD;
	`endif
	
	if (IsLoadingMap) return false;
	if (class'GameMod'.static.GetChallengeRoadID() == "") return false;
	
	// Are we subscribed to all challenge road mods? If not, let's do it
	ModList = class'GameMod'.static.GetModList();
	IsMissingInstalledMod = false;
	for (i = 0; i < ModList.Length; i++)
	{
		if (ModList[i].IsSubscribed) continue;
		if (!ModList[i].Tag_IsChallengeRoad) continue;
		if (ModList[i].WorkshopId <= 0) continue;
		
		// Do we have a non-subscribed, downloaded mod?
		HasModInstalled = false;
		for (j = 0; j < ModList.Length; j++)
		{
			if (i == j) continue;
			if (!ModList[j].IsSubscribed) continue;
			if (ModList[j].IsDownloading) continue;
			if (ModList[j].WorkshopId != ModList[i].WorkshopId) continue;
			// Yup, we have it
			HasModInstalled = true;
			break;
		}
		if (HasModInstalled) continue;
		
		// Subscribe to it
		IsMissingInstalledMod = true;
		class'GameMod'.static.SubscribeToFeaturedMod(ModList[i].WorkshopId);
	}
	if (IsMissingInstalledMod)
	{
		if (LastDownloadedPreview < 0) LastDownloadedPreview = LastDownload_ChallengeRoad;
		return true;
	}
	
	FirstMapName = class'Hat_SnatcherContract_ChallengeRoad'.static.GetFirstMapName();
	if (FirstMapName == "") return false;
	
	IsLoadingMap = true;
	SetMouseHidden(H, true);
	
	`if(`isdefined(WITH_GHOSTPARTY))
	if (class'Hat_SnatcherContract_ChallengeRoad'.static.IsDeathWishAvailableToRemoteJoin() && class'Hat_GhostPartyPlayerStateBase'.static.HasNonLocalPrivatePlayerStates(true))
	{
		JoinHUD = Hat_HUDElementGhostPartyJoinAct(Hat_HUD(H).OpenHUD(class'Hat_HUDElementGhostPartyJoinAct',,true));
		JoinHUD.HostJoinAct(class'Hat_SnatcherContract_ChallengeRoad');
		return false;
	}
	`endif
	
	class'Hat_HUDMenuDeathWish'.static.StaticPlayDeathWish(class'Hat_SnatcherContract_ChallengeRoad');
	GetSaveGame().ActiveDeathWishes.Length = 0;
	GetSaveGame().ActiveDeathWishes.AddItem(class'Hat_SnatcherContract_ChallengeRoad');
	return false;
}

function VoteSubmit(HUD H, bool positive)
{
	if (!Preview) return;
	ClickDelay = 0.5;
	if (PreviewMod.VoteStatus == (positive ? 1 : 0)) return; // Same vote
	class'GameMod'.static.SetModVote(PreviewMod.WorkshopId, positive);
	RefreshGameModInfos(H);
}

function bool CheckMouseHover(HUD H, float PosX, float PosY, float SizeX, float SizeY)
{
	local bool r;
	if (IsMenuFrozen) return false;
	r = !Hat_HUD(H).IsGamepad() && MouseActivated && IsMouseInArea(H, PosX, PosY, SizeX, SizeY);
	if (r && MouseClear) MouseClear = false;
	return r;
}

function bool OnClick(HUD H, bool release)
{
	if (release)
	{
		LScrollbarPress = false;
		PScrollbarPress = false;
		return false;
	}
	if (IsMenuFrozen) return false;
	if (ClickDelay > 0) return false;
	if (IsLoadingMap) return false;
	if (UndoPreview) return false;

	if (SelectedButton == LevelPreview_Back || IsCredits)
	{
		return OnAltClick(H, false);
	}
	else if (!Preview)
	{
		if (!Hat_HUD(H).IsGamepad() && MouseActivated && LScrollbarState > -1)
		{
			if (LScrollbarState == 0)
			{
				LScrollbarPress = true;
				PlayOwnerSound(H, TabSound);
				return true;
			}
			else if (LScrollbarState == 1)
			{
				ScrollTarget = FMax(ScrollTarget - 1, 0);
				LScrollbarPress = true;
				PlayOwnerSound(H, TabSound);
				return true;
			}
			else if (LScrollbarState == 2)
			{
				ScrollTarget = FMin(ScrollTarget + 1, (FFloor((ModMenuTabs[CurrentModMenuIndex].GameMods.Length-1)/NumItemsPerRow)-2));
				LScrollbarPress = true;
				PlayOwnerSound(H, TabSound);
				return true;
			}
		}

		if (SelectedInTab != INDEX_NONE)
		{
			if (!PreviewSelected(H)) return false;
		}
		else if (SelectedTab != INDEX_NONE && SelectedTab != CurrentModMenuIndex)
		{
			SwitchTab(SelectedTab);
			PlayOwnerSound(H, TabSound);
			return true;
		}
		else if (SelectedWorkshopBrowse)
		{
			OpenWorkshop(H);
			return true;
		}
		else if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 1 && SelectedButton == LevelPreview_DownloadModMap)
		{
			if (StartChallengeRoad(H)) PlayOwnerSound(H, WorkshopSound);
			return true;
		}
		else
			return false;
	}
	else
	{
		if (!Hat_HUD(H).IsGamepad() && MouseActivated && PScrollbarState > -1)
		{
			if (PScrollbarState == 0)
			{
				PScrollbarPress = true;
				PlayOwnerSound(H, TabSound);
				return true;
			}
			else if (PScrollbarState == 1)
			{
				TextScrollOffset = FMax(TextScrollOffset - 3, 0);
				PScrollbarPress = true;
				PlayOwnerSound(H, TabSound);
				return true;
			}
			else if (PScrollbarState == 2)
			{
				TextScrollOffset = FMin(TextScrollOffset + 3, TextScrollMax);
				PScrollbarPress = true;
				PlayOwnerSound(H, TabSound);
				return true;
			}
		}

		if (Preview && SelectedButton == LevelPreview_Play)
			LoadMap(H);
//		else if (Preview && SelectedButton == LevelPreview_PlayIntroduction)
//			LoadMap(H, 1);
		else if (Preview && SelectedButton == LevelPreview_Credits)
			TogglePreviewCredits(H, true);
		else if (Preview && SelectedButton == LevelPreview_Enable)
			TogglePreviewModEnabled(H);
		else if (Preview && SelectedButton == LevelPreview_Config)
			GoToConfig(H);
		else if (Preview && SelectedButton == LevelPreview_Workshop)
		{
			ViewInWorkshop(H);
			PlayOwnerSound(H, WorkshopSound);
			return true;
		}
		else if (Preview && SelectedButton == LevelPreview_ThumbsUp)
		{
			VoteSubmit(H, true);
			PlayOwnerSound(H, RateUpSound);
			CreateVoteParticle(H, true);
			return true;
		}
		else if (Preview && SelectedButton == LevelPreview_ThumbsDown)
		{
			VoteSubmit(H, false);
			PlayOwnerSound(H, RateDownSound);
			CreateVoteParticle(H, false);
			return true;
		}
		else if (Preview && (SelectedButton == LevelPreview_DownloadMod || SelectedButton == LevelPreview_DownloadModMap))
		{
			PlayOwnerSound(H, DownloadSound);
			class'GameMod'.static.SubscribeToFeaturedMod(PreviewMod.WorkshopId);
			RefreshGameModInfos(H);
			UpdatePreviewButtons(H);
			LastDownloadedPreview = PreviewMod.WorkshopId;
			return true;
		}
		else if (Preview && (SelectedButton == LevelPreview_UnSubscribe || SelectedButton == LevelPreview_CancelDownload))
		{
			PlayOwnerSound(H, UnsubscribeSound);
			class'GameMod'.static.UnsubscribeFromMod(PreviewMod.WorkshopId);
			ExitPreview();
			BuildModList(H);
			LastDownloadedPreview = INDEX_NONE;
			return true;
		}
		else
		{
			return false;
		}
	}
	
	PlayOwnerSound(H, (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2 && CreatorDLCSelectSound != None) ? CreatorDLCSelectSound : SelectSound);
	return true;
}

function bool OnAltClick(HUD H, bool release)
{
	if (release) return false;
	if (IsMenuFrozen) return false;
	if (ClickDelay > 0) return false;
	if (IsLoadingMap) return false;
	if (UndoPreview) return false;

	if (Preview)
	{
		if (IsCredits)
		{
			TogglePreviewCredits(H, false);
		}
		else if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
		{
			UndoPreview = true;
			PreviewTime = FMin(PreviewTime, 4);
		}
		else
		{
			ExitPreview();
		}
	}
	else
	{
		Hat_HUD(H).CloseHUD(self.Class);
	}
	
	if (ModListMode == 2 && CreatorDLCClose != None)
	{
		PlayOwnerSound(H, CreatorDLCClose);
	}
	else
	{
		PlayOwnerSound(H, ExitSound);
	}

	return true;
}

function bool CheckDefaultSelection()
{
	if (Preview && SelectedButton == LevelPreview_None)
	{
		SelectedButton = LevelPreview_Play;
		return true;
	}
	else
		return false;
}

// bumpers, Q/E
function bool OnPageClick(HUD H, bool right, bool release)
{
	if (release) return false;
	if (!AllowCategories) return false;
	if (IsMenuFrozen) return false;
	if (Preview) return false;
	if (ModMenuTabs.Length <= 1) return false;
	if (right)
	{
		if (CurrentModMenuIndex < ModMenuTabs.Length-1)
			SwitchTab(CurrentModMenuIndex + 1);
		else
			SwitchTab(0);
	}
	else if (!right)
	{
		if (CurrentModMenuIndex > 0)
			SwitchTab(CurrentModMenuIndex - 1);
		else
			SwitchTab(ModMenuTabs.Length-1);
	}
	else return false;

	PlayOwnerSound(H, TabSound);
	return true;
}

// Only on gamepads. Y button on Xbox.
function bool OnYClick(HUD H, bool release)
{
	if (release) return false;
	if (IsMenuFrozen) return false;
	if (Preview) return false;
	
	if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 1)
	{
		if (StartChallengeRoad(H)) PlayOwnerSound(H, WorkshopSound);
	}
	else
		OpenWorkshop(H);

	return true;
}

function bool OnPressDown(HUD H, bool menu, bool release)
{
	if (release) return false;
	if (IsMenuFrozen) return false;
	if (SelectedWorkshopBrowse) return false;

	if (!Preview)
	{
		if (SelectedInTab == -1)
		{
			SelectedInTab = PrevMouseSelection;
			SelectedButton = LevelPreview_None;
		}
		else if (SelectedInTab + 5 < ModMenuTabs[CurrentModMenuIndex].GameMods.Length)
		{
			SelectedInTab += 5;
			SelectedButton = LevelPreview_None;
		}
		else if (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 1)
		{
			if (SelectedButton != LevelPreview_None) return false;
			SelectedButton = LevelPreview_DownloadModMap;
			SelectedInTab = INDEX_NONE;
		}
		else
		{
			PlaySelectionChangedSound(H);
			SelectedTab = INDEX_NONE;
			SelectedButton = LevelPreview_None;
			SelectedWorkshopBrowse = true;
			WipeTileSelection();
			return true;
		}
	}
	else
	{
		if (IsCredits) return false;
		if (PreviewButtons.Length == 0) return false;
		if (SelectedButton == LevelPreview_None || SelectedButton == LevelPreview_ThumbsUp || SelectedButton == LevelPreview_ThumbsDown)
			SelectedButton = PreviewButtons[0];
		else
			return false;
	}
	
	SetMouseHidden(H,true);
	PlaySelectionChangedSound(H);
	PreviewButtonsInterp = 0;
	SelectedWorkshopBrowse = false;
	return true;
}

function bool OnPressUp(HUD H, bool menu, bool release)
{
	local int CurIndex;
	if (release) return false;
	if (IsMenuFrozen) return false;

	if (!Preview)
	{
		if (SelectedWorkshopBrowse)
		{
			SelectedInTab = 0;
			SelectedButton = LevelPreview_None;
		}
		else
		{
			CurIndex = SelectedInTab == -1 ? PrevMouseSelection : SelectedInTab;
			if (CurIndex - 5 >= 0)
			{
				SelectedInTab = CurIndex - 5;
				SelectedButton = LevelPreview_None;
			}
			else return false;
		}
	}
	else
	{
		if (IsCredits) return false;
		if (PreviewButtons.Find(LevelPreview_ThumbsDown) != INDEX_NONE && (PreviewButtons.Find(SelectedButton) != INDEX_NONE || SelectedButton == LevelPreview_None))
			SelectedButton = LevelPreview_ThumbsDown;
		else
			return false;
	}
	
	SetMouseHidden(H,true);
	PlaySelectionChangedSound(H);
	PreviewButtonsInterp = 0;
	SelectedWorkshopBrowse = false;
	return true;
}

function bool OnPressLeft(HUD H, bool menu, bool release)
{
	local int CurIndex;
	if (release) return false;
	if (IsMenuFrozen) return false;

	if (!Preview)
	{
		CurIndex = SelectedInTab == -1 ? PrevMouseSelection : SelectedInTab;
		if (CurIndex%NumItemsPerRow > 0 && CurIndex - 1 >= 0)
		{
			SelectedInTab = CurIndex - 1;
			SelectedButton = LevelPreview_None;
		}
		else
		{
			if (SelectedButton != LevelPreview_Back && ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2)
			{
				SelectedButton = LevelPreview_Back;
				SelectedInTab = -1;
			}
			else
			{
				return false;
			}
		}
		if (SelectedButton != LevelPreview_Back)
		{
			SelectedButton = LevelPreview_None;
		}
	}
	else
	{
		if (IsCredits) return false;
		if (PreviewButtons.Length == 0 && PreviewMod.WorkshopId < 0 && ModListMode != 2 && !CanRenderDLCScreenForMod()) return false;
		
		if (SelectedButton == LevelPreview_None)
		{
			if (PreviewButtons.Length > 0)
				SelectedButton = PreviewButtons[0];
			else if (PreviewMod.WorkshopId >= 0)
				SelectedButton = LevelPreview_ThumbsUp;
		}
		else if (SelectedButton == LevelPreview_Credits && ModListMode == 2)
		{
			SelectedButton = LevelPreview_Back;
		}
		else if (SelectedButton == LevelPreview_ThumbsDown)
		{
			SelectedButton = LevelPreview_ThumbsUp;
		}
		else if (SelectedButton == LevelPreview_ThumbsUp && (ModListMode == 2 || CanRenderDLCScreenForMod()) && CreditsList.Length > 0)
		{
			SelectedButton = LevelPreview_Credits;
		}
		else if (PreviewButtons.Find(SelectedButton) == 0 && PreviewMod.WorkshopId >= 0)
		{
			SelectedButton = LevelPreview_ThumbsDown;
		}
		else if (PreviewButtons.Find(SelectedButton) == 0 && (ModListMode == 2 || CanRenderDLCScreenForMod()) && CreditsList.Length > 0)
		{
			SelectedButton = LevelPreview_Credits;
		}
		else if (PreviewButtons.Find(SelectedButton) == 0 && ModListMode == 2)
		{
			SelectedButton = LevelPreview_Back;
		}
		else if (PreviewButtons.Find(SelectedButton) > 0)
		{
			SelectedButton = PreviewButtons[PreviewButtons.Find(SelectedButton)-1];
		}
		else
			return false;
	}
	
	SetMouseHidden(H,true);
	PlaySelectionChangedSound(H);
	PreviewButtonsInterp = 0;
	SelectedWorkshopBrowse = false;
	return true;
}

function bool OnPressRight(HUD H, bool menu, bool release)
{
	local int CurIndex;
	if (release) return false;
	if (IsMenuFrozen) return false;

	if (!Preview)
	{
		CurIndex = SelectedInTab == -1 ? PrevMouseSelection : SelectedInTab;
		if (SelectedButton == LevelPreview_Back && ModMenuTabs[CurrentModMenuIndex].GameMods.Length > 0)
			SelectedInTab = 0;
		else if (CurIndex%NumItemsPerRow < 4 && CurIndex + 1 < ModMenuTabs[CurrentModMenuIndex].GameMods.Length)
		{
			SelectedInTab = CurIndex+1;
		}
		else return false;
	}
	else
	{
		if (IsCredits) return false;
		if (PreviewButtons.Length == 0 && PreviewMod.WorkshopId < 0) return false;
		
		if (SelectedButton == LevelPreview_None)
		{
			if (PreviewButtons.Length > 0)
				SelectedButton = PreviewButtons[0];
			else
				SelectedButton = LevelPreview_ThumbsUp;
		}
		else if (SelectedButton == LevelPreview_ThumbsUp)
		{
			SelectedButton = LevelPreview_ThumbsDown;
		}
		else if (SelectedButton == LevelPreview_Back && CreditsList.Length > 0 && PreviewButtons.Find(LevelPreview_Credits) == INDEX_NONE)
		{
			SelectedButton = LevelPreview_Credits;
		}
		else if (SelectedButton == LevelPreview_Credits && PreviewMod.WorkshopId >= 0 && PreviewButtons.Find(LevelPreview_Credits) == INDEX_NONE)
		{
			SelectedButton = LevelPreview_ThumbsUp;
		}
		else if ((SelectedButton == LevelPreview_ThumbsDown || SelectedButton == LevelPreview_Back || SelectedButton == LevelPreview_Credits) && PreviewButtons.Find(SelectedButton) == INDEX_NONE && PreviewButtons.Length > 0)
		{
			SelectedButton = PreviewButtons[0];
		}
		else if (PreviewButtons.Find(SelectedButton) < PreviewButtons.Length-1)
		{
			SelectedButton = PreviewButtons[PreviewButtons.Find(SelectedButton)+1];
		}
		else
			return false;
	}
	
	SetMouseHidden(H,true);
	PlaySelectionChangedSound(H);
	PreviewButtonsInterp = 0;
	SelectedWorkshopBrowse = false;
	if (!Preview)
		SelectedButton = LevelPreview_None;
	return true;
}

function bool DisablesMovement(HUD H)
{
    return true;
}
function bool DisablesCameraMovement(HUD H)
{
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
	H.AttachComponent(pc);
	pc.CanvasExclusive();
	pc.SecondsBeforeInactive = 0;
	pc.SetScale(3);
	
	if (VoteParticleComponent != None)
	{
		VoteParticleComponent.DetachFromAny();
		VoteParticleComponent = None;
	}
	
	VoteParticleComponent = pc;

	VoteParticleIsUpvote = Upvote;
}

function CreateBackgroundParticle(HUD H)
{
	local ParticleSystemComponent pc;
	local ParticleSystem ps;
	local int i;
	
	for (i = 0; i < 2; i++)
	{
		ps = BackgroundParticle[i];
		if (ModListMode == 2)
			ps = BackgroundParticle[2];
		if (ps == None) continue;
		
		pc = new class'ParticleSystemComponent';
		pc.SetTemplate(ps);
		H.AttachComponent(pc);
		pc.CanvasExclusive();
		pc.SecondsBeforeInactive = 0;
		pc.SetScale(3);
		pc.Trigger(true);
		BackgroundParticleComponent[i] = pc;
	}
}

function BuildModList_Levels(HUD H)
{
	local Array<GameModInfo> ModList;
	local int i;
	local ModMenuTab NewModMenu, DefaultModMenu;
	local String _mapName;
	local Array<String> splitList;
	local bool found;

	// default hub
	local GameModInfo dh;
	dh.Name = "Default HUB";
	dh.Description = "Just a default A Hat in Time hub";
	dh.Version = "1.0.0";
	dh.Author = "Gears for Breakfast";
	dh.IsMap = true;
	dh.IsSubscribed = true;
	dh.IsDownloading = false;
	dh.IsEnabled = true;
	dh.MapNames.AddItem(`GameManager.HubMapName);


	ModList = class'GameMod'.static.GetModList();
	
	// HUBs
	NewModMenu = DefaultModMenu;
	NewModMenu.TabName = "HUB Maps"; //class'Hat_Localizer'.static.GetMenu("Modding", "Category_HUBs");
	NewModMenu.Background = MaterialInstanceConstant'HatinTime_HUD_Modding.Materials.ModMenuBackground_Green';
	NewModMenu.WorkshopURL = "https://steamcommunity.com/workshop/filedetails/?id=2273080350";
	NewModMenu.TabColor = MakeColor(40,255,40);

	NewModMenu.GameMods.AddItem(dh);
	for (i = 0; i < ModList.Length; i++)
	{
		if (!ModList[i].IsSubscribed) continue;
		if (!ModList[i].IsMap) continue;
		found = false;
		foreach ModList[i].MapNames(_mapName) 
        {
            // Check if map contains prefix
            splitList = SplitString(Locs(_mapName), "_");
            if (splitList[0] == "hubexmap") 
            {
				found = true;
				break;
            }
        }
		if (!found) continue;		
		NewModMenu.GameMods.AddItem(ModList[i]);
	}
	if (NewModMenu.GameMods.Length > 0)
		ModMenuTabs.AddItem(NewModMenu);
}

function BuildModList_DLC(HUD H)
{
	local Array<GameModInfo> ModList;
	local int i;
	local ModMenuTab NewModMenu;

	ModList = class'GameMod'.static.GetModList();
	
	// DLC
	NewModMenu.TabName = "";
	NewModMenu.Background = Material'HatinTime_CreatorDLC.Materials.CreatorDLCBackground';
	NewModMenu.Overlay.AddItem(Material'HatinTime_CreatorDLC.Materials.CreatorDLCOverlayScanline');
	NewModMenu.Overlay.AddItem(Material'HatinTime_CreatorDLC.Materials.CreatorDLCOverlayShine');
	NewModMenu.TabColor = MakeColor(37,155,255);
	NewModMenu.SpecialRenderingMode = 2;
	NewModMenu.EmptyDisplayMode = -1;
	NewModMenu.WorkshopURL = "https://store.steampowered.com/dlc/253230/A_Hat_in_Time/";
	NewModMenu.GameMods.Length = 0;
	for (i = ModList.Length-1; i >= 0; i--)
	{
		if (!ModList[i].Tag_IsDLC) continue;
		
		NewModMenu.GameMods.AddItem(ModList[i]);
	}
	if (`SaveManager.GetNumberOfTimePieces() < 1)
	{
		NewModMenu.GameMods.Length = 0;
		NewModMenu.EmptyDisplayMode = 2;
	}
	ModMenuTabs.AddItem(NewModMenu);
}

function bool AreGameModInfosEqual(GameModInfo InA, GameModInfo InB)
{
	if (InA.IsFeatured != InB.IsFeatured) return false;
	if (InA.IsSubscribed != InB.IsSubscribed) return false;
	if (InA.WorkshopId > 0 && InA.WorkshopId == InB.WorkshopId) return true;
	if (InA.PackageName != "" && locs(InA.PackageName) == locs(InB.PackageName)) return true;
	return false;
}

function RefreshGameModInfos(HUD H, optional bool PreviewOnly)
{
	local Array<GameModInfo> ModList;
	local int i, ModIndex, j;
	
	ModList = class'GameMod'.static.GetModList();
	
	for (ModIndex = 0; ModIndex < ModList.Length; ModIndex++)
	{
		if (!PreviewOnly)
		{
			for (i = 0; i < ModMenuTabs.Length; i++)
			{
				for (j = 0; j < ModMenuTabs[i].GameMods.Length; j++)
				{
					if (!AreGameModInfosEqual(ModMenuTabs[i].GameMods[j], ModList[ModIndex])) continue;
					ModMenuTabs[i].GameMods[j] = ModList[ModIndex];
				}
			}
		}
		/*
		if (Preview)
		{
			`broadcast("Comparing preview (IsFeatured: " $ PreviewMod.IsFeatured $ ", IsSubscribed: " $ PreviewMod.IsSubscribed $ ", WorkshopId: " $ PreviewMod.WorkshopId $ ", PackageName: " $ PreviewMod.PackageName $ ") with mod (IsFeatured: " $ ModList[ModIndex].IsFeatured $ ", IsSubscribed: " $ ModList[ModIndex].IsSubscribed $ ", WorkshopId: " $ ModList[ModIndex].WorkshopId $ ", PackageName: " $ ModList[ModIndex].PackageName $ ")");
		}
		*/
		if (Preview && AreGameModInfosEqual(PreviewMod, ModList[ModIndex]))
		{
			PreviewMod = ModList[ModIndex];
		}
	}
	if (Preview)
		GetReplacementGameModInfo(PreviewMod);
}

function bool DisablePause(HUD H)
{
	return true;
}

function PlaySelectionChangedSound(HUD H)
{
	PlayOwnerSound(H, (ModMenuTabs[CurrentModMenuIndex].SpecialRenderingMode == 2 && CreatorDLCSelectionChangedSound != None) ? CreatorDLCSelectionChangedSound : SelectionChangedSound);
}