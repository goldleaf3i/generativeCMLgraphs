%calcola la media e varianza di sottografi per grafo e di nodi per
%sottografo
%INPUT:  F_e -  array di celle delle matrici di adiacenza dei sottografi
%       (F_e{k,i} è la matrice di adiacenza del sottografo i del grafo k)
%        numF - array del numero di sottografi di ogni grafo
%        ngrafi - numero di grafi
%OUTPUT: mediaSGin - media sottografi per grafo
%        varianzaSGin - varianza sottografi per grafo
%        medianodiSGin - media nodi per sottografo
%        varianzanodiSGin - varianza nodi per sottografo
function [mediaSGin, varianzaSGin, medianodiSGin, varianzanodiSGin] = meanAndVarianceSubgraphs(F_e, numF, ngrafi)
mediaSGin=mean(numF);
varianzaSGin=var(numF);
medianodiSGin=0;
contnodi=0;
for k=1:ngrafi,
    for i=1:numF(k),
        tmpF=removeDummy(F_e{k,i});
        contnodi=contnodi+1;
        numnodi(contnodi)=length(tmpF);
    end
end
medianodiSGin=mean(numnodi);
varianzanodiSGin=var(numnodi);
end