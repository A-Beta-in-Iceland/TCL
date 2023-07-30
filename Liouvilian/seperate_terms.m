function output = seperate_terms(input)
%output is a cell of char and input is a string
    output = {}

    if input(1) ~= '-'
        input = ['+', input]
    end
    %% Find all the Hadamard Product
    line = input;
    line = replace(line, '*', 'q');
    pattern = '\(([^q])q\(([^q]+)\)\)';
    % (\([^o()]+\) o [^o()]+\) captures the desired pattern
    % [^o()] matches any character except 'o', '(' and ')'
    
    % Find matches using regular expressions
    matches = regexp(line, pattern, 'tokens'); 
    [startIn, endIn] = regexp(line, pattern);

    % Find all the +- in the input
    mask = input == '+' | input == '-';
    str_mask = num2str(mask);
    str_mask = str_mask(str_mask ~= ' ');
    pos = strfind(str_mask, '1')
    
    for i = 1 : length(startIn)
        mask2 = pos > startIn(i) & pos < endIn(i)
        pos = pos(~mask2)
    end 
    pos = pos(2:end)
    if ~isempty(pos)
        output{1} = input(1: pos(1)-1)
        i = 1
            while i <= length(pos) -1
                output{1 + i} = input(pos(i) : pos(i + 1) - 1);
                i = i + 1;
            end
        output{i + 1} = input(pos(i) : end)
    end
end