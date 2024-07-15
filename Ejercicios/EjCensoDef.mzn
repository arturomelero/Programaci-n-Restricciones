% Ejercicio Censo --> 3 hijos cuyo producto de sus edades es 36 y la suma coincide con el num de la casa de al lado.
% Como con estos datos no sabemos las edades, es porque la solución debe ser necesariamente coincidente, es decir,
% distintas combinaciones de edades que cumplen con la primera restricción producen la misma suma como resultado.
% Al considerar que el primer hijo es mayor a los anteriores, obtenemos la solución.

% Variables para el primer cálculo -> n1 primer hijo, n2 segundo, n3 tercero
var 1..36: na1;
var 1..36: na2;
var 1..36: na3;

% Variables para el segundo cálculo -> n1 primer hijo, n2 segundo, n3 tercero
var 1..36: nb1;
var 1..36: nb2;
var 1..36: nb3;

% El producto de las edades da 36 y consideramos que cualquiera puede coincidir en edad con cualquier otro
constraint na1 * na2 * na3 == 36 /\ na3 <= na2 /\ na2 <= na1;

% El producto de las edades da 36 y consideramos que el primero es estrictamente mayor
constraint nb1 * nb2 * nb3 == 36 /\ nb3 <= nb2 /\ nb2  < nb1;

% Los valores suma deben coincidir, pero las edades de los hijos deben ser diferentes
constraint (na1 + na2 + na3) == (nb1 + nb2 + nb3) /\ (na1 != nb1 \/ na2 != nb2 \/ na3 != nb3);

% Solve the model
solve satisfy;

% Output result
output ["Edades de los niños: ", show(nb1), ", ", show(nb2), ", ", show(nb3), "\n",
        "Numero de la casa de al lado: ", show(nb1 + nb2 + nb3), "\n"];
