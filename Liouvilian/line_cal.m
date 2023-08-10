function result = line_cal(line)
% %input is a string, result is a vertorization of a 2 by 2 matrix
% 
% line = 'N{[a,(0*(GTt0-GTta))]}(L{(b*(-GTba))}P{(a*(Gba-G0a))b}-P{(a*(Gba-G0a)}L{(b*(-GTba))}P{b}))';

    %Any hadmard product is replaced by matrix A
    A = [1,2;3,4];
    a = [5,6;7,8];
    b = [9,10;11,12];
    p = [13,14;15,16];


    %setup for commutator
    line = replace(line, ',', '=');
    line = replace(line, '[', 'S');
    line = replace(line, ']', 'E');
    %% Hardmard Product
    m2 = line == '*';
    while sum(m2) ~= 0
        m1 = line == '(';
        m2 = line == '*';
        m3 = line == ')';
        m = m1 + 2 * m2 + 3 * m3;
        str_m = num2str(m);
        str_m = str_m(str_m ~= ' ');
        %find all the commas so we can find the ones we need
        had_pos = strfind(str_m, '2');
        %this pattern gives the commutator without embedded ones within
        pat = '10210+33';
        [startIn, endIn] = regexp(str_m, pat);
        com = had_pos(had_pos < endIn(1) & had_pos > startIn(1));
        %the part before target hadmard product
        pre = line(1: startIn(1) -1);
        %the two parts to plug into commutator
        part1 = line(startIn(1)+1: com -1);
        part2 = line(com+1 : endIn(1)-1);
        %the part after target commutator
        post = line(endIn(1) + 1 : end);
        line = [pre, 'A', post];
        m2 = line == '*';
    end
    %% Commutators
    target = line;
    mask1 = target == 'S';
    while sum(mask1) ~= 0
        mask1 = target == 'S';
        mask2 = target == '=';
        mask3 = target == 'E';
        mask = mask1 + 2 * mask2 + 3 * mask3;
        str_mask = num2str(mask);
        str_mask = str_mask(str_mask ~= ' ');
        %find all the commas so we can find the ones we need
        comma_pos = strfind(str_mask, '2');
        %this pattern gives the commutator without embedded ones within
        pat = '10+20+3';
        [sIn, eIn] = regexp(str_mask, pat);
        com = comma_pos(comma_pos < eIn(1) & comma_pos > sIn(1));
        %the part before target commutator
        pre = target(1: sIn(1) -1);
        %the two parts to plug into commutator
        part1 = target(sIn(1)+1: com -1);
        part2 = target(com+1 : eIn(1)-1);
        %the part after target commutator
        result = ['(', part1, '*', part2, '-', part2, '*', part1, ')'];
        post = target(eIn(1) + 1 : end);
        target = [pre, result, post];
        mask1 = target == 'S';
    end

    result = implicit_mutiplication({'a', 'b', 't', 'p', 'A'}, target);

end