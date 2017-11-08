%aggiunge il cluster degli scarti se c'è
%INPUT:  ngrafi - numero di grafi
%        clustref - matrice degli indici dei cluster di ogni sottografo
%(clustref(k,i) è l'indice del cluster dentro al quale si trova S_e{k,i},
%ossia il sottografo i del grafo k)
%        scarti - 1 se ci sono dei nodi dummy nella matrice di similarità,
%        0 altrimenti
%        ncluster - numero di cluster
%        numF - array del numero di sottografi di ogni grafo
%        graforig - matrice delle posizioni lineari (indici) dei sottografi
%        (elementi di F_e)
%OUTPUT: clustref - clustref di input con l'aggiunta degli scarti
%        ncluster - numero di cluster
function [clustref, ncluster] = addClustersForDummies(ngrafi, clustref, scarti, ncluster, numF, graforig)
if scarti==1,
    ncluster=ncluster+1;
    for k=1:ngrafi,
        for i=1:numF(k),
            if graforig(k,i)==0,
                clustref(k,i)=ncluster;
            end
        end
    end
end
end