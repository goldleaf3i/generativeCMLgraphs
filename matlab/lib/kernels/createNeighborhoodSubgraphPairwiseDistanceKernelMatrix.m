%calcola la matrice di neighborhood subgraph pairwise distance kernel (Costa)
%INPUT:  Flin - array di celle dei sottografi (linearizzazione di F_e)
%        parameters - array di due elementi, [distance radius]. Il radius è
%        il massimo raggio di espansione dal nodo selettore, mentre il
%        distance è la massima distanza tra le coppie di intra-sottografi
%        n - indica se normalizzare o meno la matrice di kernel
%OUTPUT: K - matrice di neighborhood subgraph pairwise distance kernel (Costa)
function [K] = createNeighborhoodSubgraphPairwiseDistanceKernelMatrix(Flin, parameters, n)
dim = length(Flin);
K = zeros(dim);
for i=1:dim
    disp(i);
    for j=i:dim
        F1=Flin{i};
        F2=Flin{j};
        
        simi =  NeighborhoodSubgraphPairwiseDistanceKernel(F1, F2, parameters);
        K(i,j) = simi;
        K(j,i) = simi;
    end
end

if n > 0
    %normalizzo la matrice di kernel
    diagK = diag(K);
    for i=1:dim
        for j=i:dim
            K(i,j) = K(i,j)/sqrt(diagK(i)*diagK(j));
            K(j,i) = K(i,j);
        end
    end
end
end