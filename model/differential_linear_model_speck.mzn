include "differential_operations.mzn";
include "continuous_operations.mzn";
include "linear_operations.mzn";
include "common_operations.mzn";



int: word_size = 16; 
% parameters for the differential part (top part)
int: nr_diff = 4; 
array [0..nr_diff, 0..word_size-1] of var 0..1: left_diff;  % Left word of the state, at the beginning of the round
array [0..nr_diff, 0..word_size-1] of var 0..1: right_diff;  % Right word of the state, at the beginning of the round
array [0..nr_diff, 0..word_size-1] of var 0..1: dummy_xor;  % dummy variables for the xor operator in the differential part (see [KaiFu2016])
array [0..nr_diff] of var 0..1: round_dummy;  % dummy variables for the round part (see [KaiFu2016])
array [0..nr_diff-1, 0..word_size-2] of var int: p_diff; % variables to store the probability for the differential part
var 0..4*word_size: diff_probability; % variable used to store the sum of p_diff

% parameters for the differential-linear part (middle part)
int:nr_diffLin = 2; % Number of rounds for the differential-linear part
array [0..nr_diffLin, 0..word_size-1] of var lower..upper: diffLin_left;  % Left word of the state, at the beginning of the round for the differential-linear part
array [0..nr_diffLin, 0..word_size-1] of var lower..upper: diffLin_right;  % Right word of the state, at the beginning of the round for the differential-linear part
var lower..upper: diffLin_corr; % variable used to store the correlation for the middle part
var lower..upper: diffLinComplement_corr; % variable to store the approximation of f(r) = -log2(|r|) 

% parameters for the linear part
int: nr_lin = 3; % Number of rounds for the linear part (bottom part)
array [0..nr_lin, 0..1, 0..word_size-1]  of var 0..1: lin_state; 
array [0..nr_lin, 0..word_size-1]  of var 0..1: lin_fork1; % dummy variable for the fork operation (see [KaiFu2016])
array [0..nr_lin, 0..word_size-1]  of var 0..1: lin_fork2; % dummy variable for the fork operation (see [KaiFu2016])
array [0..nr_lin, 0..1, 0..word_size-1]  of var 0..1: lin_dummy; % dummy variable for the fork operation (see [KaiFu2016])
array [0..nr_lin, 0..word_size] of var 0..1: p_lin; % variables to store the probability for the linear part
var 0..4*word_size: lin_corr; 


% model for the differential part
predicate diff_round (
  array[0..word_size-1] of var 0..1: x0, 
  array[0..word_size-1] of var 0..1: x1, 
  array[0..word_size-2] of var 0..1: p_round, 
  array[0..word_size-1] of var 0..1: y0, 
  array[0..word_size-1] of var 0..1: y1, 
  array[0..word_size-1] of var 0..1: roundDummy_xor, 
  var 0..1: roundDummy_temp, 
  int: r
) = (
  let {
    array [0..word_size-1] of var 0..1: x2 = RRot(x0, rr),
    array [0..word_size-1] of var 0..1: x3 = LRot(x1, lr),
  } in
  xor_word(x3, y1, y0, roundDummy_xor) /\
  diff_modular_addition_word(x2, x1, y0, roundDummy_temp, p_round, r)
);

constraint forall (i in 1..nr_diff) (
 diff_round(
   row(left_diff,i-1), 
   row(right_diff,i-1), 
   row(p_diff, i-1), 
   row(left_diff,i), 
   row(right_diff,i), 
   row(dummy_xor,i), 
   round_dummy[i], 
   i
 )
) /\ (sum((row(left_diff,0))) + sum(row(right_diff,0)) >= 1);

% model for the differential-linear part
function array [int] of var lower..upper: continuous_round(array [int] of var lower..upper: xx, array [int] of var lower..upper: yy) = 
let { 
    int: n = length(xx);
    array [int] of var lower..upper: rrr = continuous_RRot(xx, 7);
    array [int] of var lower..upper: lll = continuous_LRot(yy, 2);
} in
array1d(
  0..2*word_size-1, 
  continuous_modadd(rrr, yy) ++ continuous_xor(continuous_modadd(rrr, yy), lll)
);

constraint forall (i in 0..nr_diffLin-1) (
 continuous_round(row(diffLin_left,i),row(diffLin_right,i)) = 
   array1d(0..2*word_size-1, row(diffLin_left,i+1)++row(diffLin_right,i+1))
 );

% model for the linear part
predicate linear_round(
  array [0..1, 0..word_size-1] of var 0..1 : X, 
  array [0..word_size] of var 0..1 : p, 
  array [0..1, 0..word_size-1] of var 0..1 : Y,  
  array [0..1, 0..word_size-1] of var 0..1 : dummy_temp, 
  array [0..word_size-1] of var 0..1 : lin_fork1_,
  array [0..word_size-1] of var 0..1 : lin_fork2_,
  int: round) = (
   let {
     array [0..word_size-1] of var 0..1: lin_fork1,
     array [0..word_size-1] of var 0..1: lin_fork2,
     array [0..word_size-1] of var 0..1: Y4,
     array [0..word_size-1] of var 0..1: Y2,
   } in
   linear_modular_addition_word(RRot(X[0,0..word_size-1], 7), lin_fork2_, lin_fork1_, p)/\
   three_way_fork_word(X[1,0..word_size-1],lin_fork2_, RRot(Y[1,0..word_size-1], 2) , dummy_temp[0,0..word_size-1]) /\
   three_way_fork_word(lin_fork1_,Y[1, 0..word_size-1], Y[0, 0..word_size-1], dummy_temp[1,0..word_size-1]) 
 );

