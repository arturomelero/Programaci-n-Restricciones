% --------------- ESCUCHANDO MUSICA -------------------
include "alldifferent.mzn";  

% DATOS DE ENTRADA -------------------------------

% Numero de canciones
int: n;
constraint assert ( 1 <= n /\ n <= 50, "El nº de canciones debe estar entre 1 y 50" );

% Tiempo que dura el viaje de ida
int: t1;
constraint assert ( t1 >= 1, "El tiempo que dura el viaje de ida debe ser mayor o igual que uno" );

% Tiempo que dura el viaje de vuelta
int: t2;
constraint assert ( t1 >= 1 /\ t2 <= 100, "El tiempo que dura el viaje de vuelta debe estar entre 1 y 100" );

% Lista de las n canciones con {duracion, satisfaccion}
array[1..n, 1..2] of int: cancion;
constraint assert (forall (i in 1..n, j in 1..2) ( 0 <= cancion[i, j] ),
                            "La duracion y satisfaccion de las canciones debe ser mayor o igual que cero" );

% Variables solucion: 0 -> No escojo, 1 -> ida, 2 -> vuelta
array [1..n] of var 0..2: asig;

% RESTRICCIONES ----------------------------------

% No se puede superar el tiempo de ida en la seleccion de ida ni el de vuelta en el de vuelta
constraint sum(i in 1..n) (if (asig[i] = 1) then cancion[i,1] else 0 endif) <= t1 /\ sum(i in 1..n) (if (asig[i] = 2) then cancion[i,1] else 0 endif) <= t2;

solve maximize sum (i in 1..n) (if(asig[i] = 1 \/ asig[i] = 2) then cancion[i,2] else 0 endif);
