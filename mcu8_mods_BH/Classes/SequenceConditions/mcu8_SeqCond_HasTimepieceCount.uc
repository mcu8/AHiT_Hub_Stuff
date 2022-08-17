class mcu8_SeqCond_HasTimepieceCount extends SequenceCondition;

var(Data) int Count;

function int GetIndex()
{
	return (Hat_GameManager(class'WorldInfo'.static.GetWorldInfo().game).GetTimeObjects() >= Count) ? 0 : 1;
}

event Activated()
{
    OutputLinks[GetIndex()].bHasImpulse = true;
}

defaultproperties
{
	ObjName="[BH] Has Timepiece Count"
	ObjCategory="BetterHub"

	OutputLinks(0)=(LinkDesc="Equal or more")
	OutputLinks(1)=(LinkDesc="Less")
}