%calcola la matrice stochastic block model
%INPUT:  graphs - array cell delle matrici di adiacenza dei grafi su cui
%fare inferenza
%        ngroup - numero di gruppi
%OUTPUT: M - matrice stochastic block model
function [M] = stochasticBlockModel(graphs,ngroup)
%creo il grafo su cui fare inferenza, la cui matrice di adiacenza è
%diagonale con le matrici di connessione dei grafi originali
ngraphs = size(graphs,2);
Mc = [];
for i=1:ngraphs
    Mc = blkdiag(Mc,graphs{i});
end

%calcolo la somma dei gradi per ogni cluster, i gradi di ogni nodo del
%grafo su cui fare inferenza, il numero di archi tra ogni coppia di cluster
dim = size(Mc,1);
nodeDegrees = zeros(1,dim);
clusterDegrees = zeros(1,ngroup);
edgesClusterPair = zeros(ngroup);
for i=1:dim
    for j=1:dim
        if i ~= j
            nodeDegrees(i) = nodeDegrees(i) + (Mc(i,j) > 0);
            clusterDegrees(Mc(i,i)) = clusterDegrees(Mc(i,i)) + (Mc(i,j) > 0);
            edgesClusterPair(Mc(i,i),Mc(j,j)) = edgesClusterPair(Mc(i,i),Mc(j,j)) + (Mc(i,j) > 0);
        end
    end
end

%assegna le stime di massima verosimiglianza
clusterWeights = edgesClusterPair;
expectedDegrees = zeros(1,dim);
for i=1:dim
    expectedDegrees(i) = nodeDegrees(i)/clusterDegrees(Mc(i,i));
end

%calcolo la matrice dello stochastic block model
M = zeros(ngroup);
for r=1:ngroup
    for s=r:ngroup
        M(r,s) = poisspdf(1,clusterWeights(r,s));
        M(s,r) = M(r,s);
    end
end
end