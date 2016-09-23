function[ z ] = upperTriSolve( U, y )
%------------------------------------------------------
% Solve the system: 
%
%	Uz = y
%
% where,
%
% 	U = [N x N] upper triangular matrix
%	y = [N x 1] vector
%	z = [N x 1] solution vector
%
%------------------------------------------------------


N = length(y);
z = zeros(N,1);

if triu(U) ~= U
  fprintf(' U is not upper triangular! ');
  return;
end

z(N) = y(N) / U(N,N);

for i = N-1:-1:1
  z(i) = ( y(i) - U(i,i+1:N)*z(i+1:N) ) / U(i,i);
end

end
