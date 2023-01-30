//Space Plane Take-off script, supports only all-rapier spaceplanes, with no other jet or vacuum engines!
CLEARSCREEN.
declare parameter input_orbit is "none".
if input_orbit = "none" {
		set desired_orbit to (body:atm:height + 5000).
		print "No desired orbit specified, defaulting to: " + desired_orbit + " metres.".
} else if input_orbit < body:atm:height {
	set desired_orbit to (body:atm:height + input_orbit). 
	print "Specified orbit is less than atmospheric height,".
	print "Interpreting specified orbit to metres above atmospheric height.".
	print desired_orbit + " metres.".
} else {
	set desired_orbit to input_orbit.
	print "Specified orbit is: "+ desired_orbit.
}

FUNCTION heading_of_vector { // heading_of_vector returns the heading of the vector (number renge   0 to 360)
	PARAMETER vecT.

	LOCAL east IS VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).

	LOCAL trig_x IS VDOT(SHIP:NORTH:VECTOR, vecT).
	LOCAL trig_y IS VDOT(east, vecT).

	LOCAL result IS ARCTAN2(trig_y, trig_x).

	IF result < 0 {RETURN 360 + result.} ELSE {RETURN result.}
}
FUNCTION pitch_of_vector { // pitch_of_vector returns the pitch of the vector(number range -90 to  90)
	PARAMETER vecT.

	RETURN 90 - VANG(SHIP:UP:VECTOR, vecT).
}

set steeringmanager:pitchts to 0.8.
set steeringmanager:yawts to 1.
set brakes to true.
set sas to false.
set mythrot to 0.
set vPitch to pitch_of_vector(ship:facing:forevector).
set vhead to heading_of_vector(ship:facing:forevector). 
set throttle to 0.
set atrunwayheading to heading_of_vector(ship:facing:forevector).

