/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_SpaceshipPowerPanel extends Actor
    placeable
	dependson(Hat_SeqCond_HasDLC);
	
const ActivatedLevelBit = "HUBPowerPanel";
const PressButtonTime = 0.52;
	
var(Meshes) MeshComponent Mesh;
var(Meshes) MeshComponent CompleteLeft;
var(Meshes) MeshComponent CompleteRight;
var(Meshes) MaterialInterface CompleteMaterial;
var(Data) Hat_ChapterInfo ChapterInfo;
var(Data) Hat_ChapterInfo ChapterInfoBeta;
var(Data) Hat_DoorSpaceship SpaceshipDoor;
var(Data) CrossLevelActive mcu8_ActSelector Telescope;
var(Data) bool ApplyColorize;
//var(Data) HatinTime_DLC RequiredDLC;
var(Camera) Rotator TelescopeUnlockViewRotation;
var transient Hat_InteractPoint InteractPoint;
var transient MaterialInstanceConstant RuntimeMat;
var transient CameraActor TelescopeViewCamera;

var(Sounds) SoundCue UnlockChapterMusic;
var(Sounds) SoundCue ClickMonitorSound;
var(Sounds) SoundCue AttentionBeepSound;
var(Sounds) SoundCue DLCMonitorSound<HideInSimpleEditor>;
var(Particles) ParticleSystemComponent ElectricityParticle[2];
var(Particles) ParticleSystemComponent ActivateParticle;
var(Particles) ParticleSystemComponent ReadyToActivateParticle;

var(Conversation) Hat_ConversationTree UnlockConversationTree;
var(Data) string LocationName;

