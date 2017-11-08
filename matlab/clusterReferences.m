%per ogni sottografo memorizza l'indice del cluster di appartenenza
%INPUT:  ngrafi - numero di grafi
%        ncluster - numero di cluster
%        numF - array del numero di sottografi di ogni grafo
%        graforig - matrice delle posizioni lineari (indici) dei sottografi
%        (elementi di F_e)
%        riferimenti - matrice di clusterizzazione (riferimenti(c,i) è 1 se
%il sottografo i è presente nel cluster c, 0 altrimenti)
%OUTPUT: clustref - matrice degli indici dei cluster di ogni sottografo
%(clustref(k,i) è l'indice del cluster dentro al quale si trova S_e{k,i},
%ossia il sottografo i del grafo k)
function [clustref] = clusterReferences(ngrafi, ncluster, numF, graforig, riferimenti)
%clustref=zeros(ngrafi(1),ngrafi(2));
for k=1:ngrafi,
    for i=1:numF(k),
        i2=graforig(k,i);
        if i2>0,
        for c=1:ncluster,
            if riferimenti(c,i2)==1,
                clustref(k,i)=c;
                break;
            end
        end
        end
    end
end
end