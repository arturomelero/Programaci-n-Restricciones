from z3 import *

# DECLARACIÓN DE CONSTANTES DEL PROGRAMA ------------------------------------------------------------------------------------

meses = 6
veg = 2
nveg = 3
aceites = veg + nveg

# DECLARACIÓN DE PARÁMETROS DEL PROBLEMA BASE -------------------------------------------------------------------------------

VALOR = int(input())
assert VALOR >= 0, "El valor del producto debe ser positivo para que no se produzcan siempre pérdidas."

dureza1 = input().split()
dureza = []
for i in range(len(dureza1)):
    dureza.append(float(dureza1[i]))
assert all(d >= 0 for d in dureza), "La dureza de los aceites no puede ser negativa."

precios = []
for m in range (meses):
    precioMensual = input().split()
    fila = [int(elem) for elem in precioMensual]
    precios.append(fila)
assert all(p >= 0 for fila in precios for p in fila), "Los precios de los aceites no pueden ser negativos en un mercado saludable."

MAXV = int(input())
assert MAXV >= 0, "La cantidad de aceite vegetal que se puede refinar no puede ser negativa."

MAXN = int(input())
assert MAXN >= 0, "La cantidad de aceite no vegetal que se puede refinar no puede ser negativa."

MCAP = int(input())
assert MCAP >= 0, "La capacidad máxima de almacenamiento debe ser un entero positivo."

CA = int(input())
assert CA >= 0, "Los costes de almacenamiento son siempre enteros positivos."

MinD = float(input())
assert MinD >= 0, "La dureza mínima no puede ser negativa."

MaxD = float(input())
assert MaxD >= 0, "La dureza máxima no puede ser negativa."

MinB = int(input())
assert MinB >= 0, "El beneficio mínimo debe ser un número natural."

inicial1 = input().split()
inicial = []
for i in range(len(inicial1)):
    inicial.append(int(inicial1[i]))
assert all(i >= 0 for i in inicial), "La cantidad de aceite sin refinar inicial por cada tipo no puede ser negativa."
assert all(i <= MCAP for i in inicial), "La cantidad de aceite en el primer mes no puede ser superior a la capacidad de almacenamiento máxima."

PV = int(input())
assert PV >= 0, "El porcentaje de variación debe ser entero positivo."

# PARÁMETROS DEL APARTADO "EXTENSIONES"
K = int(input())
assert K > 0 , "El producto debe contener, al menos, un aceite."

# Matriz convenio contiene la matriz de aceites que podemos usar por mes
convenio = []
for m in range (meses):
    convenioMensual = input().split()
    fila = [bool(int(elem)) for elem in convenioMensual]
    convenio.append(fila)

for m in range(meses):
    assert sum([1 if convenio[m][a] else 0 for a in range(aceites)]) == K, "Cada mes debe haber exactamente K aceites disponibles."

T = int(input())
assert T >= 0, "El mínimo número de toneladas debe ser un número natural." 

# FUNCIONES AUXILIARES -------------------------------------------------------------------------------------------------------------

def almacenadoMA(m, a):
    return "AceiteAlmacenado_" + str(m) + "_" + str(a)

def compradoMA(m,a):
    return "AceiteComprado_" + str(m) + "_" + str(a)

def refinadoMA(m,a):
    return "AceiteRefinado_" + str(m) + "_" + str(a)

def beneficioM(m):
    return "Beneficio_" + str(m);


################################
# generamos un fichero smtlib2
################################

# s = SolverFor("QF_LIA")
s = Optimize()

# DECLARACIÓN DE VARIABLES PARA EL PROCESAMIENTO DEL PROBLEMA ------------------------------------------------------------------------

AceiteAlmacenado = [[Int(almacenadoMA(m, a)) for a in range(aceites)] for m in range(meses)]
AceiteComprado = [[Int(compradoMA(m,a)) for a in range(aceites)] for m in range(meses)]
AceiteRefinado = [[Int(refinadoMA(m,a)) for a in range(aceites)] for m in range(meses)]
beneficio = [Int(beneficioM(m)) for m in range(meses)]


# RESTRICCIONES DEL PROBLEMA BASE ----------------------------------------------------------------------------------------------------

# RESTRICCIONES DOMINIO DE VALORES PARA LAS VARIABLES
for m in range(meses):
    for a in range(aceites):
        # AceiteAlmacenado: 0 <= AceiteAlmacenado <= MCAP
        s.add(0 <= AceiteAlmacenado[m][a], AceiteAlmacenado[m][a] <= MCAP)
        
        # AceiteComprado: 0 <= AceiteComprado <= MCAP + max(MAXV, MAXN)
        s.add(0 <= AceiteComprado[m][a], AceiteComprado[m][a] <= MCAP + max(MAXV, MAXN))
        
        # AceiteRefinado: 0 <= AceiteRefinado <= max(MAXV, MAXN)
        s.add(0 <= AceiteRefinado[m][a], AceiteRefinado[m][a] <= max(MAXV, MAXN))


# RESTRICCIONES REFINAMIENTO MAXIMO DEL ACEITE
for m in range(meses):
    s.add(Sum([AceiteRefinado[m][a] for a in range(veg)]) <= MAXV)
    s.add(Sum([AceiteRefinado[m][a] for a in range(veg, aceites)]) <= MAXN)

