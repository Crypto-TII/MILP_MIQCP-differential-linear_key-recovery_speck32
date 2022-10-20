Dependencies
------------

    - MiniZinc 2.5.3
    - Gurobi 9.1.1


Usage Example
-------------

Run the following

    minizinc -v -p 50 --workmem 10 -D float_EPS=1e-9  --feasTol 1e-9  -a -f  --solver Gurobi differential_linear_model_speck.mzn
