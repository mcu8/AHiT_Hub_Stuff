/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_StatusEffect_NoCarry extends Hat_StatusEffect;

defaultproperties
{
	Duration = 0;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
}

simulated function OnRemoved(Actor a)
{
    Super.OnRemoved(a);
}


function bool Update(float delta)
{
	if (!Super.Update(delta)) return false;
	
    if (Hat_Player(Owner) != None)
	{
		Hat_Player(Owner).DropCarry();
	}

	return true;
}

