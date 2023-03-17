import re
from os.path import dirname, join as pjoin
import numpy as np
import pandas as pd

"""
Convert a single system term to a reduced version using the Hadamard trick.

integrals: a string of the form (abc)(def)(ghi)(jkl)(mno)
corrterms: a string of the form <ab><cd><ef>
systemterm: a string of the form a[b,[c,d]] or something like that

returns: a tuple (integrals, systemterm)
        where integrals should be (abc)(def) and systemterms are reduced
"""
def perform_hadamard_reduction(integrals, corrterms, systemterm):

    gamma_symbol = "G"
    gamma_transpose_symbol = "GT"

    while len(integrals) > 10:
        # find innermost variable of integration, and upper and lower bounds
        dt = integrals[-2]
        upper_bound = integrals[-3]
        lower_bound = integrals [-4]

        # find other time in correlation term with dt
        dt_comp = corrterms[corrterms.find(dt)-(2*(corrterms.find(dt) % 4)-3)]

        # transpose if dt is negative in correlation function
        transpose = bool((corrterms.find(dt) % 4) - 1)

        #placeholder symbol for gamma (G)/gamma transpose (GT)
        current_gs = gamma_symbol if not transpose else gamma_transpose_symbol

        # replaces the correlation factor 0 with t when within a gamma
        conform_for_time = lambda x: "t" if x == "0" else x

        # * indicates hadamard product
        if not transpose:
            systemterm = systemterm.replace(dt,
            (f"({dt_comp}*({current_gs}{upper_bound}{conform_for_time(dt_comp)}"
            f"-{current_gs}{lower_bound}{conform_for_time(dt_comp)}))"))
        else:
            systemterm = systemterm.replace(dt,
            (f"({dt_comp}*({current_gs}{conform_for_time(dt_comp)}{upper_bound}"
            f"-{current_gs}{conform_for_time(dt_comp)}{lower_bound}))"))

        integrals = integrals[:-5]
        # print(dt, " ", dt_comp, " ", transpose, " ", current_gs)
        # print(systemterm)
        # print(integrals)

    # removes all "(-)Gii" or "(-)GTii",which equals 0 (the number)
    # some regex cuz im lazy
    regex = fr"-?({gamma_symbol}|{gamma_transpose_symbol})(.)\2{{1}}"

    systemterm = re.sub(regex, "", systemterm)

    return (integrals, systemterm)

integral_ex = "(0t1)(014)(413)(012)(045)"
corrterms_ex = "<02><51><34>"
systemterm_ex = "-[1,2]4p[3,5]"

fname = pjoin(dirname(__file__), "TCL_Integrals.xlsx")

corrterms = pd.read_excel(fname, sheet_name="Nonzero Terms", usecols="A", nrows=70, header=None, skiprows=1)
corrterms = corrterms.to_numpy().flatten()

integrals = pd.read_excel(fname, sheet_name="Nonzero Terms", usecols="B,C,D", nrows=70, header=None, skiprows=1)
integrals = integrals.to_numpy()

systemterms = pd.read_excel(fname, sheet_name="Nonzero Terms", usecols="E", nrows=70, header=None, skiprows=1)
systemterms = systemterms.to_numpy().flatten()

reducedsystemterms = np.full(integrals.shape, '', dtype=object)

print(integrals.shape)

# go through all correlation terms
for i, corrterm in enumerate(corrterms):
    # check if row is blank
    if not isinstance(corrterm, float):
        # go through all integrals in that row
        for j, integral in enumerate(integrals[i]):
            # check if integral is blank
            if not isinstance(integral, float):
                # integral[1:] to remove sign
                new_integral, reduced_term = perform_hadamard_reduction(integral[1:], corrterm, systemterms[i])

                integrals[i,j] = integral[0] + new_integral
                reducedsystemterms[i,j] = reduced_term


integrals_df = pd.DataFrame(integrals)
systemterms_df = pd.DataFrame(reducedsystemterms)

with pd.ExcelWriter("TCL_Integrals.xlsx", engine="openpyxl", mode="a", if_sheet_exists="overlay") as writer: # pylint: disable=abstract-class-instantiated
    integrals_df.to_excel(writer,  index=False, header=False, na_rep="=\"\"", sheet_name='Reduced Nonzero Terms',
        startcol=1, startrow=1)
    systemterms_df.to_excel(writer,  index=False, header=False, na_rep="=\"\"", sheet_name='Reduced Nonzero Terms',
        startcol=4, startrow=1)
