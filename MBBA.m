% TOMLAB MINLPBB Code for PMU placement

nbus=14;
c=ones(nbus,1);
A=A_binary_connectivity_matrix(nbus);
bl=ones(nbus,1);
bu=inf*ones(nbus,1);
x_L= zeros(nbus,1);
x_U= ones(nbus,1);
x_min   = x_L; x_max  = x_U;
x_0=0*ones(nbus,1);
IntVars=ones(1,nbus);
Prob = mipAssign(c, A, bl, bu, x_L, x_U, x_0,'nbus14',[],[],IntVars);
Prob.optParam.IterPrint = 1; % Set to 1 to see iterations.
Prob.Solver.Alg = 2;% Depth First, then Breadth (Default Depth First)
Result = tomRun('minlpBB', Prob, 1);
Result.x_k;