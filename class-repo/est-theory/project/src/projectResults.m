% ---- Compare results from all estimators

iters = 3;

saveMat = 'estSims.mat';

if( ~exist(saveMat,'file') )
[bx_0, bP_0, bXnom, bPhi, bOMC] = runBatch(iters);
[sx_M, sP_M, sXnom, sPhi, sOMC] = runSequential(iters,'sequential');
[esx_M, esP_M, esXnom, esPhi, esOMC] = runSequential(iters,'extended');
[b5x_0, b5P_0, b5Xnom, b5Phi, b5OMC] = runBatch(iters,'five');
[b6x_0, b6P_0, b6Xnom, b6Phi, b6OMC] = runBatch(iters,'six',bXnom);

N = size(bx_0,1);
M = size(bXnom,2);

bx_M = zeros(N,iters);
b5x_M = zeros(N,iters);
b6x_M = zeros(N,iters);
sx_0 = zeros(N,iters);
esx_0= zeros(N,iters);

bP_M = zeros(N,N,iters);
b5P_M = zeros(N,N,iters);
b6P_M = zeros(N,N,iters);
sP_0 = zeros(N,N,iters);
esP_0= zeros(N,N,iters);

for i=1:iters
  bx_M(:,i) = bPhi*bx_0(:,i);
  b5x_M(:,i) = bPhi*bx_0(:,i);
  b6x_M(:,i) = bPhi*bx_0(:,i);
  sx_0(:,i) = bPhi\sx_M(:,i);
  esx_0(:,i)= bPhi\esx_M(:,i);

  bP_M(:,:,i) = bPhi*bP_0(:,:,i)*bPhi';
  b5P_M(:,:,i) = bPhi*bP_0(:,:,i)*bPhi';
  b6P_M(:,:,i) = bPhi*bP_0(:,:,i)*bPhi';
  sP_0(:,:,i) = bPhi\(sP_M(:,:,i)*inv(bPhi'));
  esP_0(:,:,i) = bPhi\(esP_M(:,:,i)*inv(bPhi'));

end

b = struct('x0',bx_0,'xM',bx_M,'P0',bP_0,'PM',bP_M,'Xnom',bXnom,'phi',bPhi,'omc',bOMC);
s = struct('x0',sx_0,'xM',sx_M,'P0',sP_0,'PM',sP_M,'Xnom',sXnom,'phi',sPhi,'omc',sOMC);
es = struct('x0',esx_0,'xM',esx_M,'P0',esP_0,'PM',esP_M,'Xnom',esXnom,'phi',esPhi,'omc',esOMC);
bf = struct('x0',b5x_0,'xM',b5x_M,'P0',b5P_0,'PM',b5P_M,'Xnom',b5Xnom,'phi',b5Phi,'omc',b5OMC);
bs = struct('x0',b6x_0,'xM',b6x_M,'P0',b6P_0,'PM',b6P_M,'Xnom',b6Xnom,'phi',b6Phi,'omc',b6OMC);

sat = struct('b',b,'s',s,'es',es,'bf',bf,'bs',bs,'iters',iters);
save(saveMat,'sat');

else
  load(saveMat);
end

% --- Nice printing ... 

  fprintf('# --- Batch --- #\n\n')
  fprintf(' xhat \n')
  fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.b.x0(:,1:3)')
  fprintf('-----------------------------------------')
  fprintf('\n')
  fprintf(' RMS( OMC )\n')
  fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.b.omc(1,1:3))
  fprintf('-----------------------------------------')
  fprintf('\n')
  fprintf(' P \n' )
  fprintf('%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t\n',sat.b.P0(:,:,3)')
  fprintf('-----------------------------------------')
  fprintf('-----------------------------------------')
  fprintf('\n')

  fprintf('# --- Sequential --- #\n\n')
  fprintf(' xhat \n')
  fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.s.x0(:,1:3)')
  fprintf('-----------------------------------------')
  fprintf('\n')
  fprintf(' RMS( OMC ) \n')
  fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.s.omc(1,1:3))
  fprintf('-----------------------------------------')
  fprintf('\n')
  fprintf(' P \n' )
  fprintf('%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t\n',sat.s.P0(:,:,3)')
  fprintf('-----------------------------------------')
  fprintf('-----------------------------------------')
  fprintf('\n')

 fprintf('# --- Ext. Sequential --- #\n\n')
 fprintf(' xhat \n')
 fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.es.x0(:,1:3)')
 fprintf('-----------------------------------------')
 fprintf('\n')
 fprintf(' RMS( OMC ) \n')
 fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.es.omc(1,1:3))
 fprintf('-----------------------------------------')
 fprintf('\n')
 fprintf(' P \n' )
 fprintf('%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t\n',sat.es.P0(:,:,3)')
 fprintf('-----------------------------------------')
 fprintf('-----------------------------------------')
 fprintf('\n')

 fprintf('# --- Problem 5: Batch --- #\n\n')
 fprintf(' xhat \n')
 fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.bf.x0(:,1:3)')
 fprintf('-----------------------------------------')
 fprintf('\n')
 fprintf(' RMS( OMC ) \n')
 fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.bf.omc(1,1:3))
 fprintf('-----------------------------------------')
 fprintf('\n')
 fprintf(' P \n' )
 fprintf('%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t\n',sat.bf.P0(:,:,3)')
 fprintf('-----------------------------------------')
 fprintf('-----------------------------------------')
 fprintf('\n')

 fprintf('# --- Problem 6: Batch --- #\n\n')
 fprintf(' xhat \n')
 fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.bs.x0(:,1:3)')
 fprintf('-----------------------------------------')
 fprintf('\n')
 fprintf(' RMS( OMC ) \n')
 fprintf('%1.4e\t%1.4e\t%1.4e\t\n',sat.bs.omc(1,1:3))
 fprintf('-----------------------------------------')
 fprintf('\n')
 fprintf(' P \n' )
 fprintf('%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\t\n',sat.bs.P0(:,:,2)')
 fprintf('-----------------------------------------')
 fprintf('-----------------------------------------')
 fprintf('\n')

iVect = 1:iters;
semilogy(iVect,sat.b.omc(1,:),'+-',iVect,sat.s.omc(1,:),'x-',iVect,sat.es.omc(1,:),'*-')
  xlabel('Iterations to convergence')
  ylabel('RMS(Observations - Model Output)')
  legend('Batch','Sequential','Ext. Sequential')

