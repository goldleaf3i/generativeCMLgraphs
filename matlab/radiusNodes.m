%dato un grafo, calcola i nodi e le etichette del sottografo centrato nel
%nodo di input e con raggio di input (gli altri nodi distano al massimo r
%dal nodo centrale)
%INPUT: A - matrice di adiacenza
%       node - nodo centrale del sottografo
%       r - raggio (distanza massima) degli altri nodi dal nodo centrale
%OUTPUT: rNodes - array degli indici dei nodi entro il raggio di
%        input
%        rLabels - array delle etichette dei nodi entro il raggio
%        di input
function [rNodes, rLabels]= radiusNodes(A,node,r)
%calcolo la matrice As dei percorsi di raggio r, un percorso di
%raggio r dal nodo i al nodo j esiste se As(i,j) > 0
Ar = A;
As = A;
for i=1:r-1
  Ar = Ar*A;
  As = As+Ar;
end

rNodes = [];
rLabels = [];
for j=1:length(As)
    if As(node,j) > 0
        rNodes = [rNodes j];
        rLabels = [rLabels A(j,j)];
    end
end
end