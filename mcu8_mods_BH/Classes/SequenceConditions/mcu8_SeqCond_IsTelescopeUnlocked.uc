/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_SeqCond_IsTelescopeUnlocked extends SequenceCondition;

var() Actor Telescope;

function int GetIndex()
{
	local mcu8_ActSelector pc;
	pc = mcu8_ActSelector(Telescope);

	if (pc == None) return 1;

	return pc.IsUnlocked() ? 0 : 1;
}

event Activated()
{
    OutputLinks[GetIndex()].bHasImpulse = true;
}

defaultproperties
{
	ObjName="[BH] Is telescope enabled?"
	ObjCategory="BetterHub"

	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Actor",PropertyName=Telescope)
}
