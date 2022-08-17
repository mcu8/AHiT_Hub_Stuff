/**
 *
 * Copyright 2012-2015 Gears for Breakfast ApS. All Rights Reserved.
 */

class mcu8_SnatcherTeleport extends mcu8_SnatcherTeleport_Base
    placeable;


defaultproperties
{
   Begin Object Class=ParticleSystemComponent Name=IdleParticle0
        Template = ParticleSystem'HatInTime_Levels_DarkForest2.SnatcherTeleport.ParticleSystems.IdleTeleport'
		MaxDrawDistance = 7000
   End Object
   Components.Add(IdleParticle0);
   IdleParticle = IdleParticle0;
   
   Begin Object Class=ParticleSystemComponent Name=LockedParticle0
        Template = ParticleSystem'HatInTime_Levels_DarkForest2.SnatcherTeleport.ParticleSystems.LockedTeleport'
		MaxDrawDistance = 7000
		bAutoActivate=false
   End Object
   Components.Add(LockedParticle0);
   LockedParticle = LockedParticle0;
   
   Begin Object Class=ParticleSystemComponent Name=EnterParticle0
        Template = ParticleSystem'HatInTime_Levels_DarkForest2.SnatcherTeleport.ParticleSystems.TeleportFlash'
		bAutoActivate=false
		MaxDrawDistance = 7000
   End Object
   Components.Add(EnterParticle0);
   EnterParticle = EnterParticle0;
   
   LinkParticle = ParticleSystem'HatInTime_Levels_DarkForest2.SnatcherTeleport.ParticleSystems.TeleportLink'
   OnEnterSound = SoundCue'HatinTime_SFX_Player.badge_teleport_go_cue'
}