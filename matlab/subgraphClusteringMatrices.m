%crea tutte le matrici di connessioni dei sottografi per ogni grafo (nuova
%rappresentazione che serve nella fase di sampling)
%INPUT:  C - array di celle delle matrici di connessioni
%        (C{k,i,j} è la matrice di connessione tra il sottografo i e il
%        sottografo j del grafo k)
%        numFgen - array del numero di sottografi generati per ogni cluster
%        graforig - matrice delle posizioni lineari (indici) dei sottografi
%        (elementi di F_e)
%        clustref - matrice degli indici dei cluster di ogni sottografo
%OUTPUT: subgraphClusteringMs - array cell delle matrici di connettività dei
%sottografi (subgraphClusteringMs{k}(i,j) con i diverso da j, rappresenta
%il numero di connessioni tra il sottografo i e quello j del grafo k; se i
%è uguale a j rappresenta l'indice del cluster in cui si trova il
%sottografo i
%        subgraphIds - indici dei sottografi
function [subgraphClusteringMs, subgraphIds] = subgraphClusteringMatrices(C_e, numF, graforig, clustref)
totalGraphs = size(C_e,1);

subgraphClusteringMs = cell(1, totalGraphs);
subgraphIds = cell(1, totalGraphs);
for k=1:totalGraphs
    M = zeros(numF(k));
    for i=1:numF(k)
        M(i,i) = clustref(k,i);
    end
    for i=1:numF(k)
        for j=i+1:numF(k)
            if graforig(k,i) > 0 && graforig(k,j) > 0
                %connessioni totali tra il sottografo i e j del grafo k
                numConnections = sum(C_e{k,i,j}(:));
                M(i,j) = numConnections;
                M(j,i) = numConnections;
            end
        end
    end
    %memorizzo gli indici dei sottografi
    subgraphIds{k} = zeros(1, numF(k));
    for i=1:numF(k)
        subgraphIds{k}(i) = graforig(k,i);
    end
    subgraphClusteringMs{k} = M;
end
end