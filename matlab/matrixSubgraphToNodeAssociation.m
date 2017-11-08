%partiziona i grafi
%INPUT:  grafi - array di grafi
%        numF - array del numero di sottografi di ogni grafo
%        graforig - matrice delle posizioni lineari (indici) dei sottografi
%        (elementi di F_e)
%        subgraphToNodeAssociation - array di celle che mantiene
%        l'associazione tra i sottografi di un grafo e i suoi nodi
%        (subgraphToNodeAssociation{k,i} è il vettore binario, lungo quanto
%        il numero di nodi del grafo k, che dice quali nodi di k si trovano
%        nel suo sottografo i)
%OUTPUT: newGraphs - array di matrici di adiacenza dei grafi che hanno
%sugli elementi della diagonale (i,i) l'indice del sottografo a cui
%appartiene il nodo i

function [newGraphs] = matrixSubgraphToNodeAssociation(grafi, numF, graforig, subgraphToNodeAssociation)
newGraphs = grafi;
for k=1:length(newGraphs)
    for i=1:numF(k)
        for j=1:length(newGraphs{k})
            if subgraphToNodeAssociation{k,i}(j) == 1
                newGraphs{k}(j,j) = graforig(k,i);
            end
        end
    end
end
end