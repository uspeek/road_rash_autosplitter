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

  int levelTime : 0x6AB4C;

  byte isThrash : 0x739A0;
  byte isBigGame : 0x73A10;
  byte currentMode : 0x753B0;
}

init{
  vars.inLevel = false;
  vars.isBigGame = false;
  vars.justStartedRace = false;
  vars.justFinishedRace = false;
  vars.inRace = false;

  vars.state = 0;
  vars.totalTime = 0;

  refreshRate = 60;
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
    vars.totalTime += current.levelTime;
    return TimeSpan.FromMilliseconds(vars.totalTime*100);
  }
}

isLoading{
  return (!vars.isBigGame && !vars.inRace);
}

start{
  if(vars.inLevel){
    if(old.levelId > 6 || old.levelId == 0) return true;
  }
}

split{
  if(vars.inLevel && vars.justFinishedRace) return true;
}

reset{
  //in Thrash mode per rule "Run ends when you have qualified in all five tracks of Level X"
  //being on wrecked/busted screen removes all qualifications rendering run dead
  if(current.levelId == 33 && !vars.isBigGame) return true;
}
