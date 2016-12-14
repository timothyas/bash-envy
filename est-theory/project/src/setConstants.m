function [consts] = setConstants()

re = 6378136.3;             %[ km  ]
h_0 = 9.2E+05;               %[ km ]
gamma_0 = 5.381E-06;         %[ m^-1]
rho_0 = 4.36E-14;            %[
w_e = 7.2921157746E-05;     %[ s^-1]
theta_0 = 1.6331958133;     %[ rad ]

consts = struct('r_e',re,'h_0',h_0,'gamma_0',gamma_0,'rho_0',rho_0,...
                'w_e',w_e,'theta_0',theta_0);

end
