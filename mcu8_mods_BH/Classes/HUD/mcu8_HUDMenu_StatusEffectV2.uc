class mcu8_HUDMenu_StatusEffectV2 extends Hat_HUDMenu;
var() string Text;
var() float Timeout;
var() float RemainTime;

function OnOpenHUD(HUD H, optional String command)
{
    local Array<String> strings;
	Super.OnOpenHUD(H, command);
    strings = SplitString(command, "|");
    Text = Repl(strings[1], "[br]", Chr(13)$Chr(10), false);
    Timeout = float(strings[0]);
    RemainTime = Timeout;
}

function bool Render(HUD H)
{
    local float posX, posY, width, height, CountdownTimeLeft;
    if (!Super.Render(H)) return false;
	
    posX = H.Canvas.ClipX/2;
    posY = H.Canvas.ClipY*0.0625+(FMin(H.Canvas.ClipX,H.Canvas.ClipY)*0.02f);//H.Canvas.ClipY*0.45;

    width = FMin(H.Canvas.ClipX, H.Canvas.ClipY)*0.6;
	height = H.Canvas.ClipY*0.125;//3;//width*0.6;

	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont("");

	// dirty way to render text outline
	H.Canvas.SetDrawColor(0,0,0,255);
    
	DrawCenterText(H.Canvas, Text, posX - 0.8, posY + 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	DrawCenterText(H.Canvas, Text, posX - 0.8, posY - 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	
	DrawCenterText(H.Canvas, Text, posX + 0.8, posY + 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	DrawCenterText(H.Canvas, Text, posX + 0.8, posY - 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);

	DrawCenterText(H.Canvas, Text, posX, posY + 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	DrawCenterText(H.Canvas, Text, posX, posY - 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	
	DrawCenterText(H.Canvas, Text, posX + 0.8, posY, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	DrawCenterText(H.Canvas, Text, posX - 0.8, posY, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);

	// finally, draw a proper text...
	H.Canvas.SetDrawColor(255,255,255,255);
	DrawCenterText(H.Canvas, Text, posX, posY, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);

    
    CountdownTimeLeft = RemainTime >= 0 ? FClamp(RemainTime / Timeout,0,1) : 0.f;
	RenderProgressBar(H, posX, posY-Height*0.25, Width*0.8, Height*0.060, CountdownTimeLeft);

    return true;
}

function RenderProgressBar(HUD H, float PosX, float PosY, float Width, float Height, float CountdownTimeLeft)
{
	local int OriginalAlpha;
	
	OriginalAlpha = H.Canvas.DrawColor.A;
	
	H.Canvas.SetDrawColor(0,0,0, OriginalAlpha*0.5f);
	DrawCenter(H, PosX, PosY, Width, Height, H.Canvas.DefaultTexture);
	
	H.Canvas.SetDrawColor(255,255,255, OriginalAlpha);
	DrawCenterLeft(H, PosX + Width*0.5*Lerp(1,-1,CountdownTimeLeft), PosY, Width*CountdownTimeLeft, Height, H.Canvas.DefaultTexture);
	
	H.Canvas.DrawColor.A = OriginalAlpha;
}

function bool Tick(HUD H, float d)
{
	if (!Super.Tick(H, d)) return false;

	if (RemainTime > 0.0)
	{
		RemainTime -= d;
	}

	return true;
}

function bool DisablesMovement(HUD H)
{
	return false;
}

function bool DisablesCameraMovement(HUD H)
{
	return false;
}