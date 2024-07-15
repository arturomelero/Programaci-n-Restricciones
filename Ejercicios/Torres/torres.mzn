% ----------------------------------------- TORRES DE COLORES -----------------------------------------
% Parámetros de entrada: Altura y Array capacidad, se generan torres de altura entre [altura, numTotalPiezas]

int: altura; % Altura de la torre
array[1..3] of int: capacidad;

int: piezas = sum(capacidad);
int: max_ceros = piezas - altura;

array[1..piezas] of var 0..3: torre; % Representa el color de cada pieza en la torre
                                     % a = 1, r = 2, v = 3, vacio = 0 

% Restricciones del problema: -------------------------------------------------------------------

% Restricciones sobre las piezas vacías
constraint sum([torre[i] = 0 | i in 1..piezas]) <= max_ceros; % Número de ceros menor o igual a max_ceros
constraint forall(i in 1..altura) (torre[i] != 0); % No puede haber huecos entre las piezas
constraint forall(i in altura..piezas-1) (torre[i] = 0 -> torre[i+1] = 0); % Todos los 0 están al final

% Restricciones sobre el numero de piezas de la torre
constraint sum([torre[i] = 1 | i in 1..piezas]) <= capacidad[1];  % Número de piezas azules es <= a
constraint sum([torre[i] = 2 | i in 1..piezas]) <= capacidad[2];  % Número de piezas rojas es  <= r
constraint sum([torre[i] = 3 | i in 1..piezas]) <= capacidad[3];  % Número de piezas verdes es <= v

% No hay dos piezas verdes seguidas  
constraint forall(i in 2..piezas) (torre[i-1] != 3 \/ torre[i] != 3); 

% El nº de piezas verdes es inferior o igual al de azules en todo momento
constraint forall(i in 1..piezas)(sum(j in 1..i)(torre[j] = 3) <= sum(k in 1..i)(torre[k] = 1));

% El nº de piezas rojas debe ser mayor al nº piezas verdes + azules al final
constraint sum(i in 1..piezas) (torre[i] = 2) > (sum(i in 1..piezas) (torre[i] = 1) + sum(i in 1..piezas) (torre[i] = 3));

% La pieza inferior es roja
constraint torre[1] = 2; 

% Encontrar una solución
solve satisfy;

% Mostrar la solución
output ["Torre : ", show(torre)]; 