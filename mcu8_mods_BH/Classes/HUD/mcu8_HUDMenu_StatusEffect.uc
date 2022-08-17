class mcu8_HUDMenu_StatusEffect extends Hat_HUDElementFancy;
var() string Text;
var transient float TimeOutCountdown;
var int CountdownTime;

function OnOpenHUD(HUD H, optional String command)
{
	local Array<String> strings;
	Super.OnOpenHUD(H, command);
	strings = SplitString(command, "|");
    Text = strings[1];
	CountdownTime = int(strings[0]);
	TimeOutCountdown = CountdownTime;
	WantsTick = true;
	ForceAppear(2.5, 25);
}

function bool Render(HUD H)
{
	local float width, height, posx, posy;
	local float CountdownTimeLeft;
    if (!Super.Render(H)) return false;

	width = FMin(H.Canvas.ClipX, H.Canvas.ClipY)*0.6;
	height = width*0.6;

	width *= 0.7f;
	height *= 0.7f;
	posx = 2.6;//H.Canvas.ClipX - width*0.5 - width*0.1;
	posy = 2.6;

	H.Canvas.SetDrawColor(255,255,255, H.Canvas.DrawColor.A);
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(Text);
	DrawBorderedText(H.Canvas, Text, posx, posy-Height*0.39, width*0.0016, false, TextAlign_Center);
	
	CountdownTimeLeft = TimeOutCountdown >= 0 ? FClamp(TimeOutCountdown / CountdownTime,0,1) : 0.f;
	RenderStatusEffect(H, PosX, PosY-Height*0.25, Width*0.8, Height*0.015, CountdownTimeLeft);

    return true;
}

function bool Tick(HUD H, float d)
{
	if (!Super.Tick(H, d)) return false;

	if (TimeOutCountdown > 0.0)
	{
		TimeOutCountdown -= d;
	}

	return true;
}

function RenderStatusEffect(HUD H, float PosX, float PosY, float Width, float Height, float CountdownTimeLeft)
{
	local int OriginalAlpha;
	
	OriginalAlpha = H.Canvas.DrawColor.A;
	
	H.Canvas.SetDrawColor(0,0,0, OriginalAlpha*0.5f);
	DrawCenter(H, PosX, PosY, Width, Height, H.Canvas.DefaultTexture);
	
	H.Canvas.SetDrawColor(255,255,255, OriginalAlpha);
	DrawCenterLeft(H, PosX + Width*0.5*Lerp(1,-1,CountdownTimeLeft), PosY, Width*CountdownTimeLeft, Height, H.Canvas.DefaultTexture);
	
	H.Canvas.DrawColor.A = OriginalAlpha;
}

defaultproperties {
	SharedInCoop = false;
	WantsTick = true;
}