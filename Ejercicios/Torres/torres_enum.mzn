% ----------------------------------------- TORRES DE COLORES -----------------------------------------
% Parámetros de entrada: Altura y Array capacidad, se generan torres de altura entre [altura, numTotalPiezas]

int: altura; % Altura de la torre
array[1..3] of int: capacidad;

% Tipo enumerado Colores:
enum Colores = {azul,rojo,verde,nada};

int: piezas = sum(capacidad);
int: max_ceros = piezas - altura;

array[1..piezas] of var Colores: torre; % Representa el color de cada pieza en la torre
                                    % a = 1, r = 2, v = 3, vacio = 0 

% Restricciones del problema: -------------------------------------------------------------------

% Restricciones sobre las piezas vacías
constraint sum([torre[i] = nada | i in 1..piezas]) <= max_ceros; % Número de ceros menor o igual a max_ceros
constraint forall(i in 1..altura) (torre[i] != nada); % No puede haber huecos entre las piezas
constraint forall(i in altura..piezas-1) (torre[i] = nada -> torre[i+1] = nada); % Todos los 0 están al final

% Restricciones sobre el numero de piezas de la torre
constraint sum([torre[i] = azul  | i in 1..piezas]) <= capacidad[azul];  % Número de piezas azules es <= a
constraint sum([torre[i] = rojo  | i in 1..piezas]) <= capacidad[rojo];  % Número de piezas rojas es  <= r
constraint sum([torre[i] = verde | i in 1..piezas]) <= capacidad[verde];  % Número de piezas verdes es <= v

% No hay dos piezas verdes seguidas  
constraint forall(i in 2..piezas) (torre[i-1] != verde \/ torre[i] != verde); 

% El nº de piezas verdes es inferior o igual al de azules en todo momento
constraint forall(i in 1..piezas)(sum(j in 1..i)(torre[j] = verde) <= sum(k in 1..i)(torre[k] = azul));

% El nº de piezas rojas debe ser mayor al nº piezas verdes + azules al final
constraint sum(i in 1..piezas) (torre[i] = rojo) > (sum(i in 1..piezas) (torre[i] = azul \/ torre[i] = verde));

% La pieza inferior es roja
constraint torre[1] = rojo; 

% Encontrar una solución
solve satisfy;

% Mostrar la solución
output ["Torre : ", show(torre)]; 