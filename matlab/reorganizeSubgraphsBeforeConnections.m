%riorganizza i sottografi di un nuovo grafo prima delle connessioni, per la
%stampa
%INPUT:   Fgen - array cell delle matrici di adiacenza dei
%sottografi scelti per il nuovo grafo (Fgen{c,:} sono le matrici di
%adiacenza dei sottografi del cluster c)
%        numFgen - array del numero di sottografi generati per ogni cluster
%        sizemax - numero massimo di partizionamento (di sottografi
%        ottenuti per un grafo)
%        ncluster - numero di cluster
%OUTPUT: Fdiviso - array di celle dei sottografi da stampare
function [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster)
lenSG = sizemax;
numSG = sum(numFgen);
SnoC = zeros(numSG*lenSG);

j = 1;
for c=1:ncluster
    for i=1:numFgen(c)
        if ~isempty(Fgen{c,i})
            Fgen{c,i} = padarray(Fgen{c,i}, [sizemax-length(Fgen{c,i}),sizemax-length(Fgen{c,i})], 'post');
            so = SnoC;
            so((j-1)*lenSG+1:j*lenSG,(j-1)*lenSG+1:j*lenSG) = Fgen{c,i};
            SnoC = so;
            j = j + 1;
        end
    end
end
Fdiviso = removeDummy(SnoC);
end