fn = readcell("Reduced_Nonzero_Terms.xlsx");
line = fn{13, 3};
[row13_I, row13_x, row13_y, row13_z] = line_calculation(line);

row13_I = expand(row13_I);
row13_x = expand(row13_x);
row13_y = expand(row13_y);
row13_z = expand(row13_z);