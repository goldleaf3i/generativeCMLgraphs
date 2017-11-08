%seleziona i nodi da connettere tra i sottografi del nuovo grafo
%INPUT:  initialConfigurationGgen - grafo finale inizializzato senza le
%connessioni inter-sottografo
%        FgenLin - array cell dei sottografi scelti
%        grafi - matrici di adiacenza del dataset di grafi originali
%        kernelDistanceFunction - funzione kernel distanza tra due grafi
%        Cgen - matrice di connettività tra i sottografi di Fgen
%        maxNodes - numero massimo di nodi tra i sottografi del grafo
%        finale
%        feasibleEdgeVector - array cell che per ogni coppia di sottografi
%        (ki,kj) e tipo di arco memorizza la lista delle coppie di nodi che
%        potenzialmente possono formare un arco da ki a kj. I nodi sono
%        indicizzati sul numero massimo di nodi.
%        feasibilityEdgeVector - array cell di vettori che per ogni
%        coppia di sottografi (ki,kj) indica il numero di archi ammessi da
%        ki a kj
%        alfa - matrice delle frequenze dei gradi dei nodi
%        beta - matrice delle frequenze delle etichette
%        gamma - matrice di cell array contenente i sottografi indotti da coppie
%        di nodi connessi e indicizzata per etichetta e degree
%        gammaCut - array cell contenente i sottografi indotti da edge
%        tagliati nella fase di segmentazione
%        zeta - matrice delle probabilità sugli edge
%        iota - matrice delle probabilità sugli edge dei tagli
%        edgeExistenceThreshold - probabilità threshold sull'esistenza di
%        un edge
%        distances - array cell delle matrici delle distanze dei sottografi
%        indotti per ogni tipo di edge
%        distancesCut - matrice delle distanze dei sottografi
%        indotti da ogni edge tagliato in fase di segmentazione
%        cutDegreeSum - somma dei gradi di tutti i nodi che fanno parte di
%        un taglio
%        kernelParameter - parametro del kernel
%        alfapar - parametro che regola la convergenza del campionamento
%        numIterations - numero di iterazioni da cui dipende una buona o
%        meno copertura dello spazio degli stati
%        dimBlocked - array degli indici delle dimensioni bloccate (da non
%        cambiare), può essere vuoto
%OUTPUT: Ggen - matrice di adiacenza del grafo finale
%        objFunctions - array dei valori delle funzioni
%        obiettivo dei vari campioni
function [Ggen, objFunctions] = sampleConnectionsNodes(initialConfigurationGgen, P, grafi, kernelDistanceFunction, Cgen, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, kernelParameter, alfapar, numIterations, dimBlocked)
    numF = size(feasibleEdgeVector,2);
    initialConfiguration = struct('Ggen',initialConfigurationGgen,'Fev',{feasibilityEdgeVector},'Sef',{selectedEdgesIndexedByFeasibleEdgeVector},'Set',{selectedEdgeIndexedByType});
    utilParameter = struct('KernelPar',{kernelParameter},'P',{P},'maxNodes',maxNodes,'Fev',{feasibleEdgeVector},'Cgen',Cgen);
    [configurationGgen, objFunctions] = MCMC(grafi, @flippingNodesMCMCKernel, kernelDistanceFunction, initialConfiguration, numF*(numF-1)/2, alfapar, numIterations, utilParameter, dimBlocked);
    Ggen = removeDummy(configurationGgen.Ggen);
end