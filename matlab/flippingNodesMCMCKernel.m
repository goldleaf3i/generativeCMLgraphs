%passa dal grafo corrente ad uno nuovo (flip) con le operazioni di ADD e SWAP, e calcola
%la distanza kernel tra il grafo non flippato e quello flippato per
%l'iterazione più interna del campionamento di Gibbs
%INPUT:  population - insieme di matrici di connessione dei grafi
%originali, ogni riga è un grafo a disposizione nello spazio degli stati
%        configuration - è una struttura che corrisponde allo stato
%        corrente. Essa è formata dalla matrice di adiacenza del grafo
%        finale corrente, dall'array cell dei potenziali archi per ogni
%        coppia di sottografi, dall'array cell degli archi selezionati
%        flipIndex - indice che identifica la coppia di sottografi su cui
%        aggiungere o rimuovere un arco
%        kernelDistanceFunction - funzione kernel distanza tra due grafi
%        utilParameter - struttura costituita dal parametro kernel, dalle
%        stime sulle probabilità condizionate, dalle stime sulle probabilità
%        congiunte, dall'array cell dei possibili archi (coppia di nodi)
%        per ogni coppia di sottografi
%        oldDistance - distanza della configurazione di input rispetto alla
%        popolazione di input (velocizza la computazione), se è minore di 0
%        si ricalcolano le distanze, altrimenti si tiene oldDistance
%        currentIterations - iterazione corrente più esterna
%        dimBlocked - array degli indici delle dimensioni bloccate (da non
%        cambiare), può essere vuoto
%OUTPUT: configurationFlipped - configurazione flippata
%        distanceA,distanceB - sono le distanze tra le due configurazioni,
%        flippata e non flippato
function [configurationFlipped, distanceA, distanceB] = flippingNodesMCMCKernel(population, configuration, flipIndex, kernelDistanceFunction, utilParameter, oldDistance, ~, dimBlocked)
    totalGraphs = size(population, 2);
    %estraggo i dati che servono dalle strutture
    %configuration
    GgenNotFlipped = configuration.Ggen;
    feasibilityEdgeVector = configuration.Fev;
    selectedEdgesIndexedByFeasibleEdgeVector = configuration.Sef;
    selectedEdgeIndexedByType = configuration.Set;
    %utilParameter
    kernelPar = utilParameter.KernelPar;
    P = utilParameter.P;
    maxNodes = utilParameter.maxNodes;
    feasibleEdgeVector = utilParameter.Fev;
    Cgen = utilParameter.Cgen;
    
    numE = size(feasibleEdgeVector,1);
    numF = size(feasibleEdgeVector,2);

    %equazioni per ottenere la coppia di indici dei due sottografi
    ki = numF - 1 - floor(sqrt(-8*(flipIndex-1) + 4*numF*(numF-1)-7)/2.0 - 0.5);
    kj = (flipIndex-1) + ki + 1 - numF*(numF-1)/2 + (numF-ki+1)*((numF-ki+1)-1)/2;
    
    GgenFlipped = GgenNotFlipped;
    %transizione (flip) del grafo corrente G ad un altro G' attraverso
    %l'operazione di SWAP
    if Cgen(ki,kj) > 0
        %SWAP edge
        %rimuovo l'edge corrente
        edgeToRemoveIndexedByType = selectedEdgeIndexedByType{ki,kj};
        if ~isempty(edgeToRemoveIndexedByType)
            nodePairToRemove = selectedEdgesIndexedByFeasibleEdgeVector{edgeToRemoveIndexedByType,ki,kj};
            
            iRemove = feasibleEdgeVector{edgeToRemoveIndexedByType,ki,kj}(nodePairToRemove,1);
            jRemove = feasibleEdgeVector{edgeToRemoveIndexedByType,ki,kj}(nodePairToRemove,2);
            iiRemove = maxNodes*(ki-1)+iRemove;
            jjRemove = maxNodes*(kj-1)+jRemove;
            GgenFlipped(iiRemove,jjRemove) = 0;
            GgenFlipped(jjRemove,iiRemove) = 0;  
        else
            configurationFlipped = configuration;
            distanceA = -1;
            distanceB = oldDistance;
            return;
        end

        selectedEdgeIndexedByType{ki,kj} = [];
        selectedEdgesIndexedByFeasibleEdgeVector{edgeToRemoveIndexedByType,ki,kj} = [];
        feasibilityEdgeVector{ki,kj}(edgeToRemoveIndexedByType) = feasibilityEdgeVector{ki,kj}(edgeToRemoveIndexedByType) + 1;
       
        %aggiungo un nuovo edge
        counter = 0;
        sumP = 0;
        for n=1:numE
            nodePairs = feasibleEdgeVector{n,ki,kj};
            for l=1:size(nodePairs,1)
                counter = counter + 1;
                if ~isempty(P{n,ki,kj,l})
                    sumP = sumP + P{n,ki,kj,l};
                end
                probabilityIndexs{counter} = [n ki kj l];
            end
        end
        probabilities = zeros(1, counter);
        for i=1:counter
            n = probabilityIndexs{i}(1);
            ki = probabilityIndexs{i}(2);
            kj = probabilityIndexs{i}(3);
            l = probabilityIndexs{i}(4);
            if ~isempty(P{n,ki,kj,l})
                probabilities(i) = P{n,ki,kj,l}/sumP;
            else
                probabilities(i) = 0;
            end
        end

        if sumP > 0
            probIndex = randsample(1:counter, 1, true, probabilities);
        else
            configurationFlipped = configuration;
            distanceA = -1;
            distanceB = oldDistance;
            return;
        end
        edgeIndex = probabilityIndexs{probIndex}(1);
        nodePairIndex = probabilityIndexs{probIndex}(4);
        
        %aggiorno i dati della configurazione
        selectedEdgesIndexedByFeasibleEdgeVector{edgeIndex,ki,kj} = nodePairIndex;
        selectedEdgeIndexedByType{ki,kj} = edgeIndex;
        feasibilityEdgeVector{ki,kj}(edgeIndex) = feasibilityEdgeVector{ki,kj}(edgeIndex) - 1;
        
        i = feasibleEdgeVector{edgeIndex,ki,kj}(nodePairIndex,1);
        j = feasibleEdgeVector{edgeIndex,ki,kj}(nodePairIndex,2);
        ii = maxNodes*(ki-1)+i;
        jj = maxNodes*(kj-1)+j;
        GgenFlipped(ii,jj) = 1;
        GgenFlipped(jj,ii) = 1;

        %calcolo le distanze delle due configurazioni dal resto della popolazione
        distanceA = 0;
        distanceB = 0;
        for k=1:totalGraphs
    %         %questo assegnamento serve se si usa EmbeddingKernelGibbs per
    %         %trovare la distanza         
    %         kernelPar{3} = k;
        
            distanceA = distanceA + kernelDistanceFunction(GgenFlipped, population{k}, kernelPar);
            if oldDistance < 0
                distanceB = distanceB + kernelDistanceFunction(GgenNotFlipped, population{k}, kernelPar);
            end
        end
        if oldDistance >= 0
            distanceB = oldDistance;
        end
    
        %impacchetto i dati della nuova configurazione nelle strutture
        configurationFlipped = struct('Ggen',GgenFlipped,'Fev',{feasibilityEdgeVector},'Sef',{selectedEdgesIndexedByFeasibleEdgeVector},'Set',{selectedEdgeIndexedByType});
    else
        configurationFlipped = configuration;
        distanceA = -1;
        distanceB = oldDistance;
    end
end