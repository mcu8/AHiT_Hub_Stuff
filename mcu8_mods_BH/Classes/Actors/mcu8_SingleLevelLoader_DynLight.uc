class mcu8_SingleLevelLoader_DynLight extends mcu8_SingleLevelLoader
	placeable;

defaultproperties 
{
	Begin Object Class=PointLightComponent Name=PointLightComponent0
		Translation=(Z=40,X=-32)
	    LightAffectsClassification=LAC_STATIC_AFFECTING
		CastShadows=TRUE
		CastStaticShadows=TRUE
		CastDynamicShadows=FALSE
		bEnabledInEditor=FALSE
		bForceDynamicLight=FALSE
		UseDirectLightMap=TRUE
		bAffectCompositeShadowDirection = FALSE
		//CullDistance=3000
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,bInitialized=TRUE)
		Brightness=2
		LightColor=(R=250,G=250,B=201)
		Radius=150
	End Object
	Components.Add(PointLightComponent0)
}
