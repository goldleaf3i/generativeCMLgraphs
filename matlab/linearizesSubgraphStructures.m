%linearizza la matrice dei sottografi F_e in tre strutture
%INPUT:  F_e -  array di celle delle matrici di adiacenza dei sottografi
%       (F_e{k,i} è la matrice di adiacenza del sottografo i del grafo k)
%        numF - array del numero di sottografi di ogni grafo
%        ngrafi - numero di grafi
%OUTPUT: Flin - array di celle dei sottografi (linearizzazione di F_e)
%        graforig - matrice delle posizioni lineari (indici) dei sottografi
%        (elementi di F_e)
%        postoKI - array di celle delle coppie di indici [k i] di ogni
%        sottografo
function [Flin, graforig, postoKI] = linearizesSubgraphStructures(F_e, numF, ngrafi)
%linearizzo F_e per creare la matrice di similarità
%popolo al contempo graforig
pos=0;
for k=1:ngrafi
    for i=1:numF(k),
        pos=pos+1;
        Flin{pos}=F_e{k,i};
        graforig(k,i)=pos;
        postoKI{pos}=[k i];
    end
end
end