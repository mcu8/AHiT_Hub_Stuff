class mcu8_HubSwapper extends Hat_DynamicStaticActor
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

var() Hat_TextRenderComponent TextRenderComponentLine1_Shadow;
var() Hat_TextRenderComponent TextRenderComponentLine2_Shadow;
var() Hat_TextRenderComponent TextRenderComponentLine3_Shadow;

var transient Hat_InteractPoint InteractPoint;

var() Color TextColor;

var() int UpdateTicks;

const PressButtonTime = 0.52;

var() SoundCue Boop;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (InteractPoint == None)
	{
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
	Hat_HUD(Hat_PlayerController(class'Engine'.static.GetEngine().GamePlayers[0].Actor).MyHUD).OpenHUD(class'mcu8_HubMapSelect',,true);
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

		
		TextRenderComponentLine1_Shadow.Text = ModNameLine1;
		TextRenderComponentLine1_Shadow.SetHidden(false);
		ReattachComponent(TextRenderComponentLine1_Shadow);
		TextRenderComponentLine1_Shadow.SetRotation(Rotation);

		TextRenderComponentLine2_Shadow.Text = ModNameLine2;
		TextRenderComponentLine2_Shadow.SetHidden(false);
		ReattachComponent(TextRenderComponentLine2_Shadow);
		TextRenderComponentLine2_Shadow.SetRotation(Rotation);

		TextRenderComponentLine3_Shadow.Text = ModNameLine3;
		TextRenderComponentLine3_Shadow.SetHidden(false);
		ReattachComponent(TextRenderComponentLine3_Shadow);
		TextRenderComponentLine3_Shadow.SetRotation(Rotation);
		UpdateTicks -= 1;
	}
}

defaultproperties 
{
    bStatic = false
    bNoDelete = false

	Begin Object Class=Hat_ModerateLightEnvironmentComponent Name=MyLightEnvironment2
		bIsCharacterLightEnvironment = true
		bDynamic = true;
		bSynthesizeDirectionalLight = false
		bSynthesizeSHLight = false
	End Object
	Components.Add(MyLightEnvironment2)





	Begin Object Class=mcu8_TextRenderComponent_OutlineText Name=TextRenderComponent0
		Translation=(Z=130)
		Size = 0.8f
		TextLimit = 150
		HiddenGame=false
		TextColor=(R=255,G=255,B=255)
		AbsoluteRotation=true
		CastShadow = false
	End Object
	TextRenderComponentLine1 = TextRenderComponent0;
	Components.Add(TextRenderComponent0)

	Begin Object Class=mcu8_TextRenderComponent_OutlineText Name=TextRenderComponent1
		Translation=(Z=145)
		Size = 0.8f
		TextLimit = 150
		HiddenGame=false
		TextColor=(R=255,G=255,B=255)
		AbsoluteRotation=true
		CastShadow = false
	End Object
	TextRenderComponentLine2 = TextRenderComponent1;
	Components.Add(TextRenderComponent1)

	Begin Object Class=mcu8_TextRenderComponent_OutlineText Name=TextRenderComponent2
		Translation=(Z=160)
		Size = 0.8f
		TextLimit = 150
		HiddenGame=false
		TextColor=(R=255,G=255,B=255)
		AbsoluteRotation=true
		CastShadow = false
	End Object
	TextRenderComponentLine3 = TextRenderComponent2;
	Components.Add(TextRenderComponent2)



	Begin Object Class=mcu8_TextRenderComponent_OutlineText Name=TextRenderComponent0_Shadow
		Translation=(Z=130, X=-0.1, Y=-0.1)
		Size = 0.8f
		TextLimit = 150
		HiddenGame=false
		TextColor=(R=0,G=0,B=0)
		AbsoluteRotation=true
		CastShadow = false
		Font=Font'mcu8_content_hubswapper.CurseCasualOutline_Shadow'
	End Object
	TextRenderComponentLine1_Shadow = TextRenderComponent0_Shadow;
	Components.Add(TextRenderComponent0_Shadow)

	Begin Object Class=mcu8_TextRenderComponent_OutlineText Name=TextRenderComponent1_Shadow
		Translation=(Z=145, X=-0.1, Y=-0.1)
		Size = 0.8f
		TextLimit = 150
		HiddenGame=false
		TextColor=(R=0,G=0,B=0)
		AbsoluteRotation=true
		CastShadow = false
		Font=Font'mcu8_content_hubswapper.CurseCasualOutline_Shadow'
	End Object
	TextRenderComponentLine2_Shadow = TextRenderComponent1_Shadow;
	Components.Add(TextRenderComponent1_Shadow)

	Begin Object Class=mcu8_TextRenderComponent_OutlineText Name=TextRenderComponent2_Shadow
		Translation=(Z=160, X=-0.1, Y=-0.1)
		Size = 0.8f
		TextLimit = 150
		HiddenGame=false
		TextColor=(R=0,G=0,B=0)
		AbsoluteRotation=true
		CastShadow = false
		Font=Font'mcu8_content_hubswapper.CurseCasualOutline_Shadow'
	End Object
	TextRenderComponentLine3_Shadow = TextRenderComponent2_Shadow;
	Components.Add(TextRenderComponent2_Shadow)


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
		LightEnvironment = MyLightEnvironment2
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
		LightEnvironment = MyLightEnvironment2
	End Object
	Mesh2=Model1
	Components.Add(Model1)
	TextColor=(R=255,G=255,B=255)

	// Begin Object Class=PointLightComponent Name=PointLightComponent0
	// 	Translation=(Z=40,X=-32)
	//     LightAffectsClassification=LAC_STATIC_AFFECTING
	// 	CastShadows=TRUE
	// 	CastStaticShadows=TRUE
	// 	CastDynamicShadows=FALSE
	// 	bEnabledInEditor=FALSE
	// 	bForceDynamicLight=FALSE
	// 	UseDirectLightMap=TRUE
	// 	bAffectCompositeShadowDirection = FALSE
	// 	CullDistance=3000
	// 	LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,bInitialized=TRUE)
	// 	Brightness=2
	// 	LightColor=(R=250,G=250,B=201)
	// 	Radius=150
	// End Object
	// Components.Add(PointLightComponent0)

	ModNameLine3 = "Change the";
	ModNameLine2 = "current";
	ModNameLine1 = "HUB map";

	UpdateTicks = 100;

	Boop = SoundCue'HatinTime_SFX_Spaceship.AreaMonitor_ActivateUnlock_cue'

//	TickIsDisabledBit[1]=false
}
