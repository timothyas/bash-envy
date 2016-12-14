function [solx_M, solP_M, Xnom, phi, omcRMS] = runSequential(iterMax,extFlag)

if nargin < 1
  iterMax = 3
end

if nargin < 2
    extFlag = 'sequential';
end

if strcmp(extFlag,'sequential')
    fprintf(' ** Running sequential estimator **' )
else
    fprintf(' ** Running extended sequential estimator **')
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
xhat = 10*ones(N,M);
phi_0 = eye(N);
y = zeros(l,M);
omcRMS = zeros(l,iterMax);

[Xnom(:,1),xbar,Pbar] = setInitialConditions();

% Iteration tolerance
TOL = 10^-2;
solx_M = zeros(N,iterMax);
solP_M = zeros(N,N,iterMax);
convIter=1;

% P=Pbar;
% Note here: t_0 is at i=1
while norm(xhat,2) > TOL && convIter <= iterMax

[xhat(:,1), P, y(:,1), Xnom(:,1)] = sequentialEstimator( Xnom(:,1), xbar, Pbar, t(1), c, obs, extFlag);
  

  for i = 2:M
      
      % --- Integrate in time
      [Xnom(:,i), phi] = integrateInTime( Xnom(:,i-1), [t(i-1) t(i)], phi_0 );
      
      % --- Propagate prior knowledge
      if strcmp(extFlag,'sequential')
        xbar = phi*xhat(:,i-1);
      end
      Pbar = phi*P*phi';
      
      [xhat(:,i), P, y(:,i), Xnom(:,i) ] = sequentialEstimator( Xnom(:,i), xbar, Pbar, t(i), c, obs, extFlag);
      
  end
  % Fill vector with iteration's x and P
  solx_M(:,convIter) = xhat(:,M);
  solP_M(:,:,convIter) = P;

  % Compute RMS of OMC's
  omcRMS(:,convIter) = sqrt(nanmean(y.^2,2));
  
  % Prep for next iteration
  [~, phi] = integrateInTime( Xnom(:,1), [0, t(M)], phi_0 );
  [~,xbar,Pbar] = setInitialConditions();
  
  if strcmp(extFlag,'sequential')
    fprintf('## Sequential: Iter %d / %d done ##\n',convIter,iterMax);
    xhat(:,1) = phi\xhat(:,M);
    xbar = xbar - xhat(:,1);
    Xnom(:,1) = Xnom(:,1) + xhat(:,1);
  else 
    fprintf('## Ext. Sequential: Iter %d / %d done ##\n',convIter,iterMax);
  end

  convIter = convIter+1;
end

end
function[ xhat, P, yVect, Xnom ] = sequentialEstimator( Xnom, xbar, Pbar, t, c, obs, extFlag )

N = length(Xnom);

% --- Observation computations
obsInd = find(obs.t == t);
sid_i = obs.sid(obsInd);
Nobs = length(sid_i);

% --- Form variables based on # of observations
Y_i = zeros(Nobs,1);
R_i = zeros(Nobs,Nobs);

for i= 1:Nobs
    Y_i(i) = obs.range(obsInd(i));
    R_i(i,i) = 1/obs.wt(obsInd(i));
end

% --- Get the important matrices and compute difference
[Gest, Htilde] = bigGandH( Xnom, t, c, sid_i );
y = Y_i - Gest;

% --- Form the filter
Cmat = (Htilde*Pbar*Htilde' + R_i);
Cinv = inv(Cmat);
K_i = Pbar*Htilde' * Cinv;


% --- Solve for state at t_i
xhat = xbar + K_i*(y-Htilde*xbar);
P= (eye(N) - K_i*Htilde)*Pbar;
if ~strcmp(extFlag,'sequential')
    Xnom = Xnom + xhat;
end

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
