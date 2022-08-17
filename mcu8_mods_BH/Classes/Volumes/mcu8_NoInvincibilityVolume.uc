/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_NoInvincibilityVolume extends Volume
	placeable;
    
var() bool Enabled;
defaultproperties
{
    Enabled = true;
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
    if (Enabled && Hat_PawnCombat(Other) != None)
    {
        Hat_PawnCombat(Other).GiveStatusEffect(class'mcu8_StatusEffect_NoInvicibility');
    }
    Super.Touch( Other, OtherComp, HitLocation, HitNormal );
}

simulated event UnTouch( Actor Other)
{
    if (Enabled && Hat_PawnCombat(Other) != None)
    {
        Hat_PawnCombat(Other).RemoveStatusEffect(class'mcu8_StatusEffect_NoInvicibility');
    }
    Super.UnTouch( Other );
}

event editoronly CheckForErrors(out Array<string> ErrorMessages)
{
	Super.CheckForErrors(ErrorMessages);
}