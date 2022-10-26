/**
 * Road Rash 1996 autosplitter & in-game timer
 * Author: uspeek & Molotok
**/
state("ROADRASH"){
/*  
  old addresses

  byte hasFinished1 : 0xC3DFC;
  byte hasFinished2 : 0x6D980;
  byte hasStarted : 0xC7498;
  byte hasStarted2 : 0xC7294;
*/
  byte hasStarted : 0xB7ECC;
  byte hasFinished : 0xC3DFC;

  byte isPaused : 0x753B8;
  byte levelId : 0x6A660;

  byte playerPos : 0x9E114;
  int levelTime : 0x6AB4C;
  int levelTime2 : 0x6AB98;
  int levelTime3 : 0x6ABE4;
  int levelTime4 : 0x6AC30;
  int levelTime5 : 0x6AC7C;
  int levelTime6 : 0x6ACC8;
  int levelTime7 : 0x6AD14;
  int levelTime8 : 0x6AD60;
  int levelTime9 : 0x6ADAC;
  int levelTime10 : 0x6ADF8;
  int levelTime11 : 0x6AE44;
  int levelTime12 : 0x6AE90;
  int levelTime13 : 0x6AEDC;
  int levelTime14 : 0x6AF28;
  int levelTime15 : 0x6AF74;

  byte isThrash : 0x739A0;
  byte isBigGame : 0x73A10;
  byte currentMode : 0x753B0;
}

startup{
  settings.Add("ILSetting", false, "Start at race start");
  settings.SetToolTip("ILSetting",
  "When enabled timer will start after pre-race countdown ends which is useful for ILs.\n" +
  "When disabled timer will start as soon as any game level loads."
  );
}

init{
  vars.inLevel = false;
  vars.isBigGame = false;
  vars.justStartedRace = false;
  vars.justFinishedRace = false;
  vars.inRace = false;

  vars.state = 0;
  vars.totalTime = 0;
}

update{
  if (timer.CurrentPhase == TimerPhase.NotRunning){
    vars.totalTime = 0;
  }

  vars.isBigGame = current.currentMode == 2 && current.isBigGame == 1;

  vars.inLevel = current.levelId < 6 && current.levelId > 0;
  vars.justStartedRace = old.hasStarted == 2 && current.hasStarted != 2;
  vars.justFinishedRace = (old.hasFinished != current.hasFinished) && current.hasFinished == 1;

  if(vars.justStartedRace) vars.inRace = true;
  if(vars.justFinishedRace) vars.inRace = false;
  if(!vars.inLevel) vars.inRace = false;
}

gameTime {
  if(vars.justFinishedRace){
    if(current.playerPos == 1){ vars.totalTime += current.levelTime; }
    else if(current.playerPos == 2){ vars.totalTime += current.levelTime2; }
    else if(current.playerPos == 3){ vars.totalTime += current.levelTime3; }
    else if(current.playerPos == 4){ vars.totalTime += current.levelTime4; }
    else if(current.playerPos == 5){ vars.totalTime += current.levelTime5; }
    else if(current.playerPos == 6){ vars.totalTime += current.levelTime6; }
    else if(current.playerPos == 7){ vars.totalTime += current.levelTime7; }
    else if(current.playerPos == 8){ vars.totalTime += current.levelTime8; }
    else if(current.playerPos == 9){ vars.totalTime += current.levelTime9; }
    else if(current.playerPos == 10){ vars.totalTime += current.levelTime10; }
    else if(current.playerPos == 11){ vars.totalTime += current.levelTime11; }
    else if(current.playerPos == 12){ vars.totalTime += current.levelTime12; }
    else if(current.playerPos == 13){ vars.totalTime += current.levelTime13; }
    else if(current.playerPos == 14){ vars.totalTime += current.levelTime14; }
    else if(current.playerPos == 15){ vars.totalTime += current.levelTime15; }
    return TimeSpan.FromMilliseconds(vars.totalTime*100);
  }
}

isLoading{
  return (!vars.isBigGame && !vars.inRace);
}

start{
  if(vars.inLevel){
    if(!settings["ILSetting"] && (old.levelId > 6 || old.levelId == 0)) return true;
    if(settings["ILSetting"] && vars.justStartedRace) return true;
  }
}

split{
  if(vars.inLevel && vars.justFinishedRace){
    if(current.playerPos < 4 || vars.isBigGame) return true;
  }
}

reset{
  //in Thrash mode per rule "Run ends when you have qualified in all five tracks of Level X"
  //being on wrecked/busted screen removes all qualifications rendering run dead
  if(current.levelId == 33 && !vars.isBigGame) return true;
}
