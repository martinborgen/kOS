@lazyGlobal off.
// parameter copy_to_local is false.
// imports a bunch of functions from other files.


// Unclear how useful this copy-feature is...?

// local funcList is list( "lib_burn.ks",
//                         "lib_input_terminal.ks",
//                         "lib_navball.ks",
//                         "RK2.ks").

// if copy_to_local = false {
//     for func in funcList {
//         runOncePath(func).
//     }
// } else if copy_to_local = true {
//     for func in funcList {
//         copyPath(func, "1:/").

//     }
// }

runOncePath("lib_burn.ks").
runOncePath("lib_input_terminal.ks").
runOncePath("lib_navball.ks").
runOncePath("lib_RK2.ks").
runOncePath("lib_num_methods.ks").
runOncePath("lib_linear_algebra.ks").