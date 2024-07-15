#!/usr/bin/python3
from z3 import *
import sys

# nc: numero de colores

nc = int(input())

################################
# generamos un fichero smtlib2
################################

# s = SolverFor("QF_LIA")
s = Solver()

#declaración de variables de la solución

hu = Int("hu")
se = Int("se")
co = Int("co")
ja = Int("ja")
ca = Int("ca")
ma = Int("ma")
gr = Int("gr")
al = Int("al")

s.add(And(1 <= hu,hu <= nc))
s.add(1 <= se)
s.add(se <= nc)
s.add(1 <= co)
s.add(co <= nc)
s.add(1 <= ja)
s.add(ja <= nc)
s.add(1 <= ca)
s.add(ca <= nc)
s.add(1 <= ma)
s.add(ma <= nc)
s.add(1 <= gr)
s.add(gr <= nc)
s.add(1 <= al)
s.add(al <= nc)

# restricciones
s.add(hu != se)
s.add(hu != ca)
s.add(se != ca)
s.add(se != ma)
s.add(se != co)
s.add(ca != ma)
s.add(ma != co)
s.add(ma != gr)
s.add(co != ja)
s.add(co != gr)
s.add(gr != ja)
s.add(gr != al)


# fin declaración
print(s.check())
print(s.model())

print(s.to_smt2())
exit(0)
