function [coff0, coff1, coff2, coff3] = seperate(input)
%Seperate out the coefficients in front of pauli matrices.
%   coff0: coefficient in front of I
%   coff1: coefficient in front of sigma_x
%   coff2: coefficient in front of sigma_y
%   coff3: coefficient in front of sigma_z
    in_copy = char(input)
    coff0 = 0;
    coff1 = 0;
    coff2 = 0;
    coff3 = 0;
    syms I sigma_x sigma_y sigma_z
    while ~isempty(in_copy)
        [part, in_copy] = strtok(in_copy, '+');
        if ~isempty(strfind(part, 'I'))
            coff0 = coff0 + str2sym(string(part)) ./ I
        elseif ~isempty(strfind(part, 'sigma_x'))
            coff1 = coff1 + str2sym(string(part)) ./ sigma_x
        elseif ~isempty(strfind(part, 'sigma_y'))
            coff2 = coff2 + str2sym(string(part)) ./ sigma_y
        elseif ~isempty(strfind(part, 'sigma_z'))
            coff3 = coff3 + str2sym(string(part)) ./ sigma_z
        end
    end
end