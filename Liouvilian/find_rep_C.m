file = readcell('hp_check_rep.xlsx');
new = file;
%array that store hadmard product
C = [];
count_C = [];

for col = [3, 5, 7]
    for row = 2 : 44
        place = [col, row];
        display(place)
        if ~strcmp(class(file{row, col}), 'missing')
            line = file{row, col};
            [out_line, C, count_C] = Com_search(line, C, count_C);
            new{row, col} = out_line;
        end
    end
end

for col = 1:7
    for row = 1 : 44
        if strcmp(class(new{row, col}), 'missing')
                new{row,col} = '';
        end
    end
end

save('commuator', 'C', "count_C");
writecell(new, 'commutator_check_rep.xlsx');