# Fully expand and collect the "Reduced Nonzero Terms" sheet, including the Hadamard products.

import TCL6HadamardReducer
import sympy as sp
import numpy as np
import pandas as pd
import itertools
from os.path import dirname, join as pjoin
from sympy.physics.quantum import Commutator
from sympy import Function
from sympy.parsing.sympy_parser import standard_transformations, implicit_multiplication_application


class CustomHadamard(Function):
    @classmethod
    def eval(cls, x,y):
        pass

    def _eval_expand_mul(self, *, expand_hadamard=True, **hints):
        if not expand_hadamard:
            return self

        x, y = self.args
        xargs = sp.Add.make_args(x)
        yargs = sp.Add.make_args(y)

        if ((x,) == xargs and (y,) == yargs
            and sp.Mul.make_args(x)[0] != -1 and sp.Mul.make_args(y)[0] != -1):
            return self

        # distribute hadamard product over addition

        cstmHLst = []

        for xterm in xargs:
            for yterm in yargs:
                # make everything positive in the hadamard inputs
                # by extracting a -1 from the inputs if negative
                # maybe this should be generalized for complex phase
                coeffs = [-1 if sp.Mul.make_args(term)[0] == -1 else 1
                        for term in (xterm, yterm)]

                cstmHLst.append(coeffs[0]*coeffs[1]*
                        CustomHadamard(coeffs[0]*xterm,coeffs[1]*yterm))

        return sp.Add(*cstmHLst)

    def _sympystr(self, printer):
        a, b = [printer.doprint(i) for i in self.args]
        return f"({a})@({b})"

# swap characters in string according to list_of_tuples
def replacechars(string, list_of_tuples):
    if isinstance(string, int):
        string = str(string)
    for replacee, replacer in list_of_tuples:
        string = string.replace(replacee, replacer)
    return string

# replaces brackets ("[]") with "(COM())" because SymPy can't parse brackets
def bracket_to_COM(systemterm):

    return replacechars(systemterm, [("[", "(COM("), ("]", "))")])

# converts string of system term into a SymPy expression
def term_to_expr(term):

    return sp.parse_expr(bracket_to_COM(term),
                        local_dict=
                        ({"COM": Commutator, "H": CustomHadamard, "a": a, "b": b, "p": p, "t": t}
                        | dict(zip(GList, GSymbols))),
                        transformations=standard_transformations + (implicit_multiplication_application,))

# Generate list of gamma terms that should be recognized by SymPy
# i.e. G0t, GTab, etc.
fconcat = lambda tup: ''.join(tup)
GList = list(map(fconcat, itertools.product(['G', 'GT'],
        map(fconcat, itertools.permutations(['0', 't', 'a', 'b'], 2)))))
a,b,t,p,*GSymbols=sp.symbols('a b t p {}'.format(' '.join(GList)), commutative=False)


if __name__ == '__main__':

    # # Example:
    # term = "-[a,H(t,GTt0-GTta)]bp[H(b,Gab),H(a,Gba-G0a)] - aH(t,GTt0)bpH(a,-G0a)H(b,Gab)"
    # eq_1 = term_to_expr(term)
    # print(eq_1.doit().expand(expand_hadamard=False))

    # File processing:

    fname = pjoin(dirname(__file__), "TCL_Integrals.xlsx")

    corrterms = pd.read_excel(fname, sheet_name="Nonzero Terms", usecols="A", nrows=70, header=None, skiprows=1)
    corrterms = corrterms.to_numpy().flatten()

    integrals = pd.read_excel(fname, sheet_name="Nonzero Terms", usecols="B,C,D", nrows=70, header=None, skiprows=1)
    integrals = integrals.to_numpy()

    systemterms = pd.read_excel(fname, sheet_name="Nonzero Terms", usecols="E", nrows=70, header=None, skiprows=1)
    systemterms = systemterms.to_numpy().flatten()

    reducedsystemterms = np.full(integrals.shape, '', dtype=object)

    # go through all correlation terms
    for i, corrterm in enumerate(corrterms):
        # check if row is blank
        if not isinstance(corrterm, float):
            # go through all integrals in that row
            for j, integral in enumerate(integrals[i]):
                # check if integral is blank
                if not isinstance(integral, float):
                    # integral[1:] to exclude sign
                    # perform reduction on integral/system term with corresponding corr term
                    new_integral, reduced_term = TCL6HadamardReducer.replace_dummy_variables(
                        *TCL6HadamardReducer.perform_hadamard_reduction(integral[1:], corrterm, systemterms[i],
                            hadamard_prod_printer = lambda x,y: f"H({x},{y})", conform_zero_operator=True))
                    integrals[i,j] = integral[0] + new_integral
                    reducedsystemterms[i,j] = reduced_term

    systemtermlist = []
    for i, systemrow in enumerate(reducedsystemterms):
        for j, systemterm in enumerate(systemrow):
            if systemterm != "":
                systemtermlist.append(term_to_expr(systemterm)*
                (-1 if integrals[i,j][0] == "-" else 1))

    """
    Counting the number of terms at different steps in the expansion/reduction process:
    Expected results:
        - # of terms with commutators and hadamard products left factored as is: 152
        - with commutators expanded but hadamard products left factored: 762
        - with commutators and hadamard terms expanded but before cancellations between cells: 3280
        - with all terms expanded and combined/cancelled: 720
    """
    counters = [0]*3
    for term in systemtermlist:
        counters[0]+=len(sp.Add.make_args(term))
        counters[1]+=len(sp.Add.make_args(term.doit().expand(expand_hadamard=False)))
        counters[2]+=len(sp.Add.make_args(term.doit().expand()))

    print((f"# terms\n as is: {counters[0]}\n only commutators expanded: {counters[1]}\n"
            f" commutators and hadamard expanded, no cancellation between cells: {counters[2]}"))

    finalexpr = sp.Add(*systemtermlist).doit().expand()

    print(f" all terms expanded and combined/cancelled: {len(sp.Add.make_args(finalexpr))}")

    finalexprstr = replacechars(str(finalexpr), (('*', ''), ('@', '*')))

    with open("Output.txt", "w") as text_file:
        text_file.write(finalexprstr)
