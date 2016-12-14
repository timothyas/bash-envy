function [Wdot] = packForPhiDot(Xdot,phiDot)

if size(phiDot,1) ~= 6
	fprintf('*** Error: packing for phi dot result, num rows /= 6 ***')
%	keyboard
end
if size(phiDot,2) ~= 9
	fprintf('*** Error: packing for phi dot result, num cols /= 9 ***')
end

Wdot = zeros(9*9+9,1);

Wdot(1:9) = [Xdot; zeros(3,1)];

for i=1:6
    ind = (i-1)*9+1+9;
	Wdot(ind:ind+8) = phiDot(i,:)';
end

for i = 7:9
    ind = (i-1)*9+1+9;
    Wdot(ind:ind+8) = zeros(1,9)';
end

end
