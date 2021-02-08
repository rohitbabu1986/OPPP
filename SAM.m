% Simulated Annealing Method for OPPP

tic;
n = length(A);
[p, ~] = OPP_GThN(A, ZIB);
X = zeros(1, n);
X(1, p) = 1;
E = @(observability) length(find(observability<1));
T0 = 15;
adj = cell(n, 1);
for i=1:1:n
    A(i,i)=0;
    adj{i} = find(A(i,:)~=0);
    A(i,i)=1;
end

equ = cell(1,n);
for i=1:1:n
    equ{i} = sprintf('f(%d)=X(%d)%s;', i, i, sprintf('+X(%d)', adj{i}));
end
for i=1:1:length(ZIB)
    equ{ZIB(i)} = sprintf('%s+~any([%s]==0);', equ{ZIB(i)}(1:length(equ{ZIB(i)})-1), sprintf('f(%d) ', adj{ZIB(i)}));
    
    num_of_incidents = length(adj{ZIB(i)});
    for j=1:1:num_of_incidents
        incidents = adj{ZIB(i)};
        incidents(j) = [];
        incidents(num_of_incidents) = ZIB(i);
        equ{adj{ZIB(i)}(j)} = sprintf('%s+~any([%s]==0);', equ{adj{ZIB(i)}(j)}(1: length(equ{adj{ZIB(i)}(j)})-1), sprintf('f(%d) ', incidents)); 
        
    end
end
constraint_function = strjoin(equ, '\n');
    f=zeros(n,1);
    c_f = f;
    while true
        eval(constraint_function);
        if c_f == f
            break;
        else
            c_f = f;
        end
    end

X_best = X;
upper_bound = nnz(X);
lower_bound = 0;
warning('off','all');
while upper_bound-lower_bound > 1
    if lower_bound <= 0
        mid_point_coefficient = 0.85;
    else
        mid_point_coefficient = 0.5;
    end
    v_test = floor(mid_point_coefficient*(upper_bound-lower_bound))+lower_bound;
    T = T0;
    M = ceil(0.002 * nchoosek(n, v_test));
   	observable = false;
    c_X = zeros(1, n);
    c_X(1, randperm(n, v_test)) = 1;
    E_cX = E(c_X);

    if E_cX == 0
        X_best = c_X;
        observable = true;
    else
        for i=1:1:40
            X = c_X;
            E_X = E_cX;
            for j=1:1:M
 
                os = find(X==1);
                zs = find(X==0);
                candidate1 = zs(unidrnd(length(zs)));
                candidate2 = os(unidrnd(length(os)));
                X_new = X;
                X_new(candidate1) = 1;
                X_new(candidate2) = 0;
                ob = f(X_new);
                E_nX = E(ob);
                if E_nX == 0
                    X_best = X_new;
                    observable = true;
                    break;
                end

                delta_E = E_nX - E_X;
                if delta_E > 0 && rand > exp(-1 * delta_E / T)
                    break;
                end
                X = X_new;
                E_X = E_nX;
            end
            if observable == true;
                break;
            end
            T = 0.879 * T;
        end
    end
end
placement = find(X_best == 1);
toc;