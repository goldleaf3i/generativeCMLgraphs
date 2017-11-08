%fa il flip di un vettore di bit (configurazione) dato in input e calcola
%la distanza di hamming tra il vettore non flippato e quello flippato per
%l'iterazione più interna del campionamento di Gibbs
%INPUT:  population - insieme di vettori sotto forma di matrice, ogni riga
%è un vettore a disposizione nello spazio degli stati
%        configuration - è un vettore su cui fare flip
%        flipIndex - indice del bit su cui fare flip
%        oldDistance - distanza della configurazione di input rispetto alla
%        popolazione di input (velocizza la computazione), se è minore di 0
%        si ricalcolano le distanze, altrimenti si tiene oldDistance
%        dimBlocked - array degli indici delle dimensioni bloccate (da non
%        cambiare), può essere vuoto
%OUTPUT: vectorFlipped - vettore flippato
%        Hsa, Hsb - sono le distanze tra i due vettori, flippato e non
%        flippato
function [vectorFlipped, Hsa, Hsb] = flippingMCMCHamming(population, configuration, flipIndex, ~, ~, oldDistance,~, dimBlocked)
    totalVectors = size(population, 1);
    vectorLength=size(population, 2);
    
    if ~isempty(dimBlocked) && ismember(flipIndex,dimBlocked)
        vectorFlipped = configuration;
        Hsa = -1;
        Hsb = oldDistance;
        return;
    end
    
    tmps = configuration;
    tmps(flipIndex) = not(tmps(flipIndex));
    vectorFlipped = tmps;
    vectorNotFlipped = configuration;
    Hsa=0;
    Hsb=0;
    for k=1:totalVectors
        adist=pdist([vectorFlipped;population(k,:)],'hamming')*vectorLength;
        Hsa=Hsa+adist;
        if oldDistance < 0
            bdist=pdist([vectorNotFlipped;population(k,:)],'hamming')*vectorLength;
            Hsb=Hsb+bdist;
        end
    end
    if oldDistance >= 0
        Hsb = oldDistance;
    end
end