% --------------- FUNCIONARIOS -------------------
include "alldifferent.mzn";  

% DATOS DE ENTRADA -------------------------------
% Numero de funcionarios
int: n;
constraint assert ( 1 <= n /\ n <= 20, "El nº de funcionarios debe estar entre 1 y 20" );

% Consumo de cada funcionario
array[1..n, 1..n] of int: t;
constraint assert (forall (i in 1..n, j in 1..n) ( 1 <= t[i, j] /\ t[i, j] <= 10000 ),
                            "Lo que tarda cada funcionario en realizar cada uno de sus N trabajos debe estar entre 1 y 10000" );
% Variable solucion
array[1..n] of var 1..n: asig;

% RESTRICCIONES ----------------------------------
constraint forall(i in 1..n) (alldifferent(asig));

solve minimize sum (i in 1..n) (t[i,asig[i]]);