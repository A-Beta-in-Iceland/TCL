function [out,C, count] = Com_search(line, C, count)
    m2 = line == '[';
    %store hadamard product
    while sum(m2) ~= 0
        m1 = line == '[';
        m2 = line == ',';
        m3 = line == ']';
        m = m1 + 2 * m2 + 3 * m3;
        str_m = num2str(m);
        str_m = str_m(str_m ~= ' ');
        check_exist = false;
        %this pattern gives the commutator without embedded ones within
        pat = '10+20+3';
        [startIn, endIn] = regexp(str_m, pat);
        line_cm = line(startIn:endIn);
        for i = 1: length(C)
            if strcmp(line_cm, C(i))
                check_exist = true;
                line_cm = sprintf('C(%d)', i);
                count(i) = count(i) + 1;
            end
        end
        if ~check_exist
            C = [C, convertCharsToStrings(line_cm)];
            count = [count, 1];
            line_cm = sprintf('C(%d)', length(C));
        end
        %the part before target commutator
        pre = line(1: startIn(1) -1);
        post = line(endIn(1) + 1 : end);
        line = [pre, line_cm, post];
        m2 = line == '[';
    end
    out = line;
end