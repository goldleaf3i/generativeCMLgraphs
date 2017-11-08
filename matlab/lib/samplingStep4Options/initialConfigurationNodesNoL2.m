%inizializza la configurazione per il Gibbs sampling sul numero di
%connessioni tra i sottografi
%INPUT:  Cgen - matrice di connettivit� tra i sottografi di Fgen
%        Fgen - array cell delle matrici di adiacenza dei
%sottografi scelti per il nuovo grafo (Fgen{c,:} sono le matrici di
%adiacenza dei sottografi del cluster c)
%        numFgen - array del numero di sottografi generati per ogni cluster
%        connectedToGen - array cell con gli indici dei sottografi esplorati,
%        per memorizzare la connessione tra sottografo esplorato e un
%        sottografo campionato
%        zeta - matrice delle probabilit� sugli edge
%        iota - matrice delle probabilit� sugli edge dei tagli
%        edgeExistenceThreshold - probabilit� threshold sull'esistenza di
%        un edge
%        compatibleNodesGen - array cell degli array binari che indicano i
%        nodi compatibili per sottografo scelto, con gli archi uscenti dai
%        sottografi esplorati
%        connectedToInternal - array cell con gli indici dei sottografi esplorati,
%        per memorizzare la connessione solo tra i sottografi esplorati
%        compatibleNodesInternal - array cell con le coppie di nodi
%        relativi agli archi che connettono i sottografi esplorati
%        corridors_label - elenco dele label che formano i corridoi
%OUTPUT: Ggen - matrice di adiacenza del grafo finale con i sottografi non
%        connessi
%        FgenLin - array cell dei sottografi scelti
%        maxNodes - numero massimo di nodi tra i sottografi del grafo
%        finale
%        feasibleEdgeVector - array cell che per ogni coppia di sottografi
%        (ki,kj) e tipo di arco memorizza la lista delle coppie di nodi che
%        potenzialmente possono formare un arco da ki a kj. I nodi sono
%        indicizzati sul numero massimo di nodi.
%        feasibilityEdgeVector - array cell di vettori che per ogni
%        coppia di sottografi (ki,kj) indica il numero di archi che possono
%        essere aggiunti tra ki e kj
%        dimBlocked - dimensioni bloccate
function [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlocked] = initialConfigurationNodesNoL2(Cgen, Fgen, numFgen, kernelDistanceFunction, kernelParameter, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridors_label,numLabel,cont,skip_errors)
    %memorizzo gli indici progressivi dei sottografi dall'alto verso il basso
    ncluster = size(Fgen,1);
    maxNodes = 0;
    numF = 0;
    for c=1:ncluster
        for i=1:numFgen(c)
            F = Fgen{c,i};
            if size(F,1) > maxNodes
                maxNodes = size(F,1);
            end
            numF = numF + 1;
            FgenLin{numF} = F;
            refFgen{c,i} = numF;
            if ~isempty(connectedToGen)
                connectedToGenTmp{numF} = connectedToGen{c,i};
                compatibleNodesGenLin{numF} = compatibleNodesGen{c,i};
                connectedToInternalTmp{numF} = connectedToInternal{c,i};
                compatibleNodesInternalLin{numF} = compatibleNodesInternal{c,i};
            end
        end
    end
    if ~isempty(connectedToGen)
        for k=1:numF
            connectedToGenLin{k} = [];
            for i=1:size(connectedToGenTmp{k},2)
                connectedToGenLin{k}{i} = refFgen{connectedToGenTmp{k}{i}(1),connectedToGenTmp{k}{i}(2)};
            end
            connectedToInternalLin{k} = [];
            for i=1:size(connectedToInternalTmp{k},2)
                connectedToInternalLin{k}{i} = refFgen{connectedToInternalTmp{k}{i}(1),connectedToInternalTmp{k}{i}(2)};
            end
        end
    end
    
    %creo il grafo finale senza le connessioni inter-sottografo
    Ggen = zeros(maxNodes*numF);
    dimBlocked = [];
    if ~isempty(connectedToGen)
        dimBlocked = zeros(maxNodes*numF);
    end
    %array dei tipi di nodi, indicizzati sul numero massimo di nodi in un sottografo
    labelSetFgen = cell(numF, numLabel);
    for k=1:numF
        F = FgenLin{k};
        dim = size(F, 1);
        for i=1:dim
            for j=1:dim
                Ggen(maxNodes*(k-1)+i,maxNodes*(k-1)+j) = F(i,j);
                if i == j
                    labelSetFgen{k, ID2index(F(i,j))} = [labelSetFgen{k, ID2index(F(i,j))} i];
                end
            end
        end
    end
    
    %determino per ogni coppia di sottografi tutti i possibili lati tra i loro nodi
    numE = numLabel*(numLabel+1)/2;
    edgeVector = zeros(numE, 2);
    counter = 0;
    for i=1:numLabel
        for j=i:numLabel
            counter = counter + 1;
            edgeVector(counter, 1) = i;
            edgeVector(counter, 2) = j;
        end
    end
    feasibilityEdgeVector = cell(numF,numF);
    feasibleEdgeVector = cell(numE,numF,numF);
    selectedEdgesIndexedByFeasibleEdgeVector = cell(numE,numF,numF);
    selectedEdgeIndexedByType = cell(numF,numF);
    for ki=1:numF
        for kj=ki+1:numF
            feasibilityEdgeVector{ki,kj} = zeros(numE, 1);
            for n=1:numE
                counter = 0;
                seti1 = labelSetFgen{ki,edgeVector(n,1)};
                setj2 = labelSetFgen{kj,edgeVector(n,2)};
                if ~isempty(connectedToGen)
                    %connessioni tra sottografi e sottografi esplorati
                    if ~isempty(connectedToGenLin{ki}) && ~isempty(connectedToGenLin{kj})
                        [seti1B, setj2B] = nodeSetBlockedSampling(ki, kj, connectedToGenLin, compatibleNodesGenLin);
                        %se entrambi gli insiemi non sono vuoti allora la
                        %coppia di sottografi ha degli archi vincolanti
                        if ~isempty(seti1B) && ~isempty(setj2B)
                            seti1 = intersect(seti1,seti1B);
                            setj2 = intersect(setj2,setj2B);
                        end
                    end
                    %connessioni interne tra sottografi esplorati
                    if ~isempty(connectedToInternalLin{ki}) && ~isempty(connectedToInternalLin{kj})
                        seti1 = [];
                        setj2 = [];
                        [seti1N, setj2N] = nodeSetBlockedSampling(ki, kj, connectedToInternalLin, compatibleNodesInternalLin); 
                        if ~isempty(seti1N) && ~isempty(setj2N)
                            i = seti1N(1);
                            j = setj2N(1);
                            ii = maxNodes*(ki-1)+i;
                            jj = maxNodes*(kj-1)+j;
                            Ggen(ii,jj) = 1;
                            Ggen(jj,ii) = 1;
                            dimBlocked(ii,jj) = 1;
                            dimBlocked(jj,ii) = 1;
                        end
                    end
                end
                len1 = length(seti1);
                len2 = length(setj2);
                if len1 > 0 && len2 > 0
                    feasibilityEdgeVector{ki,kj}(n) = feasibilityEdgeVector{ki,kj}(n) + len1*len2;
                    for ni=1:len1
                        for nj=1:len2
                            counter = counter + 1;
                            feasibleEdgeVector{n,ki,kj}(counter,1) = seti1(ni);
                            feasibleEdgeVector{n,ki,kj}(counter,2) = setj2(nj);
                        end
                    end
                end
                if edgeVector(n,1) ~= edgeVector(n,2)
                    seti2 = labelSetFgen{ki,edgeVector(n,2)};
                    setj1 = labelSetFgen{kj,edgeVector(n,1)};
                    if ~isempty(connectedToGen)
                        %connessioni tra sottografi e sottografi esplorati
                        if ~isempty(connectedToGenLin{ki}) && ~isempty(connectedToGenLin{kj})
                            [seti2B, setj1B] = nodeSetBlockedSampling(ki, kj, connectedToGenLin, compatibleNodesGenLin);
                            %se entrambi gli insiemi non sono vuoti allora la
                            %coppia di sottografi ha degli archi vincolanti
                            if ~isempty(seti2B) && ~isempty(setj1B)
                                seti2 = intersect(seti2,seti2B);
                                setj1 = intersect(setj1,setj1B);
                            end
                        end
                        %connessioni interne tra sottografi esplorati
                        if ~isempty(connectedToInternalLin{ki}) && ~isempty(connectedToInternalLin{kj})
                            seti2 = [];
                            setj1 = [];
                            [seti2N, setj1N] = nodeSetBlockedSampling(ki, kj, connectedToInternalLin, compatibleNodesInternalLin);
                            if ~isempty(seti2N) && ~isempty(setj1N)
                                i = seti2N(1);
                                j = setj1N(1);
                                ii = maxNodes*(ki-1)+i;
                                jj = maxNodes*(kj-1)+j;
                                Ggen(ii,jj) = 1;
                                Ggen(jj,ii) = 1;
                                dimBlocked(ii,jj) = 1;
                                dimBlocked(jj,ii) = 1;
                            end
                        end
                    end
                    len1 = length(seti2);
                    len2 = length(setj1);
                    if len1 > 0 && len2 > 0
                        feasibilityEdgeVector{ki,kj}(n) = feasibilityEdgeVector{ki,kj}(n) + len1*len2;
                        for ni=1:len1
                            for nj=1:len2
                                counter = counter + 1;
                                feasibleEdgeVector{n,ki,kj}(counter,1) = seti2(ni);
                                feasibleEdgeVector{n,ki,kj}(counter,2) = setj1(nj);
                            end
                        end
                    end
                end
            end
        end
    end
      
    numE = size(feasibleEdgeVector,1);
    numF = size(feasibleEdgeVector,2);
    %calcolo il vettore binario che mi dice per ogni sottografo se contiene
    %uno o pi� corridoi (label={1,2,13})
    % mandatoryLabels = [1 2 13];
    mandatoryLabels = [];
    for q=corridors_label
        mandatoryLabels = [mandatoryLabels,ID2index(q)];
    end
    
    mandatoryConnections = zeros(1,numF);
    for k=1:numF
        F = FgenLin{k};
        for i=1:size(F,1)
            if ismember(ID2index(F(i,i)),mandatoryLabels) 
                mandatoryConnections(k) = 1;
                break;
            end
        end
    end
    %calcolo le probabilit� dell'esistenza degli edge per ogni coppia di sottografi
    for ki=1:numF
        Fi = FgenLin{ki};
        for kj=ki+1:numF
            Fj = FgenLin{kj};
            for n=1:numE
                if feasibilityEdgeVector{ki,kj}(n) > 0
                    nodePairs = feasibleEdgeVector{n,ki,kj};
                    for l=1:size(nodePairs,1)
                        nodei = nodePairs(l,1);
                        nodej = nodePairs(l,2);
                        labeli = ID2index(Fi(nodei,nodei));
                        labelj = ID2index(Fj(nodej,nodej));
                        degi = sum(Fi(nodei,:)) - Fi(nodei,nodei) + 1;
                        degj = sum(Fj(nodej,:)) - Fj(nodej,nodej) + 1;
                        Plabeli = beta(labeli);
                        Plabelj = beta(labelj);
                        Pdegi = alfa(labeli,degi);
                        Pdegj = alfa(labelj,degj);
                        
                        Pexistij = zeta(labeli,labelj);
                        Pexistcutij = iota(labeli,labelj);
                        weights{n,ki,kj,l} = Pexistcutij*(degi/cutDegreeSum)*(degj/cutDegreeSum);
                                                
                        inducedSubgraphsij = [];
                        for di=1:size(gamma{labeli,labelj},1)
                            for dj=1:size(gamma{labeli,labelj},1)
                                for e=1:size(gamma{labeli,labelj}{di,dj},2)
                                    inducedSubgraphsij = [inducedSubgraphsij gamma{labeli,labelj}{di,dj}(e)];
                                end
                            end
                        end        
                        
                        %if Pexistcutij < edgeExistenceThreshold || Pexistij == 0 || Pdegi == 0 || Pdegj == 0 || Plabeli == 0 || Plabelj == 0 || ((mandatoryConnections(ki)==1 && mandatoryConnections(kj)==1) && (~ismember(labeli,mandatoryLabels) || ~ismember(labelj,mandatoryLabels)))
                        if Pexistcutij < edgeExistenceThreshold || Pdegi == 0 || Pdegj == 0 ...
                               || Plabeli == 0 || Plabelj == 0 || Pexistij == 0 ...
                               || (mandatoryConnections(ki) && ~ismember(labeli,mandatoryLabels)) ...
                               || (mandatoryConnections(kj) && (~ismember(labelj,mandatoryLabels)))
                            PinducedSubgraphij = 0;
                        else
                            inducedSubgraphij = subgraphPotentialConnection(Fi, Fj, nodei, nodej);
                            inducedSubgraphsij = [inducedSubgraphsij {inducedSubgraphij}];
                                           
                            dimij = size(distances{labeli,labelj},1) + 1;
                            distanceMatrix = zeros(dimij);
                            for i=1:dimij-1
                                for j=i:dimij-1
                                    distanceMatrix(i,j) = distances{labeli,labelj}(i,j);
                                    distanceMatrix(j,i) = distanceMatrix(i,j);
                                end
                            end
                            for j=1:dimij
                                distanceMatrix(dimij,j) = kernelDistanceFunction(inducedSubgraphij,inducedSubgraphsij{j}, kernelParameter);
                                distanceMatrix(j,dimij) = distanceMatrix(dimij,j);
                            end
                            
                            meanDistance = zeros(1,dimij);
                            for i=1:dimij
                                meanDistance(i) = sum(distanceMatrix(i,:))/dimij;
                            end
                            
                            numer = 0;
                            for i=1:dimij
                                numer = numer + kernelFunction(distanceMatrix(dimij,i),meanDistance(i));
                            end
                            
                            denomer = 0;
                            for i=1:dimij
                                for j=1:dimij
                                    denomer = denomer + kernelFunction(distanceMatrix(i,j),meanDistance(j));
                                end
                            end
                            
                            PinducedSubgraphij = numer/denomer;
                        end
                        P{n,ki,kj,l} = weights{n,ki,kj,l}*PinducedSubgraphij*Pexistij*Pdegi*Pdegj;%*Plabeli*Plabelj;
                    end
                end
            end
            
            %aggiungo un edge tra i due sottografi correnti in base
            %alla matrice Cgen
            if Cgen(ki,kj) > 0 && sum(feasibilityEdgeVector{ki,kj}) > 0
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
                    edgeIndex = probabilityIndexs{probIndex}(1);
                    nodePairIndex = probabilityIndexs{probIndex}(4);
                else
                    %se le probabilit� di aggiunta edge sono tutte zero
                    %prendo un edge con probabilit� uniforme
                    if skip_errors
                        error(strcat('Problema di probabilita al grafo: ',num2str(cont),'-',datestr(datetime),' passo al prox'))
                    else 
                        warning(strcat('Problema di probabilita al grafo: ',num2str(cont),'-',datestr(datetime)));
                    end
                    w = feasibilityEdgeVector{ki,kj}>0;
                    edgeIndex = randsample(1:numE, 1, true, w);
                    potentialEdges = feasibleEdgeVector{edgeIndex,ki,kj};
                    nodePairIndex = randi(size(potentialEdges,1));
                end
               
                %aggiorno i dati della configurazione
                selectedEdgesIndexedByFeasibleEdgeVector{edgeIndex,ki,kj} = nodePairIndex;
                selectedEdgeIndexedByType{ki,kj} = edgeIndex;
                feasibilityEdgeVector{ki,kj}(edgeIndex) = feasibilityEdgeVector{ki,kj}(edgeIndex) - 1;

                i = feasibleEdgeVector{edgeIndex,ki,kj}(nodePairIndex,1);
                j = feasibleEdgeVector{edgeIndex,ki,kj}(nodePairIndex,2);
                ii = maxNodes*(ki-1)+i;
                jj = maxNodes*(kj-1)+j;
                Ggen(ii,jj) = 1;
                Ggen(jj,ii) = 1;
            end
        end
    end
end
