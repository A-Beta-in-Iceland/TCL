% Input string
% line = '-[I*b*(conj(g11(b, a))/2 + conj(g22(b, a))/2 - conj(g11(b, t))/2 - conj(g22(b, t))/2) + b*x*(conj(g12(b, a))/2 + conj(g21(b, a))/2 - conj(g12(b, t))/2 - conj(g21(b, t))/2) - b*y*((conj(g12(b, a))*1i)/2 - (conj(g21(b, a))*1i)/2 - (conj(g12(b, t))*1i)/2 + (conj(g21(b, t))*1i)/2) + b*z*(conj(g11(b, a))/2 - conj(g22(b, a))/2 - conj(g11(b, t))/2 + conj(g22(b, t))/2),[[a, a; a, a],0]I*a*(conj(g11(a, 0))/2 + conj(g22(a, 0))/2 - conj(g11(a, b))/2 - conj(g22(a, b))/2) + a*x*(conj(g12(a, 0))/2 + conj(g21(a, 0))/2 - conj(g12(a, b))/2 - conj(g21(a, b))/2) - a*y*((conj(g12(a, 0))*1i)/2 - (conj(g21(a, 0))*1i)/2 - (conj(g12(a, b))*1i)/2 + (conj(g21(a, b))*1i)/2) + a*z*(conj(g11(a, 0))/2 - conj(g22(a, 0))/2 - conj(g11(a, b))/2 + conj(g22(a, b))/2)]';
line = char(out0)
% Replace conj(g\d\d(...)) with \Gamma^*_{$1$2}(...)
pattern = 'conj\(g(\d)(.*?)\)';
replacement = '\\gamma^*_{$1}$2'
line = regexprep(line, pattern, replacement);

pattern = 'g(\d)(.*?)';
replacement = '\\gamma_{$1}$2'
line = regexprep(line, pattern, replacement);


line = replace(line, 'x', '\sigma_x')
line = replace(line, 'y', '\sigma_y')
line = replace(line, 'z', '\sigma_z')

line = replace(line, 'del', '\Delta')
line = replace(line, 'epsilon', '\epsilon')

pat = '\((.*?)\)\^\(1/2\)'
replacement = '\\sqrt\{$1\}'
line = regexprep(line, pat, replacement)

% Display the modified string
disp(line);
