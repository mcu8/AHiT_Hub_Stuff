class mcu8_SeqCond_IsUncanny extends SequenceCondition;

var() Hat_ChapterInfo ChapterInfo;

function int GetIndex()
{
	return (ChapterInfo != None && class'Hat_GameManager'.static.IsChapterUncannyFinaleEnabled(ChapterInfo)) ? 0 : 1;
}

event Activated()
{
    OutputLinks[GetIndex()].bHasImpulse = true;
}

defaultproperties
{
	ObjName="[BH] Is uncanny"
	ObjCategory="BetterHub"

	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
}