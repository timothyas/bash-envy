function[ z ] = upperTriSolve( U, y )
%------------------------------------------------------
% Solve the system: 
%
%	UZ = Y
%
% where,
%
% 	U = [N x N] upper triangular matrix
%	y = [N x N] vector
%	z = [N x N] solution vector
%
%------------------------------------------------------


N = length(y);
z = zeros(N,1);

if triu(U) ~= U
  fprintf(' U is not upper triangular! ');
  return;
end

for j = 1:N
  z(N,j) = y(N,j) / U(N,N);
end

for i = N-1:-1:1
  for j = 1:N
    z(i,j) = ( y(i,j) - U(i,i+1:N)*z(i+1:N,j) ) / U(i,i);
  end
end

end
