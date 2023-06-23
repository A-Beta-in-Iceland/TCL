% Input string
% line = '-[I*b*(conj(g11(b, a))/2 + conj(g22(b, a))/2 - conj(g11(b, t))/2 - conj(g22(b, t))/2) + b*x*(conj(g12(b, a))/2 + conj(g21(b, a))/2 - conj(g12(b, t))/2 - conj(g21(b, t))/2) - b*y*((conj(g12(b, a))*1i)/2 - (conj(g21(b, a))*1i)/2 - (conj(g12(b, t))*1i)/2 + (conj(g21(b, t))*1i)/2) + b*z*(conj(g11(b, a))/2 - conj(g22(b, a))/2 - conj(g11(b, t))/2 + conj(g22(b, t))/2),[[a, a; a, a],0]I*a*(conj(g11(a, 0))/2 + conj(g22(a, 0))/2 - conj(g11(a, b))/2 - conj(g22(a, b))/2) + a*x*(conj(g12(a, 0))/2 + conj(g21(a, 0))/2 - conj(g12(a, b))/2 - conj(g21(a, b))/2) - a*y*((conj(g12(a, 0))*1i)/2 - (conj(g21(a, 0))*1i)/2 - (conj(g12(a, b))*1i)/2 + (conj(g21(a, b))*1i)/2) + a*z*(conj(g11(a, 0))/2 - conj(g22(a, 0))/2 - conj(g11(a, b))/2 + conj(g22(a, b))/2)]';
line = 'x*(cos(t*(del^2 + eps^2)^(1/2)) + (2*del^2*sin((t*(del^2 + eps^2)^(1/2))/2)^2)/(del^2 + eps^2)) - (eps*y*sin(t*(del^2 + eps^2)^(1/2)))/(del^2 + eps^2)^(1/2) + (2*del*eps*z*sin((t*(del^2 + eps^2)^(1/2))/2)^2)/(del^2 + eps^2)';
% Replace conj(g\d\d(...)) with \Gamma^*_{$1$2}(...)
% pattern = 'conj\(g(\d)(\d)(.*?)\)';
% replacement = '\\Gamma^*_{$1$2}$3'
% line_modified = regexprep(line, pattern, replacement);
% 
% pattern = '[+-]'
% replacement = '\&$0'
% line_modified = regexprep(line_modified, pattern, replacement);

pattern = 'del';
replacement = '\\Delta';
line_modified = regexprep(line, pattern, replacement);

pattern = 'eps';
replacement = '\\epsilon';
line_modified = regexprep(line_modified, pattern, replacement);

% Display the modified string
disp(line_modified);
