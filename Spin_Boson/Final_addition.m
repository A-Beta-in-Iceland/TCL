fn = readcell("Calculation_Output.xlsx");
s = size(fn);
final_out_I = 0;
final_out_x = 0;
final_out_y = 0;
final_out_z = 0;

for i = 1 : s(1)
    display(i);
    if ~strcmp(fn{i, 1}, 'N/A')
        final_out_I = final_out_I + str2sym(fn{i, 1});
    end
    if ~strcmp(fn{i, 2}, 'N/A')
        final_out_x = final_out_x + str2sym(fn{i, 2});
    end
    if ~strcmp(fn{i, 3}, 'N/A')
        final_out_y = final_out_y + str2sym(fn{i, 3});
    end
    if ~strcmp(fn{i, 4}, 'N/A')
        final_out_z = final_out_z + str2sym(fn{i, 4});
    end
end