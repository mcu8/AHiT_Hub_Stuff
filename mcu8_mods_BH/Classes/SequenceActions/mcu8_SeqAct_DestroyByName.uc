/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */
 
class mcu8_SeqAct_DestroyByName extends SequenceAction;

var() Array<string> Names;
var() string IgnoreTag;

event Activated()
{
    DestroyName();
}

function DestroyName()
{
	local Actor a;
	local String sName;
    foreach class'Worldinfo'.static.GetWorldInfo().AllActors(class'Actor', a)
    {
		foreach Names(sName) {
			if (sName ~= String(a.Name)) {
				if (IgnoreTag != "" && String(a.Tag) ~= IgnoreTag) {
					continue;
				}
				a.SetHidden(true);
				a.SetCollision(false,false,false);
			}			
		}
    }
}

defaultproperties
{
	ObjName="[BH] Destroy by name"
	ObjCategory="BetterHub"
    
    bCallHandler=false;
    VariableLinks.Empty;
}