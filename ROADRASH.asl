/**
 * Road Rash 1996 autosplitter & in-game timer
 * Author: uspeek
**/

state("ROADRASH"){
  byte hasFinished1 : 0xC3DFC;
  byte hasFinished2 : 0x6D980;
  byte hasStarted : 0xC7498;
  byte hasStarted2 : 0xC7294;
  byte isPaused : 0x753B8;
  byte levelId : 0x6A660;
}

startup {
  settings.Add("startOnLevelLoad", true, "Start on level load");
  settings.SetToolTip("startOnLevelLoad", 
    "When disabled timer will start after pre-race countdown ends which is useful for ILs.\n" +
    "When enabled timer will start as soon as any game level loads."
  );
  
  settings.Add("removeLoadingChecks", false, "Remove loading checks");
  settings.SetToolTip("removeLoadingChecks", 
    "Current Big Game mode ruleset states that RTA is to be used\n" +
    "This setting will treat RTA as IGT to account for that without layout changes\n" +
    "Or just use Real Time comparison in LiveSplit settings"
  );
}

init{
  vars.delay = 0;
  refreshRate = 60;
}

isLoading{
  if(settings["removeLoadingChecks"]) return false;
  if((current.hasFinished1 == 1 || current.hasFinished2 == 1) && vars.delay == 0) return true;
  if(current.levelId > 5 || current.levelId == 0) return true;
  if(current.hasStarted == 5 && current.hasStarted2 == 5) return true;
  return false;
}

start{
  if(current.levelId < 6 && current.levelId > 0){
    if(old.hasStarted2 == 5 && current.hasStarted2 != 5) return true;
    if(old.hasStarted == 5 && current.hasStarted != 5) return true;
    if((old.levelId > 6 || old.levelId == 0) && settings["startOnLevelLoad"]) return true;
  }
}

split{
  //split at the end of the race is delayed to be in sync with in-game time
  if(current.levelId < 6 && current.levelId > 0){
    if((vars.delay > 3) && current.hasFinished1 == 1 && current.hasFinished2 == 1){
      vars.delay = 0;
      return true;
    }

    if(
      ((old.hasFinished1 == 0 || old.hasFinished2 == 0) &&
      current.hasFinished1 == 1 && current.hasFinished2 == 1)
      || vars.delay > 0
    ) vars.delay++;
  }
}
