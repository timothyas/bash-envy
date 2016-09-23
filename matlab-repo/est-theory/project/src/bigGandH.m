function[ y_est, Htilde ] = bigGandH(X,t,c,sid)

N = length(sid);
y_est = zeros(N,1);
Htilde = zeros(N,12);
rs = zeros(3,3);

% --- Station 1 
rs(1,:) = X(10:12)'; % Estimate of station 1

% --- Station 2 (real station 7062)
rs( 2, 1 ) = -2428826.1117;
rs( 2, 2 ) = -4799750.4339;
rs( 2, 3 ) =  3417273.0738;               

% --- Station 3 (real station 7046)
rs( 3, 1 ) = -1736003.0850;
rs( 3, 2 ) = -4425049.6149;
rs( 3, 3 ) =  4241427.1084;   

% --- Get rotation
theta = c.theta_0 + c.w_e*t;
K = [cos(theta) -sin(theta) 0; ...
     sin(theta)  cos(theta) 0; ...
     0              0       1];

for j = 1:N
    r = rs(sid(j),:)';
    r_rot = K*r;
    Rsi = X(1:3) - r_rot;
    
    y_est(j) = norm( Rsi , 2 );
    
    Rsi_inv = 1/y_est(j);
    Htilde(j,1:3) = [Rsi(1)*Rsi_inv, Rsi(2)*Rsi_inv, Rsi(3)*Rsi_inv];
    if sid(j) == 1
    % We estimate position of station 1
    Htilde(j,10:12) = [-(Rsi(1)*cos(theta) + Rsi(2)*sin(theta)) * Rsi_inv, ...
                  (Rsi(1)*sin(theta) - Rsi(2)*cos(theta)) * Rsi_inv, ...
                  -Rsi(3) * Rsi_inv];
    end
end
    




end
