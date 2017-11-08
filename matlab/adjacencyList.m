%calcola la lista di adiacenza di un grafo
%INPUT:  A - matrice di adiacenza
%OUTPUT: adjList - lista di adiacenza
function [adjList] = adjacencyList(A)
dim = length(A);
adjList = cell(1,dim);
for i=1:dim
    l = find(A(i,:) > 0);
    l = setdiff(l,i);
    adjList{i} = l;
end
end

