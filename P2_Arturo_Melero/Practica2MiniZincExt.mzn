% PRACTICA 2 -- PRODUCCIÓN DE ALIMENTOS

% VARIABLES CONSTANTES ---------------------------------------------------------------------------------------------------
int: meses = 6;
int: veg = 2;
int: nveg = 3;
int: aceites = veg + nveg;

% PARÁMETROS DEL PROBLEMA BASE -------------------------------------------------------------------------------------------

int: VALOR;
constraint assert (VALOR >= 0, "El valor del producto debe ser positivo para que no se produzcan siempre pérdidas.");

array [1..aceites] of float: dureza;
constraint assert (forall (i in 1..aceites) (dureza[i] >= 0), "La dureza de los aceites no puede ser negativa.");

array [1..meses, 1..aceites] of int: precios;
constraint assert (forall (j in 1..meses, i in 1..aceites) (precios[j,i] >= 0), "Los precios de los aceites no pueden ser negativos en un mercado saludable.");

int: MAXV;
constraint assert (MAXV >= 0, "La cantidad de aceite vegetal que se puede refinar no puede ser negatiava.");

int: MAXN;
constraint assert (MAXN >= 0, "La cantidad de aceite no vegetal que se puede refinar no puede ser negatiava.");

int: MCAP;
constraint assert (MCAP >= 0, "La capacidad máxima de almacenamiento debe ser un entero positivo.");

int: CA;
constraint assert (CA >= 0, "Los costes de almacenamiento son siempre enteros positivos.");

float: MinD;
constraint assert (MinD >= 0, "La dureza mínima no puede ser negativa.");

float: MaxD;
constraint assert (MaxD >= 0, "La dureza máxima no puede ser negativa.");

int: MinB;
constraint assert (MinB >= 0, "El beneficio mínimo debe ser un número natural.");

array [1..aceites] of int: inicial;
constraint assert (forall (i in 1..aceites) (inicial[i] >= 0), "La cantidad de aceite sin refinar inicial por cada tipo no puede ser negativa.");
constraint assert (forall (i in 1..aceites) (inicial[i] <= MCAP), "La cantidad de aceite en el primer mes no puede ser superior a la capacidad de almacenamiento máxima.");

int: PV;
constraint assert (PV >= 0, "El porcentaje de variación debe ser entero positivo.");

% Parámetros del apartado "Extensiones":
int: K;
constraint assert (K > 1, "El producto debe contener, al menos, dos aceites (al ser mezcla).");
% Matriz convenio contiene la matriz de aceites que podemos usar por mes
array[1..meses, 1..aceites] of bool: convenio;  
constraint assert (forall (m in 1..meses) (count(a in 1..aceites) (convenio[m,a]) = K), "Cada mes debe haber exactamente K aceites disponibles.");
int: T;
constraint assert (T >= 0, "El mínimo número de toneladas debe ser un número natural.");
% VARIABLES ----------------------------------------------------------------------------------------------------------------------------------

% Para la representación de la solución, emplearemos tres matrices que almacenarán, respectivamente, el aceite almacenado (al inicio de cada mes)
% el aceite que se compra de cada tipo en cada mes y la cantidad de aceite que se refina cada mes para cada tipo.
% Utilizaremos un vector adicional para almacenar el beneficio (o pérdida) por mes, para facilitar los cálculos.

array[1..meses, 1..aceites] of var 0..MCAP: AceiteAlmacenado;                    % Como mucho, el almacenado puede ser MCAP
array[1..meses, 1..aceites] of var 0..(MCAP + max(MAXV, MAXN)): AceiteComprado;  % No se comprará más del que se pueda almacenar y refinar
array[1..meses, 1..aceites] of var 0..(max(MAXV, MAXN)): AceiteRefinado;         % No se puede superar la capacidad de refinación por mes
array[1..meses] of var int: beneficio;

% RESTRICCIONES DEL PROBLEMA ------------------------------------------------------------------------------------------------------------------

% RESTRICCIÓN REFINAMIENTO MAXIMO DEL ACEITE
% Refinamiento del aceite vegetal y no vegetal unidos en una sola condición
constraint forall (m in 1..meses) (sum(a in 1..veg) (AceiteRefinado[m,a]) <= MAXV /\ sum(a in veg+1..aceites) (AceiteRefinado[m,a]) <= MAXN);
% Por definición, el producto se forma como combinación de aceites, por lo que debemos refinar, al menos, dos aceites distintos por mes.
constraint forall (m in 1..meses) ( let {
      var int: nRef = count(a in 1..aceites) (AceiteRefinado[m,a] > 0);
      } in nRef > 0 -> nRef > 1);
% Nota. Esta restricción se cumplirá al maximizar el beneficio salvo para casos extremos donde todos los aceites tengan sobrecoste a excepción de uno.
%       Considera la posibilidad de no refinar aceite durante un mes (no hacer producto). Se incluye por las características del problema.


% RESTRICCIÓN DE COMPRA DEL ACEITE.
%   -->  Implícita en resto de restricciones y rango de variables


