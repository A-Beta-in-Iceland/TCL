%define pauli matrices
%need to clear and reset every time you run
syms I x y z 

%define elements used in TCL6
%Assume that all matrix is m by m, at this point we assume large m bc
%matlab doesn't support arbitrary matrix size
%Gamma funciton
syms g11(a,b) g12(a,b) g21(a,b) g22(a,b) 
%A operators, a function of time
syms p a b A(t)
assume(a > 0);
assume(b > 0);
%Dummy A(t) for siplicity
A(t) = [1,1;1,1];
%Now on spin boson
syms eps del real
H_0 = (eps/2) .* z + (del / 2) .* x;

% line = '-[(b*(GTba-GTbt)),[a,(0*(GTtb-GTta))](a*(GTa0-GTab))]';
% line = '[a,(0*(GTtb-GTta))]';
% row 2
% line = '[a,(0*(GTtb-GTta))][b,(a*(GTa0-GTab))](b*(GTb0))p';
% row 9 
line = '[a,(0*(GTt0-GTta))]([(b*(-GTba)),p(a*(Gba-G0a))b]-[(b*(-GTba)),pb](a*(Gba-G0a)))';


%setup for hadmard
line = replace(line, '*', 'q');
%setup for commutator
line = replace(line, ',', '=');
line = replace(line, '[', 'S');
line = replace(line, ']', 'E');
%% Hardmard Product
pattern = '\(([^q])q([^q]+)\)';
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
    content2{i} = regexprep(content2{i}, 'GT(\w)(\w)', '[g11($1,$2), g12($1,$2); g21($1,$2), g22($1,$2)]\''');
    content2{i} = regexprep(content2{i}, 'G(\w)(\w)', '[g11($1,$2), g12($1,$2); g21($1,$2), g22($1,$2)]');
end
% these value are here just to turn first and second into matrix
% treating the parts before Hadmard Product
element = replace(line(1:startIn(1)-1), 'a', char(A(a)));
element = replace(element, 'b', char(A(b)));
element = replace(element, 't', char(A(t)));
element = replace(element, '0', char(A(0)));
hadout = element;
for k = 1: length(matches)
    %checking bracket is only legit if it has extra bracket before startIn
    %or after endIn
    [startIn(k),first] = checkBracket(startIn(k),content1{k});
    first = str2sym(first);
    first = Matrix_to_Bloch(A(first));
    [endIn(k), second] = checkBracket(endIn(k), content2{k});
    second = Matrix_to_Bloch(str2sym(second));

%     final = subs(second, [t, t_a, t_b], [t_val, t_a_val, t_b_val]);
%     second = subs(second, [t, a, b], [t_val, t_a_val, t_b_val]);

    result = char(HadamardProduct(first, second));
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
%%
%process commutator
%     while sum(line == '[') >0
%         line = regexprep(line, '\[(.*?)\,(.*?)\]', 'comm($1,$2)')
%     end
%create a copy of hadout
target = hadout;
mask1 = 1;
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
    result = char(comm(part1, part2));
    post = target(min(endIn(1) + 1, length(target)) : end);
    target = [pre, result, post];
    mask1 = target == 'S';
end
comm_output = simplify(str2sym(target))