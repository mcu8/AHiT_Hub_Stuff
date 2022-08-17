class mcu8_ObjectiveActor_ModIcon extends Hat_ObjectiveActor;

var Texture2D CurrentIcon;

function bool OnDrawSub(HUD H, Hat_HUDElement hel, float pulse, Vector ViewLoc, float size, float alpha, float fadein, bool InView)
{
	local float distance;
	// Render only if player can see base actor
	if (Base != None && !Base.PlayerCanSeeMe()) return false;

	// Render only if player is near
	distance = VSize2D(Location - Hat_PlayerController(H.PlayerOwner).Pawn.Location);
	if (distance > 220) return false;

	return Super.OnDrawSub(H, hel, pulse, ViewLoc, size, alpha, fadein, InView);
}

static function Hat_PlayerController GetPC() {
    return Hat_PlayerController(class'Engine'.static.GetEngine().GamePlayers[0].Actor);
}

function SetModIcon(Texture2D InIcon)
{
	local MaterialInstanceConstant inst;
	
	if (InIcon == None) return;
	CurrentIcon = InIcon;
	
	if (HUDIcon != None && HUDIcon.IsA('MaterialInstanceConstant'))
		inst = MaterialInstanceConstant(HUDIcon);
	else
	{
		inst = new class'MaterialInstanceConstant';
		inst.SetParent(MaterialInterface(default.HUDIcon));
	}
	inst.SetTextureParameterValue('Texture', CurrentIcon);
	HUDIcon = inst;
}

defaultproperties
{
	Enabled = true;
	ClampToView = false;
	MinCullDistance = 0;
	MaxCullDistance = 1600;
	CullDistanceFade = 1024;
	AttractHelperHat = false;
	PulseScale = 0;
	IconScale = 1.3;
	InheritLocationFromBase = false;
	// TODO: maybe replace it with squared icon :>
	HUDIcon = Material'HatinTime_GhostParty.Materials.AvatarObjectiveIcon'
}
