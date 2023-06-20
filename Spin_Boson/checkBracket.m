function [out_index, out] = checkBracket(in_index, input)
%%checking if there are any extra bracket that is for some outer bracket
    val1 = sum(input == '(');
    val2 = sum(input == ')');
    if val1 > val2
        out = input(2:end);
        out_index = in_index + 1;
    elseif val1 < val2
        out = input(1:end-1);
        out_index = in_index - 1;
    else
        out = input;
        out_index = in_index;
    end
end