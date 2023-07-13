file = readcell('Reduced_Nonzero_Terms.xlsx');
fn = file;
syms I x y z a b A(t) p_1 p_2 p_3 p A1(t) A2(t) A3(t) n al(t) n1 n2 n3 g0(t) g1(t) g2(t) g3(t) 
syms e del real
tic
data = struct([]);
i = 1;
for col = [3, 5, 7]
    for row = 2 : 44
        str = fn{row, col};
        if ~strcmp(class(str), 'missing')
            data(i).pos = [row, col];
            display(data(i).pos)
            tic
            [out0, out1, out2, out3] = line_calculation(str);
            toc
            output = out0 * I + out1 * x + out2 * y + out3 * z;
            if col == 5
                %note that on column 5 it's minus the integral
                output = output * (-1);
            end
            data(i).exp = output;
            i = i + 1;
        end
    end
end
toc

for j = 1 : length(data)
    for k = 1 : j - 1
        out1 = data(j).exp;
        out2 = data(k).exp;
        if check_exp == 0
            data(j).exp = 0;
            data(j).check = 'eliminated';
            data(k).exp = 0;
            data(k).check = 'eliminated';
        end
    end
end