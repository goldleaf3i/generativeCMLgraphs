%restituisce il sottografo indotto da due nodi A e B connessi
%INPUT:  graph - matrice di adiacenza del grafo
%        nodeA - indice del primo nodo
%        nodeB - indice del secondo nodo
%OUTPUT: inducedSubgraphAB - sottografo indotto
%        neighborsA - nodi adiacenti ad A, escluso B e quelli comuni
%        neighborsB - nodi adiacenti a B, escluso A e quelli comuni
%        intersectionAB - nodi comuni adiacenti ad A e B
function [inducedSubgraphAB, neighborsA, neighborsB, intersectionAB] = inducedSubgraph(graph, nodeA, nodeB)
dim = size(graph,1);
neighborsA = [];
neighborsB = [];
for j=1:dim
    if j ~= nodeA && j ~= nodeB
        if graph(nodeA,j) == 1
            neighborsA = [neighborsA j];
        end
        if graph(nodeB,j) == 1
            neighborsB = [neighborsB j];
        end
    end
end
intersectionAB = intersect(neighborsA,neighborsB);
neighborsA = setdiff(neighborsA,intersectionAB);
neighborsB = setdiff(neighborsB,intersectionAB);
if isempty(neighborsA)
    neighborsA = [];
end
if isempty(neighborsB)
    neighborsB = [];
end
if isempty(intersectionAB)
    intersectionAB = [];
end
inducedSubgraphAB = zeros(2 + size(neighborsA,2) + size(neighborsB,2) + size(intersectionAB,2));
inducedSubgraphAB(1,1) = graph(nodeA,nodeA);
inducedSubgraphAB(1,2) = 1;
inducedSubgraphAB(2,2) = graph(nodeB,nodeB);
inducedSubgraphAB(2,1) = 1;

offset = 2;
for j=1:size(neighborsA,2)
    joffset = j + offset;
    inducedSubgraphAB(joffset,joffset) = graph(neighborsA(j),neighborsA(j));
    inducedSubgraphAB(1,joffset) = 1;
    inducedSubgraphAB(joffset,1) = 1;
    
    %inserisco i lati tra i neighbors di A
    for jj=1:size(neighborsA,2)
        jjoffset = jj + offset;
        if j ~= jj && graph(neighborsA(j),neighborsA(jj)) == 1
            inducedSubgraphAB(joffset,jjoffset) = 1;
            inducedSubgraphAB(jjoffset,joffset) = 1;
        end
    end
    
    %inserisco i lati tra i neighbors di A e B
    for jj=1:size(neighborsB,2)
        jjoffset = jj + offset + size(neighborsA,2);
        if graph(neighborsA(j),neighborsB(jj)) == 1
            inducedSubgraphAB(joffset,jjoffset) = 1;
            inducedSubgraphAB(jjoffset,joffset) = 1;
        end
    end
end

offset = offset + size(neighborsA,2);
for j=1:size(neighborsB,2)
    joffset = j + offset;
    inducedSubgraphAB(joffset,joffset) = graph(neighborsB(j),neighborsB(j));
    inducedSubgraphAB(2,joffset) = 1;
    inducedSubgraphAB(joffset,2) = 1;
    
    %inserisco i lati tra i neighbors di B
    for jj=1:size(neighborsB,2)
        jjoffset = jj + offset;
        if j ~= jj && graph(neighborsB(j),neighborsB(jj)) == 1
            inducedSubgraphAB(joffset,jjoffset) = 1;
            inducedSubgraphAB(jjoffset,joffset) = 1;
        end
    end
    
    %inserisco i lati tra i neighbors di A e B
    for jj=1:size(neighborsA,2)
        jjoffset = jj + 2;
        if graph(neighborsB(j),neighborsA(jj)) == 1
            inducedSubgraphAB(joffset,jjoffset) = 1;
            inducedSubgraphAB(jjoffset,joffset) = 1;
        end
    end
end

offset = offset + size(neighborsB,2);
for j=1:size(intersectionAB,2)
    joffset = j + offset;
    inducedSubgraphAB(joffset,joffset) = graph(intersectionAB(j),intersectionAB(j));
    inducedSubgraphAB(1,joffset) = 1;
    inducedSubgraphAB(joffset,1) = 1;
    inducedSubgraphAB(2,joffset) = 1;
    inducedSubgraphAB(joffset,2) = 1;
    
    %inserisco i lati tra i neighbors di A e il nodo comune
    for jj=1:size(neighborsA,2)
        jjoffset = jj + 2;
        if graph(intersectionAB(j),neighborsA(jj)) == 1
            inducedSubgraphAB(joffset,jjoffset) = 1;
            inducedSubgraphAB(jjoffset,joffset) = 1;
        end
    end
    
    %inserisco i lati tra i neighbors di B e il nodo comune
    for jj=1:size(neighborsB,2)
        jjoffset = jj + 2 + size(neighborsA,2);
        if graph(intersectionAB(j),neighborsB(jj)) == 1
            inducedSubgraphAB(joffset,jjoffset) = 1;
            inducedSubgraphAB(jjoffset,joffset) = 1;
        end
    end
end
end