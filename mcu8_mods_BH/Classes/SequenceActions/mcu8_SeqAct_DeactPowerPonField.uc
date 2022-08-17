class mcu8_SeqAct_DeactPowerPonField extends SequenceAction;

var Object Target;

event Activated()
{
	local Hat_PowerPonField f;
	f = Hat_PowerPonField(Target);
	
	f.IsActive = false;
	f.DoDeactivate();
}

defaultproperties
{
	ObjName="[BH] Deactivate Power Pon Field"
	ObjCategory="BetterHub"

	VariableLinks.Empty
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",bWriteable=true,PropertyName=Target)
}
