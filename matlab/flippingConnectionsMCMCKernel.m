%fa il flip di un grafo (configurazione) dato in input e calcola
%la distanza kernel tra il grafo non flippato e quello flippato per
%l'iterazione più interna del campionamento di Gibbs
%INPUT:  population - insieme di matrici di connessione dei grafi
%originali, ogni riga è un grafo a disposizione nello spazio degli stati
%        configuration - è un grafo su cui fare flip
%        flipIndex - indice su cui fare flip
%        alfapar - parametro che regola la convergenza del campionamento
%        kernelFunction - funzione che restituisce la distanza kernel
%        di due grafi
%        utilParameter - parametro di utilità, può servire ad esempio per
%        la funzione kernel
%        oldDistance- distanza della configurazione di input rispetto alla
%        popolazione di input (velocizza la computazione), se è minore di 0
%        si ricalcolano le distanze, altrimenti si tiene oldObjective
%        currentIterations - iterazione corrente più esterna
%        dimBlocked - array degli indici delle dimensioni bloccate (da non
%        cambiare), può essere vuoto
%OUTPUT: graphFlipped - grafo flippato
%        objectiveA,objectiveB - sono i valori delle funzioni obiettivo,
%        nel caso di flip e non flip rispettivamente
function [graphFlipped, distanceA, distanceB] = flippingConnectionsMCMCKernel(population, configuration, ~, kernelDistanceFunction, utilParameter, oldDistance, ~, dimBlocked)
    totalGraphs = size(population, 2);
    dim = size(configuration, 1);
    
    noConnection = [];
    yesConnection = [];
    degree = zeros(1,dim);
    count = 0;
    for i=1:dim
        degree(i) = sum(configuration(i,:))-configuration(i,i);
    end
    for i=1:dim
        for j=i+1:dim
            count = count + 1;
            if configuration(i,j) == 1
                if isempty(dimBlocked) || (~isempty(dimBlocked) && dimBlocked(i,j) == 0)
                    yesConnection = [yesConnection count];
                end
            else
                if isempty(dimBlocked) || (~isempty(dimBlocked) && dimBlocked(i,j) == 0)
                    noConnection = [noConnection count];
                end
            end
        end
    end
    
    tmps = configuration;
    lambdaAdd = 0.10;
    lambdaRemove = 0.10;
    numConnections = sum(degree)/2;
    eps = 1 - exp(-lambdaRemove*numConnections/dim);
    Padd = 1 - exp(-lambdaAdd*dim/numConnections);
    Premove = (1 - Padd)*eps;
    Pswap = (1 - Padd)*(1-eps);
    editOperation = randsample([1 2 3], 1, true, [Padd Premove Pswap]);
    if editOperation == 1 && ~isempty(noConnection)
        %ADD   
        flipIndex = noConnection(randi(length(noConnection)));
        [i, j] = upperDiagonalIndexToMatrixIndex(flipIndex, dim);
        tmps(i,j) = 1;
        tmps(j,i) = tmps(i,j);
    elseif editOperation == 2 && ~isempty(yesConnection)
        %REMOVE
        flipIndex = yesConnection(randi(length(yesConnection)));
        [i, j] = upperDiagonalIndexToMatrixIndex(flipIndex, dim);
        tmps(i,j) = 0;
        tmps(j,i) = tmps(i,j);
    else
        %SWAP connessioni tra due nodi scelti a caso
        i = randsample(1:dim,1);
        if dim~=1
            j = randsample([1:i-1 i+1:dim],1);
        else
            j =1;
        end
        for k=1:size(configuration, 1)
            if k ~= i && k ~= j
                %se uno dei due elementi è bloccato non faccio swap tra i
                %due elementi
                if isempty(dimBlocked) || (~isempty(dimBlocked) && (dimBlocked(i,k) == 0 && dimBlocked(j,k) == 0))
                    tmps(i,k) = configuration(j,k);
                    tmps(k,i) = tmps(i,k);
                    tmps(j,k) = configuration(i,k);
                    tmps(k,j) = tmps(j,k);
                end
            end
        end
    end
    graphFlipped = tmps;
    graphNotFlipped = configuration;
    
    if checkDiscardSample(graphFlipped) %|| ~boyer_myrvold_planarity_test(sparse(cast(graphFlipped,'int8')))
        graphFlipped = configuration;
        distanceA = -1;
        distanceB = oldDistance;
        return;
    end
    
    %calcolo le distanze delle due configurazioni dal resto della popolazione
    distanceA = 0;
    distanceB = 0;
    for k=1:totalGraphs
%         %questo assegnamento serve se si usa EmbeddingKernelGibbs per
%         %trovare la distanza         
%         utilParameter{3} = k;

        distanceA = distanceA + kernelDistanceFunction(graphFlipped, population{k}, utilParameter);
        if oldDistance < 0
            distanceB = distanceB + kernelDistanceFunction(graphNotFlipped, population{k}, utilParameter);
        end
    end
    if oldDistance >= 0
        distanceB = oldDistance;
    end
end