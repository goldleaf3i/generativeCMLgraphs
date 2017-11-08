%calcola la distanza neighborhood subgraph pairwise distance kernel (Costa) tra due grafi,
%considera sfere topologiche centrate sui nodi e aventi raggio e distanza
%incrementali fino ad un upper bound di input
%INPUT:  F1, F2 - matrici di adiacenza dei sottografi con le etichette
%sulla diagonale
%        parameters - array di due elementi, [distance radius]. Il radius è
%        il massimo raggio di espansione dal nodo selettore, mentre il
%        distance è la massima distanza tra le coppie di intra-sottografi
%OUTPUT: NSPDKdistance - distanza neighborhood subgraph pairwise distance kernel (Costa)
function [NSPDKdistance] = NeighborhoodSubgraphPairwiseDistanceKernelDistance(F1, F2, parameters)
Flin = cell(1,2);
Flin{1} = F1;
Flin{2} = F2;
K = createNeighborhoodSubgraphPairwiseDistanceKernelMatrix(Flin, parameters, 0);
NSPDKdistance = sqrt(K(1,1) + K(2,2) - 2*K(1,2));
end