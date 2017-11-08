%calcola la distanza shortest path kernel tra due grafi
%INPUT:  F1, F2 - matrici di adiacenza dei sottografi con le etichette
%sulla diagonale ed eventualmente pesate
%        dimLabels - è la dimensione dell'alfabeto delle etichette
%OUTPUT: SPKdistance - distanza shortest path kernel
function [SPKdistance] = ShortestPathKernelDistance(F1, F2, dimLabels)
Flin = cell(1,2);
Flin{1} = F1;
Flin{2} = F2;
K = createShortestPathKernelMatrix(Flin, dimLabels);
SPKdistance = sqrt(K(1,1) + K(2,2) - 2*K(1,2));
end