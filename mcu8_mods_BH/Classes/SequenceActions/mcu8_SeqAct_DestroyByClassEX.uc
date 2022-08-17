/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */
 
class mcu8_SeqAct_DestroyByClassEX extends SequenceAction;

var() class<Actor> ClassToDestroy;
var() Array< class<Actor> > Exceptions;
var() string IgnoreTag;

defaultproperties
{
	ObjName="[BH] Destroy by Class extended"
	ObjCategory="BetterHub"
    
    bCallHandler=false;
    VariableLinks.Empty;
}

event Activated()
{
    DestroyClass(ClassToDestroy, Exceptions);
}

function DestroyClass(class<Actor> c, optional Array< class<Actor> > exception)
{
	local Actor a;
	if (c == None || c == class'Actor') return;
    foreach class'Worldinfo'.static.GetWorldInfo().AllActors(c, a)
    {
		if (exception.Find(a.Class) != INDEX_NONE) continue;
		if (a.IsA('Hat_Pawn_SnatcherMinion_Base'))
		{
			Hat_Pawn_SnatcherMinion_Base(a).OnDoDisappear();
			continue;
		}
        if (Locs(a.Tag) == Locs(IgnoreTag)) continue;
        a.Destroy();
    }
}