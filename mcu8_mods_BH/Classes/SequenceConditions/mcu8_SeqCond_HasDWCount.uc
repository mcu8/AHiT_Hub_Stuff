class mcu8_SeqCond_HasDWCount extends SequenceCondition;

var(Data) int Count;

function int GetIndex()
{
	return class'Hat_SnatcherContract_DeathWish'.static.GetNumberOfCompletedDeathWishStamps(Hat_SaveGame(`SaveManager.SaveData)) >= Count ? 0 : 1;
}

event Activated()
{
    OutputLinks[GetIndex()].bHasImpulse = true;
}

defaultproperties
{
	ObjName="[BH] Has completed DeathWish Count"
	ObjCategory="BetterHub"

	OutputLinks(0)=(LinkDesc="Equal or more")
	OutputLinks(1)=(LinkDesc="Less")
}