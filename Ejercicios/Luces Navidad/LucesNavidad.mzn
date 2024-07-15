% ----------------------LUCES DE NAVIDAD---------------
% Longitud de la linea de luces
int: longitud;
constraint assert ( longitud > 0, "La longitud de la línea de luces debe ser mayor que cero" );

% DATOS DE ENTRADA -------------------

% Número de bombillas
int: n;
constraint assert ( n > 0, "El número de bombillas debe ser mayor que cero" );

% Consumo maximo tolerado
int: consumo;
constraint assert ( consumo >= 0, "El consumo máximo debe ser mayor o igual que cero" );

% Consumo de cada bombilla
array[1..n] of int: b;
constraint assert (forall (i in 1..n) ( b[i] >= 0 ),
                            "El consumo de cada bombilla debe ser mayor o igual que cero" );
                            
% Variable solucion
array[1..longitud] of var 1..n: asig;
                            
% RESTRICCIONES -----------------------

% No puede haber más de dos luces seguidas del mismo color
constraint forall (i in 2..longitud-1) (asig[i-1] != asig[i] \/ asig[i] != asig[i+1]);

% En cualquier punto, la suma de las luces de un color son menor o igual a la suma del resto de colores mas 1
constraint forall (i in 1..longitud, t in 1..n) (sum(j in 1..i)(asig[j] = t) <= sum(k in 1..i)(asig[k] != t) + 1);

% La suma del consumo de cada bombilla debe ser menor al consumo maximo tolerable
constraint sum (i in 1..longitud) (b[asig[i]]) <= consumo;

% Aplicamos el resolutor
solve satisfy;
