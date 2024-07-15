
% PRIMERA PRACTICA DE PROGRAMACION CON RESTRICCIONES (EVAL TIPO A) --> PROBLEMA DE SATISFACCION TURNOS DE UNA FABRICA



% PARAMETROS DE ENTRADA: ---------------------------------------------------------------------------------------------

int: D;                                  % Dias para los que debemos planificar los turnos
int: T;                                  % Numero de trabajadores
int: N1;                                 % Numero de trabajadores en T1
int: N2;                                 % Numero de trabajadores en T2
int: N3;                                 % Numero de trabajadores en T3
int: MaxDT;                              % Maximo dias consec que un trabajador puede trabajar
int: MaxDL;                              % Maximo dias consec que un trabajador puede librar
int: MinDT;                              % Minimo dias que un trabajador debe trabajar
int: A;                                  % Cada trabajador en turno tiene que estar con al menos A trabajadores afines
array [1..T, 1..T] of bool: afines;      % Matriz de booleanos con las afinidades de los trabajadores
set of 1..T: R;                          % Conjunto de encargados. Debe haber al menos uno en cada turno



% RESTRICCIONES PARA DESCARTAR ENTRADAS SIN SOLUCION: ----------------------------------------------------------------

% 1) Restricciones para los valores de los parametros de entrada
constraint assert (D >= 0 /\ T >= 0 /\ N1 >= 0 /\ N2 >= 0 /\ N3 >= 0 /\ MaxDT >= 0 /\ MaxDL >= 0 /\ MinDT >= 0 /\ A >= 0, "\n\t---> Los parámetros de entrada deben ser >= 0...");

% 2) Restricciones para la cantidad de encargados
constraint assert (length(R) >= 3, "\n\t---> No hay suficientes encargados para cubrir los tres turnos...");

% 3) Debe haber al menos suficientes trabajadores para cubrir los turnos
constraint assert (N1+N2+N3 <= T, "\n\t---> No hay suficientes trabajadores para cubrir los turnos...");

% 4) Todos los trabajadores pueden trabajar al menos MinDT
constraint assert (MinDT <= (D*(N1+N2+N3) / T), "\n\t---> Imposible satisfacer que todos los trabajadores trabajen al menos MinDT dias...");

% 5) Todos los trabajadores pueden trabajar como mucho MaxDT dias consecutivos
constraint assert (if (D = ceil(D*(N1+N2+N3) / T) \/ length(R) = 3) then MaxDT >= D else true endif, 
                    "\n\t---> Imposible satisfacer que todos los trabajadores trabajen como mucho MaxDT dias...");

% 6) El numero de personas por turno siempre debe ser mayor o igual al numero de personas afines por turno
constraint assert (A < N1 /\ A < N2 /\ A < N3 /\ forall(i in 1..T) (sum(j in 1..T)(afines[i,j]) >= A), "\n\t---> Imposible satisfacer la afinidad de los empleados en turno...");



% VARIABLES: ---------------------------------------------------------------------------------------------------------

% Representacion: matriz de D filas x T columnas, con sol[i,j] turno que realiza el trabajador j en el dia i
array [1..D, 1..T] of var 0..3: sol;             % Turno asociado a cada trabajador por dia con | 0 -> libre    2 -> T2
                                                 %                                              | 1 -> T1       3 -> T3



% RESTRICCIONES DEL PROBLEMA: ----------------------------------------------------------------------------------------

% 1) Cada turno tiene el num de trabajadores (“N1”, “N2” o “N3”) que le corresponde.
constraint forall(i in 1..D)( sum(j in 1..T)(sol[i,j] = 1) = N1 /\
                              sum(j in 1..T)(sol[i,j] = 2) = N2 /\
                              sum(j in 1..T)(sol[i,j] = 3) = N3
);                               

% 2) Un trabajador solo puede estar en un turno cada dia. --> Se cumple por construccion

% 3) Dado un numero “MaxDT”, garantizar que nadie trabaja “MaxDT” días consecutivos.
constraint forall(j in 1..T, i in 1..D - MaxDT) ((sum (k in i..i + MaxDT) (sol[k,j] != 0)) <= MaxDT);

% 4) Dado un numero “MaxDL”, garantizar que nadie tiene “MaxDL” dias libres consecutivos
constraint forall(j in 1..T, i in 1..D - MaxDL) (sum (k in i..i + MaxDL) (sol[k,j] = 0) <= MaxDL);

% 5) Dado un numero “MinDT”, garantizar que todos trabajan como minimo “MinDT” en los “D” dias.
constraint forall (j in 1..T) ( (sum(i in 1..D) (sol[i, j] != 0)) >= MinDT );

% 6) Si un trabajador hace el ultimo turno de un dia entonces no puede tener el primero del dia siguiente.
constraint forall (j in 1..T, i in 1..D-1) (sol[i,j] = 3 -> sol[i+1,j] != 1);

% 7) Si un trabajador hace el ultimo turno dos dias seguidos entonces tiene que librar el dia siguiente.
constraint forall (j in 1..T, i in 1..D-2) (sol[i,j] = 3 /\ sol[i+1,j] = 3 -> sol[i+2,j] = 0);

% 8) Dada una serie de parejas de trabajadores afines, que se indicarán con una matriz 1..T x 1..T de Booleanos “afines”, 
%    y un número “A”, cada trabajador de un turno tiene que estar con al menos A trabajadores afines en ese turno.
constraint forall(i in 1..D, j in 1..T where sol[i,j] != 0) ( sum(k in 1..T where afines[j,k] /\ j!= k) (sol[i,j] = sol[i,k]) >= A );

% 9) Sea “R” el conjunto de trabajadores (que se obtendrá como un set of números de trabajador) que tienen la categoría de 
%    encargados. En cada turno debe haber al menos un responsable.
constraint forall(i in 1..D, t in 1..3) ( exists(j in R)(sol[i,j] == t) );


% Resolucion: --------------------------------------------------------------------------------------------------------
solve satisfy;

% Output: ------------------------------------------------------------------------------------------------------------

output [ if j == 1 then "Dia " ++ show(i) ++ ":\t[" else "" endif ++  
         if j != T then show(sol[i,j]) ++ ", " else show(sol[i,j]) ++ "]\n" endif |
         i in 1..D, j in 1..T
];


