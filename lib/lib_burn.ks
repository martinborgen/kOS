@lazyGlobal OFF.

// burn_time() returns the time in seconds to a achieve a given deltaV. 
// Must input deltaV and isp, optional thrust (defaults to ship:maxthrust). 
function burn_time {
    parameter deltaV.
    parameter isp.
    parameter F is ship:maxThrust.
    local Ve is isp * constant:g0.
    local deltaT is ship:mass * Ve / F * (1 - constant:e ^(-1 * deltaV / Ve)).

    return deltaT.
}

// total_isp() returns the calculated total isp of a given set of engines (optional). 
// If no set of engines are given, it will use the total of all active engines.
function total_isp {
    parameter englist is list().
    if englist:length = 0 {
        list engines in englist.
    }

    local thrustSum is 0.
    local massFlowSum is 0.
    for eng in englist {
        set thrustSum to thrustSum + eng:availablethrust.
        set massFlowSum to massFlowSum + eng:availablethrust / (eng:isp + 1e-9) . // to avoid division by zero.
    }
    return thrustSum / massFlowSum.
}

// print burn_time(200, total_isp()).