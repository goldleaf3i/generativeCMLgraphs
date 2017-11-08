%per ogni cluster memorizza il massimo numero di sottografi di uno stesso
%cluster che fanno anche parte di uno stesso grafo
%INPUT:  numgrafi - numero di grafi
%        ncluster - numero di cluster
%        clustref - matrice degli indici dei cluster di ogni sottografo
%(clustref(k,i) è l'indice del cluster dentro al quale si trova S_e{k,i},
%ossia il sottografo i del grafo k)
%        numF - array del numero di sottografi di ogni grafo
%OUTPUT: maxsgxcluster - array dei massimi sottografi di uno stesso cluster
%che fanno parte di uno stesso grafo
function [maxsgxcluster] = maxSubgraphsForCluster(numgrafi, ncluster, clustref, numF)
maxsgxcluster=zeros(1,ncluster);
for c=1:ncluster,
    maxc=0;
    for k=1:numgrafi,
        tmp=0;
        for i=1:numF(k),
            if clustref(k,i)==c,
              tmp=tmp+1;
            end
        end
        if tmp>maxc,
            maxc=tmp;
        end
    end
    maxsgxcluster(c)=maxc;
end
end