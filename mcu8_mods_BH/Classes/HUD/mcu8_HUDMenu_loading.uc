class mcu8_HUDMenu_loading extends Hat_HUDMenu;
var() string Text;

function OnOpenHUD(HUD H, optional String command)
{
	Super.OnOpenHUD(H, command);
    Text = command;
}

function bool Render(HUD H)
{
    if (!Super.Render(H)) return false;
	
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont("");
	
	H.Canvas.SetDrawColor(0,0,0,255);
	H.Canvas.DrawRect(H.Canvas.ClipX, H.Canvas.ClipY);

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