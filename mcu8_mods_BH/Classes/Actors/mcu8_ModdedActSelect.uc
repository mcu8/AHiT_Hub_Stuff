/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_ModdedActSelect extends Hat_ActSelector
    placeable
	dependson(Hat_SeqAct_SetActorRotation);

var(Data) string ChapterInfoName;
var(Data) string ModChapterPackage;
var(Data) string ModName;

var() string ModNameLine1;
var() string ModNameLine2;
var() string ModNameLine3;

var() Hat_TextRenderComponent TextRenderComponentLine1;
var() Hat_TextRenderComponent TextRenderComponentLine2;
var() Hat_TextRenderComponent TextRenderComponentLine3;

var transient mcu8_ObjectiveActor_ModIcon ObjectiveActor;

var() Texture2D Sprite;
var() GameModInfo BaseGameMod;

var() Color TextColor;

simulated event PostBeginPlay()
{
	local Rotator r;
	
    Super.PostBeginPlay();
	
	OriginalLocation = Location;
	
    CacheActsAvailable();
	
    if (InteractPoint == None)
	{
		InteractPoint = Spawn(class'Hat_InteractPoint',self,,Location + vect(0,0,1)*90,Rotation,,true);
		InteractPoint.PushDelegate(OnInteractDelegate);
	}
	if (PeekCameraActor == None)
	{
		r = Rotation;
		r.Pitch += ScopeRotation.Pitch*0.6;
		PeekCameraActor = Spawn(class'DynamicCameraActor',,, Location - Vector(r)*60 + vect(0,0,85),r,,true);
	}
		
	if (Worldinfo.Netmode == NM_Standalone || Role == Role_Authority)
	{
		SetTimer(1.5, true, NameOf(DoSmallBounceAnimation));
		CreateTimeRiftParticles();
	}
}

simulated event Tick(float d)
{   
	// nope
	//Super.Tick(d);

    //TextRenderComponent.TextColor = LinearColorToColor(PlayerState.PlayerColor);
	TextRenderComponentLine1.Text = ModNameLine1;
	TextRenderComponentLine1.TextColor = TextColor;
	TextRenderComponentLine1.SetHidden(false);
	ReattachComponent(TextRenderComponentLine1);
	TextRenderComponentLine1.SetRotation(Rotation);

	TextRenderComponentLine2.Text = ModNameLine2;
	TextRenderComponentLine2.TextColor = TextColor;
	TextRenderComponentLine2.SetHidden(false);
	ReattachComponent(TextRenderComponentLine2);
	TextRenderComponentLine2.SetRotation(Rotation);

	TextRenderComponentLine3.Text = ModNameLine3;
	TextRenderComponentLine3.TextColor = TextColor;
	TextRenderComponentLine3.SetHidden(false);
	ReattachComponent(TextRenderComponentLine3);
	TextRenderComponentLine3.SetRotation(Rotation);

	if (BounceAnimation >= 0)
		UpdateBounceAnimation(d);
	
	if (SquishAnimation > 0)
	{
		SquishAnimation = FMax(SquishAnimation- d*1.7,0);
		SetDrawScale3D(GetSquishScale(SquishAnimation));
	}
	
	//UpdateTimeRifts();

	if (ObjectiveActor == None)
	{
		ShowObjectiveActor(true);
	}
}

simulated function ShowObjectiveActor(bool show)
{
	if (show && bHidden) return;
	//if (show && PlayerState != None && PlayerState.IsPublic) return;
	if (show && ObjectiveActor != None) return;
	if (!show && ObjectiveActor == None) return;

	if (show)
	{
		ObjectiveActor = Spawn(class'mcu8_ObjectiveActor_ModIcon',,, Location+vect(0,0,240), Rotation);
		ObjectiveActor.SetBase(self);

		// query icon only if it needed
		if (Sprite == None)
		{
			Sprite = class'GameMod'.static.GetModIcon(BaseGameMod);
			if (Sprite == None) Sprite = Texture2D'HatinTime_GhostParty.Textures.noavatar';
		}

		ObjectiveActor.SetModIcon(Sprite);
		//ObjectiveActor.OcclusionComponents.AddItem(SkeletalMeshComponent);
	}
	else
	{
		ObjectiveActor.Destroy();
		ObjectiveActor = None;
	}
}

