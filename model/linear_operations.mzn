predicate linear_modular_addition_word(
 array [int] of var 0..1 : A, 
 array [int] of var 0..1 : B, 
 array [int] of var 0..1 : C, 
 array [int] of var 0..1 : di_list) = 
let {
    int: n = length(A);
} in 
 forall (j in 0..n-1) (linear_modular_addition_bit(di_list[j],C[j],A[j],B[j], di_list[j+1]))/\di_list[0] = 0;

predicate three_way_fork_word(array [int] of var 0..1: X, array [int] of var 0..1: Y, array [int] of var 0..1: Z, array [int] of var 0..1: Dummy) = 
let {
    int: n = length(X);
} in 
forall (j in 0..n-1) (
three_way_fork(X[j], Y[j], Z[j], Dummy[j])
);
 
predicate three_way_fork(var 0..1:x, var 0..1:y, var 0..1:z, var 0..1:dummy) =
  x + y + z - 2*dummy >= 0 /\
  x + y + z <= 2 /\
  dummy - x >= 0 /\
  dummy - y >= 0 /\
  dummy - z >= 0;
 
 
predicate linear_modular_addition_bit(var 0..1:di,var 0..1:a0,var 0..1:a1,var 0..1:a2, var 0..1:di1) =
 di - a0  - a1  +  a2  +  di1 >= 0 /\
 di + a0  + a1  -  a2  -  di1 >= 0 /\
 di + a0  - a1  -  a2  +  di1 >= 0 /\
 di - a0  + a1  -  a2  +  di1 >= 0 /\
 di + a0  - a1  +  a2  -  di1 >= 0 /\
 di - a0  + a1  +  a2  -  di1 >= 0 /\
 a0 - di  + a1  +  a2  +  di1 >= 0 /\
 di + a0  + a1  +  a2  +  di1 <= 4;
