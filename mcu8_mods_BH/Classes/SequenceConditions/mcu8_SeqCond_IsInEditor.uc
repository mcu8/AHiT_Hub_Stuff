class mcu8_SeqCond_IsInEditor extends SequenceCondition;

function int GetIndex()
{
	local WorldInfo w;
	w = class'WorldInfo'.static.GetWorldInfo();
	
	if (w == None) return 1; // It should never happen, but eh.
	
	return (w.IsPlayInEditor() || w.IsPlayInPreview()) ? 0 : 1;
}

event Activated()
{
    OutputLinks[GetIndex()].bHasImpulse = true;
}

defaultproperties
{
	ObjName="[BH] Is in editor"
	ObjCategory="BetterHub"

	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
}