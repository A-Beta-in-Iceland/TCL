function out = check_vec(matrix, vec)
    syms A B zero one p [2,2]
    %you can add as many dummy variables as you want
    
    % zero = [1, 2; 3, 4];
    % one = [5, 6; 7, 8];
    % A = [9, 10; 11, 12];
    % B = [13, 14; 15, 16];
    
    % matrix = comm(zero, comm(A, one) * p * B);
    matrix = reshape(matrix, [4,1]);
    
    vec_p = reshape(p, [4,1]);
    id = eye(2);
    
    % vec = (kron(id, zero) - kron(zero.', id)) * kron(B.', comm(A, one)) * vec_p;
    
    out = simplify(matrix - vec);
    out = char(sum(out));
    out = strcmp(out, '0');
end
