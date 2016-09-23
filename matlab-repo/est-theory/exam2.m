function [] = exam2()

% Important matrices
phi = [1 1; 0 1];
gamma = [1 1; 1 0];
Q = [1 0; 0 1];

Htilde = [0 0.5; 1 0.5];


% A priori information
xbar_0 = [2;3];
Pbar_0 = [1 0; 0 1];

% Observation data
y = [3; 2];
R = [1 0; 0 2];

% -----------------------------
% Sequential algorithm
% -----------------------------

% Already have integrated ref. trajectory and state transition matrix

% Propagate prior knowledge at t0 -> t1
% Use propagation equations with State Noise Compensation

xbar_1 = phi*xbar_0; % + gamma * ubar ...? 	% 4.9.46, discrete of 4.9.19-20

Pbar_1 = phi*Pbar_0*phi' + gamma*Q*gamma'; 	% 4.9.50

% Given observation deviation, obs-state matrix, compute gain

C = (Htilde*Pbar_1*Htilde' + R);

Cinv1 = inv(C);
L = chol(C,'lower');
Cinv2 = inv(L')*inv(L);
[qq,rr] = qr(C);
Cinv3 = rr\qq';

K = Pbar_1*Htilde' * Cinv1;

% Solve for updated state and covariance

fprintf('*** With State Noise Compensation ***')
xhat_1 = xbar_1 + K*( y - Htilde*xbar_1 )

P_1 = (eye(size(y,1)) - K*Htilde) * Pbar_1

% Now solve without SNC

xbarwo_1 = phi*xbar_0;
Pbarwo_1 = phi*Pbar_0*phi';

Cwo = (Htilde*Pbarwo_1*Htilde' + R);

Cinv1wo = inv(Cwo);

Kwo = Pbarwo_1*Htilde' * Cinv1wo;

fprintf('*** Without SNC ***')
xhatwo_1 = xbarwo_1 + Kwo*( y - Htilde*xbarwo_1 )

Pwo_1 = (eye(size(y,1)) - Kwo*Htilde) * Pbarwo_1

keyboard
end

