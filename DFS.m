% Depth First Search for OPPP;
tic;
n = length(A);
X = zeros(n, 1);
in_degree = sum(A, 2);

for k=1:1:n
    [~, index] = max(in_degree);
    X(index) = 1;
    f = A*X;
    
   if ~any(f < 1)
              break;
    end
    
    in_degree(index) = 0;
    for i=1:1:num_buses
        if A(index, i) == 0 || in_degree(i) == 0
            continue;
        end
        in_degree(i) = 0;
        for j=1:1:num_buses
            if A(i, j) == 0 || f(j) > 0
                continue;
            end
            in_degree(i) = in_degree(i) + 1;
        end
    end
end
placement = find(transpose(X)==1);
toc;

