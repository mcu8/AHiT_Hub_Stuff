class mcu8_SeqAct_JoinStrings extends SeqAct_SetSequenceVariable;

var String Target;

var() String strA;
var() String strB;
var() String strC;
var() String strD;
var() String strE;
var() String strF;
var() String strG;
var() String strH;
var() String strI;

var() String Seperator<autocomment=true>;

defaultproperties
{
	ObjName="[BH] Join Strings (alt)"
	ObjCategory="BetterHub"

	VariableLinks.Empty
	
	VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="Target",bWriteable=true,PropertyName=Target)
	VariableLinks(1)=(ExpectedType=class'SeqVar_String',LinkDesc="A",PropertyName=strA)
	VariableLinks(2)=(ExpectedType=class'SeqVar_String',LinkDesc="B",PropertyName=strB)
	VariableLinks(3)=(ExpectedType=class'SeqVar_String',LinkDesc="C",PropertyName=strC)
	VariableLinks(4)=(ExpectedType=class'SeqVar_String',LinkDesc="D",PropertyName=strD)
	VariableLinks(5)=(ExpectedType=class'SeqVar_String',LinkDesc="E",PropertyName=strE)
	VariableLinks(6)=(ExpectedType=class'SeqVar_String',LinkDesc="F",PropertyName=strF)
	VariableLinks(7)=(ExpectedType=class'SeqVar_String',LinkDesc="G",PropertyName=strG)
	VariableLinks(8)=(ExpectedType=class'SeqVar_String',LinkDesc="H",PropertyName=strH)
	VariableLinks(9)=(ExpectedType=class'SeqVar_String',LinkDesc="I",PropertyName=strI)
	
	InputLinks.Empty
	InputLinks(0)=(LinkDesc="A+B")
    InputLinks(1)=(LinkDesc="A+..C")
	InputLinks(2)=(LinkDesc="A+..D")
	InputLinks(3)=(LinkDesc="A+..E")
	InputLinks(4)=(LinkDesc="A+..F")
	InputLinks(5)=(LinkDesc="A+..G")
	InputLinks(6)=(LinkDesc="A+..H")
	InputLinks(7)=(LinkDesc="A+..I")
}

event Activated()
{
	if (InputLinks[0].bHasImpulse) 
		Target = strA $ Seperator $ strB;
	else 
	if (InputLinks[1].bHasImpulse) 
		Target = strA $ Seperator $ strB $ Seperator $ strC;
	else 
	if (InputLinks[2].bHasImpulse) 
		Target = strA $ Seperator $ strB $ Seperator $ strC $ Seperator $ strD;
	else 
	if (InputLinks[3].bHasImpulse) 
		Target = strA $ Seperator $ strB $ Seperator $ strC $ Seperator $ strD $ Seperator $ strE;
	else 
	if (InputLinks[4].bHasImpulse) 
		Target = strA $ Seperator $ strB $ Seperator $ strC $ Seperator $ strD $ Seperator $ strE $ Seperator $ strF;
	else 
	if (InputLinks[5].bHasImpulse) 
		Target = strA $ Seperator $ strB $ Seperator $ strC $ Seperator $ strD $ Seperator $ strE $ Seperator $ strF $ Seperator $ strG;
	else 
	if (InputLinks[6].bHasImpulse) 
		Target = strA $ Seperator $ strB $ Seperator $ strC $ Seperator $ strD $ Seperator $ strE $ Seperator $ strF $ Seperator $ strG $ Seperator $ strH;
	else 
	if (InputLinks[7].bHasImpulse) 
		Target = strA $ Seperator $ strB $ Seperator $ strC $ Seperator $ strD $ Seperator $ strE $ Seperator $ strF $ Seperator $ strG $ Seperator $ strH $ Seperator $ strI;
	else
		Target = "";
}


