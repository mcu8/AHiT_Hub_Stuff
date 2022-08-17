class mcu8_Note extends Actor
	placeable;

var() String Text;
var mcu8_TextRenderComponent_OutlineText TextCmp;
var mcu8_TextRenderComponent_OutlineText TextCmp_Shadow;

simulated event PostBeginPlay()
{	
    Super.PostBeginPlay();

	SetText(Text);
}

function SetText(String textVal)
{
	Text = textVal;

	TextCmp.Text = Text;
	TextCmp.SetHidden(false);
	ReattachComponent(TextCmp);

	TextCmp_Shadow.Text = Text;
	TextCmp_Shadow.SetHidden(false);
	ReattachComponent(TextCmp_Shadow);

	ForceUpdateComponents();
}

defaultproperties
{
	Begin Object Class=mcu8_TextRenderComponent_OutlineText Name=TextRenderComponent10
		//Translation=(X=-0.1)
		PropertyName_Text = "Text"
		TextLimit = 150
		HiddenGame=false
		TextColor=(R=255,G=255,B=255)
		MaxDrawDistance = 9000
	End Object
	Components.Add(TextRenderComponent10)
	TextCmp = TextRenderComponent10;

	Begin Object Class=mcu8_TextRenderComponent_OutlineText Name=TextRenderComponent10_Shadow
		Translation=(X=-0.1)
		PropertyName_Text = "Text"
		TextLimit = 150
		Font=Font'mcu8_content_hubswapper.CurseCasualOutline_Shadow'
		HiddenGame=false
		TextColor=(R=0,G=0,B=0)
		MaxDrawDistance = 9000
	End Object
	Components.Add(TextRenderComponent10_Shadow)
	TextCmp_Shadow = TextRenderComponent10_Shadow;

	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=150,G=200,B=255)
		ArrowSize=0.5
		bTreatAsASprite=True
		HiddenGame=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Notes"
	End Object
	Components.Add(Arrow)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Note'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Notes"
	End Object
	Components.Add(Sprite)

	bStatic=false
	bNoDelete=false
	bMovable=false
	bRouteBeginPlayEvenIfStatic=false
    IgnoreTickWhenHidden = true;
}