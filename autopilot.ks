// autopilot
@lazyGlobal off.
declare parameter desried_hdg is "none".
declare parameter desired_alt is "none".
declare parameter desired_vel is "none".

runOncePath("lib/lib_navball.ks").

clearscreen.
sas off.

global mysteer is heading(90, 0).
global myThrot is 0.
lock steering to mySteer.
lock throttle to myThrot.

// global STALL_SPEED is 70.
// global MAX_SPEED is 300. 
global MAX_PITCH is 30.
global MAX_ROLL is 5.
global MAX_RATE is 60.

function takeoff {
    // parameter desired_heading is ship:heading.
    set myThrot to 1.

    until ship:groundspeed > 60 {
        wait 0.
    }

    set mySteer to heading(90, 15).

    until ship:verticalSpeed > 5 {
        wait 0.
    }

    set gear to false.

    until ship:altitude > 1000 {
        wait 0.
    }

    lock steering to heading(90, 0).
    print "completed takeoff".
    return.    
}

function steer { // TODO change such that this function is called to update the PIDs, who are kept outside this scope. 
    parameter steer_hdg is 90.
    parameter steer_alt is 1000. 
    parameter steer_vel is 200.
    local pitch is 0.
    local roll is 0.

    set STEERINGMANAGER:PITCHTS to 0.8.

    set mysteer to heading(steer_hdg, pitch, roll).

    // Climb pid takes alt difference and outputs a climb rate. 
    local kpClimb is 0.7.
    local kiClimb is 0.02.
    local kdClimb is 0.001.
    local climbPid is pidLoop(kpClimb, kiClimb, kdClimb, -MAX_RATE, MAX_RATE).
    set climbPid:setpoint to steer_alt.

    // Pitch pid takes climb rate and outputs a pitch angle. 
    local kpPitch is 0.4.
    local kiPitch is 1e-1.
    local kdPitch is 0.002.
    local pitchPid is pidLoop(kpPitch, kiPitch, kdPitch, -MAX_PITCH, MAX_PITCH).
    set pitchPid:setpoint to 0.

    // Velocity pid takes difference in velocity and outpts throttle. 
    local kpVel is 0.1.
    local kiVel is 0.0002.
    local kdVel is 0.1.
    local velPid is pidLoop(kpVel, kiVel, kdVel, 0, 1).
    set velPid:setpoint to steer_vel.

    // Roll pid takes difference in heading and outputs a roll. 
    local kpRoll is 0.1.
    local kiRoll is 0.002.
    local kdRoll is 0.01.
    local rollPid is pidLoop(kpRoll, kiRoll, kdRoll, -30, 30).

    until false {
        clearScreen.
        print "mythrot: " + mythrot at(0, 1).
        print "pitch: " + pitch at(0, 2).
        print "roll: " + roll at(0, 3).
        set pitchPid:setpoint to climbPid:update(TIME:SECONDS, ship:altitude).
        set rollPid:setpoint to max(min(steer_hdg - heading_of_vector(ship:facing:forevector), MAX_ROLL), -MAX_ROLL).
        print "climbSetpt: " + climbPid:setpoint at(0, 4).
        print "pitchSetpt: " + pitchPid:setpoint at(0, 5).
        print "rollSetpt:  " + rollPid:setpoint at(0, 6).
        
        set pitch to pitchPid:update(TIME:SECONDS, ship:verticalspeed).
        set myThrot to velPid:update(TIME:SECONDS, ship:airspeed).
        set roll to rollPid:update(TIME:SECONDS, ship:facing:roll - 90).
        
        set mysteer to heading(steer_hdg, pitch, roll).
        wait 0.
    }
}

function mainloop {
    until false {
        if ship:status = "LANDED" or ship:status = "PRELAUNCH" {
            print "CHANGEMODE TO TAKEOFF".
            if desried_hdg = "none" {
                set desried_hdg to 90.
            }
            if desired_alt = "none" {
                set desired_alt to 1000.
            }
            if desired_vel = "none" {
                set desired_vel to 200.
            }

            takeoff().
        } else if ship:status = "FLYING" {
            print "CHANGEMODE TO: FLYING".
            steer(desried_hdg, desired_alt, desired_vel).
        }
    }
}

mainloop().
