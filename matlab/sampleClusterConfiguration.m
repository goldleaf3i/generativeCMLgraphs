%campionatore MCMC per ottenere la configurazione di cluster
%INPUT:  U - matrice della configurazione dei cluster nei grafi di
%input (U{k,pos} = 1 indica la presenza nel grafo k di un sottografo
%contenuto nel cluster di posizione pos). Descrive, quindi, ogni grafo k
%come costituito da un certo numero di sottografi per ogni cluster
%        alfapar - parametro che regola la convergenza del campionamento
%        numIterations - numero di iterazioni da cui dipende una buona o
%        meno copertura dello spazio degli stati
%        dimBlocked - array degli indici delle dimensioni bloccate (da non
%        cambiare), può essere vuoto
%OUTPUT: Ugen - matrice della configurazione dei cluster di un nuovo grafo
%        objFunctions - array dei valori delle funzioni
%        obiettivo dei vari campioni
function [Ugen, objFunctions] = sampleClusterConfiguration(U, alfapar, numIterations, dimBlocked)
    ngrafi=size(U, 1);
    dimslotgrafo=1/ngrafi;
    krand=fix(rand/dimslotgrafo)+1;
    s=U(krand,:);
    if ~isempty(dimBlocked)
        for i=1:size(dimBlocked,2)
            s(dimBlocked(i)) = 1;
        end
    end
    [Ugen,objFunctions] = MCMC(U, @flippingMCMCHamming, [], s, size(s, 2), alfapar, numIterations, 0, dimBlocked);
end