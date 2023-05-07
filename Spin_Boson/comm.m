function out = comm(A, B)
    %Commutator for pauli matrices, the output will the summation of I,
    %sigma_x, sigma_y, sigma_z. A and B are sym and output a sym. Suppose that A and B are already expanded
    %as a summation of ... I + ... sigma_x + ... sigma_y + ... sigma_z
    syms I sigma_x sigma_y sigma_z
    %Note that at this point they are seen in matlab as scalars so you
    %can't expand the commutation, it will always return 0.
    %We don't need to keep track of I since every element commutes with I
    [~, coff_A_x, coff_A_y, coff_A_z] = seperate(A)
    [~, coff_B_x, coff_B_y, coff_B_z] = seperate(B)
    coff_x = 2i*(coff_A_y * coff_B_z - coff_A_z * coff_B_y)
    coff_y = 2i*(coff_A_x * coff_B_z - coff_A_z * coff_B_x)
    coff_z = 2i*(coff_A_x * coff_B_y - coff_A_y * coff_B_x)

    out = coff_x * sigma_x + coff_y * sigma_y + coff_z * sigma_z
end
