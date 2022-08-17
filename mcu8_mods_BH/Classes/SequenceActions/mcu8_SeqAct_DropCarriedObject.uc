class mcu8_SeqAct_DropCarriedObject extends SeqAct_Latent;

event Activated()
{
    if (InputLinks[0].bHasImpulse) 
		GetHatPlayer(0).DropCarry();
	else if (InputLinks[1].bHasImpulse) 
		GetHatPlayer(1).DropCarry();
	else if (InputLinks[2].bHasImpulse) {
        GetHatPlayer(0).DropCarry();
        GetHatPlayer(1).DropCarry();
    }
}

function Hat_Player GetHatPlayer(int index) {
    local Controller C;
    local Actor srcActor;
    srcActor = class'Engine'.static.GetEngine().GamePlayers[index].Actor;

	C = Controller(srcActor);

	if(C != None && C.Pawn != None)
	{
		srcActor = C.Pawn;
	}
	return Hat_Player(srcActor);
}

defaultproperties
{
	ObjName="[BH] Drop carry object"
	ObjCategory="BetterHub"
    bAutoActivateOutputLinks = true
    VariableLinks.Empty
	OutputLinks.Empty
	OutputLinks(0)=(LinkDesc="Out")
    InputLinks.Empty
	InputLinks(0)=(LinkDesc="Player1")
    InputLinks(1)=(LinkDesc="Player2")
    InputLinks(2)=(LinkDesc="All")
	bSuppressAutoComment=false;
}