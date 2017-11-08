%Script che esegue il sampling bloccato di un grafo, ossia ho un grafo
%esplorato e da questo voglio campionare un nuovo grafo. Come dati in
%ingresso utilizzo il cell array dei grafi originali "grafi", il cell array
%dei sottografi che compongono il grafo esplorato "sottografi", il cell
%array degli archi di cut di ogni sottografo "matr_adiac_cut_subgraph",
%gli archi uscenti dal grafo esplorato "archi_cut_uscenti", gli archi
%presenti per ogni coppia di sottografi
%"estremi_archi_cut_coppie_sottografi". Prima di eseguire questo script si
%deve eseguire Segmentation e ClusteringAndConnectionManager

% %codice che serve per preparare il parametro ausiliario utilParameter,
% %da usare quando si utilizza EmbeddingKernelGibbs per trovare la
% %distanza (a selectConnectionsGibbsSampling dovrà quindi passare come
% %parametri @EmbeddingKernelGibbs e utilParameter)
% %kernelPar è un cell array monodimensionale che contiene 4
% %elementi: una matrice che raggruppa i label embedding di tutti i
% %grafi della popolazione messi nella nuova rappresentazione, un'altra
% %matrice dello stesso tipo per i topological embedding, un indice (che
% %viene aggiornato di volta in volta in flippingGibbsSamplerKernel, riga
% %60) e il numero dei cluster (ncluster)
% kernelPar = cell(1,4);
% len = length(subgraphClusteringMs);
% label_embeddings = [];
% topol_embeddings = [];
% 
% %costruisco le matrici label_embeddings e topol_embeddings, ciascuna riga
% %di queste matrici è rispettivamente il label e il topological embedding
% %dell'i-esimo grafo all'interno del cell array subgraphClusteringMs, che
% %contiene i grafi della popolazione messi nella nuova rappresentazione
% for i = 1:len
%     matrice_adiacenza = subgraphClusteringMs{i};
%     lab_emb = LabelEmbeddingGibbs(matrice_adiacenza, ncluster);
%     top_emb = TopologicalEmbeddingGibbs(matrice_adiacenza, ncluster);
%     label_embeddings = [label_embeddings; lab_emb];
%     topol_embeddings = [topol_embeddings; top_emb];

% end
% 
% %inizializzo utilParameter con i valori che mi sono trovato
% kernelPar{1} = label_embeddings;
% kernelPar{2} = topol_embeddings;
% kernelPar{3} = 0;
% kernelPar{4} = ncluster;

%--------------------------------------------------------------------------

% %codice che serve per preparare il parametro ausiliario utilParameter,
% %da usare quando si utilizza GraphHopperGibbs per trovare la
% %distanza (a selectConnectionsGibbsSampling dovrò quindi passare come
% %parametri @GraphHopperKernelDistance e utilParameter)
% %utilParameter è un cell array monodimensionale che contiene 3 elementi:
% %la stringa node_kernel_type che specifica quale kernel deve essere usato
% %dentro GraphHopper (le scelte sono: 'linear', 'gaussian',
% %'diractimesgaussian', 'dirac' ('dirac' uses only discrete node labels)
% %e 'bridge'), il parametro mu per il gaussian node kernel e il parametro 
% %vecvalues che serve per stabilire quali attributi devono essere usati (
% %se vuoi usare le label scalari dei nodi allora vale 0 mentre invece se
% %vuoi usare i vettori di attributi associati a ciascun nodo allora vale 1)
% node_kernel_type = 'linear';
% mu = 1;
% vecvalues = 0;
% kernelPar = {node_kernel_type, mu, vecvalues};

%%%%%%%%%%%-PARAMETRI DA IMPOSTARE-%%%%%%%%%%%%%%%%%%

if ~exist('ngen')
    ngen=50;
end
if ~exist('edgeExistenceThreshold')
    edgeExistenceThreshold = 0.05;
end

%%%%%%%%%%%-PARAMETRI CONNESSIONE NODO NODO-%%%%%%%%%%%
%ci sono tre metodi di sampling, come definito in tesi NinoMatti (dove sono
%chiamate 1, 2 e 3) e nella cartella dropbox, dove sono 1.6.2, 1.7 e
%"newHope"

if ~exist('sampling_algo')
    sampling_algo = 1;
end

if ~exist('skip_errors')
    % se un grafo ha errori di connessione non plottarlo
    skip_erros = 0;
