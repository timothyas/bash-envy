function [Xnom, phi] = unpackForPhi(W,Xprev)

if length(W) ~= 9*9+9
	fprintf('*** Error: Unpacking phi after integration, output vector not the expected size ***')
end

Xnom = [W(1:6); Xprev(7:12)];
phi = eye(12);

for i = 1:6
	ind = (i-1)*9 + 1 + 9;
	phi(i,1:9) = W(ind:ind+8)';
end

end
