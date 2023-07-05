fn = readcell("Reduced_Nonzero_Terms.xlsx");
row2_I = 0;
row2_x = 0;
row2_y = 0;
row2_z = 0;
for i = [3, 5, 7]
    display(i);
    line = fn{2, i};
    [out0, out1, out2, out3] = line_calculation(line);
    row2_I = row2_I + out0;
    row2_x = row2_x + out1;
    row2_y = row2_y + out2;
    row2_z = row2_z + out3;
end

row2_I = expand(row2_I);
row2_x = expand(row2_x);
row2_y = expand(row2_y);
row2_z = expand(row2_z);