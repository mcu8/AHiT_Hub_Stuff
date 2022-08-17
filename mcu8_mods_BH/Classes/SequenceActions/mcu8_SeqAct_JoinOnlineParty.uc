class mcu8_SeqAct_JoinOnlineParty extends SequenceAction;
 
var() string LobbyName<Tooltip=Lobby name>;
var() bool bDebug<Tooltip=Debug.>;
 
defaultproperties
{
    ObjName="[BH] JoinOnlineParty"
    ObjCategory="BetterHub"
 
    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="Lobby name",bWriteable=false,PropertyName=LobbyName)
 
    bDebug = false
}
 
event Activated()
{
    local OnlineSubsystem OnlineSubsystem;
    OnlineSubsystem = class'GameEngine'.static.GetOnlineSubsystem();
    if (OnlineSubsystem != None) {
        class'Hat_GhostPartyPlayerStateBase'.static.ConfigSetUseOnlineFunctionality(True);
        class'Hat_GhostPartyPlayerStateBase'.static.ConfigSetLobbyName(LobbyName);
 
        if (LobbyName != "")
        {
            DebugPrint("Joining lobby '" $ LobbyName $ "'");
            class'Hat_GhostPartyPlayerStateBase'.static.LobbyJoinByName(LobbyName);
        }
        else
        {
            DebugPrint("Leaving lobby because input is empty or none");
            class'Hat_GhostPartyPlayerStateBase'.static.LobbyJoinPublic();
        }
    }
    else {
        DebugPrint("Unable to join lobby '" $ LobbyName $ "' because OnlineSubsystem is None");
    }
}
 
function DebugPrint(string v) {
    if (bDebug) Hat_PlayerController(class'Engine'.static.GetEngine().GamePlayers[0].Actor).ClientMessage(v);
}