// Script to make a rover "on hinges" keep level. 
// Tag the pitch hinge "pitch" and the roll hinge "roll".

@lazyGlobal off.
clearscreen.

local rollHinge is ship:partstagged("roll").
local pitchHinge is ship:partstagged("pitch").
// local k is 0.02.
if rollHinge:length = 0 or pitchHinge:length = 0 {
    print "ERROR, no hinges labeled".
    print "Press ctrl + c to terminate".
    wait until false.
}

lock rollAngle to vang(ship:facing:starvector, ship:up:vector) - 90.
lock pitchAngle to vang(ship:facing:forevector, ship:up:vector) - 90.

function set_hinge {
    parameter hinge.
    parameter angle.
    hinge[0]:getmodule("ModuleRoboticServoHinge"):setfield("Target Angle", angle).
}

local Kp is 0.8.
local Ki is 0.5.
local Kd is 0.001.
local epsilon is 1.

local rollPid is pidLoop(Kp, Ki, Kd, -90, 90, epsilon).
local pitchPid is pidLoop(Kp, Ki, Kd, -90, 90, epsilon).
set rollPid:setpoint to 0.
set pitchPid:setpoint to 0.

// local oldRoll is 0.
// local oldPitch is 0.
until false {
    print "roll angle: " + rollAngle at(0, 1).
    print "pitch angle: " + pitchAngle at(0, 2).

    
    // set_hinge(rollHinge, oldRoll - k *rollAngle).
    // set_hinge(pitchHinge, oldPitch - k *pitchAngle).
    // set oldRoll to oldRoll - k *rollAngle.
    // set oldPitch to oldPitch - k * pitchAngle.

    set_hinge(rollHinge, rollPid:update(time:seconds, rollAngle)).
    set_hinge(pitchHinge, pitchPid:update(time:seconds, pitchAngle)).
    
    wait 0.
}