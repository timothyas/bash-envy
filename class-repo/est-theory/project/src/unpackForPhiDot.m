function [Xreduced,phiReduced] = unpackForPhiDot(W)

if length(W) ~= 9*9+9
	fprintf('*** Error: Unpacking to form phi dot, input vector not the size expected ***');
	size(W)
%	keyboard
end

Xreduced = W(1:9);

phiReduced = zeros(9,9);

for i = 1:9
	ind = (i-1)*9 + 1 + 9;
	phiReduced(i,:) = W(ind:ind+8)';
end

end