set rapiermode to 0.
lock shipHead to heading_of_vector(ship:facing:forevector).
lock mysteer to heading(vHead, vPitch).
lock throttle to mythrot.
lock steering to mysteer.
lock locGrav to (body:mu / (ship:altitude + body:radius)^2).
lock TWR to (ship:availablethrust / (locGrav * Ship:mass)).
list engines in englist.
for engine in englist {
	if engine:multimode = true {
		if engine:mode = "ClosedCycle" {
			engine:togglemode.
		}
		if engine:autoswitch = true {
			set engine:autoswitch to false.
		}
	}
}
//configuring the craft
panels off.
drills off.
deploydrills off.
intakes on. 
if bays {
	wait 1.
	bays off.
}
//Check if the staging works
if ship:availablethrust = 0 {
	for engine in englist {
		if engine:multimode {
			if engine:mode = "AirBreathing"{
				engine:activate.
			}
		}
	}
}
//heading adjuster:
if abs(atrunwayheading - 90) > 0.5 {
	until abs(atrunwayheading - 90) < 0.2 {
		print "adjusting heading".
		if shipHead - 90 > 0 {
			until shipHead - 90 < 0.2 {
				lock vhead to 90.
				lock wheelsteering to 90.
				set mythrot to 0.7 - ship:groundspeed / 10. 
				set brakes to false. 
				wait 0.1. 
			}
		} else if shipHead - 90 < 0 {
			until shipHead - 90 > (-0.2) {
				lock vhead to 90.
				lock wheelsteering to 90.
				set mythrot to 0.7 - ship:groundspeed / 10. 
				set brakes to false. 
				wait 0.1. 
			}
		}
		set brakes to true.
		set mythrot to 0.
		unlock wheelsteering.
		wait until ship:groundspeed < 0.1.
		// set vHead to heading_of_vector(ship:facing:forevector).
		set vhead to 90.
		set atrunwayheading to heading_of_vector(ship:facing:forevector).
		print atrunwayheading.
	}
}
//takeoff run 
set brakes to false.
set mythrot to 1.
//wait until speed is gained
until ship:groundspeed > 100 or ship:airspeed > 100 or alt:radar > 5  {
	clearscreen.
	print "Airspeed: " at(0,1). print round(ship:airspeed) + "m/s" at(11,1). 
	print "vPitch: " at(0,2). print round(vPitch) + " degrees" at(11,2). 
	wait 0.5.
}
//start adding rotation until liftoff
until ship:verticalspeed > 1 AND alt:radar > 5 {
	clearscreen.
	print "Airspeed: " at(0,1). print round(ship:airspeed) + "m/s" at(16,1). 
	print "vPitch: " at(0,2). print round(vPitch) + " degrees" at(16,2).
	if vPitch < 25 {
		set vPitch to round(vPitch) + 2.
	}
	wait 0.5.
}
set vPitch to 10.
set vhead to 90.
set gear to false.
print "Retracting gear" at(0,3).
set oldSpeed to ship:airspeed.
set oldAccel to 0. 
set Accel to 0.
set jerk to 0.
//sub-7.5 km climb loop
until ship:altitude > 7000 {
	wait 1.
	set Accel to ship:airspeed - oldSpeed.
	set oldSpeed to ship:airspeed.
	set jerk to Accel - oldAccel.
	set oldAccel to Accel.
	clearscreen.
	print "Airspeed: " at(0,1). print round(ship:airspeed, 2) + " m/s" at(15,1). 
	print "vPitch: "  at(0,2). print vPitch + " degrees" at(15,2). 
	print "Acceleration: " at(0,3). print round(Accel, 2) + " m/s^2" at(15,3).
	print "Jerk: " at(0,4). print round(jerk, 2) + " m/s^3" at(15,4).
	if Accel < 0 and ship:airspeed < 325 {
		if vPitch > -2 {
			set vPitch to vPitch - 1.
		}
	} else if Accel < 0 and abs(ship:airspeed - 340 ) < 15 {
		if vPitch < 10 {
			set vPitch to vPitch + 1.
		}
	}
	if jerk > 2 or Accel > 10 or ship:airspeed > 900 or ship:verticalspeed < 0 or TWR > 2.5 {
		if vPitch < 25 {
			set vPitch to vPitch + 1.
		}
	}
}
//engine mode-switch trigger
when Accel < 0 and ship:altitude > 10000 then {
	for engine in englist {
		if engine:multimode = true and engine:mode = "AirBreathing" {
			engine:togglemode.
			set Rapiermode to 1.
			intakes off.
		}
	}
}
//pitch degrease and speed gain loop
set vPitch to 7.
until ship:apoapsis > desired_orbit {
	wait 1.
	set Accel to ship:airspeed - oldSpeed.
	set oldSpeed to ship:airspeed.
	set jerk to Accel - oldAccel.
	set oldAccel to Accel.
	clearscreen.
	print "Airspeed: " at(0,1). print round(ship:airspeed, 2) + " m/s" at(15,1). 
	print "vPitch: "  at(0,2). print vPitch + " degrees" at(15,2). 
	print "Acceleration: " at(0,3). print round(Accel, 2) + " m/s^2" at(15,3).
	print "Jerk: " at(0,4). print round(jerk, 2) + " m/s^3" at(15,4).
	if Accel < 0 or ship:airspeed < 0.1 * ship:altitude and ship:airspeed < 1300 and vPitch > 10 {
		if vPitch > -2 and rapiermode = 0 {
			set vPitch to vPitch - 1.
		} else if vPitch > 0 and rapiermode = 1 {
			set vPitch to vPitch - 1.
		}
	} 
	if ship:airspeed > 0.1 * ship:altitude {
		if vPitch < 15 and rapiermode = 0 {
			set vPitch to vPitch + 1.
		} else if rapiermode = 1 and vPitch < 45 {
			set vPitch to vPitch + 1.
		}
	}
}
//coasting to apoapsis 
set mythrot to 0.
lock mysteer to prograde.
until ship:altitude > 70000 {
	clearscreen.
	print "Airspeed: " at(0,1). print round(ship:airspeed, 2) + " m/s" at(15,1).
	print "Apoapsis: " at(0,2). print round(ship:apoapsis, 2) + " m" at(15,2).
	if ship:apoapsis < desired_orbit {
		set mythrot to 0.5.
		until ship:apoapsis > desired_orbit {
			clearscreen.
			print "Airspeed: " at(0,1). print round(ship:airspeed) + " m/s" at(15,1).
			print "Apoapsis: " at(0,2). print round(ship:apoapsis) + " m" at(15,2).
			wait 0.5.
		}
		set mythrot to 0.
	}
	wait 0.5.
}
//circularization calculation
lock orbit_vel to sqrt(body:mu/(ship:apoapsis + body:radius)).
lock dVreq to orbit_vel - velocityat(ship, time+eta:apoapsis):orbit:mag.
rcs on.
for engine in englist {
	if engine:ignition {
		set vacIsp to engine:visp.
	}
}
set Ev to vacIsp * constant:g0.
set vPitch to 0.
set burntime to (ship:mass * Ev ) / ship:availablethrust * (1 - constant:e^(-(dVreq / Ev))).
lock mysteer to heading(vhead, vPitch).
until eta:apoapsis < burntime/2 + 10 {
	clearscreen.
	print "Apoapsis: " at(0,1). print round(ship:apoapsis, 2) + " m" at(22,1).
	print "Orbital vel. at ap.: " at(0,2). print round(orbit_vel, 2) + " m/s" at(22, 2).
	print "Required dV at ap.: " at(0,3). print round(dVreq, 2) + " m/s" at(22,3).
	print "Burntime: "at(0,4). print round(burntime, 2) + " s" at(22,4).
	print "Time to burn: " at(0,5). print round(eta:apoapsis - burntime/2) + " s" at(22,5).
	wait 0.5.
}
set orbit_vel to sqrt(body:mu/(ship:apoapsis + body:radius)).
set dVreq to orbit_vel - velocityat(ship, time+eta:apoapsis):orbit:mag.
set burntime to (ship:mass * Ev ) / ship:availablethrust * (1 - constant:e^(-(dVreq / Ev))). 
if kuniverse:TimeWarp:rate > 1 {
	kuniverse:timewarp:cancelwarp.
}
until eta:apoapsis <= burntime / 2 {
		clearscreen.
	print "Apoapsis: " at(0,1). print round(ship:apoapsis, 2) + " m" at(22,1).
	print "Orbital vel. at ap.: " at(0,2). print round(orbit_vel, 2) + " m/s" at(22, 2).
	print "Required dV at ap.: " at(0,3). print round(dVreq, 2) + " m/s" at(22,3).
	print "Burntime: "at(0,4). print round(burntime, 2) + " s" at(22,4).
	print "Time to burn: " at(0,5). print round(eta:apoapsis - burntime/2) + " s" at(22,5).
	wait 0.5.
}
if kuniverse:TimeWarp:rate > 1 {
	kuniverse:timewarp:cancelwarp.
}
//Circularisation burn
set mythrot to 1.
wait burntime. 
set mythrot to 0.
wait 0.5.
if ship:periapsis > body:atm:height {
	clearscreen. 
	if abs(desired_orbit - ship:apoapsis) < 2000 and abs(desired_orbit - ship:periapsis) < 2000 {
		print "Sucessfully launched to whithin 2 km of desired orbit (" + desired_orbit + " metres)!".
	}
	if abs(desired_orbit - ship:apoapsis) > 2000 or abs(desired_orbit - ship:periapsis) > 2000 and ship:periapsis > body:atm:height {
		print "failed to reach desired orbit (" + desired_orbit + " metres) but periapsis is still above atmospheric height.".
		
	}
	if not bays {
		bays on.
	}
} else if ship:periapsis < body:atm:height {
	clearscreen.
	print "WARNING! SHIP PERIAPIS BELOW ATMOSPHERIC HEIGHT!". 
	print "Ship periapsis is: " + round(ship:periapsis) + " metres.".
	print "Atmospheric height is: " + round(body:atm:height) + " metres. TAKE APPROPRIATE ACTION!".
}

unlock steering.
set sas to true.
rcs off.
SteeringManager:RESETTODEFAULT().
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
lock throttle to ship:control:pilotmainthrottle.