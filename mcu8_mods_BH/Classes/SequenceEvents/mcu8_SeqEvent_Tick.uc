class mcu8_SeqEvent_Tick extends SequenceEvent;

public function DoTick() {
	ActivateOutputLink(0);
}

defaultproperties
{
	ObjName="[BH] Tick"
	VariableLinks.Empty
	OutputLinks(0)=(LinkDesc="Tick")
}
