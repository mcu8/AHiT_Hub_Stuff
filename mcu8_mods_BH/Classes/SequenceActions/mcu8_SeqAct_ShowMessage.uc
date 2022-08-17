class mcu8_SeqAct_ShowMessage extends SeqAct_Latent;

var(Message) Hat_ConversationTree ConversationTree<Tooltip=Conversation tree>;
var(Message) bool IsRadio<Tooltip=Is Radio>;

var(InputVars) String InputMessage<Tooltip=Message,AutoComment=true>;
var String OutputString;
var String TmpOutput;

var(Sounds) bool OverrideDefaultSounds;
var(Sounds) SoundCue SoundSkip;
var(Sounds) SoundCue SoundCursorMove;

var(Sounds) bool PlayCueOnMessageOpen;
var(Sounds) SoundCue CueOnMessageOpen;

var(Misc) bool bDebug;

var(Misc) float InputCheckDelay;

var Hat_PlayerTalkManager talkManagerInstance;
var bool bFinishedTalking;

event Activated()
{
	local string msg;
	
	local array<Object> actors;
	local array<Object> players;

	local Hat_PlayerController ctrl;
	local Object actor;
	
	bFinishedTalking = false;
	
	
	msg = GetConversationString(InputMessage);
	
	DebugPrint("Formatted Message => " $ msg);
	
	SetConversationString("myMessage", msg, 0);
	
	GetObjectVars(actors, "Actor");
	GetObjectVars(players, "Player");
	
    if (players.Length > 0)
    {
		foreach players(actor) {
			DebugPrint("TestObject => " $ actor.Class);

			ctrl = Hat_PlayerController(GetController(Actor(actor)));

			//if (players[0].Class != class'Hat_PlayerController' 
			//	&& ClassIsChildOf(players[0].Class, class'Hat_PlayerController') == false) 
			if (ctrl == None)
			{
				DebugPrint("No Hat_PlayerController found!");
				DebugPrint(ActivateNamedOutputLink("Out") ? "true" : "false");
			}		 	
			else 
			{

				ShowTree(ctrl, actors.Length > 0 ? Actor(actors[0]) : None);
			}
		}
    }
    else {
		DebugPrint(ActivateNamedOutputLink("Out") ? "true" : "false");	
    }
}

event bool Update(float DeltaTime)
{
	super.Update(DeltaTime);
	
	if (bFinishedTalking) {
		OutputString = TmpOutput;
		bAborted = false;
		return false;
	}
	
    return true;
}

event Deactivated()
{
	DebugPrint(ActivateNamedOutputLink("Out") ? "true" : "false");
}

function OnConversationFinish() {
	local string outMessage;
	talkManagerInstance = none;
	
	outMessage = Caps(GetConversationString("[inputTextMe]")); 
	
	DebugPrint("UserInput => " $ outMessage);
	
    SetConversationString("lastUInput", outMessage, 0);
    TmpOutput = outMessage;
   
    DebugPrint("Finish talk");
	bFinishedTalking = true;
}


function ShowTree(Hat_PlayerController pc, Actor a)
{
	local Hat_PlayerTalkManager tm;
	
	if (pc.TalkManager == none || pc.TalkManager.Class != class'Hat_PlayerTalkManager') 
	{
		DebugPrint("No TalkManager");
		return;
	}
	
	if (PlayCueOnMessageOpen) {
		pc.PlaySound(CueOnMessageOpen);
	}
	
	if (!IsRadio) {
		tm = pc.TalkManager;
	
		if (pc.TalkManager.Controller == none) {
			DebugPrint("No TalkManager handler");
			return;
		}
	
		if (OverrideDefaultSounds) {
			tm.SoundCursorMove = SoundCursorMove;
			tm.SoundSkip = SoundSkip;
		} 
		
		tm.PushConversation(ConversationTree, a, false, false);
		
		CheckAllDialogsClosed(tm);
	}
	else
	{
		class'Hat_HUDElementPlayerRadio'.static.PushConversationInstance(pc, ConversationTree.CreateInstance(pc), none, OnReachedEndDelegate, InOnClosedDelegate);
	}
}

function InOnClosedDelegate(Hat_BubbleTalker b) {
	DebugPrint("Radio finish talk");
	TmpOutput = "radioNone";
	bFinishedTalking = true;	
}

function OnReachedEndDelegate(Hat_BubbleTalker b) {
	//
}

function CheckAllDialogsClosed(optional Hat_PlayerTalkManager tm) {
	if (tm != none)
		talkManagerInstance = tm;
	
	if (talkManagerInstance.IsTalking()) {
		// don't hang the CPU
		DebugPrint("Still talking!");
		Hat_PlayerController(class'Engine'.static.GetEngine().GamePlayers[0].Actor).SetTimer(InputCheckDelay, false, NameOf(CheckAllDialogsClosed), self);
	}
	else 
	{
		DebugPrint("Finished talking!");
		OnConversationFinish();
	}
}


function string GetConversationString(string _input) {
	local Worldinfo w;
	local Hat_GameManager g;
	local string output;
	output = _input;
	
	w = GetWorldInfo();
	if (w != None && w.game != None)
	{
		g = Hat_GameManager(w.game);
		if (g != None)
		{
			g.ReplaceByConversationString(output);
		}
	}
	return output;
}

function SetConversationString(string varname, string value, int lifetime)
{
	local Worldinfo w;
	local Hat_GameManager g;
	
	w = GetWorldInfo();
	if (w != None && w.game != None)
	{
		g = Hat_GameManager(w.game);
		if (g != None)
		{
			g.SetConversationString(varname, value, lifetime);
		}
	}
}

function DebugPrint(string v) {
    if (bDebug) Hat_PlayerController(class'Engine'.static.GetEngine().GamePlayers[0].Actor).ClientMessage("[Debug " $ self.Class $ "] => " $ v);
}


defaultproperties
{
	ObjName="[BH] Show conversation Message"
	ObjCategory="BetterHub"
    
    OverrideDefaultSounds = false
    PlayCueOnMessageOpen = false
    
    bAutoActivateOutputLinks = false
    bFinishedTalking = false
    
    InputCheckDelay = 0.05
    
    IsRadio = false

	InputMessage = "{UNDEFINED}"
	
	OutputLinks.Empty
	OutputLinks(0)=(LinkDesc="Out")
	
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Player", bHidden=false)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Actor",  bHidden=false)
	
	VariableLinks(2)=(ExpectedType=class'SeqVar_String',LinkDesc="Message",PropertyName=InputMessage, bHidden=false)
	VariableLinks(3)=(ExpectedType=class'SeqVar_String',LinkDesc="Output", PropertyName=OutputString, bHidden=false, bWriteable=true)
	
	SoundCursorMove = SoundCue'HatInTime_Hud.SoundCues.CursorMove'
	SoundSkip = SoundCue'HatInTime_Hud.SoundCues.MenuSkip'

	bSuppressAutoComment=false;
}