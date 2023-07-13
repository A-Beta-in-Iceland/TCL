function [out0, out1, out2, out3] = line_calculation(line)
  %define pauli matrices
    %need to clear and reset every time you run
    syms I x y z 
    out0 = 0;
    out1 = 0;
    out2 = 0;
    out3 = 0;
    
    %define elements used in TCL6
    %Assume that all matrix is m by m, at this point we assume large m bc
    %matlab doesn't support arbitrary matrix size
    %Gamma funciton
    %A operators, a function of time
    syms a b A(t) p_1 p_2 p_3 p A1(t) A2(t) A3(t) n al(t) n1 n2 n3 g0(t) g1(t) g2(t) g3(t) 
    assume(a > 0);
    assume(b > 0);
    % e: epsilon, del: Delta
    syms e del real
    %Dummy A(t) for siplicity
    % n = [del, 0 , e] ./ sqrt(del^2 + e^2);
    % n = [n1, n2, n3];
    % al(t) = t * sqrt(del^2 + e^2)/ 2;

    % A(t) = x * A1(t) + y * A2(t) + z * A3(t);

    A_sin = [-n1^2 * n3, n3, -n1*n3^2];
    A_cos = [n3^3, 0, n1*n3^2];
    A_con = [n1^2 * n3, 0, n1^3 - n1 * n3^2];

    sig(t) = sin(n*t) .* A_sin + cos(n*t) * A_cos + A_con;
    A(t) = sig(t) * [x; y; z];
    %Now on spin boson
    H_0 = (e/2) .* z + (del / 2) .* x;

    assume(n1^2 + n3^2 == 1);
    
    % line = '-[(b*(GTba-GTbt)),[a,(0*(GTtb-GTta))](a*(GTa0-GTab))]';
    % line = '[a,(0*(GTtb-GTta))]';
    % row 2
    % line = '[a,(0*(GTtb-GTta))][b,(a*(GTa0-GTab))](b*(GTb0))p';
    % row 9 
    % line = '[a,(0*(GTt0-GTta))]([(b*(-GTba)),p(a*(Gba-G0a))b]-[(b*(-GTba)),pb](a*(Gba-G0a)))';
    % line = '[a,(0*(GTt0-GTta))]([(b*(Gab)),b(a*(GTa0-GTab))p]-(a*(GTa0-GTab))[(b*(Gab)),bp])';
    % line =  '-[a,(0*(GTt0-GTta))][(b*(-GTba)),(a*(GTa0-GTab))]pb';
        %setup for hadmard
    line = replace(line, '*', 'q');
    %setup for commutator
    line = replace(line, ',', '=');
    line = replace(line, '[', 'S');
    line = replace(line, ']', 'E');
    %% Hardmard Product
    pattern = '\(([^q])q\(([^q]+)\)\)';
    % (\([^o()]+\) o [^o()]+\) captures the desired pattern
    % [^o()] matches any character except 'o', '(' and ')'
    
    % Find matches using regular expressions
    matches = regexp(line, pattern, 'tokens'); 
    [startIn, endIn] = regexp(line, pattern);
    
    % Initialize arrays to store the extracted content
    content1 = cell(size(matches));
    content2 = cell(size(matches));
    
    % Extract the content from the matches
    for i = 1:numel(matches)
        values = matches{i};
        content1{i} = values{1};
        %a little hard code here but since all the hadmard product we have here
        %is A(t)* (GT something something), we can just plug it in later
        content2{i} = values{2};
        content2{i} = regexprep(content2{i}, 'GT(\w)(\w)', 'g0($1-$2) * I + g1($1-$2) * x + g2($1-$2) * y');
        content2{i} = regexprep(content2{i}, 'G(\w)(\w)', 'g0($1-$2) * I + g1($1-$2) * x - g2($1-$2) * y');
    end
    % these value are here just to turn first and second into matrix
    % treating the parts before Hadmard Product
    if ~isempty(startIn)
        element = replace(line(1:startIn(1)-1), 'a', char(A(a)));
        element = replace(element, 'b', char(A(b)));
        element = replace(element, 't', char(A(t)));
        element = replace(element, '0', char(A(0)));
        hadout = element;
    else
        hadout = line;
    end
    for k = 1: length(matches)
        %checking bracket is only legit if it has extra bracket before startIn
        %or after endIn
        [startIn(k),first] = checkBracket(startIn(k),content1{k});
        first = str2sym(first);
        first = A(first);
        [endIn(k), second] = checkBracket(endIn(k), content2{k});
        second = str2sym(second);
    
    %     final = subs(second, [t, t_a, t_b], [t_val, t_a_val, t_b_val]);
    %     second = subs(second, [t, a, b], [t_val, t_a_val, t_b_val]);
    
        result = simplify(HadamardProduct(first, second));
        result = char(result);
        % plug back in, this doens't work
    %     [first_int, final_int] = regexp(line, pattern)
    %     line = [line(1:max(1, first_int(1) -1)) , result , line(min(final_int(1) + 1, strlength(line)) : end)
        if endIn(k) < length(line)
            %the first hadmard term
                if k < length(matches)
                    % replace = regexprep(line(endIn(k): startIn(k+1)), '[abt0]', 'A($0)')
                    element = replace(line(endIn(k) + 1: startIn(k+1)-1), 'a', char(A(a)));
                    element = replace(element, 'b', char(A(b)));
                    element = replace(element, 't', char(A(t)));
                    element = replace(element, '0', char(A(0)));
                    hadout = [hadout, '(' , result ')' , element];
                    %hadout = [hadout, result, line(endIn(k): startIn(k+1))]
                else
                    % no trailing hadmard term
                    % replace = regexprep(line(endIn(k): end), '[abt0]', 'A($0)')
                    element = replace(line(endIn(k)+1 : end), 'a', char(A(a)));
                    element = replace(element, 'b', char(A(b)));
                    element = replace(element, 't', char(A(t)));
                    element = replace(element, '0', char(A(0)));
                    hadout = [hadout, '(' , result ')', element];
                    %hadout = [hadout, result, line(endIn(k): end)];
                end
            else
                hadout = [hadout, result];
        end
    end
    hadout = implicit_mutiplication({'a', 'b', 't', 'p','x','y','z','I', 'eps', 'del'}, hadout);
    % Processing Hadamard product would not change the order of multiplication
    hadout = replace(hadout, 'p','1/2 * (I + p_1*x + p_2*y + p_3 * z)' );
    
    %%
    %process commutator
    %     while sum(line == '[') >0
    %         line = regexprep(line, '\[(.*?)\,(.*?)\]', 'comm($1,$2)')
    %     end
    %create a copy of hadout
    target = hadout;
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
        [startIn, endIn] = regexp(str_mask, pat);
        com = comma_pos(comma_pos < endIn(1) & comma_pos > startIn(1));
        %the part before target commutator
        pre = target(1: startIn(1) -1);
        %the two parts to plug into commutator
        part1 = str2sym(target(startIn(1)+1: com -1));
        part2 = str2sym(target(com+1 : endIn(1)-1));
        %the part after target commutator
        result = comm(part1, part2);
        result = simplify(result);
        result = char(result);
        post = target(endIn(1) + 1 : end);
        target = [pre, result, post];
        mask1 = target == 'S';
    end
    out = replace(target, 'I', '[1,0;0,1]');
    out = replace(out, 'x', '[0,1;1,0]');
    out = replace(out, 'y', '[0, -i; i, 0]');
    out = replace(out, 'z', '[1, 0; 0, -1]');
    out = str2sym(out);

    [out0, out1, out2, out3] = Matrix_to_Bloch_vector(out);

    % out0 = simplify(out0);
    % out1 = simplify(out1);
    % out2 = simplify(out2);
    % out3 = simplify(out3);
end