// Script to automatically engage SAS and RCS to level a flipped rover
@lazyGlobal off.
clearScreen.

// when vang(ship:up:vector, ship:facing:topvector) > 50 then {
//     sas off.
//     rcs on.
//     lock steering to lookDirUp(ship:facing:forevector, ship:up:vector).
//     return True.
// }

// when vAng(ship:up:vector, ship:facing:topvector) < 10 then {
//     sas off.
//     rcs off.
//     unlock steering.
//     return True.
// }
// lock forwards to ship:facing:forevector.

local stab is False.    // Bool to keep triggers from firing all the time.
until False{
    clearScreen.
    print "vang: " + vang(ship:up:vector, ship:facing:topvector) at(0,1).
    print "stab: " + stab at(0, 2).
    if stab = False and vang(ship:up:vector, ship:facing:topvector) > 50 {
        sas off.
        rcs on.
        lock steering to lookDirUp(vxcl(ship:up:vector, ship:facing:forevector), ship:up:vector).
        set stab to True.
    } else if stab = True and vAng(ship:up:vector, ship:facing:topvector) < 10 {
        wait until ship:status = "landed".
        sas off.
        rcs off.
        unlock steering.
        set stab to False.
    }
    wait 0.
}