constraint forall (i in 1..nr_lin) (
 linear_round(
   lin_state[i-1, 0..1, 0..word_size-1], 
   p_lin[i-1, 0..word_size], 
   lin_state[i, 0..1, 0..word_size-1], 
   lin_dummy[i-1, 0..1, 0..word_size-1], 
   lin_fork1[i-1, 0..word_size-1],
   lin_fork2[i-1, 0..word_size-1],
   i-1)
 ) /\ (sum(lin_state[0, 0..1, 0..word_size-1])>0);


 
% Rotational constants
int: lr=if word_size = 16 then 2 else 3 endif; % left rotation value : 2 for speck 32, 3 otherwise
int: rr=if word_size = 16 then 7 else 8 endif; % right rotation value : 7 for speck 32, 8 otherwise

% connecting the differential part with the differential-linear part
constraint forall(i in 0..word_size-1)(
             if left_diff[nr_diff, i] = 0 then 
               diffLin_left[0, i] = -1 
             else 
               diffLin_left[0, i] = 1 
             endif
           );
constraint forall(i in 0..word_size-1)(
             if right_diff[nr_diff, i] = 0 then 
               diffLin_right[0, i] = -1 
             else 
               diffLin_right[0, i] = 1 
             endif
           );

% connecting the differential-linear part with the linear part
array [1..2*word_size] of var lower..upper: linear_mask_times_diff_lin_output=array1d(0..word_size-1, [if lin_state[0, 0, i]=0 then 1 else lin_state[0, 0, i]*(abs(row(diffLin_left,nr_diffLin)[i])) endif |i in 0..word_size-1])++array1d(0..word_size-1, [if lin_state[0, 1, i]=0 then 1 else lin_state[0, 1, i]*(abs(row(diffLin_right,nr_diffLin)[i])) endif |i in 0..word_size-1]);

constraint diffLin_corr = product(linear_mask_times_diff_lin_output);
constraint diffLin_corr != 0.0;



% equation 6 of the paper
constraint diffLinComplement_corr =
if diffLin_corr <= 0.001021453702391378 then
-19931.57001201849*diffLin_corr+29.89737278555626
elseif diffLin_corr <= 0.004151650554233785 /\ diffLin_corr > 0.002000001 then
-584.962260272084*diffLin_corr+10.13570866882117
elseif diffLin_corr <= 0.01359667098324998 /\ diffLin_corr > 0.007000001 then
-192.6450521799878*diffLin_corr+8.506944714410169
elseif diffLin_corr <= 0.05399137458004444 /\ diffLin_corr > 0.028000001 then
-50.62607129324977*diffLin_corr+6.575959357916722
elseif diffLin_corr <= 0.1420480516058986 /\ diffLin_corr > 0.121000001 then
-11.87410019056137*diffLin_corr+4.483687170396419
elseif diffLin_corr <= 0.2463455066216964 /\ diffLin_corr > 0.167000001 then
-8.613130253286352*diffLin_corr+4.020472744461092
elseif diffLin_corr <= 0.595815289564374 /\ diffLin_corr > 0.383000001 then
-3.761918786389538*diffLin_corr+2.825398597919413
elseif diffLin_corr <= 0.998000001 /\ diffLin_corr > 0.595815289564374 then
-1.444862453710759*diffLin_corr+1.44486100812744
else
1=1
endif;



% getting the exponent of the probability for the top part
constraint diff_probability = sum(p_diff);
% getting the exponent of the probability for the bottom part
constraint lin_corr = sum(p_lin[0..nr_lin, 0..word_size-1]);

solve :: float_search(diffLin_left,0.000000000001,smallest,indomain_min,complete)
      minimize diffLinComplement_corr+diff_probability+2*lin_corr;

output["Differential Part: Round " ++ show(i) ++ "\n" ++ show(left_diff[i, 0..word_size-1]) ++ show(right_diff[i, 0..word_size -1]) ++ "\n"  | i in 0..nr_diff];
output["Differential-Linear Part: Round " ++ show(i) ++ "\n" ++show(diffLin_left[i, 0..word_size-1]) ++ show(diffLin_right[i, 0..word_size-1]) ++ "\n"  | i in 0..nr_diffLin];
output["Linear Part: Round " ++ show(i) ++ "\n" ++ show(lin_state[i, 0, 0..word_size-1]) ++ show(lin_state[i,1,0..word_size-1]) ++ "\n"  | i in 0..nr_lin];
output["\n"];
output["Differential Probability: " ++ show(diff_probability)];
output["\n"];
output["Differential-Linear Probability: " ++ show(diffLin_corr)];
output["\n"];
output["Linear Probability: " ++ show(lin_corr)];
output["\n"];
output["Total Number of Rounds:" ++ show(nr_diff+nr_diffLin+nr_lin)];
output["\n"];
output["Total Probability:" ++ show(log2(diffLin_corr)-diff_probability-2*lin_corr)];
%output["\n"];
%output["Python Format Distinguisher"];
%output["\n"];
%output["diff_left = int('" ++ int_array_to_bin_str(row(left_diff,0)) ++ "', 2)"];
%output["\n"];
%output["diff_right = int('" ++ int_array_to_bin_str(row(right_diff,0)) ++ "', 2)"];
%output["\n"];
%output["lin_mask_left = int('" ++ int_array_to_bin_str(lin_state[nr_lin, 0, 0..word_size-1]) ++ "', 2)"];
%output["\n"];
%output["lin_mask_right = int('" ++ int_array_to_bin_str(lin_state[nr_lin, 1, 0..word_size-1]) ++ "', 2)"];


