function [] = hw1_2()

Nmax = 500;

Prior = zeros(7,1);
Likelihood = zeros(7,Nmax);
evidence = zeros(1,Nmax);
posteri = zeros(7,Nmax);
numerator = zeros(7,1);
for N = 1:Nmax
    for n = 0:6
        m = simDie(n,N);
        Prior(n+1) = pri(n);
        Likelihood(n+1,N) = likeli(m,n,N);
        numerator(n+1) = Prior(n+1)*Likelihood(n+1,N);
        for n2=0:6
            evidence(N) = evidence(N)+pri(n2)*likeli(m,n2,N);
        end
        posteri(n+1,N) = numerator(n+1)/evidence(N);
        evidence(N)=0;
    end
    
end
a=figure;
for i=1:7
    subplot(4,2,i),plot(posteri(i,:))
    legend(sprintf('n = %d',i-1))
end

keyboard
end

function[prob] = pri(n)
prob = ((1/6)^n)*((5/6)^(6-n))*nchoosek(6,n);
end

function[prob] = likeli(m,n,N)
prob = ((n/6)^m)*((1 - n/6)^(N-m))*nchoosek(N,m);
end

function[m] = simDie(n,N)
rollNum = ceil(rand(1,N)*6);
m = sum(rollNum <= n);
end
