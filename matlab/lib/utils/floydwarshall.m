function [matrixDistance] = floydwarshall(A)
n = size(A,1); % number of nodes

matrixDistance=A; % if A(i,j)=1,  D(i,j)=w(i,j);
matrixDistance(A+diag(repmat(Inf,n,1))==0)=Inf; % If A(i,j)~=0 and i~=j D(i,j)=Inf;
matrixDistance=full(matrixDistance.*(ones(n)-eye(n))); % set the diagonal to zero

for k=1:n
    Daux1=repmat(full(matrixDistance(:,k)),1,n);
    Daux2=repmat(full(matrixDistance(k,:)),n,1);
    Sumdist=Daux1+Daux2;
    matrixDistance(Sumdist<matrixDistance)=Sumdist(Sumdist<matrixDistance);
end
end
