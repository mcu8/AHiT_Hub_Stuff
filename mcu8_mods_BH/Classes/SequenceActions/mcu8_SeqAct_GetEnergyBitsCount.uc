class mcu8_SeqAct_GetEnergyBitsCount extends SeqAct_SetSequenceVariable;

var int Target;
event Activated()
{
	Target = Hat_GameManager(class'WorldInfo'.static.GetWorldInfo().game).GetEnergyBits();
}

defaultproperties
{
	ObjName="[BH] Get pons count"
	ObjCategory="BetterHub"
	
	VariableLinks.Empty
    VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Out integer",bWriteable=true,PropertyName=Target)
}
