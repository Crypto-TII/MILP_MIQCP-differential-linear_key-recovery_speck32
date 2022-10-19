function array [int] of string : float_array_to_string_array(array [int] of var float: X) =
let {
    int: n = length(X);
} in 
array1d(0..n-1, [format(X[i])|i in 0..n-1]);

function array [int] of string : int_array_to_string_array(array [int] of var 0..1: X) =
let {
    int: n = length(X);
} in 
array1d(0..n-1, [format(X[i])|i in 0..n-1]);

function string : int_array_to_bin_str(array [int] of var 0..1: X) =
let {
    int: n = length(X);
} in 
join("", int_array_to_string_array(X));

