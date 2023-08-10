function [out,had, count] = HP_search(line, had,count)
    m2 = line == '*';
    %store hadamard product
    while sum(m2) ~= 0
        m1 = line == '(';
        m2 = line == '*';
        m3 = line == ')';
        m = m1 + 2 * m2 + 3 * m3;
        str_m = num2str(m);
        str_m = str_m(str_m ~= ' ');
        check_exist = false;
        %this pattern gives the commutator without embedded ones within
        pat = '10210+33';
        [startIn, endIn] = regexp(str_m, pat);
        line_had = line(startIn:endIn);
        for i = 1: length(had)
            if strcmp(line_had, had(i))
                check_exist = true;
                line_had = sprintf('H(%d)', i);
                count(i) = count(i) + 1;
            end
        end
        if ~check_exist
            had = [had, convertCharsToStrings(line_had)];
            line_had = sprintf('H(%d)', length(had));
            count = [count, 1];
        end
        %the part before target commutator
        pre = line(1: startIn(1) -1);
        post = line(endIn(1) + 1 : end);
        line = [pre, line_had, post];
        m2 = line == '*';
    end
    out = line;
end