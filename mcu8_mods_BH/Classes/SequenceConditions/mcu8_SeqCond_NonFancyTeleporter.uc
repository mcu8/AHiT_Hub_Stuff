class mcu8_SeqCond_NonFancyTeleporter extends SequenceCondition;

var(Data) int Count;

function int GetIndex()
{
	return (class'mcu8_mods_BetterHubMain'.static.ShouldUseManholeInsteadTeleporter()) ? 0 : 1;
}

event Activated()
{
    OutputLinks[GetIndex()].bHasImpulse = true;
}

defaultproperties
{
	ObjName="[BH] Should use non-fancy teleporter"
	ObjCategory="BetterHub"

	OutputLinks(0)=(LinkDesc="Yes")
	OutputLinks(1)=(LinkDesc="No")
}