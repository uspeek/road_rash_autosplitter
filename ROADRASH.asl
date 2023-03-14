/**
 * Road Rash 1996 PC autosplitter & in-game timer
 * Authors: uspeek + Molotok
**/
state("ROADRASH"){
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
    switch((int)current.playerPos){
      case 1: vars.totalTime += current.levelTime1;  break;
      case 2: vars.totalTime += current.levelTime2;  break;
      case 3: vars.totalTime += current.levelTime3;  break;
      case 4: vars.totalTime += current.levelTime4;  break;
      case 5: vars.totalTime += current.levelTime5;  break;
      case 6: vars.totalTime += current.levelTime6;  break;
      case 7: vars.totalTime += current.levelTime7;  break;
      case 8: vars.totalTime += current.levelTime8;  break;
      case 9: vars.totalTime += current.levelTime9;  break;
      case 10: vars.totalTime += current.levelTime10;  break;
      case 11: vars.totalTime += current.levelTime11;  break;
      case 12: vars.totalTime += current.levelTime12;  break;
      case 13: vars.totalTime += current.levelTime13;  break;
      case 14: vars.totalTime += current.levelTime14;  break;
      case 15: vars.totalTime += current.levelTime15;  break;
      default: break;
    }

    return TimeSpan.FromMilliseconds(vars.totalTime*100);
  }
}

isLoading{
  return (!vars.isBigGame && !vars.inRace);
}

start{
  // Starts timer on level load for RTA timing
  // In case IGT timer moves a few seconds, it'll fix itself with gametime at the end
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
