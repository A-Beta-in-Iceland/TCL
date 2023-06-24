function out = comm(A, B)
    %Commutator for pauli matrices, the output will the summation of I,
    %sigma_x, sigma_y, sigma_z. A and B are sym and output a sym. Suppose that A and B are already expanded
    %as a summation of ... I + ... sigma_x + ... sigma_y + ... sigma_z.
    %Commutator will not have I terms since I commutes with all square
    %matrices, in this case 2 x 2 matrices
    syms I x y z
    %Note that at this point they are seen in matlab as scalars so you
    %can't expand the commutation, it will always return 0.
    %We don't need to keep track of I since every element commutes with I
     if sum(size(A) == [1,1]) == 2
        A = subs(A, [I,x,y,z], {[1,0;0,1], [0,1;1,0], [0, -i; i, 0], [1, 0; -1, 0]});
    end
    if sum(size(B) == [1,1]) == 2
        B = subs(B, [I,x,y,z], {[1,0;0,1], [0,1;1,0], [0, -i; i, 0], [1, 0; -1, 0]});
    end

    [~, coff_A_x, coff_A_y, coff_A_z] = Matrix_to_Bloch_vector(A);
    [~, coff_B_x, coff_B_y, coff_B_z] = Matrix_to_Bloch_vector(B);
    coff_x = 2i*(coff_A_y * coff_B_z - coff_A_z * coff_B_y);
    coff_y = 2i*(coff_A_x * coff_B_z - coff_A_z * coff_B_x);
    coff_z = 2i*(coff_A_x * coff_B_y - coff_A_y * coff_B_x);

    out = coff_x * x + coff_y * y + coff_z * z;
end
