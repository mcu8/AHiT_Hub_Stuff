/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_SnatcherTeleport_Base extends Hat_SnatcherTeleport_Base
    abstract;

event PostBeginPlay()
{
	RebuildLinkedTeleporters();
	SetLinkTemplate(LinkParticle);

	if (IsLocked())
	{
		IdleParticle.SetActive(false);
		LockedParticle.SetActive(true);
	}
}

function bool IsLocked()
{
	return bIsLocked;
}

function DoUnlock()
{
	bIsLocked = false;
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	if (Other.IsA('Hat_Player') && IsLocked())
		DoUnlock();
	Super.Bump(Other, OtherComp, HitNormal);
}

function RebuildLinkedTeleporters()
{
	local int i;
	for (i = 0; i < Teleporters.Length; i++)
	{
		if (Teleporters[i].Teleporters.Find(self) != INDEX_NONE)
			continue;
		Teleporters[i].Teleporters.AddItem(self);
	}
}

function int GetAngleYaw(Hat_SnatcherTeleport_Base a)
{
	return GetRotatorTowardsTeleporter(a).Yaw;
}

function Rotator GetRotatorTowardsTeleporter(Hat_SnatcherTeleport_Base a)
{
	local Rotator r;
	r = Rotator((a.Location - Location)*vect(1,1,0));
	return r;
}

function int GetBestIndexFromAngle(Rotator r)
{
	local float angle_radians, best_angle;
	local int i, best_index;
	
	best_index = -1;
	
	r.Pitch = 0;
	r.Roll = 0;
	
	for (i = 0; i < Teleporters.Length; i++)
	{
		angle_radians = VSize(Vector(r) - Vector(GetRotatorTowardsTeleporter(Teleporters[i])));
		
		if (best_index >= 0 && angle_radians >= best_angle) continue;
		
		best_index = i;
		best_angle = angle_radians;
	}
	return best_index;
}

function int SortTeleportersBasedOnAngle_Compare(Hat_SnatcherTeleport_Base a, Hat_SnatcherTeleport_Base b)
{
	return GetAngleYaw(b) - GetAngleYaw(a);
}

function SortTeleportersBasedOnAngle()
{
	Teleporters.Sort(SortTeleportersBasedOnAngle_Compare);
}

function bool OnPlayerJumpInto(Pawn p, optional bool force)
{
	local Hat_StatusEffect fx;
	if (!force && p.Base != self) return false;
	
	RebuildLinkedTeleporters();
	
	p.SetPhysics(Phys_Falling);
	p.Velocity = vect(0,0,1)*500;
	p.AirControl = 0;
	
	Hat_PawnOccluded(p).SetOcclusionHidden(true);
	
	fx = Hat_PawnCombat(p).GiveStatusEffect(class'Hat_StatusEffect_SnatcherTeleport');
	Hat_StatusEffect_SnatcherTeleport(fx).Teleporter = self;
	
	return true;
}

function OnPlayerEnter(Pawn p, optional bool relocate = true, optional bool effect = true)
{
	local Vector v;
	local bool bOldCollideActors, bOldBlockActors;
	if (effect)
	{
		if (OnEnterSound != None)
			PlaySound(OnEnterSound);
		EnterParticle.SetActive(true);
	}
	if (relocate)
	{
		v = p.Location;
		
		bOldCollideActors	= p.bCollideActors;
		bOldBlockActors		= p.bBlockActors;
		p.bCollideWorld = false;
		p.SetCollision(FALSE, FALSE);
		p.Move((Location + vect(0,0,1)*40) - p.Location);
		//p.SetLocation(Location + vect(0,0,1)*40);
		p.SetCollision(bOldCollideActors, bOldBlockActors);
		Hat_PlayerCamera(PlayerController(p.Controller).PlayerCamera).ApplyLocationOffset(Location - v);
	}
	if (IsScripted == 1 && Teleporters.Length > 0)
	{
		Teleporters[0].OnPlayerEnter(p, true, true);
		Teleporters[0].OnPlayerExit(p);
		Teleporters[0].DoFadeOut();
		DoFadeOut();
	}
}

function OnPlayerExit(Pawn p)
{
	p.bCollideWorld = true;
	Hat_PawnOccluded(p).SetOcclusionHidden(false);
	if (OnExitSound != None)
		PlaySound(OnExitSound);
		
	p.SetHidden(false);
	p.SetPhysics(Phys_Falling);
	p.Velocity = vect(0,0,1)*400;
	p.AirControl = 0;
	Hat_PawnCombat(p).RemoveStatusEffect(class'Hat_StatusEffect_SnatcherTeleport');
}

function SetLinkTemplate(ParticleSystem s)
{
	local int i;
	for (i = 0; i < Links.Length; i++)
	{
		Links[i].SetTemplate(s);
		Links[i].SetAbsolute(true,true,true);
		Links[i].SetDepthPriorityGroup(SDPG_Foreground);
	}
}

function SetLinksHidden(bool b)
{
	local int i;
	if (b)
	{
		LinkProgress = -1;
		if (TickOptimize == TickOptimize_None)
			SetTickIsDisabled(true);
	}
	else
	{
		LinkProgress = 0;
		if (TickOptimize == TickOptimize_None)
			SetTickIsDisabled(false);
	}
	
	for (i = 0; i < Min(Links.Length, Teleporters.Length); i++)
	{
		UpdateLinkLocation(i);
		Links[i].SetActive(!b);
		Links[i].SetHidden(b || Teleporters[i].IsLocked());
	}
}

function UpdateLinkLocation(int i)
{
	local Vector v, delta, deltan, startloc;
	local float leeway;
	if (i >= Links.Length) return;
	if (i >= Teleporters.Length) return;
	
	leeway = 70;
	
	delta = (Teleporters[i].Location - Location);
	deltan = Normal(delta);
	startloc = Location + deltan*leeway;
	v = startloc + FMin(VSize(delta)-leeway*2, LinkProgress)*deltan;
	
	Links[i].SetTranslation(startloc);
	Links[i].SetVectorParameter('LinkBeamEnd', v);
}

function DoFadeIn()
{
	FadeIn = 0;
	Tick(0);
}

function DoFadeOut()
{
	FadeIn = -1;
	FadeOut = 0;
	SetCollision(false,false,false);
}

event Tick(float d)
{
	local int i;
	Super.Tick(d);
	if (LinkProgress >= 0 && LinkProgress < 90000)
	{
		LinkProgress += LinkProgress*7*d + d*400;
		if (LinkProgress >= 90000)
		{
			LinkProgress = 90000;
			if (TickOptimize == TickOptimize_None)
				SetTickIsDisabled(true);
		}
		for (i = 0; i < Min(Links.Length, Teleporters.Length); i++)
		{
			UpdateLinkLocation(i);
		}
	}
	if (FadeIn >= 0)
	{
		FadeIn += d*5;
		FadeIn = FMin(FadeIn,1.0);
		IdleParticle.SetScale(FadeIn);
		if (FadeIn >= 1.0)
			FadeIn = -1;
	}
	if (FadeOut >= 0)
	{
		FadeOut += d*2;
		FadeOut = FMin(FadeOut,1.0);
		IdleParticle.SetScale(1.0 - FadeOut);
		if (FadeOut >= 1.0)
		{
			FadeOut = -1;
			Destroy();
		}
	}
}


defaultproperties
{   
	bCollideActors=true
	bBlockActors=true
	TickOptimize = TickOptimize_View;
	Enabled = true;
	
	LinkProgress = -1;
	FadeIn = -1;
	FadeOut = -1;
}
