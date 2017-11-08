%per ogni cluster trova Rorig, la coppia di indici (k,i) del sottografo di
%riferimento
%INPUT:  ngrafi - numero di grafi
%        ncluster - numero di cluster
%        numF - array del numero di sottografi di ogni grafo
%        graforig - matrice delle posizioni lineari (indici) dei sottografi
%        (elementi di F_e)
%        R - array dei sottografi di riferimento di ogni cluster
%OUTPUT: Rorig - array delle coppie di indici (k,i)=(grafo,sottografo) dei
%sottografi di riferimento di ogni cluster
function [Rorig] = subgraphReferenceKIForClusters(ngrafi, ncluster, numF, graforig, R)
Rorig=cell(1,ncluster);
for c=1:ncluster,
    i2=R(c);
    for k=1:ngrafi,
        for i=1:numF(k),
            if graforig(k,i)==i2,
                Rorig{c}=[k i];
                break;
            end
        end
    end
end 
end