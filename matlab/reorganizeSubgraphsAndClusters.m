%riorganizza i sottografi e i cluster per la stampa
%INPUT:  ngrafi - numero di grafi
%        sizemax - numero massimo di partizionamento (di sottografi
%        ottenuti per un grafo)
%        ncluster - numero di cluster
%        clustref - matrice degli indici dei cluster di ogni sottografo
%(clustref(k,i) è l'indice del cluster dentro al quale si trova S_e{k,i},
%ossia il sottografo i del grafo k)
%        numF - array del numero di sottografi di ogni grafo
%        F_o - array di celle delle matrici di adiacenza permutate dei sottografi
%       (F_o{k,i} è la matrice di adiacenza del sottografo i del grafo k)
%OUTPUT: Fdivisi - array di celle dei sottografi da stampare
%        Fcluster - array di celle dei cluster da stampare
%        groupCluster - array di celle dei cluster
function [Fdivisi, Fcluster, groupCluster] = reorganizeSubgraphsAndClusters(ngrafi, sizemax, ncluster, clustref, numF, F_o)
%creo i sottografi divisi da stampare per ogni grafo
lenSG=sizemax;
for k=1:ngrafi
    SnoC{k}=zeros(numF(k)*lenSG);
    %e le popolo
    for i=1:numF(k),
        so=SnoC{k};
        so((i-1)*lenSG+1:i*lenSG,(i-1)*lenSG+1:i*lenSG)=F_o{k,i};
        SnoC{k}=so;
    end
end
for k=1:ngrafi,
    Fdivisi{k} = removeDummy(SnoC{k});
end

%riorganizzo pure i cluster per lo stesso motivo
sz=size(F_o);
ngrafi=sz(1);
numFcluster=zeros(1,ncluster);
for k=1:ngrafi,
    for i=1:numF(k),
        c=clustref(k,i);
        numFcluster(c)=numFcluster(c)+1;
        Fcluster{c,numFcluster(c)}=F_o{k,i};
    end
end
groupCluster=cell(1,ncluster);
dim=sizemax;
for c=1:ncluster,
    groupCluster{c}=zeros(numFcluster(c)*dim);
    for i=1:numFcluster(c),
        tmp=groupCluster{c};
        tmp((i-1)*dim+1:i*dim,(i-1)*dim+1:i*dim)=Fcluster{c,i};
        groupCluster{c}=tmp;
    end
end
for c=1:ncluster,
    groupCluster{c}=removeDummy(groupCluster{c});
end
end