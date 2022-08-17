/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_StatusEffect_SpeedBoostPVP extends Hat_StatusEffect_SpeedBoost;

defaultproperties
{
    Duration = 5.0;
}

function float GetSpeed()
{
	return 1200;
}
