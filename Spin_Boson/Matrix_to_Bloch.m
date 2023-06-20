%This is to save the spectral density. This function takes in a 2x2 matrix
%and return it in terms of Pauli matrices
function out = Matrix_to_Bloch(A)
    syms I x y z 
    X = A;
    coff0 = 1/2 * trace(X);
    coff1 = 1/2 * (X(1,2) + X(2,1));
    coff2 = i/2 * (X(1,2) - X(2,1));
    coff3 = 1/2 * (X(1,1) - X(2,2));
    out = coff0 * I + coff1 * x + coff2 * y + coff3 * z;
end
