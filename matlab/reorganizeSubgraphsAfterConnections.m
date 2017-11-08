%riorganizza i sottografi di un nuovo grafo dopo delle connessioni, per la
%stampa
%INPUT:  type - se type=0 allora i sottografi hanno le label quelle
%normali, se type=1 avranno come label l'indice del sottografo
%        Fgen - array cell delle matrici di adiacenza dei
%sottografi scelti per il nuovo grafo (Fgen{c,:} sono le matrici di
%adiacenza dei sottografi del cluster c)
%        numFgen - array del numero di sottografi generati per ogni cluster
%        numSG - numero di sottografi del nuovo grafo
%        sizemax - numero massimo di partizionamento (di sottografi
%        ottenuti per un grafo)
%        ncluster - numero di cluster
%        Cgen - matrice di connettività tra i sottografi di Fgen
%OUTPUT: Fdiviso - array di celle dei sottografi da stampare
function [Fdiviso] = reorganizeSubgraphsAfterConnections(type, Fgen, numFgen, numSG, sizemax, ncluster, Cgen)
lenSG = sizemax;
SnoC = zeros(numSG*lenSG);

j = 0;
for c=1:ncluster
    for i=1:numFgen(c)
        if ~isempty(Fgen{c,i})
            Fgen{c,i} = padarray(Fgen{c,i}, [sizemax-length(Fgen{c,i}),sizemax-length(Fgen{c,i})], 'post');
            j = j + 1;
            m = Fgen{c,i};
            if type == 1
                for l=1:size(m,1)
                    if sum(m(l,:)) > 0
                        m(l,l) = j;
                    end
                end
            end
            so = SnoC;
            so((j-1)*lenSG+1:j*lenSG,(j-1)*lenSG+1:j*lenSG) = m;
            SnoC = so;
        end
    end
end

% assegno delle connessioni tra i nodi
for i=1:numSG
    for j=i+1:numSG
        connections = Cgen(i,j);
        if connections >= 1
            indexI = (i-1)*lenSG+1;
            while sum(SnoC(indexI,:)) == 0
                indexI = indexI+1;
            end
            indexJ = (j-1)*lenSG+1;
            while sum(SnoC(indexJ,:)) == 0
                indexJ = indexJ+1;
            end
            SnoC(indexI,indexJ) = 2;
            SnoC(indexJ,indexI) = 2;
        end
        if connections >= 2  
            indexI = indexI + 1;
            while sum(SnoC(indexI,:)) == 0
                indexI = indexI+1;
            end
            indexJ = indexJ + 1;
            while sum(SnoC(indexJ,:)) == 0
                indexJ = indexJ + 1;
            end
            SnoC(indexI,indexJ) = 2;
            SnoC(indexJ,indexI) = 2;
        end
    end
end

Fdiviso = removeDummy(SnoC);
end