line = '-[(b*(GTba-GTbt)),[a,(0*(GTtb-GTta))](a*(GTa0-GTab))]pb-[(b*(GTba-GTbt)),(0*(GTtb-GTta))](a*(GTa0-GTab))p[a,b]'
line = regexprep(line, 'GT(\w)(\w)', 'G($1,$2)\''')
line = regexprep(line, 'G(\w)(\w)', 'G($1,$2)')
while sum(line == '[') >0
    line = regexprep(line, '\[(.*?)\,(.*?)\]', ' comm($1,$2)')
end
line = replace(line, '0', 't_0')
%I will work on this to make it generalize rather than hard coding