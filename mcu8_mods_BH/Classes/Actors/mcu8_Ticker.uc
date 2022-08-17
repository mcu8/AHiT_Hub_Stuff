class mcu8_Ticker extends Actor
	placeable;

event Tick(float d)
{
	TickAllTickers();
}

function TickAllTickers()
{
	local array<SequenceObject> AllTickEvents;
	local mcu8_SeqEvent_Tick TickEvt;
	local Sequence GameSeq;
	local int Idx;
	// Get the gameplay sequence.
	GameSeq = class'WorldInfo'.static.GetWorldInfo().GetGameSequence();
	if (GameSeq != None)
	{
		// Find all mcu8_SeqEvent_Tick objects anywhere.
		GameSeq.FindSeqObjectsByClass(class'mcu8_SeqEvent_Tick', TRUE, AllTickEvents);

		// Iterate over them, seeing if the name is the one we typed in.
		for( Idx=0; Idx < AllTickEvents.Length; Idx++ )
		{
			TickEvt = mcu8_SeqEvent_Tick(AllTickEvents[Idx]);
			if (TickEvt != None)
			{
				TickEvt.DoTick();
			}
		}
	}
}

defaultproperties
{
	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=150,G=200,B=255)
		ArrowSize=0.5
		bTreatAsASprite=True
		HiddenGame=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Notes"
	End Object
	Components.Add(Arrow)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Note'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Notes"
	End Object
	Components.Add(Sprite)

	bRouteBeginPlayEvenIfStatic=true
    IgnoreTickWhenHidden = false;
	TickOptimize = TickOptimize_None;
}