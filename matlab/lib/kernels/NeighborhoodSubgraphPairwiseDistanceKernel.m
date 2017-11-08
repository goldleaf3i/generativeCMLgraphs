%calcola il neighborhood subgraph pairwise distance kernel (Costa) tra due grafi,
%considera sfere topologiche centrate sui nodi e aventi raggio e distanza
%incrementali fino ad un upper bound di input
%INPUT:  F1, F2 - matrici di adiacenza dei sottografi con le etichette
%sulla diagonale
%        parameters - array di due elementi, [distance radius]. Il radius è
%        il massimo raggio di espansione dal nodo selettore, mentre il
%        distance è la massima distanza tra le coppie di intra-sottografi
%OUTPUT: NSPDK - neighborhood subgraph pairwise distance kernel (Costa)
function [NSPDK] = NeighborhoodSubgraphPairwiseDistanceKernel(F1, F2, parameters)
distance = parameters(1);
radius = parameters(2);
numnodesF1 = length(F1);
numnodesF2 = length(F2);
shortestPathMatrixF1 = floydwarshall(F1);
shortestPathMatrixF2 = floydwarshall(F2);

% precalcolo i nodi alle varie distanze e raggi per ogni nodo dei due
% grafi
distanceMatrixF1 = cell(numnodesF1, distance);
radiusMatrixF1 = cell(numnodesF1, radius);
distanceMatrixF2 = cell(numnodesF2, distance);
radiusMatrixF2 = cell(numnodesF2, radius);
for s=1:max(numnodesF1, numnodesF2)
    % per le distanze memorizzo gli indici dei nodi
    for d=1:distance
        if s <= numnodesF1
            dNodesF1 = find(shortestPathMatrixF1(s,:) == d);
            distanceMatrixF1{s,d} = dNodesF1;
        end
        if s <= numnodesF2
            dNodesF2 = find(shortestPathMatrixF2(s,:) == d);
            distanceMatrixF2{s,d} = dNodesF2;
        end
    end
    
    % per i raggi memorizzo le etichette dei nodi
    for r=1:radius
        if s <= numnodesF1
            [~, rLabelsF1] = radiusNodes(F1,s,r);
            radiusMatrixF1{s,r} = rLabelsF1;
        end
        if s <= numnodesF2
            [~, rLabelsF2] = radiusNodes(F2,s,r);
            radiusMatrixF2{s,r} = rLabelsF2;
        end
    end
end

neighborhoodSubgraphPairwiseMapping = containers.Map();
NSPDK = 0;
for d=1:distance
    for s1=1:numnodesF1
        dnodesF1 = distanceMatrixF1{s1, d};
        for s2=1:numnodesF2
            if F1(s1,s1) == F2(s2,s2)
                dnodesF2 = distanceMatrixF2{s2, d};
                for i=1:length(dnodesF1)
                    for j=1:length(dnodesF2)
                        ss1 = dnodesF1(i);
                        ss2 = dnodesF2(j);
                        pair1 = sort([s1 ss1]);
                        pair2 = sort([s2 ss2]);
                        key = [num2str(pair1(1)) ',' num2str(pair1(2)) ',' num2str(pair2(1)) ',' num2str(pair2(2))];
                        if ~isKey(neighborhoodSubgraphPairwiseMapping, key) && F1(ss1,ss1) == F2(ss2,ss2)
                            neighborhoodSubgraphPairwiseMapping(key) = 1;
                            for r=1:radius
                                labelsF1 = [radiusMatrixF1{s1,r} radiusMatrixF1{ss1,r}];
                                labelsF2 = [radiusMatrixF2{s2,r} radiusMatrixF2{ss2,r}];
                                NSPDK =  NSPDK + graphHistogramKernel(labelsF1,labelsF2);
                            end
                        end
                    end
                end
            end
        end
    end
end
end