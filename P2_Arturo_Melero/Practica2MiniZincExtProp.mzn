% PRACTICA 2 -- PRODUCCIÓN DE ALIMENTOS

% Los comentarios relativos a las restricciones del problema base se encuentran en el archivo Practica2MiniZincExt.mzn.

% VARIABLES CONSTANTES ---------------------------------------------------------------------------------------------------
% int meses = 6;
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

% MODIFICACIÓN 2: ESPECIFICACIÓN DE LA CAPACIDAD POR TIPO DE ACEITE: INT --> ARRAY [1..ACEITES] OF INT
array [1..aceites] of int: MCAP;
constraint assert (forall (i in 1..aceites) (MCAP[i] >= 0), "La capacidad máxima de almacenamiento debe ser un entero positivo.");

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
constraint assert (forall (i in 1..aceites) (inicial[i] <= MCAP[i]), "La cantidad de aceite en el primer mes no puede ser superior a la capacidad de almacenamiento máxima.");

int: PV;
constraint assert (PV >= 0, "El porcentaje de variación debe ser entero positivo.");

% Parámetros del apartado "Extensiones":
int: K;
constraint assert (K > 1, "El producto debe contener, al menos, dos aceites (al ser mezcla).");
array[1..meses, 1..aceites] of bool: convenio;  % Matriz convenio contiene la matriz de aceites que podemos usar por mes
constraint assert (forall (m in 1..meses) (count(a in 1..aceites) (convenio[m,a]) = K), "Cada mes debe haber exactamente K aceites disponibles.");
int: T;
constraint assert (T >= 0, "El mínimo número de toneladas debe ser un número natural.");

% VARIABLES ----------------------------------------------------------------------------------------------------------------------------------

array[1..meses, 1..aceites] of var int: AceiteAlmacenado;
array[1..meses, 1..aceites] of var int: AceiteComprado;  
array[1..meses, 1..aceites] of var 0..(max(MAXV, MAXN)): AceiteRefinado;
array[1..meses] of var int: beneficio;

% Restricciones adicionales por modificación de MCAP:
constraint forall(m in 1..meses, a in 1..aceites) (AceiteAlmacenado[m,a] >= 0 /\ AceiteAlmacenado[m,a] <= MCAP[a]                  /\
                                                   AceiteComprado[m,a] >= 0   /\ AceiteComprado[m,a]   <= MCAP[a] + max(MAXV,MAXN) );
                                                   
% RESTRICCIONES DEL PROBLEMA ------------------------------------------------------------------------------------------------------------------

% RESTRICCIÓN REFINAMIENTO MAXIMO DEL ACEITE
constraint forall (m in 1..meses) (sum(a in 1..veg) (AceiteRefinado[m,a]) <= MAXV /\ sum(a in veg+1..aceites) (AceiteRefinado[m,a]) <= MAXN);
constraint forall (m in 1..meses) ( let {
      var int: nRef = count(a in 1..aceites) (AceiteRefinado[m,a] > 0);
      } in nRef > 0 -> nRef > 1);
      

% RESTRICCIÓN DE COMPRA DEL ACEITE.


% RESTRICCIONES DE ALMACENAMIENTO.
constraint forall(a in 1..aceites) (AceiteAlmacenado[1,a] = inicial[a]);
constraint forall(m in 2..meses, a in 1..aceites) (AceiteAlmacenado[m,a] = AceiteAlmacenado[m-1,a] + AceiteComprado[m-1,a] - AceiteRefinado[m-1,a]);
constraint forall(a in 1..aceites) ( inicial[a] - inicial[a] * PV/100 <= AceiteAlmacenado[meses,a] + AceiteComprado[meses,a] - AceiteRefinado[meses,a] /\ 
                                     AceiteAlmacenado[meses,a] + AceiteComprado[meses,a] - AceiteRefinado[meses,a] <= inicial[a] + inicial[a] * PV/100 );
                                    
% RESTRICCIÓN DUREZA.
constraint forall(m in 1..meses) (if (exists (a in (veg+1..aceites)) (AceiteRefinado[m,a] > 0)) 
           then ( let { var float: durezaProducto = sum(a in 1..aceites)(dureza[a]*AceiteRefinado[m,a]);
                        var int: cantidadProducto =  sum(a in 1..aceites)(AceiteRefinado[m,a]);         }
                  in MinD * cantidadProducto <= durezaProducto /\ durezaProducto <= MaxD * cantidadProducto) 
           else true endif);


