% Recursive Security N Algorithm for OPPP
tic;
n = length(A);
CM_p = symrcm(A);
A = A(CM_p,CM_p);
for i=1:1:length(ZIB)
    ZIB(i) = find(CM_p==ZIB(i));
end
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
    af=zeros(n,1);
    c_f = f;
    while true
        eval(constraint_function);
        if c_f == f
            break;
        else
            c_f = f;
        end
    end


X_best = ones(1, n);
xb_len = 1;
xb_used = n;
cand_X = nan(n, n);
cX_len = 0;

tmp = eye(n);
while ~isempty(tmp)
    c_X = transpose(tmp(1,:));
    tmp(1,:)=[];
    obd = find(A*c_X>0);
    if length(obd) == n
        cX_len = cX_len + 1;
        cand_X(cX_len, :) = c_X;
        continue;
    end
    in_degree = sum(A, 2);
    for i=1:1:length(obd)
        in_degree(obd(i)) = 0;
    end
    
    [~, max_index] = max(in_degree);
    tmp_X = transpose(c_X);
    tmp_X(max_index) = 1;
    if ~any(ismember(tmp, tmp_X, 'rows'))
    	tmp(size(tmp, 1)+1,:) = tmp_X;
    end
end

cand_X(cX_len+1:end,:) = [];
cand_X = unique(cand_X, 'rows');


Xs = zeros(0, n);
Xs_len = 0;
tic
while ~isempty(cand_X)
    c_X = cand_X(1,:);
    cand_X(1,:) = [];
    os = find(c_X==1);
    add = false;
    all_continue = true;
    for i=1:1:length(os)
        for j=1:1:length(adj{os(i)})
            if c_X(adj{os(i)}(j)) == 1
                continue;
            end
            all_continue = false;
            tmp = c_X;
            tmp(os(i)) = 0;
            tmp(adj{os(i)}(j)) = 1;
            if ~any(F(tmp) < 1)
                add = true;
                break;
            end
        end
        if add==true
            break;
        end
    end
    if all_continue == false && add == false;
        continue;
    else
        Xs_len = Xs_len + 1;
        Xs(Xs_len,:) = c_X;
    end
end

cand_X = Xs(find(sum(Xs,2) == min(sum(Xs, 2))),:);
i=0;

while ~isempty(cand_X)
    Xs = cand_X;
    cand_X = zeros(0,n);
    for k=1:1:size(Xs, 1)
        os = find(Xs(k,:)==1);
        for l=1:1:length(os)
            ttmp_X = Xs(k, :);
            ttmp_X(os(l)) = 0;
            repeat = find(ismember(cand_X, ttmp_X, 'rows'), 1);
            if ~isempty(repeat)
                cand_X(repeat,:) = [];
            end            
            
            observability = F(ttmp_X);
             if any(observability < 1)
                    continue;
            end
               c_used = nnz(ttmp_X);
            if xb_used > c_used
                X_best = ttmp_X;
                xb_len = 1;
                xb_used = c_used;
            elseif xb_used == nnz(ttmp_X)
                xb_len = xb_len + 1;
                X_best(xb_len,:) = ttmp_X;
            end
                cand_X(size(cand_X,1)+1,:) = ttmp_X;
        end
    end
    
end

X_best = unique(X_best, 'rows');
placements = nan(size(X_best, 1), nnz(X_best(1,:)));
for i=1:1:size(X_best, 1)
    os = find(X_best(i,:)==1);
    for j=1:1:length(os)
        placements(i, j) = CM_p(os(j));
    end
end

toc;

