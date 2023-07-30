function out = implicit_mutiplication(symbols, line)
    %this function serve to recover the multiplication opertators that is
    %omitted in the written lines. 

    %between brackets
    out = replace(line, '][', ']*[');
    out = replace(out, '](', ']*(');
    out = replace(out, ')[', ')*[');
    out = replace(out, ')(', ')*(');
    out = replace(out, 'ES', 'E*S');
    out = replace(out, 'E(', 'E*(');
    out = replace(out, ')S', ')*S');
    out = replace(out, 'E[', 'E*[');
    out = replace(out, ']S', ']*S');
    
    %bracket and symbols
    for k = 1 : length(symbols)
        out = replace(out, [']', symbols{k}], [']*', symbols{k}]);
        out = replace(out, ['E', symbols{k}], ['E*', symbols{k}]);
        out = replace(out, [')', symbols{k}], [')*', symbols{k}]);
        out = replace(out, [symbols{k}, '['], [symbols{k}, '*[']);
        out = replace(out, [symbols{k}, 'S'], [symbols{k}, '*S']);
        out = replace(out, [symbols{k}, '('], [symbols{k}, '*(']);
    end

    %symbols and symbols
    for k = 1: length(symbols)
        for i = 1: length(symbols)
            out = replace(out, [symbols{k}, symbols{i}], [symbols{k}, '*', symbols{i}]);
        end 
    end
end 