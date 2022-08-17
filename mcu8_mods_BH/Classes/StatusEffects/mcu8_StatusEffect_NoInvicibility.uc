/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_StatusEffect_NoInvicibility extends Hat_StatusEffect;

defaultproperties
{
	Duration = 0;
	PreventFirstPerson = true
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
}

simulated function OnRemoved(Actor a)
{
    Super.OnRemoved(a);
}

// thanks Шарарамош :hueh:
static function bool MakePlayerHittable(Hat_Player ply)
{
    local Hat_StatusEffect s;
    local bool WasPurified;
	local int i;
    if (ply != None)
    {
        for (i = ply.StatusEffects.Length-1; i > -1; i--)
        {
            s = ply.StatusEffects[i];
            if (s != None)
            {
                if (s.CannotTakeDamage(true) || s.CannotTakeDamage(false))
                {
                    ply.RemoveStatusEffect(s.Class, false);
                    WasPurified = true;
                }
            }
        }
        if (!ply.bCollideActors)
        {
            ply.SetCollision(true);
            WasPurified = true;
        }
    }
    return WasPurified;
}

function bool Update(float delta)
{
	if (!Super.Update(delta)) return false;
	
    if (Hat_Player(Owner) != None)
	{
		MakePlayerHittable(Hat_Player(Owner));
	}

	return true;
}

