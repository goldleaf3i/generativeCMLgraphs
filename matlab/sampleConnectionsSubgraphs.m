%seleziona le connessioni tra i sottografi del nuovo grafo
%INPUT:  initialConfiguration - configurazione iniziale di lunghezza
%        fissata
%        subgraphClusteringMs - array cell delle matrici di connettività dei
%sottografi (subgraphClusteringMs{k}(i,j) con i diverso da j, rappresenta
%il numero di connessioni tra il sottografo i e quello j del grafo k; se i
%è uguale a j rappresenta l'indice del cluster in cui si trova il
%sottografo i
%        distanceFunction - funzione distanza tra due matrici di connessione
%        che prende in input le matrici e un parametro di utilità
%        utilParameter - parametro di utilità, può servire ad esempio per
%        la funzione distanza
%        alfapar - parametro che regola la convergenza del campionamento
%        numIterations - numero di iterazioni da cui dipende una buona o
%        meno copertura dello spazio degli stati
%        dimBlocked - array degli indici delle dimensioni bloccate (da non
%        cambiare), può essere vuoto
%OUTPUT: Cgen - matrice di connettività tra i sottografi di Fgen
%        objFunctions - array dei valori delle funzioni
%        obiettivo dei vari campioni
function [Cgen, objFunctions] = sampleConnectionsSubgraphs(initialConfiguration, subgraphClusteringMs, kernelDistanceFunction, utilParameter, alfapar, numIterations, dimBlocked)
    lenConfiguration = 1;
    [Cgen, objFunctions] = MCMC(subgraphClusteringMs, @flippingConnectionsMCMCKernel, kernelDistanceFunction, initialConfiguration, lenConfiguration, alfapar, numIterations, utilParameter, dimBlocked);
end