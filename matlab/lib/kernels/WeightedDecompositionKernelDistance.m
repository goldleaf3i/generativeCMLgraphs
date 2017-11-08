%calcola la distanza weighted decomposition kernel (Menchetti) tra due grafi,
%considera i selettori fatti dai singoli nodi, mentre i contesti sono i
%sottografi centrati sui selettori con un certo raggio
%INPUT:  F1, F2 - matrici di adiacenza dei sottografi con le etichette
%sulla diagonale
%        radius - massimo raggio di espansione dal nodo selettore
%OUTPUT: WDKdistance - distanza weighted decomposition kernel (Menchetti)
function [WDKdistance] = WeightedDecompositionKernelDistance(F1, F2, radius)
Flin = cell(1,2);
Flin{1} = F1;
Flin{2} = F2;
K = createWeightedDecompositionKernelMatrix(Flin, radius, 0, 0);
WDKdistance = sqrt(K(1,1) + K(2,2) - 2*K(1,2));
end