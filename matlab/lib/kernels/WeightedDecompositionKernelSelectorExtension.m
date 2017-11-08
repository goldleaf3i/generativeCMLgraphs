%estensione del weighted decomposition kernel (Menchetti) tra due grafi,
%considera i selettori fatti dai singoli nodi con label fissate a priori,
%da cambiare sotto nel codice (labelSelector),mentre i contesti sono i
%sottografi centrati sui selettori con raggio incrementale fino ad un upper
%bound (maxradius)
%INPUT:  F1, F2 - matrici di adiacenza dei sottografi con le etichette
%sulla diagonale
%        radius - massimo raggio di espansione dal nodo selettore
%OUTPUT: WDK - weighted decomposition kernel (Menchetti)
function [WDK] = WeightedDecompositionKernelSelectorExtension(F1, F2, radius)
%label dei selettori: C=100, H=105, Y=10, R=5, F=6, K=0
%labelSelector = [100 105 10 5 6 0];
labelSelector = [100,105,110,115];
numnodesF1 = length(F1);
numnodesF2 = length(F2);
%maxradius = max(numnodesF1,numnodesF2);

WDK = 0;
for s1=1:numnodesF1
    for s2=1:numnodesF2
            if F1(s1,s1) == F2(s2,s2) % delta (uguaglianza) tra due nodi basata sull'etichetta
                if labelSelector(labelSelector==F1(s1,s1))
                    [~, rLabelsF1] = radiusNodes(F1,s1,radius);
                    [~, rLabelsF2] = radiusNodes(F2,s2,radius);
                    WDK = WDK + graphProbabilityKernel(rLabelsF1, rLabelsF2, 0.5); %ro=0.5 Bhattacharyya kernel
                end
            end
    end
end
end