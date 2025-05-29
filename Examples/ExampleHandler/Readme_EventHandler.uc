/* 
    Example event handler for Hub Swapper

    ** THIS IS EXAMPLE CODE WHICH YOU SHOULD PUT INTO YOUR GAMEMOD CLASS **
*/

// Hack method to cross-mod events
// Hub Swapper sends the "bhinitialized" event id when it's ready
function OnMiniMissionGenericEvent(Object object, String id)
{
  local String mapName;
  // Do something when SpaceshipEX is loaded
  if (id == "bhinitialized")
  {
    // do the stuff...
  }
}


/*
    By m_cu8 @ https://hat.ovh | https://bsky.app/profile/m-cu.be
*/