simulated function OnActivated(Pawn p)
{ 
    local PlayerController pc;
	local SetRotationGradually srg;
	
	if (DependentActor != None && !DependentActor.bDeleteMe && !DependentActor.bHidden) return;

	if (Hat_Player(p) != None && Worldinfo.Netmode != NM_Standalone && Role == Role_Authority)
		Hat_Player(p).ActSelectorOnActivated(self, p);
	
    pc = PlayerController(p.Controller);
	
	pc.SetViewTargetWithBlend(PeekCameraActor, CameraTransitionTime*0.7);
	SetCinematicMode(true);
	
	srg.Rotation = PeekCameraActor.Rotation;
	srg.AffectYaw = true;
	srg.AffectPitch = true;
	srg.AffectRoll = true;
	srg.TurnTime = CameraTransitionTime*0.4;
	Hat_PlayerController(pc).SetRotationSequence = srg;
	class'Hat_SeqAct_SetActorRotation'.static.OnSetActorRotation(pc, Hat_PlayerController(pc).SetRotationSequence);

	LastPlayer = pc;
	PlaySound(LookIntoSound,true);

	SetTimer(CameraTransitionTime*0.5, false, NameOf(StartFadeOut));
	SetTimer(CameraTransitionTime + 0.01, false, NameOf(OpenActSelectMenu));
}

simulated function StartFadeOut()
{
	class'Hat_HUD'.static.FadeOutAllPlayers(CameraTransitionTime*0.5, 0);
}

simulated function OpenActSelectMenu()
{
	LastPlayer.SetCinematicMode(false, false, true, true, true, true);
	`GameManager.LoadNewAct(99);
	HudMenuSelect = OpenActSelectMenuStatic(LastPlayer, GetChapterInfo(), ModChapterPackage, ActSelectCameraActor);
	LastPlayer.SetRotation(Rotation + ExitCameraRotationOffset);
	LastPlayer = None;
}

simulated static function Hat_HUDMenuActSelect OpenActSelectMenuStatic(PlayerController InPlayer, Hat_ChapterInfo InChapterInfo, optional string ModChapterPackageName, optional out CameraActor InActSelectCameraActor)
{
	local Hat_HUDMenuActSelect he;
	local CameraActor ca;
	
	he = None;
	if (InPlayer == None) return None;
	
	if (InPlayer.MyHUD == None && class'Worldinfo'.static.GetWorldInfo().Netmode != NM_Standalone)
	{
		if (InActSelectCameraActor == None)
		{
			foreach class'Worldinfo'.static.GetWorldInfo().AllActors(class'CameraActor',ca)
			{
				if (ca.Tag != 'ActSelectCameraActor') continue;
				
				InActSelectCameraActor = ca;	
				break;
			}
		}
		InPlayer.SetViewTarget(InActSelectCameraActor);
	}
	if (InPlayer.MyHUD != None)
	{
		he = Hat_HUDMenuActSelect(Hat_HUD(InPlayer.MyHUD).OpenHUD(class'Hat_HUDMenuActSelect'));
		he.SetChapterInfo(InPlayer.MyHUD, InChapterInfo, ModChapterPackageName);
		Hat_HUD(InPlayer.MyHUD).FadeIn(0.4, 0);
	}

	Hat_PlayerCamera(InPlayer.PlayerCamera).SetCameraDistance(300, true);
	return he;
}

simulated function SetUnlocked(bool b)
{
	SetHidden(!b);
	InteractPoint.Enabled = b;
	//SetTickIsDisabled(!b);
	
	if (b)
	{
		if (AppearSound != None)
			PlaySound(AppearSound, true);
		if (RevealParticle != None)
			RevealParticle.SetActive(true);
		BounceAnimation = 0;
		DoBounceAnimation();
		
		SetTimer(1.5, true, NameOf(DoSmallBounceAnimation));
	}
}

simulated function int GetActsAvailable()
{
    return MaxUnlockedAct;
}

simulated function Hat_ChapterInfo GetChapterInfo()
{
	local Hat_ChapterInfo ci;
	ci = class'Hat_ClassHelper'.static.LoadObject(class'Hat_ChapterInfo', ChapterInfoName);
	if (ci == None)
	{
		`broadcast("ChapterInfo is None");
		return None;
	}
	return ci;
}

simulated function bool IsUnlocked()
{
	return true;
}

simulated function bool HasTimePiece(string s)
{
	return Worldinfo.game != None && Hat_GameManager(worldinfo.game).HasTimePiece(s);
}

simulated function CacheActsAvailable()
{
    local int i;
	for (i = 0; i < TelescopeLenses.Length; i++)
	{
		TelescopeLenses[i].SetHidden(false);
	}
}

simulated function bool OnInteractDelegate(Hat_InteractPoint point, Pawn p)
{
	local Hat_CoopPlayerSync Sync;

	SyncDataPawn = p;
	
	Sync = Spawn(class'Hat_CoopPlayerSync', p,, p.Location, p.Rotation,, true);
	Sync.OnCoopPlayerSyncComplete = OnCoopPlayerSyncComplete;
	Sync.SkipFadeOut = true;
	Sync.NoTeleport = true;
	Sync.StartPlayerSync(Hat_Player(p).GetOtherPlayer());
	
    return true;
}

