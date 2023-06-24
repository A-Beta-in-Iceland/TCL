function [coff0, coff1, coff2, coff3] = seperate(input)
%Seperate out the coefficients in front of pauli matrices.
%   coff0: coefficient in front of I
%   coff1: coefficient in front of sigma_x
%   coff2: coefficient in front of sigma_y
%   coff3: coefficient in front of sigma_z
    syms I x y z
    if ~strcmp(class(input), 'sym')
        in_copy = string(input);
        in_copy = str2sym(in_copy);
    else
        in_copy = input;
    end
    coff0 = 0;
    coff1 = 0;
    coff2 = 0;
    coff3 = 0;
    coff0 = subs(in_copy, [I, x, y, z], [1, 0, 0, 0]);
    coff1 = subs(in_copy, [I, x, y, z], [0, 1, 0, 0]);
    coff2 = subs(in_copy, [I, x, y, z], [0, 0, 1, 0]);
    coff3 = subs(in_copy, [I, x, y, z], [0, 0, 0, 1]);
end