% RESTRICCIONES SOBRE EL BENEFICIO.
constraint forall (m in 1..meses) (beneficio[m] = sum(a in 1..aceites)(AceiteRefinado[m,a] * VALOR - AceiteComprado[m,a] * precios[m,a] - AceiteAlmacenado[m,a] * CA) );
constraint forall (m in 1..meses - 2) (beneficio[m] >= 0 \/ beneficio[m+1] >= 0 \/ beneficio[m+2] >= 0);
constraint sum(m in 1..meses) (beneficio[m]) >= MinB; 


% RESTRCICCIONES DEL APARTADO "EXTENSIONES" Si comentar, comentar también parametros de extensiones.
constraint forall (m in 1..meses) ( let {
        var int: utilizados = sum (a in 1..aceites) (AceiteRefinado[m,a] > 0);
     } in utilizados <= K);
constraint forall (m in 1..meses, a in 1..aceites) (not (convenio[m,a]) -> AceiteRefinado[m,a] = 0);
constraint forall (m in 1..meses, a in 1..aceites) (AceiteRefinado[m,a] > 0 -> AceiteRefinado[m,a] >= T);
constraint forall (m in 1..meses) ((AceiteRefinado[m,3] > 0 \/ AceiteRefinado[m,4] > 0) -> AceiteRefinado[m,2] > 0);


% EXTENSIONES ADICIONALES IMPLEMENTADAS:
% 1) ESPECIFICACIÓN DE MESES. 
%     Se añade como parámetro la variable "meses", de forma que cambiando la matriz de precios y el valor de meses para que coincidan,
%     el resolutor obtiene la planificación para el número de meses establecido.

int: meses;
constraint assert (meses >= 1, "La planificación debe ser para, al menos, de 1 mes.");

% 2) ESPECIFICACIÓN DE MCAP.
%     En lugar de considerar una capacidad máxima para todos los tipos de aceites, consideraremos un máximo para cada uno de ellos.
%     De esta forma, se agrega más variedad y flexibilidad a la planificación.
%     Modificaciones en su parámetro y en rango de variables del problema. Añadida restricción de rango.

% 3) CONSUMO DE ENERGÍA. 
%     La Unión Europea, en su preocupación galopante por el medio ambiente, ofrecerá fondos europeos a las empresas que cumplan
%     con ciertos requisitos de consumo de energía. Para nuestra empresa, se ha establecido un consumo de energía que debemos cumplir 
%     todos los meses para meterle mano a los fondos europeos. Dado que refinamos aceites vegetales y no vegetales, cada tipo de refinamiento
%     consume una energía por tonelada de producto, especificado como parámetro.

int: maxEnergia;
int: consumoVEG;
int: consumoNVEG;
constraint assert(maxEnergia >= 0 /\ consumoVEG >= 0 /\ consumoNVEG >= 0, "Los valores de energía deben ser naturales.");

constraint forall (m in 1..meses) ( (sum (a in 1..aceites) (AceiteRefinado[m,a] * (if a <= 2 then consumoVEG else consumoNVEG endif))) <= maxEnergia );

% 4) FISCALIZACIÓN DE LA ACTIVIDAD EMPRESARIAL.
%     Por la normativa europea, de nuevo, para recibir fondos nuestros beneficios mensuales no pueden superar cierta cuantía, establecida en la variable 
%     maxBeneficio. Tendremos que planificar más conciencudamente si queremos meterle mano a esos fondos, manteniendo nuestros objetivos de beneficio.
%     Como estamos interesados en los fondos para obtener más maquinaria e instalaciones, merece la pena sacrificar los beneficios propios durante algunos meses.

int: maxBeneficio;
constraint assert (maxBeneficio * meses > MinB, "Insatisfactible para el maxBeneficio mensual establecido, considerando el valor de minB.");

constraint forall (m in 1..meses) (beneficio[m] <= maxBeneficio);

% RESOLVEMOS Y PRESENTAMOS LA SOLUCIÓN ----------------------------------------------------------------------------------------------------------

solve maximize (sum(m in 1..meses)(beneficio[m]));
    
output ["\nSolución:\n"];

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