var transient Pawn PlyInstigator;
//var transient bool WasSilence;
var transient Hat_MusicNodeBlend_Dynamic SilenceMusicNode;
var transient Hat_MusicNodeBlend_Dynamic UnlockChapterMusicNode;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=Model0
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.hub_powerwall_monitor'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = True
		LightingChannels  = (Static=True,Dynamic=True)
		BlockActors=true
		CollideActors=true
		Rotation = (Yaw=-16384)
		Materials(0)=MaterialInstanceConstant'HatinTime_Spaceship.PowerPanels.Materials.PowerPanel_Locked_INST'
	End Object
	Mesh=Model0
	Components.Add(Model0)
	
	Begin Object Class=StaticMeshComponent Name=CompleteLeft0
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.hub_powerwall_door_left'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = True
		LightingChannels  = (Static=True,Dynamic=True)
		BlockActors=false
		CollideActors=false
		Rotation = (Yaw=-16384)
		Translation = (X=7)
		HiddenGame=true
		HiddenEditor=true
	End Object
	CompleteLeft=CompleteLeft0
	Components.Add(CompleteLeft0)
	
	Begin Object Class=StaticMeshComponent Name=CompleteRight0
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.hub_powerwall_door_right'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = True
		LightingChannels  = (Static=True,Dynamic=True)
		BlockActors=false
		CollideActors=false
		Rotation = (Yaw=-16384)
		Translation = (X=7)
		HiddenGame=true
		HiddenEditor=true
	End Object
	CompleteRight=CompleteRight0
	Components.Add(CompleteRight0)
	
	Begin Object Class=ParticleSystemComponent Name=ElectricityParticle0
		Template=ParticleSystem'HatInTime_HUB_Martin.Particles.hub_monitor_electro'
		bAutoActivate=false
		Scale3D=(X=1,Y=1,Z=1)
		Translation = (X=7.2,Z=55.5)
	End Object
	ElectricityParticle(0) = ElectricityParticle0;
	Components.Add(ElectricityParticle0);
	
	Begin Object Class=ParticleSystemComponent Name=ElectricityParticle1
		Template=ParticleSystem'HatInTime_HUB_Martin.Particles.hub_monitor_electro'
		bAutoActivate=false
		Scale3D=(X=1,Y=1,Z=1)
		Translation = (X=7.2,Z=-55.5)
	End Object
	ElectricityParticle(1) = ElectricityParticle1;
	Components.Add(ElectricityParticle1);
	
	Begin Object Class=ParticleSystemComponent Name=ActivateParticle0
		Template=ParticleSystem'HatinTime_Spaceship.Particles.PowerPanel_Activate'
		bAutoActivate=false
		Translation = (X=10)
	End Object
	ActivateParticle = ActivateParticle0;
	Components.Add(ActivateParticle0);
	
	Begin Object Class=ParticleSystemComponent Name=ReadyToActivateParticle0
		Template = ParticleSystem'HatinTime_Spaceship.PowerPanels.Particles.PowerPanelReady'
		bAutoActivate=false
		Translation = (X=2)
	End Object
	ReadyToActivateParticle = ReadyToActivateParticle0;
	Components.Add(ReadyToActivateParticle0);

	bEdShouldSnap=true;
	bCollideActors=true;
	bBlockActors=true;
	bCollideWorld = false;
	bNoDelete = true;
	bNoEncroachCheck = true;
	IgnoreTickWhenHidden = true;
	IgnoreActorCollisionWhenHidden = true;
	UnlockConversationTree = Hat_ConversationTree'HatinTime_Conv_Spaceship.Chapters.ChapterUnlocked'
	UnlockChapterMusic = SoundCue'HatinTime_Music_General.SoundCues.good_job_jingle'
	ClickMonitorSound = SoundCue'HatinTime_SFX_Spaceship.AreaMonitor_ActivateUnlock_cue'
	AttentionBeepSound = SoundCue'HatinTime_SFX_Spaceship.AreaMonitor_AttentionBeep_cue'
	DLCMonitorSound = SoundCue'HatinTime_SFX_Photoshooting.SoundCues.Drawing_Cursor_Confirm_Alternate'
	ApplyColorize = true;
	
	SupportedEvents.Add(class'Hat_SeqEvent_OnInteraction')
	
	CompleteMaterial = Material'HatinTime_Spaceship.PowerPanels.Materials.PowerPanel_Unlocked'
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
	
	RuntimeMat = Mesh.CreateAndSetMaterialInstanceConstant(0);
	
	if (HasBeenActivated())
	{
		if (CompleteMaterial != None)
		{
			Mesh.SetMaterial(0, CompleteMaterial);
			RuntimeMat = Mesh.CreateAndSetMaterialInstanceConstant(0);
		}
		RuntimeMat.SetScalarParameterValue('Unlocked', 1);
		ElectricityParticle[0].SetActive(true);
		ElectricityParticle[1].SetActive(true);
	}
	else if (NeedsDLC())
	{
		if (GetChapterInfo().HasDLCSupported(false))
		{
			if (InteractPoint == None)
			{
				InteractPoint = Spawn(class'Hat_InteractPoint',self,,Location + Vector(Rotation)*10 + vect(0,0,1)*20,Rotation,,true);
				InteractPoint.PushDelegate(OnInteractDelegate);
			}
			RuntimeMat.SetTextureParameterValue('CountTexture', Texture2D'HatinTime_Spaceship.PowerPanels.Textures.ppanel_locked_count_--');
			ElectricityParticle[0].SetActive(true);
			ElectricityParticle[1].SetActive(true);
		}
		else
		{
			SetHidden(true);
		}
	}
    else if (CanBeUnlocked())
	{
		if (InteractPoint == None)
		{
			InteractPoint = Spawn(class'Hat_InteractPoint',self,,Location + Vector(Rotation)*10 + vect(0,0,1)*20,Rotation,,true);
			InteractPoint.PushDelegate(OnInteractDelegate);
		}
		RuntimeMat.SetScalarParameterValue('Unlockable', 1);
		ElectricityParticle[0].SetActive(true);
		ElectricityParticle[1].SetActive(true);
		ReadyToActivateParticle.SetActive(true);
		SetTimer(1.8, true, NameOf(DoAttentionBeep));
	}
}

simulated function Hat_ChapterInfo GetChapterInfo()
{
	if (class'Hat_SeqCond_IsBeta'.static.IsBeta() && ChapterInfoBeta != None)
		return ChapterInfoBeta;
	return ChapterInfo;
}

function bool CanBeUnlocked()
{
	if (!GetChapterInfo().HasDLCSupported(true)) return false;
	return class'Hat_SeqCond_ChapterUnlocked'.static.IsChapterUnlocked(GetChapterInfo());
}

function bool HasBeenActivated()
{
	if (!CanBeUnlocked()) return false;
	return IsPowerPanelActivated(GetChapterInfo());
}