# Restricción refinamiento: se puede hacer producto o no hacer nada, pero el producto es combinación de dos o más aceites:
for m in range(meses):
    nRef = Sum([If(AceiteRefinado[m][a] > 0, 1, 0) for a in range(aceites)])
    s.add(Implies(nRef > 0, nRef > 1))


# RESTRICCIONES DE ALMACENAMIENTO
for a in range(aceites):  # El almacenamiento en el primer mes es el almacenado en inicial:
    s.add(AceiteAlmacenado[0][a] == inicial[a])

for m in range(1, meses):    # Cada mes nos queda lo Comprado - Producido + Almacenado(mes anterior), salvo en el primer mes:
    for a in range(aceites):
        s.add(AceiteAlmacenado[m][a] == AceiteAlmacenado[m - 1][a] + AceiteComprado[m - 1][a] - AceiteRefinado[m - 1][a])

for a in range(aceites):  # Restricción sobre el almacenamiento al final de la temporada, considernado variación PV:
    s.add(inicial[a] - inicial[a] * PV / 100 <= AceiteAlmacenado[meses - 1][a] + AceiteComprado[meses - 1][a] - AceiteRefinado[meses - 1][a])
    s.add(AceiteAlmacenado[meses - 1][a] + AceiteComprado[meses - 1][a] - AceiteRefinado[meses - 1][a] <= inicial[a] + inicial[a] * PV / 100)


# RESTRICCIÓN DUREZA
for m in range(meses): # Si se emplea aceite NV para el producto, entonces MinD <= dureza <= MaxD:
    durezaProducto = Sum([dureza[a] * AceiteRefinado[m][a] for a in range(aceites)])
    cantidadProducto = Sum([AceiteRefinado[m][a] for a in range(aceites)])
    s.add(And(MinD * cantidadProducto <= durezaProducto, durezaProducto <= MaxD * cantidadProducto))


# RESTRICCIONES SOBRE EL BENEFICIO
for m in range(meses): # Restricción para el cálculo del beneficio mensual
    s.add(beneficio[m] == Sum([AceiteRefinado[m][a] * VALOR - AceiteComprado[m][a] * precios[m][a] - AceiteAlmacenado[m][a] * CA for a in range(aceites)]))

for m in range(meses - 2): # No hay dos meses consecutivos con pérdidas (si valor producción < coste compra más almacenamiento, del mes)
    s.add(Or(beneficio[m] >= 0, beneficio[m + 1] >= 0, beneficio[m + 2] >= 0))

# Restricción sobre el beneficio mínimo
s.add(Sum([beneficio[m] for m in range(meses)]) >= MinB)



# RESTRICCIONES DEL APARTADO "EXTENSIONES". Si comentar, comentar tambíen parámetros.

# El producto no puede hacerse con más de K aceites
for m in range(meses):
    s.add(sum(a > 0 for a in AceiteRefinado[m]) <= K)

# Además, la selección de aceites que podemos usar es distinta para cada mes:
for m in range(meses):
    for a in range(aceites):
        s.add(Implies(Not(convenio[m][a]), AceiteRefinado[m][a] == 0))

# Si se emplea aceite, se emplea como mínimo T toneladas
for m in range (meses):
    for a in range (aceites):
        s.add(Implies(AceiteRefinado[m][a] > 0, AceiteRefinado[m][a] >= T))

# Si empleamos ANV1 (aceite 3) o ANV2 (aceite 4), hay que usar VEG2 (aceite 2) -- restas para consistencia con miniZinc
for m in range (meses):
    s.add(Implies(Or(AceiteRefinado[m][3-1] > 0, AceiteRefinado[m][4-1] > 0), AceiteRefinado[m][2-1] > 0))


# FUNCION OBJETIVO: MINIMIZAR EL NÚMERO DE ACEITE USADO POR MES
s.minimize(Sum([If(AceiteRefinado[m][a] > 0, 1, 0) for m in range(meses) for a in range(aceites)]))

# IMPRESIÓN BONITA DE LA SOLUCIÓN ---------------------------------------------------------------------------------------------------

if s.check() == sat:
    modelo = s.model()
    print("\nSolución:")
    print("\n\tCompra de aceite:")
    for m in range(meses):
        print("\t\tMes", m, ":", end="\t")
        for a in range(aceites):
            print(modelo[AceiteComprado[m][a]], end="\t")
        print()
    print("\n\tRefinamiento de aceite:")
    for m in range(meses):
        print("\t\tMes", m + 1, ":", end="\t")
        for a in range(aceites):
            print(modelo[AceiteRefinado[m][a]], end="\t")
        print()
    print("\nAlmacenado (final):", end="\t")
    for a in range(aceites):
        print(modelo[AceiteAlmacenado[meses - 1][a]].as_long() + modelo[AceiteComprado[meses - 1][a]].as_long() - modelo[AceiteRefinado[meses - 1][a]].as_long(), end="\t")
    print("\n\nBeneficio de cada mes:", [modelo[beneficio[i]] for i in range(meses)])
    print("\nBeneficio total:", sum([modelo[beneficio[i]].as_long() for i in range(meses)]))
    print("")
#    print("\tAceite almacenado:")
#    for m in range(meses):
#        print("\t\tMes", m + 1, ":", end="\t")
#        for a in range(aceites):
#            print(modelo[AceiteAlmacenado[m][a]], end="\t")
#        print()
else:
    print("No se encontró solución.")

