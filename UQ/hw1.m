function [] = hw1()

Nmax = 50;
n = [0:6]';
% N = [1:Nmax];
% m_vec = [0:N]';

m = zeros(7,Nmax);
pri = m;
likeli = m;
cc=m;

for N=1:Nmax
    
    for i=1:7
        m(i,N) = simDie(n(i),N);

    % Compute prior
    pri(i,N) = (1/6).^n(i) .* (5/6).^(6-n(i)) .* nchoosek(6,n(i));
    % Simulate N die rolls, gives m 1's, m<=N
    c1=(n(i)>0 && n(i)<6);
    c2=(n(i) == 0 && m(i,N) == 0);
    c3=(n(i) == 6 && m(i,N) == N);
    cc(i,N) = nchoosek(N,m(i,N));
    likeli(i,N) = ((n(i)/6)^m(i,N)) * ((1-n(i)/6)^(N-m(i,N))) * cc(i,N) * c1 + c2+c3;
    end
    
end

% Compute evidence
evi = repmat(sum(pri.*likeli,1),7,1);

posteri = pri.*likeli./evi;
keyboard
% figure
% for i=0:6
% plot(m_vec,likeli(:,i+1))
% keyboard
% end
% 
% for i=0:N
%     plot(n_vec,posteri(i+1,:))
%     pause(.5)
% end
% keyboard
end

function [m] = simDie(ni,N)
% Compute number of times 1 was rolled given n 1 faces

rollNum = ceil(rand(length(ni),N)*6);
% rollNumMat = repmat(rollNum,7,1);
n = repmat(ni,1,N);
m = sum(rollNum <= n,2);
% if N==50
%     keyboard
% end
end

% function [likeli] = likeliFunc(n,N)
% 
% m = [0:N]';
% 
% likeli = (n/6).^m .* (1-n/6).^(N-m) .* ( factorial(N) ./ (factorial(m)*factorial(N)) );
% end