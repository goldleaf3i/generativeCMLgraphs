%partiziona i grafi usando le informazioni sulle label.
%INPUT:  grafi - array di grafi
%        subpar - parametro di segmentation - numero minimo di nodi non
%        corridoio che devono essere connesse ad un nodo C per farlo
%        diventare un HUB
%        corridors - elenco di label che corrispondono ai corridoi
%        ATTENZIONE - PARAMETRO DI DEBUG "WITHPLOT" STAMPA O MENO I TAGLI
%        DEI CORRIDOI - � HARDCODATO perch� non serve cambiarlo
%OUTPUT: F_e -  array di celle delle matrici di adiacenza dei sottografi
%       (F_e{k,i} � la matrice di adiacenza del sottografo i del grafo k)
%        C_e - array di celle delle matrici di connessioni (C_e{k,i,j} � la
%        matrice di connessione tra il sottografo i e il sottografo j del
%        grafo k)
%        numF - array del numero di sottografi di ogni grafo
%        ngrafi - numero di grafi
%        sizemax - numero massimo di partizionamento (di sottografi
%        ottenuti per un grafo)
%        subgraphToNodeAssociation - array di celle che mantiene
%        l'associazione tra i sottografi di un grafo e i suoi nodi
%        (subgraphToNodeAssociation{k,i} � il vettore binario, lungo quanto
%        il numero di nodi del grafo k, che dice quali nodi di k si trovano
%        nel suo sottografo i)
function [F_e, C_e, numF, ngrafi, sizemax, subgraphToNodeAssociation] = graphPartitionCorr(grafi, subpar,corridors) 
ngrafi=length(grafi);
numF=zeros(1,ngrafi);
sizemax=0;
withPlot = 0;
for k=1:ngrafi,
    if withPlot
        [tmpF_e,tmpC_e,n, numF(k), nodes]=subgraphsCorr(grafi{k},subpar,corridors,k);
    else
        [tmpF_e,tmpC_e,n, numF(k), nodes]=subgraphsCorr(grafi{k},subpar,corridors,0);
    end
    
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