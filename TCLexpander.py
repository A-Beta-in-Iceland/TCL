# Primarily used to check whether two factorizations of system terms are

import sympy as sp
import numpy as np
import pandas as pd
from os.path import dirname, join as pjoin
from sympy.physics.quantum import Commutator
from sympy.parsing.sympy_parser import standard_transformations, implicit_multiplication_application

# swap characters in string according to list_of_tuples
def replacechars(string, list_of_tuples):
    if isinstance(string, int):
        string = str(string)
    for replacee, replacer in list_of_tuples:
        string = string.replace(replacee, replacer)
    return string

# replaces brackets ("[]") with "(COM())" because SymPy can't parse brackets
def bracket_to_COM(systemterm):
    # leftbracketindex = -1
    # for i in range(len(systemterm)):
    #     if systemterm[i] == "[":
    #         leftbracketindex = i
    #     if systemterm[i] == "]" and leftbracketindex != -1:
    #         systemterm = (systemterm[:leftbracketindex] + "(COM("
    #                         + systemterm[leftbracketindex+1: i] + "))"
    #                         + systemterm[i+1:] )
    #         break
    #
    # if leftbracketindex == -1:
    #     return systemterm
    # return bracket_to_COM(systemterm)

    return replacechars(systemterm, [("[", "(COM("), ("]", "))")])

# converts string of system term into a SymPy expression
def term_to_expr(term):
    charmap = [("1", "a"), ("2", "b"), ("3", "c"), ("4", "d"), ("5", "e")]

    return sp.parse_expr(bracket_to_COM(replacechars(term, charmap)), local_dict={"COM": Commutator, "a": a, "b": b, "c": c, "d": d, "e": e, "p": p},
                         transformations=standard_transformations + (implicit_multiplication_application,))

a,b,c,d,e,p=sp.symbols('a b c d e p', commutative=False)

# eq_1 = sp.parse_expr("-a(COM(b,(COM(c,pe))d))-a(COM((COM(b,pd))e, c))",
#                     local_dict={"COM": Commutator, "a": a, "b": b, "c": c, "d": d, "e": e, "p": p},
#                     transformations=standard_transformations+(implicit_multiplication_application,))
# print(eq_1)

charmap = [("1", "a"), ("2", "b"), ("3", "c"), ("4", "d"), ("5", "e")]
invcharmap = [("a", "1"), ("b", "2"), ("c", "3"), ("d", "4"), ("e", "5")]

term = "5[2,[1,p4]3]-5[1,[2,p43]]-[2,5[1,p4]3]"
term = replacechars(term, charmap)
term = bracket_to_COM(term)
eq_1 = sp.parse_expr(term, local_dict={"COM": Commutator, "a": a, "b": b, "c": c, "d": d, "e": e, "p": p},
                     transformations=standard_transformations + (implicit_multiplication_application,))
print("eq1 expanded: ", replacechars(str(eq_1.doit().expand()), invcharmap))

fname = pjoin(dirname(__file__), "TCL.xlsx")
unsimplifieddata = pd.read_excel(fname, sheet_name="cumulative correlation terms", usecols="E,H", nrows=100, header=None, skiprows=1)
unsimplifieddata = unsimplifieddata.dropna()
terms = unsimplifieddata.to_numpy()

unsimplifieds = []
for row in terms:
    sum=""
    for term in row:
        sum=sum + "+" + term
    sum=sum[1:]
    unsimplifieds.append(sum)

print(unsimplifieds)

simpdata = pd.read_excel(fname, sheet_name="cumulative correlation terms", usecols="I", nrows=100, header=None, skiprows=1)
simpdata = simpdata.dropna()
simpterms = simpdata.to_numpy().flatten()
print(simpterms.flatten())

print("-----")

# for (unsimplified, simp) in zip(unsimplifieds, simpterms):
#     print(type(simp))

print(term_to_expr(simpterms[0]))

diffs = [(term_to_expr(unsimplified) - term_to_expr(simp)) for (unsimplified, simp) in zip(unsimplifieds, simpterms)]

# prints difference between unreduced terms and reduced terms, fully expanded and cancelled
print(all([diff.doit().expand()==0 for i, diff in enumerate(diffs)]))
