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

    # iteratively reduces systemterms one integral at a time
    # when len(integrals) = 10, there are only two integrals left and we are done
    while len(integrals) > 10:
        # find innermost variable of integration, and upper and lower bounds
        dt = integrals[-2]
        upper_bound = integrals[-3]
        lower_bound = integrals[-4]

        # find other time in the same correlation term as dt
        # e.g. corrterm = <01><23><45>, dt=5, dt_comp=4
        dt_comp = corrterms[corrterms.find(dt)-(2*(corrterms.find(dt) % 4)-3)]

        # transpose if dt is negative in correlation function
        # e.g. using above corrterm: <45> <--> C(4-5), so we need to use transpose
        transpose = bool((corrterms.find(dt) % 4) - 1)

        #placeholder symbol for gamma (G)/gamma transpose (GT)
        current_gs = gamma_symbol if not transpose else gamma_transpose_symbol

        # replaces the correlation factor 0 with t when within a gamma
        conform_for_time = lambda x: "t" if x == "0" else x

        # replaces the relevant system operator (dt) with the hadamard product
        # following the rules outlined in the "Hadamard_Equation_Proof.pdf" file
        # * indicates hadamard product
        if not transpose:
            systemterm = systemterm.replace(dt,
            (f"({dt_comp}*({current_gs}{upper_bound}{conform_for_time(dt_comp)}"
            f"-{current_gs}{lower_bound}{conform_for_time(dt_comp)}))"))
        else:
            systemterm = systemterm.replace(dt,
            (f"({dt_comp}*({current_gs}{conform_for_time(dt_comp)}{lower_bound}"
            f"-{current_gs}{conform_for_time(dt_comp)}{upper_bound}))"))

        # Removes the innermost integral, which is now encapsualted in the gamma function
        integrals = integrals[:-5]

        # print(dt, " ", dt_comp, " ", transpose, " ", current_gs)
        # print(systemterm)
        # print(integrals)

        # Repeat three times

    # Some post processing

    # removes all instances of "(-)Gii" or "(-)GTii", which equals 0 (the number)
    # some regex cuz im lazy (don't ask me how this works, but you can test it at regex101.com)
    regex = fr"-?({gamma_symbol}|{gamma_transpose_symbol})(.)\2{{1}}"

    systemterm = re.sub(regex, "", systemterm)

    return (integrals, systemterm)

# expect 'integrals' to be of the form (0tx)(abc), only two integrals
# replaces dummy variables with standardized symbols depending on the integration region
# will swap a triangular integration region so that it is always a lower triangle
def replace_dummy_variables(integrals, systemterm):

    # dummy variables we will use for triangular region
    triangle_symbols=("a", "b")

    # doesnt look like theres any square integrals but ill include this case anyways
    # in any case, a square integration region can be split into two triangular regions
    square_symbols=("c", "d")

    current_intsymb = triangle_symbols

    old_indices=(integrals[3],integrals[8])

    if integrals[6]=="0":
        # (0tx)(0ty), square integral region
        if integrals[7]=="t":
            current_intsymb=square_symbols
        # (0tx)(0xy), lower triangle integral
        elif integrals[7]==old_indices[0]:
            pass
        else:
            print(integrals, " --- ", systemterm)
            raise Exception("unknown integral region")
    # (0tx)(xty), upper triangle integral
    elif integrals[6]==old_indices[0] and integrals[7]=="t":
        # swap integrals first, from upper to lower triangular
        integrals = integrals[:3] + old_indices[1] + ")(0" + old_indices[1] + old_indices[0] + ")"
        old_indices=(integrals[3], integrals[8])
    else:
        print(integrals, " --- ", systemterm)
        raise Exception("unknown integral region")

    # replace dummy variables
    for old_index, new_symbol in zip(old_indices, current_intsymb):
        integrals = integrals.replace(old_index, new_symbol)
        systemterm = systemterm.replace(old_index, new_symbol)

    return (integrals, systemterm)

# Example:

# integral_ex = "(0t1)(014)(413)(012)(045)"
# corrterms_ex = "<02><51><34>"
# systemterm_ex = "-[1,2]4p[3,5]"
#
# new_integral_ex, reduced_term_ex = perform_hadamard_reduction(integral_ex, corrterms_ex, systemterm_ex)
#
# print("reduced int = ", new_integral_ex)
# print("reduced term = ", reduced_term_ex)
#
# new_integral_ex, reduced_term_ex = replace_dummy_variables(new_integral_ex, reduced_term_ex)
#
# print("reduced int = ", new_integral_ex)
# print("reduced term = ", reduced_term_ex)


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
                new_integral, reduced_term = replace_dummy_variables(
                    *perform_hadamard_reduction(integral[1:], corrterm, systemterms[i]))
                integrals[i,j] = integral[0] + new_integral
                reducedsystemterms[i,j] = reduced_term

# export remaining integrals and system terms to a spreadsheet

integrals_df = pd.DataFrame(integrals)
systemterms_df = pd.DataFrame(reducedsystemterms)

with pd.ExcelWriter("TCL_Integrals.xlsx", engine="openpyxl", mode="a", if_sheet_exists="overlay") as writer: # pylint: disable=abstract-class-instantiated
    integrals_df.to_excel(writer,  index=False, header=False, na_rep="=\"\"", sheet_name='Reduced Nonzero Terms',
        startcol=1, startrow=1)
    systemterms_df.to_excel(writer,  index=False, header=False, na_rep="=\"\"", sheet_name='Reduced Nonzero Terms',
        startcol=4, startrow=1)
