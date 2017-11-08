%eseguo il padding dei sottografi alla dimensione del sottografo più grande
%INPUT:  F_e -  array di celle delle matrici di adiacenza dei sottografi
%       (F_e{k,i} è la matrice di adiacenza del sottografo i del grafo k)
%        C_e - array di celle delle matrici di connessioni (C_e{k,i,j} è la
%        matrice di connessione tra il sottografo i e il sottografo j del
%        grafo k)
%        numF - array del numero di sottografi di ogni grafo
%        ngrafi - numero di grafi
%        sizemax - numero massimo di partizionamento (di sottografi
%        ottenuti per un grafo)
%OUTPUT: F_e - F_e in input con padding
%        C_e - C_e in input con padding
function [F_e, C_e] = paddingSubgraphsAndConnections(F_e, C_e, numF, ngrafi, sizemax)
for k=1:ngrafi,
    for i=1:numF(k),
        F_e{k,i} = padarray(F_e{k,i}, [sizemax-length(F_e{k,i}),sizemax-length(F_e{k,i})], 'post');     
    end
    %padding anche delle matrici di connessione
    for i=1:numF(k)-1,
        for j=i+1:numF(k),
            sz=size(C_e{k,i,j});
            C_e{k,i,j} = padarray(C_e{k,i,j}, [sizemax-sz(1),sizemax-sz(2)], 'post');
        end 
    end
end
end