function[ Xnom, phi ] = integrateInTime( Xprev, tspan, phi_0 )
% ------------------------------------------------------
% Use ODE45 to integrate the Xnom and phi from tspan(1) to 
% tspan(2)
% 
%
% ------------------------------------------------------

opts = odeset('RelTol',10^-10);

Win = packForPhi(Xprev,phi_0);

[tout,Wout] = ode45(@xAndPhiFunc,tspan, Win, opts);

[Xnom, phi] = unpackForPhi(Wout(end,:)',Xprev);

end
