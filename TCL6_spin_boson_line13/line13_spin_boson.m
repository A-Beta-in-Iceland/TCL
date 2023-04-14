%define pauli matrices
sigma_x = [0, 1; 1, 0];
sigma_y = [0, -i; i, 0];
sigma_z = [1, 0; 0, -1];

%define elements used in TCL6
%Assume that all matrix is m by m, at this point we assume large m bc
%matlab doesn't support arbitrary matrix size
m = 2;
%Gamma funciton
syms G(a,b) [m, m] matrix
%A operators, a function of time
syms A(t) [m,m] matrix
syms p [m,m] matrix
syms t_0
line13 = - comm((A(b)*(G(b,a)'-G(b,t)')), comm(A(a),(A(t_0)*(G(t,b)'-G(t,a)')))*(A(a)*(G(a,t_0)'-G(a,b)')))*p*A(b)- comm((A(b)*(G(b,a)'-G(b,t)')),(A(t_0)*(G(t,b)'-G(t,a)')))*(A(a)*(G(a,t_0)'-G(a,b)'))*p*comm(a,b)'

%Now on spin boson
syms eps del
H_0 = (eps/2) .* sigma_z + (del / 2) .* sigma_x;
syms sigma_z(t)
sigma_z(t) = expm(i.*t.*H_0) * sigma_z * expm((-i).*t .* H_0)
line_val = subs(line13, 'A(t)', 'sigma_z(t)')