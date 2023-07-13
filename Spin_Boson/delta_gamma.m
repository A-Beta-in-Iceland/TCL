function out = delta_gamma(str)
    syms a b t real
    assume(t > 0);
    assumeAlso(t < a);
    assumeAlso(a > 0);
    assumeAlso(a < b);
    
    % str = '-[a,(0*(GTtb-GTta))](b*(GTb0))p[b,(a*(Gba-G0a))]';
    pattern = '\(G\w\w\-G\w\w\)';
    [startIndex,endIndex] = regexp(str,pattern);
    while ~isempty(startIndex)
        element1 = str2sym(str(startIndex(1) + 2));
        element2 = str2sym(str(startIndex(1) + 3));
        element3 = str2sym(str(endIndex(1) - 2));
        element4 = str2sym(str(endIndex(1) - 1));
        part1 = element1 - element2;
        part2 = element3 - element4;
        pre = [];
        post = [];
        if startIndex(1) - 1 > 0
            pre = str(1: startIndex(1) - 1);
        end
        if endIndex(1) + 1 < length(str)
            post = str(endIndex(1) + 1: end);
        end
        if isAlways(part1 > part2)
            str = [pre, '(dG', '(', char(part1), ',',  char(part1 - part2), '))',post];
        else
            str = [pre, '(-dG', '(', char(part2), ',',  char(part2 - part1), '))',post];
        end
        [startIndex,endIndex] = regexp(str,pattern);
    end
    out = str;
end