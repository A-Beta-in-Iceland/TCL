function out = comm(A, B)   
    if all(size(A) == size(B))
        out = A * B - B * A;
    else
        out = 'size does not match';
        display(out)
    end
end