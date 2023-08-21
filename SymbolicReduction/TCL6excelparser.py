# Used to complete expansion of PLLLLLLP term

import numpy as np
import pandas as pd
from os.path import dirname, join as pjoin

# takes a correlation term e.g. <240513> and expands it into a list of sets of
# products of 2-correlations, corresponding to the sum of products by Wick's theorem
def expandcorrterm(corrterm):
    start = corrterm.find("<") + 1
    end = corrterm.find(">")

    if end - start % 2 == 1:
        return "0"

    if end - start == 2:
        return [{corrterm}]

    corrterm = corrterm[1:-1]

    expanded = []

    for i in range(1, end - start):
        expanded = expanded + [{f"<{corrterm[0]}{corrterm[i]}>"} | x for x in expandcorrterm("<" + corrterm[1:i] + corrterm[i+1:] + ">")]

    # expanded = expanded[3:]
    return expanded

# separate function to expand a product of corrterms to a set of corrterms
def corrtermstr_to_set(corrterm):
    i = 0

    corrset = set()

    while i < len(corrterm):
        i = corrterm.find("<", i)
        if i == -1:
            break
        # print(i)
        corrset.add(corrterm[i:i+4])
        # print(corrterm[i:i+4])
        i+=1

    return corrset
    # print(corrset)

# returns an array of the system terms grouped in rows by their correlation terms
def group_by_correlation(systemterms, corrterms, corrsorder):
    systemarr = np.full((corrsorder.size,corrterms.size), '', dtype=object)
    corr_cols = np.zeros(corrsorder.size, dtype=np.int64)

    sum0 = 0

    for index, *_ in np.ndenumerate(corrterms):

        print(corrterms[index])

        # if this correlation term matches one of the 120 correlation terms <0x>
        if (corrsorder == corrterms[index]).nonzero()[0].size != 0:

            corr_row = (corrsorder == corrterms[index]).nonzero()[0][0]

            systemarr[corr_row, corr_cols[corr_row]] = systemterms[index[0]]

            corr_cols[corr_row] = corr_cols[corr_row] + 1

    return systemarr


corrarr_to_sets = np.vectorize(corrtermstr_to_set)


fname = pjoin(dirname(__file__), "TCL.xlsx")
data = pd.read_excel(fname, sheet_name="PLLLLLLP", usecols="T,V:AJ", nrows=32, header=None)

terms = data.to_numpy()


systemterms = terms[:,0]
corrterms = terms[:, 1:]

corrterms = corrarr_to_sets(corrterms)

rel_corrs_data = pd.read_excel(fname, sheet_name="cumulative correlation terms", skiprows=1, usecols="A", header=None)
rel_corrs_str = rel_corrs_data.dropna().to_numpy().flatten()
corrsorder = corrarr_to_sets(rel_corrs_str)

regrouped = group_by_correlation(systemterms, corrterms, corrsorder)

finalcorrsstring = np.full((corrsorder.size,), '', dtype=object)

for i, row in zip(range(regrouped.shape[0]), regrouped):
    string = ''
    for element in row:
        if element != '':
            string += ' + ' + element[3:-1]
    string = string[3:]
    finalcorrsstring[i] = string

print(finalcorrsstring.shape)

pd.DataFrame(finalcorrsstring).to_clipboard()

# with pd.ExcelWriter("time_data.xlsx", engine="openpyxl", mode="a", if_sheet_exists="replace") as writer: # pylint: disable=abstract-class-instantiated
#     data.to_excel(writer, sheet_name='sheet3', index_label="1nm exact opt no data function", index=True)

# check that correlation term expansion was done correctly

# recursion works!
# print({frozenset(x) for x in expandcorrterm("<abcdef>")} == {frozenset({'<ab>', '<cd>', '<ef>'}),frozenset({'<ab>', '<ce>', '<df>'}),frozenset({'<ab>', '<cf>', '<de>'}),frozenset({'<ac>', '<bd>', '<ef>'}),frozenset({'<ac>', '<be>', '<df>'}),frozenset({'<ac>', '<bf>', '<de>'}),frozenset({'<ad>', '<bc>', '<ef>'}),frozenset({'<ad>', '<be>', '<cf>'}),frozenset({'<ad>', '<bf>', '<ce>'}),frozenset({'<ae>', '<bc>', '<df>'}), frozenset({'<ae>', '<bd>', '<cf>'}), frozenset({'<ae>', '<bf>', '<cd>'}), frozenset({'<af>', '<bc>', '<de>'}), frozenset({'<af>', '<bd>', '<ce>'}), frozenset({'<af>', '<be>', '<cd>'})})
# print({frozenset(x) for x in expandcorrterm("<abcdef>")})

# initcorrsdata = pd.read_excel(fname, sheet_name="PLLLLLLP", usecols="B", nrows=32, header=None)
#
# initcorrs = initcorrsdata.to_numpy()[:,0]
# print(initcorrs.shape)
# fullexpand = [{frozenset(y) for y in expandcorrterm(x)} for x in initcorrs]
#
# corrterm_as_sets = [{frozenset(x) for x in corrtermrow} for corrtermrow in corrterms]
# print([i == j for i, j in zip(fullexpand, corrterm_as_sets)])
# print(corrterm_as_sets[23].difference(fullexpand[23]))
# print(fullexpand[23].difference(corrterm_as_sets[23]))
# print(fullexpand==corrterm_as_sets)
