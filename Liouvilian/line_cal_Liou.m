function result = line_cal_Liou(input)

    A = [1,2;3,4];
    a = [5,6;7,8];
    b = [9,10;11,12];
    p = [13;15;14;16];
    I = eye(2);

    % input = 'N{[(b*(Gtb-Gab)),[a,(0*(GTt0-GTta))](a*(GTab))]b}+N{[(b*(Gtb-Gab)),(0*(GTt0-GTta))]}L{a}N{(a*(GTab))b}-N{[(b*(Gtb-Gab)),(0*(GTt0-GTta))]b}L{a}N{(a*(GTab))}';
    
    input = line_cal(input);

    pattern = 'M\{([^\{\}]+)\s([^\{\}]+)\}';
    replace = '(kron(transpose($2),$1))';
    input = regexprep(input, pattern, replace); 

    pattern = 'N\{([^\{\}]+)\}';
    replace = '(kron(I, $1))';
    input = regexprep(input, pattern, replace);

    pattern = 'P\{([^\{\}]+)\}';
    replace = '(kron(transpose($1),I))';
    input = regexprep(input, pattern, replace);


    pattern = 'L\{([^\{\}]+)\}';
    replace = '((kron(I, $1)) - (kron(transpose($1),I)))';
    input = regexprep(input, pattern, replace);
    input = implicit_mutiplication({'a', 'b', 't', 'p', 'A'}, input);
    result = eval(input);
    result = result * p;

end