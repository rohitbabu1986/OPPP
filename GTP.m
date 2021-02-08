% Graphic Theoretic Procedure for OPPP

tic;
n = length(A);
X = zeros(n, 1);
in_degree = sum(A, 2);
mod_A = A;
handled = false;
for i=1:1:length(ZIB)
    for j=1:1:n
        if any(ZIB == j)
            continue;
        else
            mod_A(j,:) = or(A(i,:), A(j,:));
            mod_A(i,:) = mod_A(j,:);
            handled = true;
            break;
        end
    end
    if handled == false
       mod_A(i, :) = zeros(1, n);
    end
    handled = false;
end
success = true;

for k=1:1:n
   [~, index] = max(in_degree);
    X(index) = 1;
    f = mod_A*X;
   if ~any(f < 1)
        break;
    end
    in_degree(index) = 0;
    for i=1:1:n
        if A(index, i) == 0 || in_degree(i) == 0
            continue;
        end
        in_degree(i) = 0;
        for j=1:1:n
            if A(i, j) == 0 || f(j) > 0
                continue;
            end
            in_degree(i) = in_degree(i) + 1;
        end
    end
end

placement = find(transpose(X)==1);
toc;

