class mcu8_SeqAct_TeleportPlayersNew extends SequenceAction;

/** If true, actor rotation will be aligned with destination actor */
var() bool bUpdateRotation;
/** If actor is more than this far away, it will be teleported. Ignored if < 0 */
var() float TeleportDistance;
/** If actor is NOT in one of these volumes, it will be teleported */
var() array<Volume> TeleportVolumes;

/** If TRUE, check to see if this actor overlaps any other colliding actors and don't teleport there if a better option exists */
var() bool bCheckOverlap;

/** @return Whether the given Actor should be teleported */
final static function bool ShouldTeleport(Actor TestActor, vector TeleportLocation, optional float TeleportDist, optional array<Volume> Volumes )
{
	local int VolumeIdx;

	if (TeleportDist > 0.0 && VSizeSq(TestActor.Location - TeleportLocation) < TeleportDist*TeleportDist)
	{
		return false;
	}
	else if (Volumes.length > 0)
	{
		for (VolumeIdx = 0; VolumeIdx < Volumes.length; ++VolumeIdx)
		{
			if (Volumes[VolumeIdx] != None && Volumes[VolumeIdx].Encompasses(TestActor))
			{
				return false;
			}
		}
	}

	return true;
}

event Activated()
{
	local Engine LocalEngine;
	local array<Object> DestinationP1;
	local array<Object> DestinationP2;
	local Controller C;
	local Actor dstActorP1;
	local Actor dstActorP2;
	local Actor srcActorP1;
	local Actor srcActorP2;

	LocalEngine = class'Engine'.static.GetEngine();

	GetObjectVars(DestinationP1, "Destination P1");
	
	if (DestinationP1.Length > 0) {
		dstActorP1 = Actor(DestinationP1[0]);
		C = Controller(dstActorP1);
		if(C != None && C.Pawn != None)
		{
			dstActorP1 = C.Pawn;
		}	
		
		srcActorP1 = LocalEngine.GamePlayers[0].Actor;
		C = Controller(srcActorP1);
		if(C != None && C.Pawn != None)
		{
			srcActorP1 = C.Pawn;
		}
		srcActorP1.TeleportActorTo(dstActorP1, bUpdateRotation);
	}
	
	
	
	if (LocalEngine.GamePlayers.Length > 1)
	{
		GetObjectVars(DestinationP2, "Destination P2");
		if (DestinationP2.Length > 0) {
			dstActorP2 = Actor(DestinationP2[0]);
			C = Controller(dstActorP2);
			if(C != None && C.Pawn != None)
			{
				dstActorP2 = C.Pawn;
			}
			
			srcActorP2 = LocalEngine.GamePlayers[1].Actor;
			C = Controller(srcActorP2);
			if(C != None && C.Pawn != None)
			{
				srcActorP2 = C.Pawn;
			}
			srcActorP2.TeleportActorTo(dstActorP2, bUpdateRotation);	
		}
	}
}

/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}

defaultproperties
{
	ObjName="[bh] Teleport Players"
	ObjCategory="BetterHub"
	bCallHandler=false
	VariableLinks.Empty()
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Destination P1")
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Destination P2")
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Teleport Volumes",PropertyName=TeleportVolumes,bHidden=TRUE)
	bUpdateRotation=TRUE

	TeleportDistance=-1.f
}
