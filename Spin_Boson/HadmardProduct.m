function out = HadmardProduct(A, B)
   syms I sigma_x sigma_y sigma_z 
   [coff_A_I, coff_A_x, coff_A_y, coff_A_z] = seperate(A)
   [coff_B_I, coff_B_x, coff_B_y, coff_B_z] = seperate(B)
   coff0 = coff_A_I * coff_B_I + coff_A_z * coff_B_z
   coff1 = -2 * coff_A_y * coff_B_y
   coff2 = i * (coff_A_x * coff_B_y + coff_B_x * coff_A_y)
   coff3 = coff_A_I * coff_B_z + coff_A_z * coff_B_I
   out = coff0 * I + coff1 * sigma_x + coff2 * sigma_y + coff3 * sigma_z
end
