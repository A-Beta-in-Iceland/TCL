file = readcell('Liouvillian.xlsx');
new = file;
%array that store hadmard product
H = [];
count_H = [];

for col = [3, 5, 7]
    for row = 2 : 44
        place = [col, row];
        display(place)
        if ~strcmp(class(file{row, col}), 'missing')
            line = file{row, col};
            [out_line, H, count_H] = HP_search(line, H, count_H);
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

save('hadamard.mat', 'H', 'count_H')
writecell(new, 'hp_check_rep.xlsx');