end
% a loro volta si puo scegliere se usare o NON usare L (# di label) dentro
% la rete baesiana
if ~exist('sampling_with_labels')
    sampling_with_labels = 0;
end
% e infine si puo scegliere se fare MCMC su questo passaggio o scegliere
% solo l'argmax
if ~exist('isARGMAX')
    isARGMAX = 1;
end

%% DEFINISCO I KERNEL
if exist('kernelSampling')
    disp(['USO KERNEL ',kernelSampling]);
    switch kernelSampling
        case 'W'
            % PARAMETRI PER WEISFEILER LEHMAN
            kernelDistance = @WeisfeilerLehmanKernelDistance;
            kernelPar = 5;
        case 'G'
            % PARAMETRI PER GRAPH HOPPER
            kernelDistance = @GraphHopperKernelDistance;
            if ~exist('graphHopperNodeKernel')
                node_kernel_type = 'linear';
            else
                node_kernel_type = graphHopperNodeKernel;
            end
            mu = 1;
            vecvalues = 0;
            kernelPar = {node_kernel_type, mu, vecvalues};

            %da usare quando si usa GraphHopper come kernel - RICORDARSI DI COMMENTARE
            %O DECOMMENTARE IL FONDO.
            pool = parpool('local', 4);
        case 'N'
            disp('Sto usando NSPDK');
            kernelDistance = @NeighborhoodSubgraphPairwiseDistanceKernelDistance;
            if ~exist('NSPDK_distance')
                NSPDK_distance = 4;
            end
            if ~exist('NSPDK_radius')
                NSPDK_radius = 3; 
            end
            kernelPar={[NSPDK_distance,NSPDK_radius]};
            % Parametri: Raggio / Distanza / Normalizzazione 
        case 'S'
            disp('Sto usando ShortestPath Kernel');
            kernelDistance = @ShortestPathKernelDistance;
            % Il parametro che vuole � l'alfabeto della label in ingresso.
            % andrebbe calcolato in maniera pi� rigorosa.
            num_max_label = 26;
            kernelPar=num_max_label;
        case 'M'
            disp('Sto usando Menchetti WeightedDecompositionKernel');
            if ~exist('MENCHETTI_extension')
                MENCHETTI_extension = 0;
            end
            if ~exist('MENCHETTI_radius')
                MENCHETTI_radius = 4;
            end
            kernelPar = MENCHETTI_radius;
            if MENCHETTI_extension
                kernelDistance = @WeightedDecompositionKernelSelectorExtensionDistance;
                disp('ATTENZIONE! STAI USANDO MENCHETTI CON EXTENSION: I SELETTORI DELLE LABEL CHE VENGONO USATI SONO HARD-CODED DENTRO LA FUNZIONE; CERCA DI ESSERE SICURO CHE SONO QUELLI CORRETTI');
            else
                kernelDistance = @WeightedDecompositionKernelDistance;

            end
    end
else
    disp('Uso kernel di default, GH');
    % PARAMETRI PER GRAPH HOPPER
    kernelDistance = @GraphHopperKernelDistance;
    node_kerne_type = 'linear';
    mu = 1;
    vecvalues = 0;
    kernelPar = {node_kernel_type, mu, vecvalues};

    %da usare quando si usa GraphHopper come kernel - RICORDARSI DI COMMENTARE
    %O DECOMMENTARE IL FONDO.
    if ~exist('num_parallel_cores')
        num_parallel_cores = 4;
    end
    pool = parpool('local', num_parallel_cores);
end

%% DEFINISCO IL NUMERO DI ITERAZIONI DA SVOLGERE
if ~exist('alphaClusterConfiguration')
                alphaClusterConfiguration = 0.11;
            end


% VECCHI PARAMETRI
% edgeExistenceThreshold = 0.05;
% kernelDistance = @WeisfeilerLehmanKernelDistance;
% kernelPar = 5;

% alphaClusterConfiguration = 0.11;
alphaClusterConfiguration_str = num2str(alphaClusterConfiguration);
alphaClustersConnections = 1;
alphaNodesConnections = 1;

iterationsClusterConfiguration = 300;
iterationsClustersConnections = 2000;
iterationsNodesConnections = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

indexSubgraph = 0;
for k=1:size(sottografi,2)
    if sottografi{k}{2} == 1
        indexSubgraph = indexSubgraph + 1;
        counter = 0;
        subgraphs{indexSubgraph} = sottografi{k}{1};
        exploredConnections{indexSubgraph} = [];
        for i=1:size(archi_cut_uscenti, 2)
            if archi_cut_uscenti{i}{3} == k
                counter = counter + 1;
                nodex = archi_cut_uscenti{i}{2}(3);
                labelx = subgraphs{indexSubgraph}(nodex,nodex);
                degx = sum(subgraphs{indexSubgraph}(nodex,:)) - subgraphs{indexSubgraph}(nodex,nodex) + sum(sum(matr_adiac_cut_subgraph{k}{1} == -1))/2;
                exploredConnections{indexSubgraph}{counter}{1} = [nodex degx labelx];
                exploredConnections{indexSubgraph}{counter}{2} = [archi_cut_uscenti{i}{4}(1) archi_cut_uscenti{i}{4}(2)];
            end
        end
    end
end

i = 0;

for k1=1:size(estremi_archi_cut_coppie_sottografi,1)
    if sottografi{k1}{2} == 1
        i = i + 1;
        j = 0;
        for k2=1:size(estremi_archi_cut_coppie_sottografi,2)
             if sottografi{k2}{2} == 1
                 j = j + 1;
                 estremi_archi_cut_coppie_sottografi_esplorati(i,j) = estremi_archi_cut_coppie_sottografi(k1,k2);
             end
        end
    end
end

for k1=1:size(estremi_archi_cut_coppie_sottografi_esplorati,1)
    for k2=k1+1:size(estremi_archi_cut_coppie_sottografi_esplorati,2)
        estremi_archi_cut_coppie_sottografi_esplorati(k2,k1) = estremi_archi_cut_coppie_sottografi_esplorati(k1,k2);
    end
end

disp('Classifico i sottografi esplorati');
%devo assegnare un cluster ad ogni sottografo e lo faccio calcolando la
%distanza media minima dai sottografi appartenenti ai cluster
clustersSubgraphs = zeros(1,size(subgraphs,2));
minDistances = zeros(1,size(subgraphs,2));
for c=1:ncluster
    numSub = 0;
    distancesFromCluster = zeros(size(sottografi,2));
    for k=1:size(Fcluster,2)
        Fclust = removeDummy(Fcluster{c,k});
        if isempty(Fclust)
            break;
        else
            numSub = numSub + 1;
            for kk=1:size(subgraphs,2)
                distancesFromCluster(kk) = distancesFromCluster(kk) + kernelDistance(subgraphs{kk},removeDummy(Fcluster{c,k}),kernelPar);
            end
        end
    end
    
    if c == 1
        for kk=1:size(subgraphs,2)
            clustersSubgraphs(kk) = c;
            minDistances(kk) = distancesFromCluster(kk)/numSub;
        end
    else
        for kk=1:size(subgraphs,2)
            distance_cl = distancesFromCluster(kk)/numSub;
            if distance_cl < minDistances(kk)
                clustersSubgraphs(kk) = c;
                minDistances(kk) = distance_cl;
            end
        end
    end
end

%cambio la configurazione dei cluster, adeguando le posizioni dei cluster
%in base ai nuovi sottografi
for c=1:ncluster
    if sum(clustersSubgraphs == c) > maxsgxcluster(c)
        diff = sum(clustersSubgraphs == c) - maxsgxcluster(c);
        Unew = zeros(size(U,1),size(U,2)+diff);
        tmpDiff = diff;
        for j=1:size(Unew,2)
            if j < poscluster(c+1)
                Unew(:,j) = U(:,j);
            elseif tmpDiff > 0
                tmpDiff = tmpDiff - 1;
                Unew(:,j) = zeros(1,size(U,1));
            else
                Unew(:,j) = U(:,j-diff);
            end
        end
        for cc=c+1:size(poscluster,2)
            poscluster(cc) = poscluster(cc) + diff;
        end
        maxsgxcluster(c) = maxsgxcluster(c) + diff;
        U = Unew;
    end
end

countsgxcluster = zeros(1,ncluster);
dimblocked = size(clustersSubgraphs, 2);

for k=1:size(clustersSubgraphs,2)
    c = clustersSubgraphs(k);
    pos = poscluster(c) + countsgxcluster(c);
    dimblocked(k) = pos;
    countsgxcluster(c) = countsgxcluster(c) + 1;
end

%salvo il grafo esplorato finora così può essere plottato
save(strcat('Predict/matfiles/Grafo_esplorato_', num2str(contatore_per_salvataggi_file), '-', suffisso_nome_file, 'Subpar0,', subpar_str(3:end),'ClustAFF0,', clustpar_str(3:end), 'A=0,', alphaClusterConfiguration_str(3:end), '_', num2str(alphaClustersConnections), '_', num2str(alphaNodesConnections), 'Iter=', num2str(iterationsClusterConfiguration), '_', num2str(iterationsClustersConnections), '_', num2str(iterationsNodesConnections)),'grafo_esplorato');

%STEP 1
disp('Genero la configurazione dei cluster')

Ugen = sampleClusterConfiguration(U, alphaClusterConfiguration, iterationsClusterConfiguration, dimblocked);
save(strcat('Predict/matfiles/Ugen_blocked_', num2str(contatore_per_salvataggi_file), '-', suffisso_nome_file, 'Subpar0,', subpar_str(3:end),'ClustAFF0,', clustpar_str(3:end), 'A=0,', alphaClusterConfiguration_str(3:end), '_', num2str(alphaClustersConnections), '_', num2str(alphaNodesConnections), 'Iter=', num2str(iterationsClusterConfiguration), '_', num2str(iterationsClustersConnections), '_', num2str(iterationsNodesConnections)),'Ugen');

%STEP 2
disp('Scelgo i sottografi')

[Fgen, numFgen, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, exploredSubgraphsGen] = sampleSubgraphs(Ugen, F_e, ncluster, clustref, numF, poscluster, maxsgxcluster, dimblocked, subgraphs, clustersSubgraphs, exploredConnections, estremi_archi_cut_coppie_sottografi_esplorati);
save(strcat('Predict/matfiles/Fgen_blocked_', num2str(contatore_per_salvataggi_file), '-', suffisso_nome_file, 'Subpar0,', subpar_str(3:end),'ClustAFF0,', clustpar_str(3:end), 'A=0,', alphaClusterConfiguration_str(3:end), '_', num2str(alphaClustersConnections), '_', num2str(alphaNodesConnections), 'Iter=', num2str(iterationsClusterConfiguration), '_', num2str(iterationsClustersConnections), '_', num2str(iterationsNodesConnections)),'Fgen');
 
%STEP 3
disp('Genero le connessioni tra i sottografi')

[initialConfiguration, dimBlockedClusterConnections] = initialConfigurationConnections(ncluster, numFgen, connectedToGen, estremi_archi_cut_coppie_sottografi_esplorati, exploredSubgraphsGen);

% try
%TODO QUI
%     % se ci sono degli errori: catturo e vado avanti
%     Cgen = sampleConnectionsSubgraphs(initialConfiguration, subgraphClusteringMs, kernelDistance, kernelPar, alphaClustersConnections, iterationsClustersConnections, dimBlockedClusterConnections);
% catch ME
%     ME
%     Cgen = 'ERRORE'
% end
% PROVO A VEDERE COSA SUCCEDE COSI
%TODO QUI
Cgen = sampleConnectionsSubgraphs(initialConfiguration, subgraphClusteringMs, kernelDistance, kernelPar, alphaClustersConnections, iterationsClustersConnections, dimBlockedClusterConnections);
save(strcat('Predict/matfiles/Cgen_blocked_', num2str(contatore_per_salvataggi_file), '-', suffisso_nome_file, 'Subpar0,', subpar_str(3:end),'ClustAFF0,', clustpar_str(3:end), 'A=0,', alphaClusterConfiguration_str(3:end), '_', num2str(alphaClustersConnections), '_', num2str(alphaNodesConnections), 'Iter=', num2str(iterationsClusterConfiguration), '_', num2str(iterationsClustersConnections), '_', num2str(iterationsNodesConnections)),'Cgen');

% pause(500);

%STEP 4
disp('Genero il grafo finale connettendo i nodi tra i sottografi')

%[Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
% = initialConfigurationNodes(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold,...
%  distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal);

%funzione da eseguire se si vuol fare random walk anche per l'ultima
%fase di campionamento per la connessione nodo-nodo
%Ggen = sampleConnectionsNodes(Ggen, P, grafi, kernelDistance, Cgen, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, kernelPar, alphaNodesConnections, iterationsNodesConnections, dimBlockedNodesConnections);

%Ggen = removeDummy(Ggen);

    if ~exist('corridor_label')
        disp('Uso corridor labels di default');
        corridor_label =[100,105,110];
    end
%TODO QUI
%try 
    disp([' configurazione con algoritmo: ', num2str(sampling_algo), ' con labels: ', num2str(sampling_with_labels), ' e argMAX: ', num2str(isARGMAX)]);
    if isARGMAX
        switch sampling_algo
            case 1
            [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
             = initialConfigurationNodesNoLArgmax1(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridor_label,size(label_list,1)+4,cont,skip_errors);
            case 2 
            [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
             = initialConfigurationNodesNoLArgmax2(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridor_label,size(label_list,1)+4,cont,skip_errors);
            case 3 
            [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
             = initialConfigurationNodesNoLArgmax3(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridor_label,size(label_list,1)+4,cont,skip_errors);
        end
    else 
        if sampling_with_labels 
            switch sampling_algo
                case 1
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
                 = initialConfigurationNodes1(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                    distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridor_label,size(label_list,1)+4,cont,skip_errors);
                case 2 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
                 = initialConfigurationNodes2(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                    distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridor_label,size(label_list,1)+4,cont,skip_errors);
                case 3 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
                 = initialConfigurationNodes3(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                    distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridor_label,size(label_list,1)+4,cont,skip_errors);
            end
        else 
            switch sampling_algo
                case 1
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
                 = initialConfigurationNodesNoL1(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                    distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridor_label,size(label_list,1)+4,cont,skip_errors);
                case 2 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
                 = initialConfigurationNodesNoL2(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                  distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridor_label,size(label_list,1)+4,cont,skip_errors);
                case 3 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, dimBlockedNodesConnections]...
                 = initialConfigurationNodes3(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                  distances, distancesCut, cutDegreeSum, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, corridor_label,size(label_list,1)+4,cont,skip_errors);
            end
        end
    end
    
    %funzione da eseguire se si vuol fare random walk anche per l'ultima
    %fase di campionamento per la connessione nodo-nodo
    if ~isARGMAX 
        %fase di campionamento per la connessione nodo-nodo
        Ggen = sampleConnectionsNodes(Ggen, P, grafi, kernelDistance, Cgen, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, kernelPar, alphaNodesConnections, iterationsNodesConnections, dimBlockedNodesConnections);
    end
    
    %% FINE - SALVO I DATI
    Ggen = removeDummy(Ggen);

%TODO QUI
%catch ME
%    ME
%    Ggen = 'ERRORE'
%end


save(strcat('Predict/matfiles/Ggen_blocked_', num2str(contatore_per_salvataggi_file), '-', suffisso_nome_file, 'Subpar0,', subpar_str(3:end),'ClustAFF0,', clustpar_str(3:end), 'A=0,', alphaClusterConfiguration_str(3:end), '_', num2str(alphaClustersConnections), '_', num2str(alphaNodesConnections), 'Iter=', num2str(iterationsClusterConfiguration), '_', num2str(iterationsClustersConnections), '_', num2str(iterationsNodesConnections)),'Ggen');

% pause(500);

% PER STAMPA ***************************************************

%main_directory = 'D:\Dropbox\GenerativeModelsOfGraphs\OUTPUTS\Run 27 scuole nuove\Clustering affinity propagation';
main_directory = strcat(pwd,'/Predict/Prediction_results_')

switch kernelSampling
    case 'G'
        kernel_name = 'GH';
        if exist ('graphHopperNodeKernel')
            kernel_name = strcat(kernelString,graphHopperNodeKernel);
        end
    case 'W'
        kernel_name = 'WL';
    case 'N'
        kernel_name = 'NSPDK';
    case 'S'
        kernel_name = 'SHORTPATH';
    case 'M'
        kernel_name = 'MENCHWD';
end

%kernel_name = 'Kernel_WL_iter=5';
%kernel_name = strcat(kernelSampling,'');
pathgrafoespl=(strcat(main_directory,'/',kernel_name,'_subpar=',num2str(subpar),'_clustpar=',num2str(clustpar),'/Grafi espl durante prediz'));
mkdir(pathgrafoespl);

dlmwrite(strcat(pathgrafoespl,'/grafo_esplorato_',num2str(contatore_per_salvataggi_file),'.txt'),grafo_esplorato);

pathCgen=(strcat(main_directory,'/',kernel_name,'_subpar=',num2str(subpar),'_clustpar=',num2str(clustpar),'/Grafi conn clust prediz'));
mkdir(pathCgen);

dlmwrite(strcat(pathCgen,'/clustergen_blocked_',num2str(contatore_per_salvataggi_file),'.txt'),Cgen);

[Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);

pathAgenBefore=(strcat(main_directory,'/',kernel_name,'_subpar=',num2str(subpar),'_clustpar=',num2str(clustpar),'/Grafi finali segm prediz'));
mkdir(pathAgenBefore);

dlmwrite(strcat(pathAgenBefore,'/grafogenseg_blocked_',num2str(contatore_per_salvataggi_file),'.txt'),Fdiviso);
    
pathAgenAfter=(strcat(main_directory,'/',kernel_name,'_subpar=',num2str(subpar),'_clustpar=',num2str(clustpar),'/Grafi finali prediz'));
mkdir(pathAgenAfter);

dlmwrite(strcat(pathAgenAfter,'/grafogen_blocked_',num2str(contatore_per_salvataggi_file),'.txt'),Ggen);

% PER STAMPA ***************************************************