simulated static function bool IsPowerPanelActivated(Hat_ChapterInfo ci)
{
	if (ci == None) return false;
	if (ci.ChapterID <= 0) return false;
	if (!ci.HasDLCSupported(true)) return false;
	if (!class'Hat_SaveBitHelper'.static.HasLevelBit(ActivatedLevelBit, ci.ChapterID, "hub_spaceship")) return false;
	return true;
}

function bool OnInteractDelegate(Hat_InteractPoint point, Pawn p)
{
	local SetRotationGradually srg;
	
	if (Instigator != None) return false;

	ClearTimer(NameOf(ShowDLCSplash));
	
	srg.Rotation = Rotator(Vector(Rotation)*vect(1,1,0)*-1);
	srg.AffectYaw = true;
	srg.AffectPitch = false;
	srg.AffectRoll = false;
	srg.TurnTime = 0.5;
	Hat_PawnCombat(p).SetRotationSequence = srg;
	class'Hat_SeqAct_SetActorRotation'.static.OnSetActorRotation(p, Hat_PawnCombat(p).SetRotationSequence);

	Hat_Player(p).Taunt("Click_Monitor");
	PlyInstigator = p;
	SetTimer(PressButtonTime, false, NameOf(OnDoUnlock));

	if (NeedsDLC()) return true;

	Hat_PlayerController(p.Controller).CoopCriticalCountStack += 1;

	SetTimer(1.15 + PressButtonTime, false, NameOf(ShowTelescopeUnlock));
	SetTimer(1.95 + PressButtonTime, false, NameOf(ShowTelescopeUnlock2));
	SetTimer(3.45 + PressButtonTime, false, NameOf(DisplayUnlockMessage));
	
	if (`GameManager.IsCoop())
	{
		if (Hat_PlayerController(p.Controller).GetOtherPlayer() != None)
			Hat_PlayerController(p.Controller).GetOtherPlayer().SetCinematicMode(true, false, true, true, true, true);

		`GameManager.EnterExclusiveSplitscreen( Hat_PlayerController(p.Controller) );
	}
    return true;
}

