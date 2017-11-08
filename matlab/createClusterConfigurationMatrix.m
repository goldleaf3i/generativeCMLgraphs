%crea la matrice della configurazione dei cluster
%INPUT:  numgrafi - numero di grafi
%        ncluster - numero di cluster
%        clustref - matrice degli indici dei cluster di ogni sottografo
%(clustref(k,i) è l'indice del cluster dentro al quale si trova S_e{k,i},
%ossia il sottografo i del grafo k)
%        numF - array del numero di sottografi di ogni grafo
%        poscluster - array degli slot (colonne) riservati ad
%ogni cluster
%        sumMaxSubgraphs - somma dei massimi sottografi di ogni cluster
%OUTPUT: U - matrice della configurazione dei cluster nei grafi di
%input (U{k,pos} = 1 indica la presenza nel grafo k di un sottografo
%contenuto nel cluster di posizione pos). Descrive, quindi, ogni grafo k
%come costituito da un certo numero di sottografi per ogni cluster
function [U] = createClusterConfigurationMatrix(numgrafi, ncluster, clustref, numF, poscluster, sumMaxSubgraphs)
U=zeros(numgrafi,sumMaxSubgraphs);

for k=1:numgrafi,
    for c=1:ncluster,
        pos=poscluster(c);
        for i=1:numF(k),
            if clustref(k,i)==c,
                U(k,pos)=1;
                pos=pos+1;
            end
        end
    end
end
end