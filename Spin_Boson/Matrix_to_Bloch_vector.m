%This is to save the spectral density. This function takes in a 2x2 matrix
%and return it in terms of Pauli matrices
function [coff0, coff1, coff2, coff3] = Matrix_to_Bloch_vector(A)
    syms I x y z 
    X = A;
    S = size(X);
    if X == 0
        coff0 = 0;
        coff1 = 0;
        coff2 = 0;
        coff3 = 0;
    elseif S(1) == 2 & S(2) == 2
        coff0 = 1/2 * trace(X);
        coff1 = 1/2 * (X(1,2) + X(2,1));
        coff2 = 1i/2 * (X(1,2) - X(2,1));
        coff3 = 1/2 * (X(1,1) - X(2,2));
    else
        coff0 = 'error';
        coff1 = 'error';
        coff2 = 'error';
        coff3 = 'error';
    end
end