function OnDoUnlock()
{
	if (NeedsDLC())
	{
		if (DLCMonitorSound != None)
			PlaySound(DLCMonitorSound);
		if (PlyInstigator.IsA('Hat_Player'))
			Hat_Player(PlyInstigator).PlayVoice(Hat_Player(PlyInstigator).VoiceMonitorClick, 0.5);
		//ActivateParticle.SetActive(true);
		SetTimer(0.6, false, NameOf(ShowDLCSplash));
		return;
	}

	if (CompleteMaterial != None)
	{
		Mesh.SetMaterial(0, CompleteMaterial);
		RuntimeMat = Mesh.CreateAndSetMaterialInstanceConstant(0);
	}
	
	RuntimeMat.SetScalarParameterValue('Unlocked', 1);
	ReadyToActivateParticle.SetActive(false);

	ClearTimer(NameOf(DoAttentionBeep));
	
	InteractPoint.Destroy();
	InteractPoint = None;
	
	if (SpaceshipDoor != None)
	{
		SpaceshipDoor.Enabled = true;
		SpaceshipDoor.ForceOpen = true;
		SpaceshipDoor.Open(None);
		SpaceshipDoor.SetLockedVisuals(false);
	}
	if (ClickMonitorSound != None)
		PlaySound(ClickMonitorSound);
	if (PlyInstigator.IsA('Hat_Player'))
		Hat_Player(PlyInstigator).PlayVoice(Hat_Player(PlyInstigator).VoiceMonitorClick, 2);
		
	//WasSilence = Hat_GameManager(worldinfo.game).MusicManager.IsLayerPlaying(50);
		
	CallInteractionEvent(PlyInstigator);
		
	SilenceMusicNode = new class'Hat_MusicNodeBlend_Dynamic';
	SilenceMusicNode.Music = None;
	SilenceMusicNode.Priority = 99;
	`PushMusicNode(SilenceMusicNode);
	//Hat_GameManager(worldinfo.game).MusicManager.PushActionMusicLayer(None, 99, false, 5,,false);
	ActivateParticle.SetActive(true);
		
	class'Hat_SaveBitHelper'.static.AddLevelBit(ActivatedLevelBit, GetChapterInfo().ChapterID, "hub_spaceship");
	
	// If Mafia Town, this is a new save. Mark the GP machine alert as seen, since we've seen it basically since the game started (its always visible)
	`if(`isdefined(WITH_GHOSTPARTY))
	if (GetChapterInfo().ChapterID == 1)
	{
		class'Hat_IntruderInfo_GhostParty'.static.ConditionalMarkAlertAsSeenOnNewSave();
	}
	`endif
}

function bool NeedsDLC()
{
	/*
	local Hat_GameDLCInfo GameDLCInfo;
	`if(`isdefined(WITH_DLC1))
	return !class'Hat_HUDMenuDLCSplash'.static.HasDLC(RequiredDLC);
	`endif
	*/
	if (!GetChapterInfo().HasDLCSupported(true)) return true;
	//return RequiredDLC != HatinTime_DLC_None;
	return false;
}

function ShowDLCSplash()
{
	`if(`isdefined(WITH_DLC1))
	local Hat_HUDMenuDLCSplash h;
	h = Hat_HUDMenuDLCSplash(Hat_HUD(Hat_PlayerController(PlyInstigator.Controller).MyHUD).OpenHUD(class'Hat_HUDMenuDLCSplash'));
	h.SetDLCInfo(class'Hat_GameDLCInfo'.static.GetGameDLCInfoByClass(GetChapterInfo().RequiredDLC));
	`endif

	Hat_Player(PlyInstigator).EndTaunt();
}

function Rotator GetTelescopeViewCameraRotation()
{
	local Rotator r;
	r = Telescope.Rotation;
	r.Yaw -= 65536/2 + 65536/8;
	r.Pitch = -65536/16;
	r += TelescopeUnlockViewRotation;
	return r;
}

function ShowTelescopeUnlock()
{
	local Rotator r;
	if (Telescope != None)
	{
		r = GetTelescopeViewCameraRotation();
		TelescopeViewCamera = Spawn(class'DynamicCameraActor',,, Telescope.Location - Vector(r)*400 + vect(0,0,30),r,,true);
		PlayerController(PlyInstigator.Controller).SetViewTarget(TelescopeViewCamera);
		
		if (ApplyColorize)
		{
			PlayerController(PlyInstigator.Controller).PlayerCamera.bEnableColorScaling = true;
			PlayerController(PlyInstigator.Controller).PlayerCamera.ColorScale = vect(0.1, 0.1, 0.4);
		}
	}
	Hat_Player(PlyInstigator).EndTaunt();
	Hat_Player(PlyInstigator).Taunt("Victory");

	if (Hat_Player(PlyInstigator).GetOtherPlayer() != None)
		Hat_Player(PlyInstigator).GetOtherPlayer().Taunt("Victory");
}

function ShowTelescopeUnlock2()
{
	if (Telescope != None)
	{
		Telescope.SetUnlocked(true);
	}
	if (ApplyColorize)
		FadeScreenColor(PlayerController(PlyInstigator.Controller), PlayerController(PlyInstigator.Controller).PlayerCamera.ColorScale, vect(1,1,1), 0.5);
}

delegate OnTalkMessageComplete(Controller c, int answer)
{
	SetTimer(0.5, false, NameOf(OnCompleteUnlockAnimation));
	SetTimer(1.5, false, NameOf(OnCompleteUnlockAnimation2));
}

function DisplayUnlockMessage()
{
	local Hat_ConversationTreeInstance tree;
	
	//Hat_GameManager(worldinfo.game).MusicManager.SetLayerActive(99, false);
	if (SilenceMusicNode != None)
		SilenceMusicNode.Stop();
	SilenceMusicNode = None;
	if (UnlockChapterMusic != None)
	{
		UnlockChapterMusicNode = new class'Hat_MusicNodeBlend_Dynamic';
		UnlockChapterMusicNode.Music = UnlockChapterMusic;
		UnlockChapterMusicNode.Priority = 100;
		UnlockChapterMusicNode.BlendTimes[1] = 0; // no fade in
		`PushMusicNode(UnlockChapterMusicNode);
		//Hat_GameManager(worldinfo.game).MusicManager.PushActionMusicLayer(UnlockChapterMusic, 100, false,,,!WasSilence);
	}
	tree = UnlockConversationTree.CreateInstance(self);
	tree.AddKeywordReplacement("chaptername",class'Hat_Localizer'.static.GetGame("levels", GetChapterInfo().ChapterName));
	tree.AddKeywordReplacement("location",class'Hat_Localizer'.static.GetSequence("spaceship", "locations", LocationName));
	
	Hat_PlayerController(PlyInstigator.Controller).TalkManager.PushConversationInstance(tree);
	Hat_PlayerController(PlyInstigator.Controller).TalkManager.PushCompleteDelegate(OnTalkMessageComplete);
	
	PlayerController(PlyInstigator.Controller).PlayerCamera.bEnableColorScaling = false;
}

