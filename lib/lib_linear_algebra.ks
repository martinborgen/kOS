// Linear Algebra lib
@lazyGlobal off.

function eye {      // Creates a nxn identity matrix. If second argument given, generates a diag matrix. 
    parameter n.
    parameter const is 1.
    local rows is list().
    
    local i is 0.
    until i = n {
        local cols is list().
        local j is 0.
        until j = n {
            if i = j {
                cols:add(1*const).
            } else {
                cols:add(0).
            }
            set j to j + 1.
        }
        set i to i + 1.
        rows:add(cols).
    }
    return rows.
}

function diag {       // arguments in number, dimension, uses eye. 
    parameter num.
    parameter n.
    return eye(n, num).
}

function zeros {      // Creates a nxn zero matrix, or an nxm matrix
    parameter n.
    parameter m is n.
    local rows is list().
    local i is 0.
    until i = n {
        local cols is list().
        local j is 0.
        until j = m {
            cols:add(0).
            set j to j + 1.
        }
        set i to i + 1.
        rows:add(cols).
    }
    return rows.
}

function matrix_add {
    parameter A.
    parameter B.
    
    if not (A:length = B:length and A[0]:length = B[0]:length) {
        print "ERROR: matrix dimensions must agree!".
        return B.
    }
    local output is zeros(A:length, A[0]:length).
    from {local i is 0.} until i = A:length step {set i to i + 1.} do {
        from {local j is 0.} until j = A[0]:length step {set j to j + 1.} do {
            set output[i][j] to A[i][j] + B[i][j].
        }
    }
    return output.
}

function matrix_mult {
    parameter A.
    parameter B.

    if A:istype("scalar") and B:istype("list") {
        set A to eye(B:length, A).        
    } else if B:istype("scalar") and A:istype("list") {
        local tmp is A.
        if tmp[0]:istype("list") {
            set A to eye(tmp[0]:length, B).
        } else if tmp[0]:istype("scalar") {
            set A to eye(1, B).
        } 
        set B to tmp.
    } else if not (A:istype("list") and B:istype("list")) {
        return A * B.
    }

    if not (A[0]:length = B:length) {
        print "ERROR: matrix dimensions must agree".
        return B.
    }

    local n is A:length.
    local m is A[0]:length.
    local u is B:length.
    local v is B[0]:length.
    local output is zeros(n, v).

    from {local i is 0.} until i = n step {set i to i + 1. } do {
        from {local j is 0.} until j = v step {set j to j + 1.} do {
                local tmp is 0.
                from {local k is 0.} until k = m step {set k to k + 1.} do {
                    set tmp to tmp + A[i][k] * B[k][j].
                }
                set output[i][j] to tmp.
            }
        }
    return output.
}

function matrix_transp {
    parameter A.
    local n is A:length.
    local m is 0.
    if A[0]:istype("list") {
        set m to A[0]:length.
    } else if A[0]:istype("scalar") {
        set m to 1.
    } else {
        print "Error with transposition".
        return A.
    }
    local output is zeros(m, n).
    from {local i is 0.} until i = n step {set i to i+1.} do {
        from {local j is 0.} until j = m step {set j to j+1.} do {
            set output[j][i] to A[i][j].
        }
    }
    return output.
}

// function matrix_det {
//     parameter A.
//     if A[0]:istype("scalar") {
//         if A:length = 1 {
//             return A[0].
//         } else {
//             print "Error in matrix_det, matrix must be square!".
//             return A.
//         }
//     } else if not (A:length = A[0]:length) {
//         print "Error in matrix_det, matrix must be square!".
//         return A.
//     }

//     local output is 0.
//     from {local n is 0.} until n = A:length step {set n to n+1.} do {
//         // set output to (-1)^2.
//     }
//     print "COMPUTING DETERMINANTS SUCK".
//     return A.
// }

function matrix_print {
    parameter A. 

    for i in A {
        local row is "".
        from {local j is 0.} until j = i:length step {set j to j + 1.} do {
            set row to row + " " + i[j]:tostring. 
        }
        print row.
    }
    print " ".
}
