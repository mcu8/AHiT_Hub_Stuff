class mcu8_HubSwapperHelper extends Actor;

var String msgcontext;

function PostBeginPlay()
{
    ShowNotifyIfNeeded();
}

function ShowNotifyIfNeeded()
{
    if (IsInstalled()) return;
    if (!IsNotifyEnabled()) return;
    if (!IsInVanillaHub()) return;
    if (IsAlreadyOpened()) return;

    SetTimer(1, false, nameof(ShowNotifyDelayed));
}

function ShowNotifyDelayed()
{
    local Hat_PlayerController pc;
    pc = GetPC();
    if (pc == None || pc.bCinematicMode)
    {
        SetTimer(1, false, nameof(ShowNotifyDelayed));
        return;
    }
    else
    {
        ShowNotify();
    }
}

function ShowNotify()
{
    Notify("hs_msg_1");
}

function Notify(String context)
{
    local Hat_HUDMenuConfirmationBox cb;
    msgcontext = context;
    cb = Hat_HUDMenuConfirmationBox(Hat_HUD(GetHudComponent()).OpenHUD(class'mcu8_HubSwapperNotify', context));
    cb.PushDelegate(OnConfirmationBox);
}

delegate OnConfirmationBox(HUD H, PlayerController pc, int result)
{
    if (msgcontext == "hs_msg_1")
    {
        if (result == 0)
        {
            Notify("hs_msg_2");
        }
    } 
    else if (msgcontext == "hs_msg_2")
    {
        if (result == 0)
        {
            Notify("hs_msg_3");
        }
    } 
    else if (msgcontext == "hs_msg_3")
    {
        if (result == 0)
        {
            OpenWorkshopPage();
        }
        else if (result == 1)
        {
            DisableNotify();
        }
    }
}

function bool IsAlreadyOpened()
{
    local class<Hat_HUDElement> el;
    local Hat_HUD hud;
    hud = Hat_HUD(GetHudComponent());
    foreach hud.m_hClassElements(el)
    {
        if (hud.Name == class'mcu8_HubSwapperNotify'.Name)
        {
            return true;
        }
    }
    return false;
}

function HUD GetHudComponent()
{
    return GetPC().MyHUD;
}

function bool IsNotifyEnabled()
{
    return !class'Hat_SaveBitHelper'.static.HasLevelBit("Mods_HubSwapper_WarningDisabled", 1, `GameManager.HubMapName);
}

function DisableNotify()
{
    class'Hat_SaveBitHelper'.static.AddLevelBit("Mods_HubSwapper_WarningDisabled", 1, `GameManager.HubMapName);
}

function OpenWorkshopPage()
{
    class'Hat_GameManager_Base'.static.OpenBrowserURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2850182030");
}

function Hat_PlayerController GetPC() {
    if (class'Engine'.static.GetEngine() != None && class'Engine'.static.GetEngine().GamePlayers.Length > 0)
        return Hat_PlayerController(class'Engine'.static.GetEngine().GamePlayers[0].Actor);
    return None;
}

function bool IsInstalled() {
    local object o;
    o = class'Hat_ClassHelper'.static.ActorClassFromName("mcu8_mods_BetterHubMain", "mcu8_mods_BH");
    return (o != None);
}

function bool IsInVanillaHub()
{
    return `GameManager.GetCurrentMapFilename() ~= `GameManager.HubMapName;
}


defaultproperties
{
    msgcontext = "";
}