% The following predicates and functions corresponds to the Appendix C.1

predicate xor_word(array [int] of var 0..1 : A, array [int] of var 0..1 : B, array [int] of var 0..1 : C, array [int] of var 0..1 : dummy_xor) =
let {
    int: n = length(A);
} in 
forall (j in 0..n-1) (
 xor_bit(A[j],B[j],C[j], dummy_xor[j])
);

predicate xor_bit(var int:a, var int:b, var int:c, var 0..1:dummy_xor) =
dummy_xor >= a /\ dummy_xor >= b /\ dummy_xor >= c /\ a + b + c >= 2*dummy_xor /\ a + b + c <= 2;

function var 0..1: eq(var 0..1:a,var 0..1:b,var int:c) = (if (a=b /\ b=c) then 0 else 1 endif);

predicate diff_modular_addition_word(array [int] of var 0..1 : A, array [int] of var 0..1 : B, array [int] of var 0..1 : C, var 0..1:dummy_xor, array [int] of var 0..1 : d_list, int: r) =
let {
    int: n = length(A);
} in 
forall (j in 0..n-2) (
 modular_addition(A[j+1],B[j+1],C[j+1],A[j],B[j],C[j], d_list[j])) /\
dummy_xor >= A[n-1] /\
dummy_xor >= B[n-1] /\
dummy_xor >= C[n-1] /\
A[n-1]+B[n-1]+C[n-1] >= 2*dummy_xor /\
A[n-1]+B[n-1]+C[n-1] <= 3;


predicate modular_addition(var 0..1:a,var 0..1:b,var 0..1:c,var 0..1:a1,var 0..1:b1,var 0..1:c1, var 0..1:d) =
b-1*c + d >= 0 /\
a+-b + d >= 0 /\
-a + c + d >= 0 /\
-a-b-c-d >= -3 /\
a +b +c-d >= 0 /\
-b +a1 +b1 +c1 + d >= 0 /\
b +a1-b1 +c1 + d >= 0 /\
b-a1 +b1 +c1 + d >= 0 /\
a +a1 +b1-c1 + d >= 0 /\
c-a1-b1-c1 + d >= -2 /\
-b +a1-b1-c1 + d >= -2 /\
-b-a1 +b1-c1 + d >= -2 /\
-b-a1-b1 +c1 + d >= -2;


% Left rotation of X by val positions
function array[int] of var 0..1: LRot(array[int] of var 0..1: X, int: val)=
let {
    int: n = length(X);
} in 
array1d(0..n-1, [X[(j+val) mod n] | j in 0..n-1]);

% Right rotation of X by val positions
function array[int] of var 0..1: RRot(array[int] of var 0..1: X, int: val)=
let {
    int: n = length(X);
} in 
array1d(0..n-1, [X[(n+j-val) mod n] | j in 0..n-1]);


function array[int] of var 0..1: XOR3(array[int] of var 0..1: X, array[int] of var 0..1: Y, array[int] of var 0..1: Z)=
let {
    int: n = length(X);
} in 
array1d(0..n-1, [(X[j]+Y[j]+Z[j]) mod 2 | j in 0..n-1]);

