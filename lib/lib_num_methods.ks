@lazyGlobal off.

function secant_method {
    parameter f.
    parameter x0.
    parameter x1.
    parameter imax is 1e6.
    parameter tol is 1e-3.
    
    local t is 1.
    local i is 1.
    until abs(t) < tol{
        if i = imax {return 0.}
        // local t_old is t.
        set t to f(x1) * (x1 - x0) / (f(x1) - f(x0)).
        set x0 to x1.
        set x1 to x1 - t.
        set i to i + 1.
    }
    return x1.
}