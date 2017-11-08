%dato un grafo, calcola la matrice del sottografo centrato in un nodo di
%input che ha dei percorsi con gli altri nodi distanti al massimo di un
%raggio r
%INPUT: A - matrice di adiacenza
%       node - nodo centrale del sottografo
%       r - raggio (distanza massima) degli altri nodi dal nodo centrale
%OUTPUT: Asub - matrice dei collegamenti, ricorda la matrice di
%adiacenza (Asub{i,j}=[] se non c'è un edge tra i e j, Asub{i,j}=[x y] con
%i diverso da j, c'è un edge tra i e j che nel grafo originale erano x e y
%rispettivamente. Asub{i,j}=[x C] con i=j, indica l'etichetta C del nodo i
%del grafo originale
function [Asub]= radiusSubgraph(A,node,r)
%calcolo i nodi che fanno parte del sottografo di raggio r centrato in node
[rSubgraphNodes, ~] = radiusNodes(A,node,r);
Asub = cell(length(rSubgraphNodes));

%calcolo la matrice Anew del sottografo centrato in node di raggio r
ipos = 0;
for i=1:length(A)
    if ismember(i,rSubgraphNodes)
        ipos = ipos + 1;
        jpos = ipos;
        Asub{ipos,jpos} = [i A(i,i)];
        for j=i+1:length(A)
            if ismember(j,rSubgraphNodes) && A(i,j) > 0
                jpos = jpos + 1;
                Asub{ipos,jpos} = [i j];
                Asub{jpos,ipos} = [j i];
            end
        end
    end
end
end