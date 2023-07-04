tic

file = readcell('Reduced_Nonzero_Terms.xlsx');
fn = file;
output = {};
sym_output = {};
output{1,1} = 'I';
output{1,2} = 'x';
output{1,3} = 'y';
output{1,4} = 'z';
% outcol = [0, 0, 1, 0, 5, 0, 10]
r = 1;
for col = [3, 5, 7]
    for row = 2 : 44
        place = [col, row];
        display(place);
        line = fn{row, col};
        if ~strcmp(class(line), 'missing')
            try 
                [out0, out1, out2, out3] = line_calculation(line);
                output{r, 1} = char(out0);
                output{r, 2} = char(out1);
                output{r, 3} = char(out2);
                output{r, 4} = char(out3);

                % sym_output{r, 1} = out0;
                % sym_output{r, 2} = out1;
                % sym_output{r, 3} = out2;
                % sym_output{r, 4} = out3;
                if out0 == 0 & out1 == 0 & out2 == 0 & out3 == 0
                    fn{row, col} = '0';
                end
            catch
                fn{row, col} = 'error';
            end
        else
            fn{row, col} = 'N/A';
            output{r, 1} = 'N/A';
            output{r, 2} = 'N/A';
            output{r, 3} = 'N/A';
            output{r, 4} = 'N/A';
        end
        r = r + 1;
    end
end

toc

[k, l] = size(fn);
for n = 1 : k
    for m = 1 : l
        if strcmp(class(fn{n, m}), 'missing')
            fn{n, m} = [];
        end
    end
end

writecell(fn, 'Check_0_and_error.xlsx')
writecell(output, 'Calculation_Output.xlsx');