%SAMPLESUBGRAPHS E SAMPLECONNECTIONS

% %codice che serve per preparare il parametro ausiliario utilParameter,
% %da usare quando si utilizza EmbeddingKernelGibbs per trovare la
% %distanza (a selectConnectionsGibbsSampling dovr? quindi passare come
% %parametri @EmbeddingKernelGibbs e utilParameter)
% %kernelPar ? un cell array monodimensionale che contiene 4
% %elementi: una matrice che raggruppa i label embedding di tutti i
% %grafi della popolazione messi nella nuova rappresentazione, un'altra
% %matrice dello stesso tipo per i topological embedding, un indice (che
% %viene aggiornato di volta in volta in flipping
% % e il numero dei cluster (ncluster)
% kernelPar = cell(1,4);
% len = length(subgraphClusteringMs);
% label_embeddings = [];
% topol_embeddings = [];
% 
% %costruisco le matrici label_embeddings e topol_embeddings, ciascuna riga
% %di queste matrici ? rispettivamente il label e il topological embedding
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
% %distanza (a selectConnectionsGibbsSampling dovr� quindi passare come
% %parametri @GraphHopperGibbs e utilParameter)
% %utilParameter � un cell array monodimensionale che contiene 3 elementi:
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

% %da usare quando si usa GraphHopper come kernel
% pool = parpool('local', 4);

%% DEFINISCO I PARAMETRI DA IMPOSTARE 
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
% a loro volta si pu� scegliere se usare o NON usare L (# di label) dentro
% la rete baesiana
if ~exist('sampling_with_labels')
    sampling_with_labels = 0;
end
% e infine si pu� scegliere se fare MCMC su questo passaggio o scegliere
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

alphaClustersConnections = 1;
alphaNodesConnections = 1;

iterationsClusterConfiguration = 300;
iterationsClustersConnections = 2000;
iterationsNodesConnections = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INIZIO IL SAMPLING EFFETIVO
CgenGraphs = {};
for cont=1:ngen
    %% STEP 1
    disp('Genero la configurazione dei cluster')
    Ugen = sampleClusterConfiguration(U, alphaClusterConfiguration, iterationsClusterConfiguration, []);
    [~, ~, ~] = mkdir('Data/matFiles/');
    save(strcat(pwd,'/Data/matFiles/Ugen_',num2str(cont)),'Ugen');
        
    %% STEP 2
    disp('Scelgo i sottografi')
    [Fgen, numFgen, ~, ~, ~, ~, ~] = sampleSubgraphs(Ugen, F_e, ncluster, clustref, numF, poscluster, maxsgxcluster, [], [], [], [], []);
    [~, ~, ~] = mkdir('Data/matFiles/');
    save(strcat(pwd,'/Data/matFiles/Fgen_',num2str(cont)),'Fgen');
    
    %% STEP 3
    disp('Genero le connessioni tra i sottografi')
    initialConfiguration = initialConfigurationConnections(ncluster, numFgen, [], [], []);
    
    %connessioni tra i sottografi tramite 
    try
        Cgen = sampleConnectionsSubgraphs(initialConfiguration, subgraphClusteringMs, kernelDistance, kernelPar, alphaClustersConnections, iterationsClustersConnections, []);
    catch ME
        ME
        continue
    end
    %connessioni tra i sottografi tramite stochastic block model
%     Cgen = [];
%     while isempty(Cgen)
%         disp('grafo di connessione a pi� componenti, continuo a campionare con stochastic block model...')
%         Cgen = sampleConnectionsStochasticBlockModel(initialConfiguration, [], subgraphClusteringMs, ncluster);
%     end

    CgenGraphs = [CgenGraphs {Cgen}];
    [~, ~, ~] = mkdir('Data/matFiles/');
    save(strcat(pwd,'/Data/matFiles/Cgen_',num2str(cont)),'Cgen');
    
    %% STEP 4
    disp('Genero il grafo finale connettendo i nodi tra i sottografi')
    % codice funzione default 
    %[Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~] = initialConfigurationNodes(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, distances, distancesCut, cutDegreeSum, [], [], [], []);
    
    if ~exist('corridor_label')
        disp('Uso corridor labels di default');
        corridor_label =[100,105,110];
    end

    disp([' configurazione con algoritmo: ', num2str(sampling_algo), ' con labels: ', num2str(sampling_with_labels), ' e argMAX: ', num2str(isARGMAX)]);
    try
        if isARGMAX
            switch sampling_algo
                case 1
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                 = initialConfigurationNodesNoLArgmax1(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                    distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                case 2 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                 = initialConfigurationNodesNoLArgmax2(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                    distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                case 3 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                 = initialConfigurationNodesNoLArgmax3(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                    distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
            end
        else 
            if sampling_with_labels 
                switch sampling_algo
                    case 1
                    [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                     = initialConfigurationNodes1(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                        distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                    case 2 
                    [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                     = initialConfigurationNodes2(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                        distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                    case 3 
                    [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                     = initialConfigurationNodes3(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                        distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                end
            else 
                switch sampling_algo
                    case 1
                    [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                     = initialConfigurationNodesNoL1(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                        distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                    case 2 
                    [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                     = initialConfigurationNodesNoL2(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                      distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                    case 3 
                    [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                     = initialConfigurationNodes3(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, ...
                      distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                end
            end
        end

        %funzione da eseguire se si vuol fare random walk anche per l'ultima
        %fase di campionamento per la connessione nodo-nodo
        if ~isARGMAX 
            Ggen = sampleConnectionsNodes(Ggen, P, grafi, kernelDistance, Cgen, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, kernelPar, alphaNodesConnections, iterationsNodesConnections, []);
        end
    catch ME
        ME
        continue
    end
    %% FINE - SALVO I DATI
    Ggen = removeDummy(Ggen);
    [~, ~, ~] = mkdir('Data/matFiles/');
    save(strcat(pwd,'/Data/matFiles/Ggen_',num2str(cont)),'Ggen');

    % PER STAMPA ***************************************************
    pathCgen=(strcat(pwd,'/','Data','/GrafiConnessioneCluster/'));
    [~, ~,  ~] = mkdir(pathCgen);
    dlmwrite(strcat(pathCgen,'clustergen_',num2str(cont),'.txt'),Cgen);
    [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);
    pathAgenBefore=(strcat(pwd,'/','Data','/GrafiFinaliSegmentati/'));
    [~, ~,  ~] = mkdir(pathAgenBefore);
    dlmwrite(strcat(pathAgenBefore,'grafogenseg_',num2str(cont),'.txt'),Fdiviso);
    
    pathAgenAfter=(strcat(pwd,'/','Data','/GrafiFinali/'));
    [~, ~,  ~] = mkdir(pathAgenAfter);
    dlmwrite(strcat(pathAgenAfter,'grafogen_',num2str(cont),'.txt'),Ggen);
    % PER STAMPA ***************************************************
end

%% CHIUDO TUTTO - FACCIO PULIZIA 
%stampo la matrice di similarit� tra i grafi di connessione dei cluster
%campionati e quelli originali (serve a TSNE)
createMixSimilarityMatrix(subgraphClusteringMs, CgenGraphs, 1, 2);

if exist('kernelSampling')
    if kernelSampling == 'G'
        %da usare quando si usa GraphHopper come kernel
        delete(pool);
    end
else
    %da usare quando si usa GraphHopper come kernel
    delete(pool);
end
