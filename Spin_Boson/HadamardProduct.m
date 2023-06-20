function out = HadmardProduct(A, B)
   syms I x y z
   [coff_A_I, coff_A_x, coff_A_y, coff_A_z] = seperate(A);
   [coff_B_I, coff_B_x, coff_B_y, coff_B_z] = seperate(B);
   coff0 = coff_A_I * coff_B_I + coff_A_z * coff_B_z;
   coff1 = coff_A_x * coff_B_x - coff_A_y * coff_B_y;
   coff2 = coff_A_x * coff_B_y + coff_B_x * coff_A_y;
   coff3 = coff_A_I * coff_B_z + coff_A_z * coff_B_I;
   out = coff0 * I + coff1 * x + coff2 * y + coff3 * z;
end
