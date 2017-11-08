function [ L,N ] = laplacian( A )
    %calcolo laplaciana e N a partire da matrice adiacenza
    D=degree(A);
    L=D-A;
    N=(D^(-0.5))*L*(D^(-0.5));
end

