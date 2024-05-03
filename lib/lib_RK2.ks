@lazyglobal off.
//This is a Runge-Kutta45 function, atm. only in one variable.
//Requires an odefun as a function delegate@, that takes the arguments(time, y), even if time is not used. 
//tspan is [start, stop] -times, h is step-length, and y0 is starting values.
function ode { 
	parameter odefun.
	parameter tspan.
	parameter h.
	parameter y0.
	
	local t0 is tspan[0].
	local tfinal is tspan[tspan:length - 1].
	local y1 is y0.
	
	local yout is list(y0).
	local tout is list(t0).
	local t is t0.
	until t > (tfinal - h) {
		local k1 is h * odefun(t, y1).
		local k2 is h * odefun(t + h/2, y1 + k1/2).
		local k3 is h * odefun(t + h/2, y1 + k2/2).
		local k4 is h * odefun(t + h, y1 + k3).
		
		local y2 is y1 + 1/6 * (k1 + 2*k2 + 2*k3 + k4).
		
		yout:add(y2).
		tout:add(t + h).
		set y1 to y2.
		set t to t + h.
		print t.
	}
	return list(tout, yout).
}

// function myode {
	// parameter xin.
	// parameter yin.
	// return -2 * xin * yin.

// }

// set test to ode(myode@, list(0, 3), 0.1, 2).

// print test.