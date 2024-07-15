% --------------- ADORNANDO LA CASA POR NAVIDAD -------------------

% DATOS DE ENTRADA -------------------------------
% Numero de objetos que pueden comprar
int: n;
constraint assert ( 1 <= n /\ n <= 30, "El nº de objetos debe estar entre 1 y 30" );

% Presupuesto maximo
int: p;
constraint assert ( p >= 0, "El presupuesto debe ser mayor o igual que cero" );

% Lista de los n objetos con {precio, superficie}
array[1..n, 1..2] of int: objeto;
constraint assert (forall (i in 1..n, j in 1..2) ( 0 <= objeto[i, j] ),
                            "La superficie y precio de los objetos debe ser mayor o igual que cero" );

% Variable solucion
array [1..n] of var 0..1: asig;

% RESTRICCIONES ----------------------------------

% No se puede superar el presupuesto
%  constraint sum(i in 1..n) (asig[i]*objeto[i,1]) <= p; --> Otra forma chula de hacerlo
constraint sum(i in 1..n) (if (asig[i] = 1) then objeto[i,1] else 0 endif) <= p;

solve maximize sum (i in 1..n) (if(asig[i] = 1) then objeto[i,2] else 0 endif);
