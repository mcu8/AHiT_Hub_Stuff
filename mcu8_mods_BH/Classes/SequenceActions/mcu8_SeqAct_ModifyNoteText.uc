class mcu8_SeqAct_ModifyNoteText extends SeqAct_SetSequenceVariable;

var Object VNote<autocomment=true>;
var String Text<autocomment=true>;

defaultproperties
{
	ObjName="[BH] Write to note"
	ObjCategory="BetterHub"

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="VNote",PropertyName=VNote)
	VariableLinks(1)=(ExpectedType=class'SeqVar_String',LinkDesc="Text",PropertyName=Text)
}

event Activated()
{
	local int i;
	local string target;
	target = Text;

	i = 10;
	while (i > 0) {
		mcu8_Note(VNote).SetText(target);
		i--;
	}
}
