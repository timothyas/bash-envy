function [W] = packForPhi(X,phi)

W = zeros(9+9*9,1);

W(1:9) = X(1:9);

for i=1:9
    ind = (i-1)*9+1+9;
	W(ind:ind+8) =  phi(i,1:9)';
end
end
