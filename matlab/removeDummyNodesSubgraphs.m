%elimina nodi dummy dai grafi di input
%INPUT: F_e -  array di celle delle matrici di adiacenza dei sottografi
%       (F_e{k,i} è la matrice di adiacenza del sottografo i del grafo k)
%OUTPUT: F_e - F_e dei sottografi senza nodi dummy
function [F_e] = removeDummyNodesSubgraphs(F_e)
for k=1:size(F_e,1)
    for i=1:size(F_e,2)
        F_e{k,i} = removeDummy(F_e{k,i});
    end
end
end