function OnCompleteUnlockAnimation()
{
	PlayerController(PlyInstigator.Controller).SetViewTarget(PlyInstigator);
	Hat_PlayerController(PlyInstigator.Controller).CoopCriticalCountStack -= 1;
	if (TelescopeViewCamera != None)
		TelescopeViewCamera.Destroy();

	if (`GameManager.IsCoop())
	{
		if (Hat_PlayerController(PlyInstigator.Controller).GetOtherPlayer() != None)
			Hat_PlayerController(PlyInstigator.Controller).GetOtherPlayer().SetCinematicMode(false, false, true, true, true, true);

		`GameManager.ExitExclusiveSplitscreen();
	}
}

function OnCompleteUnlockAnimation2()
{
	Hat_Player(PlyInstigator).EndTaunt();

	if (Hat_Player(PlyInstigator).GetOtherPlayer() != None)
		Hat_Player(PlyInstigator).GetOtherPlayer().EndTaunt();
	
	if (UnlockChapterMusic != None)
	{
		/*
		if (WasSilence)
			Hat_GameManager(worldinfo.game).MusicManager.DestroySyncGroup(Hat_GameManager(worldinfo.game).MusicManager.GetLayer(0).Music);
		*/
		if (UnlockChapterMusicNode != None)
			UnlockChapterMusicNode.Stop();
		UnlockChapterMusicNode = None;
		//Hat_GameManager(worldinfo.game).MusicManager.SetLayerActive(100, false);
	}
	ActivateParticle.SetActive(false);
}

function FadeScreenColor(PlayerController pc, Vector StartV, Vector EndV, float Time)
{
	local Camera c;
	c = PlayerController(PlyInstigator.Controller).PlayerCamera;
	c.bEnableColorScaling = true;
	c.ColorScale = EndV;
	c.bEnableColorScaleInterp = true;
	c.DesiredColorScale = EndV;
	c.OriginalColorScale = StartV;
	c.ColorScaleInterpDuration = Time;
	c.ColorScaleInterpStartTime = Worldinfo.TimeSeconds;
}

function bool CallInteractionEvent(Actor other, optional string command = "")
{
    local int idx;
	local Hat_SeqEvent_OnInteraction hEvent;
    local bool s;
    
    s = false;

	// search for any events
	for (idx = 0; idx < GeneratedEvents.Length; idx++)
	{
		hEvent = Hat_SeqEvent_OnInteraction(GeneratedEvents[idx]);
		if (hEvent == None) continue;
		
		// notify that we have a interaction event
		if (!hEvent.HandleInteraction(self, other, command)) continue;
		s = true;
	}
    return s;
}

function OnGoToStateAct(Hat_SeqAct_GoToState a)
{
    if (a.State == 'complete')
    {
        CompleteLeft.SetHidden(false);
        CompleteRight.SetHidden(false);
		ClearTimer(NameOf(DoAttentionBeep));
		if (InteractPoint != None)
			InteractPoint.Destroy();
		InteractPoint = None;
		if (SpaceshipDoor != None)
			SpaceshipDoor.SetLockedVisuals(false, true);
		ElectricityParticle[0].SetActive(false);
		ElectricityParticle[1].SetActive(false);
		ReadyToActivateParticle.SetActive(false);
		return;
    }
    `Broadcast("" $ self $ ": Unknown state " $ a.State);
}

function DoAttentionBeep()
{
	if (AttentionBeepSound != None)
		PlaySound(AttentionBeepSound);
}