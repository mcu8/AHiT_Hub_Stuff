class mcu8_SeqAct_FillAllLevelSpots extends SequenceAction;

var() array<Actor> TargetPoints;
var int ModCount;
var int ModCountMax;

var() Color GoodColor;
var() Color BadColor;
var() Color NeutralColor;

const MaxLLenght = 16;

event Activated()
{
    local GameModInfo mod;
    local mcu8_SingleLevelLoader proto;
    local Array<GameModInfo> modList;
    local int i;
    local int ln;
    local Array<String> split;

    i = 0;
    ModCount = 0;
    ModCountMax = TargetPoints.Length;

    modList = class'GameMod'.static.GetModList();

    foreach modList(mod)
    {
        if (i == ModCountMax)
            break; // don't add more telescopes than points
        if (mod.IsEnabled && mod.ChapterInfoName == '' && mod.FirstMap != "" && mod.ModClass != class'mcu8_mods_BetterHubMain') 
        { 
            proto = mcu8_SingleLevelLoader(SpawnLoader(TargetPoints[i], false));
            proto.Map = mod.FirstMap;
            proto.PackageName = mod.PackageName;
            proto.ModName = mod.Name;
            split = SplitLn(mod.Name);
            ln = split.Length;

            proto.ModNameLine1 = ln > 2 ? split[2] : "";
            proto.ModNameLine2 = ln > 1 ? split[1] : "";
            proto.ModNameLine3 = ln > 0 ? split[0] : "";

            // INDEX_NONE = No vote. 0 = Downvote. 1 = Upvote.
            if (mod.VoteStatus == 0) 
                proto.TextColor = BadColor;
            else if (mod.VoteStatus == 1) 
                proto.TextColor = GoodColor;
            else 
                proto.TextColor = NeutralColor;

            proto.BaseGameMod = mod;

            i++;
            ModCount++;
        }
    }
}

function Array<string> SplitLn(String str) {
    local Array<String> splitList;
    local String entity;
    local int offset;
    local Array<string> out;
    local int i;

    offset = 0;
    i = 0;
    splitList = SplitString(str, " ", true);

    foreach splitList(entity) 
    {
        if (offset == 0) {
            out[i] = entity;
        }
        else {
            out[i] $= " " $ entity;
        }
        offset += Len(entity);
        if (offset + 1 >= MaxLLenght) 
        {
            i++;
            out.AddItem("");
            offset = 0;
        }
    }
    return out;
}

function Actor SpawnLoader(Actor target, bool useDynLightVariant)
{
    local Actor loader;
    loader = class'WorldInfo'.static.GetWorldInfo().Spawn(useDynLightVariant ? class'mcu8_SingleLevelLoader_DynLight' : class'mcu8_SingleLevelLoader',,,target.Location,target.Rotation);
    return loader;
}

defaultproperties
{
	ObjName="[BH] Place modded levels at the target points"
	ObjCategory="BetterHub"
    VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Mod count",bWriteable=true,PropertyName=ModCount)
    VariableLinks(2)=(ExpectedType=class'SeqVar_Int',LinkDesc="Mod count max",bWriteable=true,PropertyName=ModCountMax)

    GoodColor=(R=0,G=255,B=0)
    BadColor=(R=255,G=0,B=0)
    NeutralColor=(R=255,G=255,B=255)
}
