//launcher.ks

//start config
SAS on.
SET SASMODE TO "STABILITYASSIST"
RCS off.
lights off.
lock throttle to 0.
gear off.

clearscreen.

set targetApo to 57500. //height of 1st stage apoasis
set runmode to 1.

until runmode = 0 {

  if runmode = 1 {//prelaunch
    lock steering to UP.
    lock THROTTLE to 1.0.
    print "Count-down:"
    from {local countdown is 10.} until countdown = 0 step {SET countdown to countdown -1} do {
      print countdown.
      wait 1.
    }
    stage.
    print "lift-off".
    if VELOCITY > 75 {
      set CA to ALTITUDE
      set runmode to 2.
    }
  
  else if runmode = 2 {//gravity turn
    print "commence gravity turn".
    lock turnAngle to 90-((45/((12000-CA)**2)))*((ALTITUDE-CA)**2).
    lock STEERING to HEADING(90,turnAngle).
    print turnangle.
  }
}
