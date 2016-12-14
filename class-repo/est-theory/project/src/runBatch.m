function [solx_0, solP_0, Xnom, phi, omcRMS] = runBatch(iterMax,probFlag,XnomFrom2)

if nargin < 1 
  iterMax = 3;
end
if nargin < 2
    probFlag = 'two';
    fprintf(' ** Implementing batch for problem 2 ** ')
end
if nargin < 3
    XnomFrom2=0;
end

%% Set parameters
c = setConstants();

%% Read all observations at once 
obs = readObs();

%% Prep vars
t = unique(obs.t);
M = length(t);
N = 12;
l = 3;

Xnom = zeros(N,M);
phi_0 = eye(N);
xhat = 10*ones(N,1);
y = zeros(l,M);

% Read in initial conditions
[Xnom(:,1),xbar,Pbar] = setInitialConditions();
if strcmp(probFlag, 'five')
    
    Pbar(10,10) = 1e-10;
    Pbar(11,11) = 1e-10;
    Pbar(12,12) = 1e-10;
    fprintf(' ** Implementing batch for problem 5 ** ')

elseif strcmp(probFlag, 'six')
    Pbar(10,10) = 1e-10;
    Pbar(11,11) = 1e-10;
    Pbar(12,12) = 1e-10;
    Xnom = XnomFrom2;
    fprintf(' ** Implementing batch for problem 6 ** ')

end

% Iteration tolerance
TOL = 10^-2;
solx_0 = zeros(N,iterMax);
solP_0 = zeros(N,N,iterMax);
omcRMS = zeros(l,iterMax);
convIter=1;

% Note here: t_0 is at i=1
while norm(xhat,2) > TOL && convIter <= iterMax
  
  Lambda = 1./Pbar;
  Lambda(isinf(Lambda)) = 0;
  bigN = Lambda*xbar;
  [Lambda,bigN, y(:,1)] = accumulateObs( Xnom(:,1), bigN, Lambda, phi_0, 0, c, obs);
  
  for i = 2:M
      
      % --- Integrate in time
      [Xnom(:,i), phi] = integrateInTime( Xnom(:,i-1), [t(i-1) t(i)], phi_0 );
      
      [Lambda, bigN,y(:,i)] = accumulateObs( Xnom(:,i), bigN, Lambda, phi, t(i), c, obs);
  
      phi_0 = phi;
  
  end

  fprintf('## Batch: Iter %d / %d done ##\n',convIter,iterMax);
  
  xhat = Lambda\bigN;
  P = inv(Lambda);

  Xnom(:,1) = Xnom(:,1)+xhat;
  xbar = xbar-xhat;
  phi_0 = eye(N);

  solx_0(:,convIter) = xhat;
  solP_0(:,:,convIter) = P;

  omcRMS(:,convIter) = sqrt(nanmean(y.^2,2));

  convIter = convIter + 1;

end


end
function[ Lambda, bigN, yVect] = accumulateObs( Xnom, bigN, Lambda, phi, t, c, obs )

% --- Observation computations
obsInd = find(obs.t == t);
sid_i = obs.sid(obsInd);
Nobs = length(sid_i);

% --- Form variables based on # of observations
Y_i = zeros(Nobs,1);
W_i = zeros(Nobs,Nobs);

for i= 1:Nobs
    Y_i(i) = obs.range(obsInd(i));
    W_i(i,i) = obs.wt(obsInd(i));
end 

% --- Get the important matrices and compute difference
[Gest, Htilde] = bigGandH( Xnom, t, c, sid_i );
y = Y_i - Gest;
H = Htilde*phi;

% --- Accumulate
Lambda = Lambda + H'*W_i*H;
bigN = bigN + H'*W_i*y;

% --- Compute y, deal with missing data as NaN
yVect = zeros(3,1);
for i = 1:3
    if isempty( find( sid_i == i ))
	yVect(i) = NaN;
    else
	ii = find(sid_i==i,1);
	yVect(i) = y(ii);
    end
end

end
