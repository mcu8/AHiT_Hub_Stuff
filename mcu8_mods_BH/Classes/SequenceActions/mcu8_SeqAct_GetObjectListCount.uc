class mcu8_SeqAct_GetObjectListCount extends SeqAct_SetSequenceVariable;

var int Target;
var() Actor ActorSource<autocomment=true>;

event Activated()
{
	local array<SequenceObject> ObjectList;
	
	GetLinkedObjects(ObjectList, class'SeqVar_ObjectList', false);
	
	if (ObjectList.Length > 0)
    {
	    Target = SeqVar_ObjectList(ObjectList[0]).ObjList.Length;
	}
	else {
		Target = 0;
	}
}

defaultproperties
{
	ObjName="[BH] Get ObjectList Entity count"
	ObjCategory="BetterHub"
	
	VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SeqVar_ObjectList',LinkDesc="Objects",bWriteable=false)
    VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Out integer",bWriteable=true,PropertyName=Target)
}
