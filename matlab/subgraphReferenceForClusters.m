%per ogni cluster trova R, il sottografo di riferimento che ha massima la
%somma delle similarità
%INPUT:  riferimenti - matrice di clusterizzazione (riferimenti(c,i) è 1 se
%il sottografo i è presente nel cluster c, 0 altrimenti)
%        ncluster - numero di cluster
%        sim2 - matrice di similarità del grafo di affinità tra tutte le
%coppie di sottografi
%OUTPUT: R - array dei sottografi di riferimento di ogni cluster
function [R] = subgraphReferenceForClusters(riferimenti, ncluster, sim2)
nsgrafi=length(sim2);
R=zeros(1,ncluster);
for c=1:ncluster,
    maxsim=-100;
    for i=1:nsgrafi,
        if riferimenti(c,i)==1,
            isim=0;
            for j=1:nsgrafi,
                if riferimenti(c,j)==1,
                    isim=isim+sim2(i,j);
                end    
            end
            if isim > maxsim,
                maxsim=isim;
                R(c)=i;
            end
        end
    end
end
end