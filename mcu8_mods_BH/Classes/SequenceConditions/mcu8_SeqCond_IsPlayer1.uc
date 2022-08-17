/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_SeqCond_IsPlayer1 extends SequenceCondition;

var() Actor Player;

function int GetIndex()
{
	local Actor pc;
	pc = Hat_PlayerController(GetController(Player));

	if (pc == None) return 2;

	if(pc == class'Hat_PlayerController'.static.GetPlayer1())
	{
		return 0; // 1 is P2
	}
	else if(pc == class'Hat_PlayerController'.static.GetPlayer2())
	{
		return 1; // 0 is P1
	}

	return 2;  // 2 is unknown
}

event Activated()
{
    OutputLinks[GetIndex()].bHasImpulse = true;
}

defaultproperties
{
	ObjName="[BH] IsPlayer1"
	ObjCategory="BetterHub"

	OutputLinks(0)=(LinkDesc="P1")
	OutputLinks(1)=(LinkDesc="P2")
	OutputLinks(2)=(LinkDesc="neither")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Actor",PropertyName=Player)
}