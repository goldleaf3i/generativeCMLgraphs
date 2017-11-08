function [ ricorrenze ] = contacluster( clustref,numF )
    ngrafi=size(clustref,1);
    ncluster=max(max(clustref));
    ricorrenze=zeros(ngrafi,ncluster);
    for k=1:ngrafi
        for i=1:numF(k)
            c=clustref(k,i);
            ricorrenze(k,c)=ricorrenze(k,c)+1;
        end
    end
end

