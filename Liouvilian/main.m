
file = readcell('Reduced_Nonzero_Terms.xlsx');
reduced = file;
file = readcell('Checking terms 2.xlsx');
Liouvillian = file;

A = [1,2;3,4];
a = [5,6;7,8];
b = [9,10;11,12];
p = [13,14;15,16];


error = 0

fn = Liouvillian;
for col = [3, 5, 7]
    for row = 2 : 44
        place = [col, row];
        display(place);
        redu = reduced{row, col};
        liou = Liouvillian{row, col};
        if ~strcmp(class(redu), 'missing')
            redu = line_cal(redu);
            redu = eval(redu);
            redu = reshape(redu, [4,1]);

            try
            liou = line_cal_Liou(liou);
                if ~all(redu == liou)
                    fn{row, col} = 'false';
                    error = error + 1;
                end
            catch
             fn{row, col} = 'false syntax';
             error = error + 1;
            end
        %     try 
        %         [out0, out1, out2, out3] = line_calculation(line);
        %         output{r, 1} = char(out0);
        %         output{r, 2} = char(out1);
        %         output{r, 3} = char(out2);
        %         output{r, 4} = char(out3);
        % 
        %         % sym_output{r, 1} = out0;
        %         % sym_output{r, 2} = out1;
        %         % sym_output{r, 3} = out2;
        %         % sym_output{r, 4} = out3;
        %         if out0 == 0 & out1 == 0 & out2 == 0 & out3 == 0
        %             fn{row, col} = '0';
        %         end
        %     catch
        %         fn{row, col} = 'error';
        %     end
        else
            fn{row, col} = '';
        %     output{r, 1} = 'N/A';
        %     output{r, 2} = 'N/A';
        %     output{r, 3} = 'N/A';
        %     output{r, 4} = 'N/A';
        end
        % r = r + 1;
    end
end


for col = 1:7
    for row = 1 : 44
        if strcmp(class(fn{row, col}), 'missing')
                fn{row,col} = '';
        end
    end
end

writecell(fn, 'check_liou_kellum_2.xlsx');
fprintf('There are %d errors', error)