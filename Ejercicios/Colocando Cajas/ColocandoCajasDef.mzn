% PROBLEMA: COLOCANDO CAJAS (COLOCAR CAJAS ANCHOxALTO EN UNA SUPERFICIE DADA DE TAMAÑO ANCHOxALTO

% Parámetros de entrada ---------------------------------------
int: ancho;
int: alto;
int: n; % número de cajas
array[1..n, 1..2] of int: cajas; % dimensiones de las cajas (ancho x alto)
constraint assert (ancho * alto = (sum (i in 1..n) (cajas[i,1]*cajas[i,2])), "O bien la superficie no queda cubierta al completo, o bien no entran todas las cajas.");

% Variables ---------------------------------------------------
array[1..n, 1..2] of var 0..max(ancho, alto)-1: esquina_sup_izq; 
array[1..n] of var bool: rotado;

% Restricciones -----------------------------------------------

constraint forall(i in 1..n) ( ((esquina_sup_izq[i,1] + cajas[i,1] - 1 < ancho) /\ (esquina_sup_izq[i,2] + cajas[i,2] - 1 < alto) /\ rotado[i] = false) \/
                               ((esquina_sup_izq[i,1] + cajas[i,2] - 1 < ancho) /\ (esquina_sup_izq[i,2] + cajas[i,1] - 1 < alto) /\ rotado[i] = true)  );                               

constraint forall(i, j in 1..n where i < j) (
    let {
       var int: posIX = if rotado[i] then esquina_sup_izq[i,1] + cajas[i,2] - 1 else esquina_sup_izq[i,1] + cajas[i,1] - 1 endif;
       var int: posIY = if rotado[i] then esquina_sup_izq[i,2] + cajas[i,1] - 1 else esquina_sup_izq[i,2] + cajas[i,2] - 1 endif; 
       var int: posJX = if rotado[j] then esquina_sup_izq[j,1] + cajas[j,2] - 1 else esquina_sup_izq[j,1] + cajas[j,1] - 1 endif;
       var int: posJY = if rotado[j] then esquina_sup_izq[j,2] + cajas[j,1] - 1 else esquina_sup_izq[j,2] + cajas[j,2] - 1 endif; 
    }
    in (posIX < esquina_sup_izq[j,1] \/ posJX < esquina_sup_izq[i,1] \/ posIY < esquina_sup_izq[j,2] \/ posJY < esquina_sup_izq[i,2])
);

% Objetivo: solo para asegurar que haya solución
solve satisfy;

% Salida
output [ "Caja " ++ show(i) ++ ": (" ++ show(esquina_sup_izq[i, 1]) ++ "," ++ show(esquina_sup_izq[i, 2]) ++ ")" ++ if fix(rotado[i]) then "*" else "" endif ++ "\n" | i in 1..n] ;

