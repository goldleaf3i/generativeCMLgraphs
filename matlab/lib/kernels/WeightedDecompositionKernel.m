%calcola il weighted decomposition kernel (Menchetti) tra due grafi,
%considera i selettori fatti dai singoli nodi, mentre i contesti sono i
%sottografi centrati sui selettori con un certo raggio
%INPUT:  F1, F2 - matrici di adiacenza dei sottografi con le etichette
%sulla diagonale
%        radius - massimo raggio di espansione dal nodo selettore
%OUTPUT: WDK - weighted decomposition kernel (Menchetti)
function [WDK] = WeightedDecompositionKernel(F1, F2, radius)
numnodesF1 = length(F1);
numnodesF2 = length(F2);
%maxradius = max(numnodesF1,numnodesF2);

WDK = 0;
for s1=1:numnodesF1
    for s2=1:numnodesF2
        if F1(s1,s1) == F2(s2,s2) % delta (uguaglianza) tra due nodi basata sull'etichetta
            [~, rLabelsF1] = radiusNodes(F1,s1,radius);
            [~, rLabelsF2] = radiusNodes(F2,s2,radius);
            WDK = WDK + graphProbabilityKernel(rLabelsF1, rLabelsF2, 0.5); %ro=0.5 Bhattacharyya kernel 
        end
    end
end
end