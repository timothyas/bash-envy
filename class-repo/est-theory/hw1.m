function [ ] = hw1( )

% prob1;
% 
% prob2;
% 
prob3;
% 
% prob4;

prob6;
% 
prob7;

end

function [] = prob7()

x=[1:5];
y=[-3,3,6,15,22];

dJda = [sum( 4*x.^2 ) sum(2*x.*(1-.5*x.^2)); sum( 2*x.*(1-.5*x.^2) ) sum( (-.5*x.^2+1).^2)];
E = [sum( 2*x.*y); sum( (-.5*x.^2+1).*y )];
p = dJda\E;

G = @(x) [2*x', (-.5*x'.^2+1)]*p;

%plot in data space
xx=x(1):.1:x(end);
figure
plot(x,y,'*',xx,G(xx))
xlabel('x')
ylabel('y')
title('Data Space')

fprintf('M(0) ~ %1.4f\n',p(1))
fprintf('B(0) ~ %1.4f\n',p(2))
end

function [] = prob6()

x=[1:5];
y=[-3,3,6,15,22];

dJda = [sum( (x.^2 - 2).^2 ) sum(2*x.*(x.^2 - 2)); sum( 2*x.*(x.^2 - 2)) sum(4*x.^2)];
E = [sum( (x.^2 - 2).*y); sum( 2*x.*y )];
p = dJda\E;

G = @(x) [(x.^2-2)',x']*p;

%plot in data space
xx=x(1):.1:x(end);
a=figure;
plot(x,y,'*',xx,G(xx))
xlabel('t')
ylabel('\rho')
xlim([0 6])
title('Data Space')
saveLatexFig('hw1-fig6',a);
fprintf('M(0) ~ %1.4f\n',p(2))
fprintf('B(0) ~ %1.4f\n',-2*p(1))
end

function [] = prob4()

x=[0,1,3];
y=[2,3,20];

dJda = [sum(x.^2) sum(x); sum(x) length(x)];
E = [sum(x.*log(y)); sum(log(y))];
p = dJda\E;

G = @(x) exp([x',ones(length(x),1)]*p);

%plot in data space
xx=x(1):.1:x(end);
figure
semilogy(x,y,'*',xx,G(xx))
xlabel('x')
ylabel('y')
title('Data Space')
end


function [] = prob3()

x=[0,1,1.5,2,2.5,3,4];
y=[1.2,2.1,2.1,1.5,-.3,-1,-2.2];

dJda = [sum(cos(x).^2) sum(cos(x).*sin(x)); sum(cos(x).*sin(x)) sum(sin(x).^2)];
E = [sum(cos(x).*y); sum(sin(x).*y)];
p = dJda\E;

G = @(x) [cos(x)',sin(x)']*p;

%plot in data space
xx=x(1):.1:x(end);
a=figure;
plot(x,y,'*',xx,G(xx))
xlabel('x')
ylabel('y')
title('Data Space')

saveLatexFig('hw1-fig3',a)

end

function [] = prob2()

x=[1,2,3];
y=[1,9,25];

dJda = [sum(x.^6) sum(x.^3); sum(x.^3) length(x)];
E = [sum(x.^3.*y); sum(y)];
p = dJda\E;

G = @(x) p(1)*x.^3 + p(2);

%plot in data space
figure
plot(x,y,'*',1:.1:3,G(1:.1:3))
xlabel('x')
ylabel('y')
title('Data Space')


end

function []=prob1()

x=[1,-1,2];
y=[1,1,2];

dJda = [sum(x.^2) sum(x); sum(x) length(x)];
E = [sum(x.*y); sum(y)];
p = dJda\E;

%plot in data space
figure
plot(x,y,'*',x,x*p(1) + p(2))
xlim([-1.5 2.5])
xlabel('x')
ylabel('y')
ylim([0.8 2.2])
title('Data Space')

beta_1=@(alpha) 1-alpha;
beta_2=@(alpha) 1+alpha;
beta_3=@(alpha) 2*(alpha-1);

% plot in parameter space
a=-5:.1:5;
figure
plot(a,beta_1(a),a,beta_2(a),a,beta_3(a),p(1),p(2),'*')
xlabel('\alpha')
ylabel('\beta')
title('Parameter Space')
legend('\beta = 1-\alpha',...
       '\beta = 1+\alpha',...
       '\beta = 2(\alpha-1)',...
       '(\alpha,\beta)_{best}')

% Check with matlab
% P_check=polyfit(x,y,1)
% p
% figure
% plot(x,y,'*',x,x*P_check(1)+P_check(2))
% keyboard
end