simulated function OnCoopPlayerSyncComplete()
{
	OnActivated(SyncDataPawn);
}

simulated function SetTelescopeRotation(Rotator r)
{
	local int i;
	local Rotator r2;
	local Vector offset;
	
	//r2.Pitch = r.Roll*-1;
	r2 = r;
	//r2.Yaw += 65536/4;
	offset = vect(0,0,48);
	
	TelescopeScope.SetRotation(r);
	for (i = 0; i < TelescopeLenses.Length; i++)
	{
		TelescopeLenses[i].SetRotation(r);
		TelescopeLenses[i].SetTranslation(TransformVectorByRotation(r2, TelescopeLenses[i].default.Translation - offset) + offset);
	}
}

simulated function UpdateBounceAnimation(float d)
{
	local float bv, BouncePi;
	local Vector loc;
	local Rotator r;
	BounceAnimation += d*(4/BounceAnimationCount);
	BounceAnimation = FMin(BounceAnimation, 1.0);
	
	BouncePi = BounceAnimation*Pi*BounceAnimationCount;
	bv = Abs(Sin(BouncePi))*BounceAnimationScale;
	
	loc = OriginalLocation + vect(0,0,1)*bv*50*(1.0-BounceAnimation);
	
	r.Yaw = TelescopeScope.default.Rotation.Yaw;
	r.Pitch = 65536/12 * Cos(BouncePi*1)*(1.0-BounceAnimation)*BounceAnimationScale + ScopeRotation.Pitch;
	
	Move(Loc - Location);
	if (BounceAnimation <= 0.1)
		r = RLerp(TelescopeScope.Rotation, r, BounceAnimation/0.1, true);
	SetTelescopeRotation(r);
	
	if (BounceAnimation >= 1.0)
		BounceAnimation = -1;
}

simulated function DoSmallBounceAnimation()
{
	local Hat_BenchCinematics bc;
	
	if (PreventBouncing) return;
	
	if (!DoBounceAnimation(0.5, 3))
		return;
	
	// Don't play bounce sound if we're in bench cinematic
	foreach DynamicActors(class'Hat_BenchCinematics', bc)
		return;
	
	if (SmallBounceSound != None)
		PlaySound(SmallBounceSound, true);
}

simulated function bool DoBounceAnimation(optional float scale = 1.0, optional int count = 4)
{
	if (BounceAnimation > 0) return false;
	BounceAnimation = 0;
	BounceAnimationScale = scale;
	BounceAnimationCount = count;
	return true;
}


event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	BounceAnimation = 0;
	DoBounceAnimation();
	if (HitSound != None)
		PlaySound(HitSound, true);
}


simulated function SetCinematicMode(bool active)
{
	local Hat_PlayerController pc;

	foreach DynamicActors(class'Hat_PlayerController', pc)
	{
		pc.SetCinematicMode(active, false, true, true, true, true);
	}
}

simulated function int GetTimeRiftCount()
{
	return 0;
}

simulated function CreateTimeRiftParticles()
{	
}

simulated function UpdateTimeRifts()
{
}

simulated function Vector GetSquishScale(float b)
{
    local Vector vScale;
    vScale.X = 1 - cos(b*Pi*2*4)*b*0.45;
	vScale.X = FMax(vScale.X, 0.01);
    vScale.Y = vScale.X;
    vScale.Z = 1 + cos(b*Pi*2*4)*b*0.3;
	vScale.Z = FMax(vScale.Z, 0.01);
	return vScale;
}

simulated function DoSquishAnimation()
{
	SquishAnimation = 1;
}

simulated function StopPreventBouncing()
{
	PreventBouncing = false;
}

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
	if (ProximityCylinder != None && ProximityMusicParameter != '' && Other.IsA('Hat_Player'))
	{
		`SetMusicParameterInt(ProximityMusicParameter, 1);
	}
	
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

simulated event UnTouch( Actor Other)
{
	if (ProximityCylinder != None && ProximityMusicParameter != '' && Other.IsA('Hat_Player'))
	{
		`SetMusicParameterInt(ProximityMusicParameter, 0);
	}
	Super.UnTouch(Other);
}

