for j = 1 : i
    for k = 1 : j - 1
        pos = [j, k];
        display(pos)
        out1 = data(j).exp;
        out2 = data(k).exp;
        check_exp = out1 - out2;
        if check_exp == 0
            data(j).exp = 0;
            data(j).check = 'eliminated';
            data(k).exp = 0;
            data(k).check = 'eliminated';
        end
    end
end