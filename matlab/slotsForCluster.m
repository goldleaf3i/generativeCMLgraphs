%calcola gli slot riservati ad ogni cluster
%INPUT:  ncluster - numero di cluster
%        maxsgxcluster - array dei massimi sottografi di uno stesso cluster
%che fanno parte di uno stesso grafo
%OUTPUT: poscluster - array degli slot (colonne) riservati ad
%ogni cluster
function [poscluster] = slotsForCluster(ncluster, maxsgxcluster)
poscluster=zeros(1,ncluster);
%creo prima S_prime come cella bidimensionale (la chiamo Scell)
dim=0;
for c=1:ncluster,
    poscluster(c)=dim+1;
    dim=poscluster(c)+maxsgxcluster(c)-1;
end
end