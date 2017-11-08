%restituisce il sottografo tra due nodi connessi e appartenenti a due
%sottgrafi A e B disgiunti
%INPUT:  subgraphA - matrice di adiacenza del sottografo A
%        subgraphB - matrice di adiacenza del sottografo B
%        nodeA - indice del nodo in A
%        nodeB - indice del nodo in B
%OUTPUT: subgraphAB - sottografo finale
function [subgraphAB] = subgraphPotentialConnection(subgraphA, subgraphB, nodeA, nodeB)
subgraphAB = blkdiag(subgraphA, subgraphB);
dimA = size(subgraphA, 1);
subgraphAB(nodeA, nodeB+dimA) = 1;
subgraphAB(nodeB+dimA, nodeA) = 1;
end