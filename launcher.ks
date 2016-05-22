//launcher.ks

//start config
SAS on.
SET SASMODE TO "STABILITYASSIST"
RCS off.
lights off.
lock throttle to 0.
gear off.
set GRAVITY to (constant():G * body:mass) / body:radius^2.

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
  }
  
  else if runmode = 2 {//gravity turn
    print "commence gravity turn".
    SAS off.
    lock turnAngle to 90-((45/((15000-CA)^2)))*((ALTITUDE-CA)^2).
    lock STEERING to HEADING(90,turnAngle).
    print turnangle.
    if turnangle < 32 {set runmode to 3.}
  }
    
  else if runmode = 3 {//gravity turn phase 2
    lock STEERING to HEADING(90,30).
    print "holding heading".
    wait 10.
    lock STEERING to PROGRADE.
    print "follow prograde".
    if APOAPSIS > targetApo {set runmode to 4.}
  }
  
  else if runmode = 4 {//engine shut down
    print "waiting for detachment."
    lock THROTTLE to 0.
    if ALTITUDE > 40000 {set runmode to 5.}
  }
  
  else if runmode = 5 {//gaining vertical velocity
    print "gaining velocity".
    lock STEERING to HEADING(90,0).
    wait 2.
    lock THROTTLE to 1.
    if VELOCITY > 1850 {set runmode to 6.}
  }
  
  else if runmode = 6 {//detachment and reentry preperation
    print "preparing detachment"
    lock THROTTLE to 0.
    lock STEERING to PROGRADE.
    wait 2.
    stage.
    print "detachment succes, preparing for reentry".
    lights on.
    RSC on.
    lock STEERING to RETROGRADE.
    wait 3.
    set WARP to 3.
    if VERTICALSPEED < 0 {set runmode to 7}
  }
  
  else if runmode = 7 {//reentry
    print "reentry".
    set WARP to 0.
    lock STEERING to RETROGRADE.
    if ALTITUDE < 27500 {set runmode to 8.}
  }
  
  else if runmode = 8 {//descent
    print "start braking procedure"
    brakes on.
    SAS off.
    lock STEERING to VELOCITY:SURFACE * -1.
    if ALTITUDE < 3000 {set runmode to 9}
  }
  
  else if runmode = 9 {//suicide burn
    print: "attempting landing".
    lock spot to SHIP:GEOPOSITION.
    lock fixalt to ALTITUDE - spot:TERRAINHEIGHT.
    lock STEERING to VELOCITY:SURFACE * -1.
    lock TWR to MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).
    set THROTTLE to (1/TWR) - (verticalspeed + max(5, min(250, fixalt^1.08 / 8)) / 3 / TWR.
    gear on.
    if fixalt < 30 and ABS(VERTICALSPEED) < 1 {
      lock throttle to 0.
      lock steering to up.
      SAS on.
      SET SASMODE TO "STABILITYASSIST".
      print "landed!"
      wait 3.
      set runmode to 0.
    }
  } 
}
 print "RUNMODE: " + runmode + " " at (5,4).
