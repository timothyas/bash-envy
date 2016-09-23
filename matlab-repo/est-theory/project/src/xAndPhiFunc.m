function[Wdot] = xAndPhiFunc(t, W)

[Xreduced,phiReduced] = unpackForPhiDot(W);

x=Xreduced(1);
y=Xreduced(2);
z=Xreduced(3);
xd=Xreduced(4);
yd=Xreduced(5);
zd=Xreduced(6);
mu=Xreduced(7);
J2=Xreduced(8);
beta=Xreduced(9);

c = setConstants;
r =  sqrt(x.^2 + y.^2 + z.^2);%[km]


%% Grad(u) = (L,M,N)'
L =  -mu*x/r^3 * (1 - 1.5*(c.r_e/r)^2 * J2 * ( 5*(z/r)^2 - 1 ));
M =  -mu*y/r^3 * (1 - 1.5*(c.r_e/r)^2 * J2 * ( 5*(z/r)^2 - 1 ));
N =  -mu*z/r^3 * (1 - 1.5*(c.r_e/r)^2 * J2 * ( 5*(z/r)^2 - 3 ));

%% Grad(L,M,N) 
dLdx =  L/x + 3*mu*x^2/r^5*(1 - 2.5*(c.r_e/r)^2 * J2 * ( 7*(z/r)^2 - 1 ));
dMdy =  M/y + 3*mu*y^2/r^5*(1 - 2.5*(c.r_e/r)^2 * J2 * ( 7*(z/r)^2 - 1 ));
dNdz =  N/z + 3*mu*z^2/r^5*(1 - 2.5*(c.r_e/r)^2 * J2 * ( 7*(z/r)^2 - 5 ));

dLdy =  3*mu*x*y/r^5*(1 - 2.5*(c.r_e/r)^2 * J2 * ( 7*(z/r)^2 - 1 ));
dLdz =  3*mu*x*z/r^5*(1 - 2.5*(c.r_e/r)^2 * J2 * ( 7*(z/r)^2 - 3 ));

dMdx =  3*mu*y*x/r^5*(1 - 2.5*(c.r_e/r)^2 * J2 * ( 7*(z/r)^2 - 1 ));
dMdz =  3*mu*y*z/r^5*(1 - 2.5*(c.r_e/r)^2 * J2 * ( 7*(z/r)^2 - 3 ));

dNdx =  3*mu*z*x/r^5*(1 - 2.5*(c.r_e/r)^2 * J2 * ( 7*(z/r)^2 - 3 ));
dNdy =  3*mu*z*y/r^5*(1 - 2.5*(c.r_e/r)^2 * J2 * ( 7*(z/r)^2 - 3 ));

%% Beta terms
rho =  c.rho_0*exp(-c.gamma_0*(r - c.r_e - c.h_0));         %[kg/m^3]


a =  xd + y*c.w_e;
b =  yd - x*c.w_e;
Q =  sqrt(a^2 + b^2 + zd^2);

dLdJ = 1.5*(c.r_e/r)^2 * mu*x/r^3 * (5*(z/r)^2 - 1);
dMdJ = 1.5*(c.r_e/r)^2 * mu*y/r^3 * (5*(z/r)^2 - 1);
dNdJ = 1.5*(c.r_e/r)^2 * mu*z/r^3 * (5*(z/r)^2 - 3);

ddx_Qa = -beta*rho*a * (c.gamma_0 *Q*x/r + b*c.w_e/Q);
ddy_Qb = -beta*rho*b * (c.gamma_0 *Q*y/r - a*c.w_e/Q);
ddz_Qc = -beta*rho*zd*  c.gamma_0 *Q*z/r;

ddy_Qa = -beta*rho * (c.gamma_0*Q*y*a/r - a^2*c.w_e/Q - Q*c.w_e);
ddx_Qb = -beta*rho * (c.gamma_0*Q*b*x/r + b^2*c.w_e/Q + Q*c.w_e);

ddx_Qc = -beta*rho*zd * (c.gamma_0*Q*x/r + b*c.w_e/Q);
ddy_Qc = -beta*rho*zd * (c.gamma_0*Q*y/r - a*c.w_e/Q);

ddz_Qa = -beta*rho * c.gamma_0*Q*a*z/r;
ddz_Qb = -beta*rho * c.gamma_0*Q*b*z/r;

ddxd_Qa = beta*rho * (a^2/Q + Q);
ddyd_Qa = beta*rho * a*b/Q;
ddzd_Qa = beta*rho * a*zd/Q;

ddxd_Qb = beta*rho * a*b/Q;
ddyd_Qb = beta*rho * (b^2/Q + Q);
ddzd_Qb = beta*rho * b*zd/Q;

ddxd_Qc = beta*rho * a*zd/Q;
ddyd_Qc = beta*rho * b*zd/Q;
ddzd_Qc = beta*rho * (zd^2/Q + Q);

%% Form A
A = [0 0 0 1 zeros(1,5); 
	 0 0 0 0 1 zeros(1,4);
	zeros(1,5) 1 zeros(1,3); 
	(dLdx - ddx_Qa), (dLdy - ddy_Qa), (dLdz - ddz_Qa), ...
	-ddxd_Qa, -ddyd_Qa, -ddzd_Qa,  L/mu, dLdJ, -rho*Q*a; ...
	dMdx - ddx_Qb, dMdy - ddy_Qb, dMdz - ddz_Qb, ...
	-ddxd_Qb, -ddyd_Qb, -ddzd_Qb, M/mu, dMdJ, -rho*Q*b; ...
	dNdx - ddx_Qc, dNdy - ddy_Qc, dNdz - ddz_Qc, ...
       -ddxd_Qc, -ddyd_Qc, -ddzd_Qc, N/mu, dNdJ, -rho*Q*zd];

%% Compute phidot
phiDot = A*phiReduced;

%% Form Xdot
Xdot = [ xd;yd;zd; ...
	  L - beta*rho*Q*a; ...
	  M - beta*rho*Q*b; ...
	  N - beta*rho*Q*zd];

Wdot = packForPhiDot( Xdot, phiDot );
end