defaultproperties 
{
    bStatic = false
    bNoDelete = false
	Components.Empty

	Begin Object Class=Hat_ModerateLightEnvironmentComponent Name=MyLightEnvironment
		bIsCharacterLightEnvironment = true
		bDynamic = true;
		bSynthesizeDirectionalLight = false
		bSynthesizeSHLight = false
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=StaticMeshComponent Name=MyModel0
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.telescope.telescope_feet'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = false
		LightingChannels = (Static = false, Dynamic = true)
		BlockActors=false
		CollideActors=false
		LightEnvironment=MyLightEnvironment
	End Object
	Mesh=MyModel0
	Components.Add(MyModel0)

	Begin Object Class=StaticMeshComponent Name=MyModel1
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.telescope.telescope_main'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = false
		LightingChannels = (Static = false, Dynamic = true)
		Translation=(Z=46)
		BlockActors=false
		CollideActors=false
		LightEnvironment=MyLightEnvironment
	End Object
	TelescopeScope=MyModel1
	Components.Add(MyModel1)
	
	Begin Object Class=StaticMeshComponent Name=MyTelescopeLens1
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.telescope.telescope_lens_01'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = false
		LightingChannels = (Static = false, Dynamic = true)
		Translation=(Z=77, X=24)
		BlockActors=false
		CollideActors=false
		LightEnvironment=MyLightEnvironment
	End Object
	TelescopeLenses(0)=MyTelescopeLens1
	Components.Add(MyTelescopeLens1)
	
	Begin Object Class=StaticMeshComponent Name=MyTelescopeLens2
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.telescope.telescope_lens_02'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = false
		LightingChannels = (Static = false, Dynamic = true)
		Translation=(Z=77, X=33)
		BlockActors=false
		CollideActors=false
		LightEnvironment=MyLightEnvironment
	End Object
	TelescopeLenses(1)=MyTelescopeLens2
	Components.Add(MyTelescopeLens2)
	
	Begin Object Class=StaticMeshComponent Name=MyTelescopeLens3
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.telescope.telescope_lens_03'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = false
		LightingChannels = (Static = false, Dynamic = true)
		Translation=(Z=77, X=42)
		BlockActors=false
		CollideActors=false
		LightEnvironment=MyLightEnvironment
	End Object
	TelescopeLenses(2)=MyTelescopeLens3
	Components.Add(MyTelescopeLens3)
	
	Begin Object Class=StaticMeshComponent Name=MyTelescopeLens4
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.telescope.telescope_lens_04'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = false
		LightingChannels = (Static = false, Dynamic = true)
		Translation=(Z=77, X=54)
		BlockActors=false
		CollideActors=false
		LightEnvironment=MyLightEnvironment
	End Object
	TelescopeLenses(3)=MyTelescopeLens4
	Components.Add(MyTelescopeLens4)
	
	Begin Object Class=StaticMeshComponent Name=MyTelescopeLens5
		StaticMesh=StaticMesh'HatInTime_HUB_H.models.telescope.telescope_lens_05'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = false
		LightingChannels = (Static = false, Dynamic = true)
		Translation=(Z=77, X=70)
		BlockActors=false
		CollideActors=false
		LightEnvironment=MyLightEnvironment
	End Object
	TelescopeLenses(4)=MyTelescopeLens5
	Components.Add(MyTelescopeLens5)
	
	CollisionComponent = CollisionCylinder;
	Components.Add(CollisionCylinder)
	
	ProximityCylinder = ProximityCylinder0;
	Components.Add(ProximityCylinder0)
	
	Components.Add(RevealParticle0);
	RevealParticle = RevealParticle0;

	Begin Object Class=Hat_TextRenderComponent Name=TextRenderComponent0
		Translation=(Z=160)
		Size = 0.8f
		TextLimit = 255
		HiddenGame=false
		TextColor=(R=255,G=255,B=255)
		AbsoluteRotation=true
		CastShadow = false
	End Object
	TextRenderComponentLine1 = TextRenderComponent0;
	Components.Add(TextRenderComponent0)

	Begin Object Class=Hat_TextRenderComponent Name=TextRenderComponent1
		Translation=(Z=175)
		Size = 0.8f
		TextLimit = 255
		HiddenGame=false
		TextColor=(R=255,G=255,B=255)
		AbsoluteRotation=true
		CastShadow = false
	End Object
	TextRenderComponentLine2 = TextRenderComponent1;
	Components.Add(TextRenderComponent1)

	Begin Object Class=Hat_TextRenderComponent Name=TextRenderComponent2
		Translation=(Z=190)
		Size = 0.8f
		TextLimit = 255
		HiddenGame=false
		TextColor=(R=255,G=255,B=255)
		AbsoluteRotation=true
		CastShadow = false
	End Object
	TextRenderComponentLine3 = TextRenderComponent2;
	Components.Add(TextRenderComponent2)

	TextColor=(R=255,G=255,B=255)
}