% RESTRICCIONES DE ALMACENAMIENTO.
% El almacenamiento en el primer mes es el almacenado en inicial:
constraint forall(a in 1..aceites) (AceiteAlmacenado[1,a] = inicial[a]);
% Cada mes nos queda lo que compramos menos lo que producimos en el mismo mes más lo que teníamos del mes anterior, salvo en el primer mes:
constraint forall(m in 2..meses, a in 1..aceites) (AceiteAlmacenado[m,a] = AceiteAlmacenado[m-1,a] + AceiteComprado[m-1,a] - AceiteRefinado[m-1,a]);
% Restricción sobre el almacenamiento al final de la temporada, considernado variación PV:
constraint forall(a in 1..aceites) ( inicial[a] - inicial[a] * PV/100 <= AceiteAlmacenado[meses,a] + AceiteComprado[meses,a] - AceiteRefinado[meses,a] /\ 
                                     AceiteAlmacenado[meses,a] + AceiteComprado[meses,a] - AceiteRefinado[meses,a] <= inicial[a] + inicial[a] * PV/100 );
                                    
% RESTRICCIÓN DUREZA.
% Si se emplea aceite no vegetal para el producto, entonces la dureza debe estar entre MinD y MaxD.
constraint forall(m in 1..meses) (if (exists (a in (veg+1..aceites)) (AceiteRefinado[m,a] > 0)) 
           then ( let { var float: durezaProducto = sum(a in 1..aceites)(dureza[a]*AceiteRefinado[m,a]);
                        var int: cantidadProducto =  sum(a in 1..aceites)(AceiteRefinado[m,a]);         }
                  in MinD * cantidadProducto <= durezaProducto /\ durezaProducto <= MaxD * cantidadProducto) 
           else true endif);
% Nota. Se multiplica cantidadProducto por MinD y MaxD para evitar overflow in floating point operation


% RESTRICCIONES SOBRE EL BENEFICIO.
% Restricción para el cálculo del beneficio mensual
constraint forall (m in 1..meses) (beneficio[m] = sum(a in 1..aceites)(AceiteRefinado[m,a] * VALOR - AceiteComprado[m,a] * precios[m,a] - AceiteAlmacenado[m,a] * CA) );
% No hay dos meses consecutivos con pérdidas (se entiende que hay pérdida si el valor de la producción es menor al coste de compra más almacenamiento del mes)
constraint forall (m in 1..meses - 2) (beneficio[m] >= 0 \/ beneficio[m+1] >= 0 \/ beneficio[m+2] >= 0);
% El beneficio total es mayor que minB
constraint sum(m in 1..meses) (beneficio[m]) >= MinB; 


% RESTRCICCIONES DEL APARTADO "EXTENSIONES" Si comentar, comentar también parametros de extensiones.
% El producto no puede hacerse con más de K aceites
constraint forall (m in 1..meses) ( let {
        var int: utilizados = sum (a in 1..aceites) (AceiteRefinado[m,a] > 0);
     } in utilizados <= K);
constraint forall (m in 1..meses, a in 1..aceites) (not (convenio[m,a]) -> AceiteRefinado[m,a] = 0);
     
% Si se emplea aceite, se emplea como mínimo T toneladas
constraint forall (m in 1..meses, a in 1..aceites) (AceiteRefinado[m,a] > 0 -> AceiteRefinado[m,a] >= T);

% Si empleamos ANV1 (aceite 3) o ANV2 (aceite 4), hay que usar VEG2 (aceite 2)
constraint forall (m in 1..meses) ((AceiteRefinado[m,3] > 0 \/ AceiteRefinado[m,4] > 0) -> AceiteRefinado[m,2] > 0);


% RESOLVEMOS Y PRESENTAMOS LA SOLUCIÓN ----------------------------------------------------------------------------------------------------------

solve maximize (sum(m in 1..meses)(beneficio[m]));
    
output ["Solución:\n"];

output ["\t", "Compra de aceite:"];
output [ if a == 1 then "\n\t\tMes " ++ show(m) ++ ":\t" ++ show(AceiteComprado[m, a])
         else "\t" ++ show(AceiteComprado[m, a])
         endif | m in 1..meses, a in 1..aceites];
         
output ["\n\n\t", "Refinamiento de aceite:"];
output [ if a == 1 then "\n\t\tMes " ++ show(m) ++ ":\t" ++ show(AceiteRefinado[m, a])
         else "\t" ++ show(AceiteRefinado[m, a])
         endif | m in 1..meses, a in 1..aceites];

% Impresiones temporales para comprobar la solución:
output ["\n\nAlmacenado (final):"];
output [ if a == 1 then "\n\t\t\t" ++ show(AceiteAlmacenado[meses,a] + AceiteComprado[meses,a] - AceiteRefinado[meses,a])
         else "\t" ++ show(AceiteAlmacenado[meses,a] + AceiteComprado[meses,a] - AceiteRefinado[meses,a])
         endif | a in 1..aceites];
output ["\nBeneficio de cada mes: ", show(beneficio), "\n"];
output ["\nBeneficio total: ", show(sum(m in 1..meses)(beneficio[m])), "\n"];
%output ["\t", "Aceite almacenado:"];
%output [ if a == 1 then "\n\t\tMes " ++ show(m) ++ ":\t" ++ show(AceiteAlmacenado[m, a])
%         else "\t" ++ show(AceiteAlmacenado[m, a])
%         endif | m in 1..meses, a in 1..aceites];
%

