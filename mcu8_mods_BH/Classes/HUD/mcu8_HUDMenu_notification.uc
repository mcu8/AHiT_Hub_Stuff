class mcu8_HUDMenu_notification extends Hat_HUDMenu;
var() string Text;

function OnOpenHUD(HUD H, optional String command)
{
	Super.OnOpenHUD(H, command);
    Text = Repl(command, "[br]", Chr(13)$Chr(10), false);
}

function bool Render(HUD H)
{
    if (!Super.Render(H)) return false;
	
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont("");

	// dirty way to render text outline
	H.Canvas.SetDrawColor(0,0,0,255);
	DrawCenterText(H.Canvas, Text, H.Canvas.ClipX/2 - 0.8, H.Canvas.ClipY*0.45 + 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	DrawCenterText(H.Canvas, Text, H.Canvas.ClipX/2 - 0.8, H.Canvas.ClipY*0.45 - 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	
	DrawCenterText(H.Canvas, Text, H.Canvas.ClipX/2 + 0.8, H.Canvas.ClipY*0.45 + 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	DrawCenterText(H.Canvas, Text, H.Canvas.ClipX/2 + 0.8, H.Canvas.ClipY*0.45 - 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);

	DrawCenterText(H.Canvas, Text, H.Canvas.ClipX/2, H.Canvas.ClipY*0.45 + 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	DrawCenterText(H.Canvas, Text, H.Canvas.ClipX/2, H.Canvas.ClipY*0.45 - 0.8, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	
	DrawCenterText(H.Canvas, Text, H.Canvas.ClipX/2 + 0.8, H.Canvas.ClipY*0.45, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
	DrawCenterText(H.Canvas, Text, H.Canvas.ClipX/2 - 0.8, H.Canvas.ClipY*0.45, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);

	// finally, draw a proper text...
	H.Canvas.SetDrawColor(255,255,255,255);
	DrawCenterText(H.Canvas, Text, H.Canvas.ClipX/2, H.Canvas.ClipY*0.45, 0.4*H.Canvas.ClipY * 0.06 * 0.03, 0.4*H.Canvas.ClipY * 0.06 * 0.03);
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