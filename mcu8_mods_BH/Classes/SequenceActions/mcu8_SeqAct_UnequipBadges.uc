class mcu8_SeqAct_UnequipBadges extends SeqAct_Latent;

event Activated()
{
    if (InputLinks[0].bHasImpulse) 
		Unequip(GetHatPlayer(0));
	else if (InputLinks[1].bHasImpulse) 
		Unequip(GetHatPlayer(1));
	else if (InputLinks[2].bHasImpulse) {
        Unequip(GetHatPlayer(0));
        Unequip(GetHatPlayer(1));
    }
}

function Unequip(Hat_Player p) {
	local Hat_PlayerController c;
	local Hat_Loadout l;
    local Hat_BackpackItem badge;


	c = Hat_PlayerController(p.Controller);

	if (c == None) return;

	l = c.MyLoadout;

    foreach l.MyLoadout.Badges(badge) {
        l.RemoveLoadout(badge.BackpackClass, true, p);
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
	ObjName="[BH] Unequip badges"
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