%partiziona i grafi
%INPUT:  grafi - array di grafi
%        subpar - parametro di segmentation
%OUTPUT: F_e -  array di celle delle matrici di adiacenza dei sottografi
%       (F_e{k,i} è la matrice di adiacenza del sottografo i del grafo k)
%        C_e - array di celle delle matrici di connessioni (C_e{k,i,j} è la
%        matrice di connessione tra il sottografo i e il sottografo j del
%        grafo k)
%        S - array di celle delle matrici finali delle connessioni (Iconn)
%        di ogni grafo
%        numF - array del numero di sottografi di ogni grafo
%        ngrafi - numero di grafi
%        sizemax - numero massimo di partizionamento (di sottografi
%        ottenuti per un grafo)
%        subgraphToNodeAssociation - array di celle che mantiene
%        l'associazione tra i sottografi di un grafo e i suoi nodi
%        (subgraphToNodeAssociation{k,i} è il vettore binario, lungo quanto
%        il numero di nodi del grafo k, che dice quali nodi di k si trovano
%        nel suo sottografo i)
function [F_e, C_e, S, numF, ngrafi, sizemax, subgraphToNodeAssociation] = graphPartitionNCut(grafi, subpar)
ngrafi=length(grafi);
S=cell(1,ngrafi);
numF=zeros(1,ngrafi);
sizemax=0;
for k=1:ngrafi,
    [tmpF_e,~,tmpC_e,S{k},n, numF(k), nodes]=subgraphs(grafi{k},subpar);
    for i=1:numF(k),
        F_e{k,i}=tmpF_e{i};
        subgraphToNodeAssociation{k,i} = nodes{i};
    end
    for i=1:numF(k)-1,
        for j=i+1:numF(k),
            C_e{k,i,j}=tmpC_e{i,j};
        end
    end    
    if n>sizemax
        sizemax=n;
    end
end

end