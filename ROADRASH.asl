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
  vars.inLevel = 0;
  vars.state = 0;
  /*
    0 - menu/loading/after race screen etc
    1 - pre-race countdown
    2 - in race
    3 - finished race
  */
  vars.justStartedRace = 0;

  refreshRate = 60;
}

update{
  vars.inLevel = (current.levelId < 6 && current.levelId > 0);
  vars.justStartedRace = ((old.hasStarted == 5 && current.hasStarted != 5) || (old.hasStarted2 == 5 && current.hasStarted2 != 5));

  if(vars.state == 0){ // menu, loading, after race screens etc
    if(vars.inLevel) vars.state = 1;
  }
  else if(vars.state == 1){// in level during countdown
    if(!vars.inLevel){ vars.state = 0;}
    if(vars.justStartedRace){ vars.state = 2;}
  }
  else if(vars.state == 2){// race
    if(!vars.inLevel){ vars.state = 0;}
    if((current.hasFinished1 == 1 || current.hasFinished2 == 1) && vars.delay > 1 ) { vars.state = 3; } 
  }
  else if(vars.state == 3){// after crossing finish line
      if(!vars.inLevel){ vars.state = 0;}
  }
  else vars.state = 0;
}

isLoading{
  if(settings["removeLoadingChecks"] || vars.state == 2) return false;
  return true;
}

start{
  if(vars.inLevel){
    if(vars.justStartedRace) return true;

    if((old.levelId > 6 || old.levelId == 0) && settings["startOnLevelLoad"]) return true;
  }
}

split{
  //split at the end of the race is delayed to be in sync with in-game time
  if((vars.delay > 1) && current.hasFinished1 == 1 && current.hasFinished2 == 1){
    vars.delay = 0;
    return true;
  }

  if(
    ((old.hasFinished1 == 0 || old.hasFinished2 == 0) &&
    current.hasFinished1 == 1 && current.hasFinished2 == 1)
    || vars.delay > 0
  ) vars.delay++;
}
