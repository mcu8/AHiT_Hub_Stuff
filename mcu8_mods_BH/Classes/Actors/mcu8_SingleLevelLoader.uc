class mcu8_SingleLevelLoader extends Hat_DynamicStaticActor
	placeable;

var() string Map;
var() string PackageName;

var() string ModName;

var() string ModNameLine1;
var() string ModNameLine2;
var() string ModNameLine3;

var() StaticMeshComponent Mesh;
var() StaticMeshComponent Mesh2;

var() Hat_TextRenderComponent TextRenderComponentLine1;
var() Hat_TextRenderComponent TextRenderComponentLine2;
var() Hat_TextRenderComponent TextRenderComponentLine3;

var() Texture2D Sprite;
var() GameModInfo BaseGameMod;

var transient Hat_InteractPoint InteractPoint;

var transient mcu8_ObjectiveActor_ModIcon ObjectiveActor;

var() Color TextColor;

const PressButtonTime = 0.52;

var() SoundCue Boop;

var() int UpdateTicks;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (InteractPoint == None)
	{
		//vect(-5,-22,40)
		InteractPoint = Spawn(class'Hat_InteractPoint',self,,Location + vect(0,0,40),Rotation,,true);
		InteractPoint.PushDelegate(OnInteractDelegate);
		InteractPoint.Enabled = true;
	}
}

simulated function bool OnInteractDelegate(Hat_InteractPoint point, Pawn hOther)
{
	local PlayerTauntInfo PTI;

	if (!hOther.IsA('Hat_Player')) return false;
    if (hOther.Physics != Phys_Walking) return false;

	ClearTimer(NameOf(AfterBoop));

    PTI.TauntDuration = 1.5;
    PTI.PlayerCanExit = false;

    Hat_Player(hOther).Taunt("Click_Monitor", PTI);
	if (Boop != None)
		PlaySound(Boop);
	Hat_Player(hOther).PlayVoice(Hat_Player(hOther).VoiceMonitorClick, 2);
    Hat_Player(hOther).SetExpression(Hat_Player(hOther).ExpressionComponent.EExpressionType.EExpressionType_Surprised, 3.0f);
	
	SetTimer(1.15 + PressButtonTime, false, NameOf(AfterBoop));
    return true;
}

function AfterBoop() {
	`if(`isdefined(WITH_GHOSTPARTY))
	local Hat_HUDElementGhostPartyJoinAct JoinHUD;
	`endif
	`GameManager.LoadNewAct(99);
	`if(`isdefined(WITH_GHOSTPARTY))
	if (class'Hat_GhostPartyPlayerStateBase'.static.HasNonLocalPrivatePlayerStates(true))
	{
		JoinHUD = Hat_HUDElementGhostPartyJoinAct(Hat_HUD(Hat_PlayerController(class'Engine'.static.GetEngine().GamePlayers[0].Actor).MyHUD).OpenHUD(class'Hat_HUDElementGhostPartyJoinAct',,true));
		JoinHUD.HostJoinAct(None, Name(Map), Name(PackageName), ModName);
		return;
	}
	`endif

	`GameManager.SoftChangeLevel(Map);
	class'GameMod'.static.SetActiveLevelMod(PackageName);

}

simulated function ShowObjectiveActor(bool show)
{
	if (show && bHidden) return;
	//if (show && PlayerState != None && PlayerState.IsPublic) return;
	if (show && ObjectiveActor != None) return;
	if (!show && ObjectiveActor == None) return;

	if (show)
	{
		/*vect*/
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

simulated event Tick(float d)
{
	Super.Tick(d);

	if (UpdateTicks > 0)
	{
		TextRenderComponentLine1.Text = ModNameLine1;
		TextRenderComponentLine1.TextColor = TextColor;
		TextRenderComponentLine1.SetHidden(false);
		ReattachComponent(TextRenderComponentLine1);
		TextRenderComponentLine1.SetRotation(Rotation);

		TextRenderComponentLine2.Text = ModNameLine2;
		TextRenderComponentLine2.SetHidden(false);
		TextRenderComponentLine2.TextColor = TextColor;
		ReattachComponent(TextRenderComponentLine2);
		TextRenderComponentLine2.SetRotation(Rotation);

		TextRenderComponentLine3.Text = ModNameLine3;
		TextRenderComponentLine3.TextColor = TextColor;
		TextRenderComponentLine3.SetHidden(false);
		ReattachComponent(TextRenderComponentLine3);
		TextRenderComponentLine3.SetRotation(Rotation);
		UpdateTicks -= 1;
	}

	if (ObjectiveActor == None)
	{
		ShowObjectiveActor(true);
	}
}

defaultproperties 
{
    bStatic = false
    bNoDelete = false

	Begin Object Class=Hat_ModerateLightEnvironmentComponent Name=MyLightEnvironment5
		bIsCharacterLightEnvironment = true
		bDynamic = true;
		bSynthesizeDirectionalLight = false
		bSynthesizeSHLight = false
	End Object
	Components.Add(MyLightEnvironment5)

	Begin Object Class=Hat_TextRenderComponent Name=TextRenderComponent0
		Translation=(Z=130)
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
		Translation=(Z=145)
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
		Translation=(Z=160)
		Size = 0.8f
		TextLimit = 255
		HiddenGame=false
		TextColor=(R=255,G=255,B=255)
		AbsoluteRotation=true
		CastShadow = false
	End Object
	TextRenderComponentLine3 = TextRenderComponent2;
	Components.Add(TextRenderComponent2)
	
	Begin Object Class=StaticMeshComponent Name=Model0
		Translation=(Z=40,X=-18)
		StaticMesh=StaticMesh'HatInTime_Levels_Science_H.models.science_train_front_red_button'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = false
		LightingChannels = (Static = false, Dynamic = true)
		BlockActors=true
		CollideActors=true
		Rotation=(Roll=-16384,Yaw=-16384)
		LightEnvironment = MyLightEnvironment5
	End Object
	Mesh=Model0
	Components.Add(Model0)

	Begin Object Class=StaticMeshComponent Name=Model1
		StaticMesh=StaticMesh'HatinTime_Habboi.models.Stone'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		bUsePrecomputedShadows = false
		LightingChannels = (Static = false, Dynamic = true)
		BlockActors=true
		CollideActors=true
		LightEnvironment = MyLightEnvironment5
	End Object
	Mesh2=Model1
	Components.Add(Model1)
	TextColor=(R=255,G=255,B=255)

	UpdateTicks = 100;

	Boop = SoundCue'HatinTime_SFX_Spaceship.AreaMonitor_ActivateUnlock_cue'

//	TickIsDisabledBit[1]=false
}
