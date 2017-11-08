if ~exist('sampling_algo')
    sampling_algo = 1;
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
            node_kerne_type = 'linear';
            mu = 1;
            vecvalues = 0;
            kernelPar = {node_kernel_type, mu, vecvalues};

            %da usare quando si usa GraphHopper come kernel - RICORDARSI DI COMMENTARE
            %O DECOMMENTARE IL FONDO.
            pool = parpool('local', 4);
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
    pool = parpool('local', 4);
end

alphaClusterConfiguration = 0.11;
alphaClustersConnections = 1;
alphaNodesConnections = 1;

iterationsClusterConfiguration = 300;
iterationsClustersConnections = 2000;
iterationsNodesConnections = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('ngen')
    ngen=50;
end
if ~exist('edgeExistenceThreshold')
    edgeExistenceThreshold = 0.05;
end
edgeExistenceInterval = [0.00:0:025:0.05]


CgenGraphs = {};
for cont=1:ngen
    %STEP 1
    disp('Genero la configurazione dei cluster')
    Ugen = sampleClusterConfiguration(U, alphaClusterConfiguration, iterationsClusterConfiguration, []);
    [~, ~, ~] = mkdir('Data/matFiles/');
    save(strcat('Data/matFiles/Ugen_',num2str(cont)),'Ugen');
        
    %STEP 2
    disp('Scelgo i sottografi')
    [Fgen, numFgen, ~, ~, ~, ~, ~] = sampleSubgraphs(Ugen, F_e, ncluster, clustref, numF, poscluster, maxsgxcluster, [], [], [], [], []);
    [~, ~, ~] = mkdir('Data/matFiles/');
    save(strcat('Data/matFiles/Fgen_',num2str(cont)),'Fgen');
    
    %STEP 3
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
    save(strcat('Data/matFiles/Cgen_',num2str(cont)),'Cgen');
    
    %STEP 4
    disp('Genero il grafo finale connettendo i nodi tra i sottografi')
    % codice funzione default 
    %[Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~] = initialConfigurationNodes(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold, distances, distancesCut, cutDegreeSum, [], [], [], []);
    
    if ~exist('corridor_label') 
        disp('Uso corridor labels di default');
        corridor_label =[100,105,110];
    end

    disp([' configurazione con algoritmo: ', num2str(sampling_algo), ' con labels: ', num2str(sampling_with_labels), ' e argMAX: ', num2str(isARGMAX)]);
    if isARGMAX
        %switch sampling_algo
            %case 1
            [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                = initialConfigurationNodesNoLArgmax1(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold,...
                distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                Ggen = removeDummy(Ggen);
                % PER STAMPA ***************************************************
                [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);
                pathAgenBefore=(strcat(pwd,'/','Data','/GrafiFinaliSegmentati162_AMAX/'));
                [~, ~,  ~] = mkdir(pathAgenBefore);
                dlmwrite(strcat(pathAgenBefore,'grafogenseg_',num2str(cont),'.txt'),Fdiviso);

                pathAgenAfter=(strcat(pwd,'/','Data','/GrafiFinali162_AMAX/'));
                [~, ~,  ~] = mkdir(pathAgenAfter);
                dlmwrite(strcat(pathAgenAfter,'grafogen_',num2str(cont),'.txt'),Ggen);
                % PER STAMPA ***************************************************
            %case 2 
            [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                = initialConfigurationNodesNoLArgmax2(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold,...
                distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                Ggen = removeDummy(Ggen);
                % PER STAMPA ***************************************************
                [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);
                pathAgenBefore=(strcat(pwd,'/','Data','/GrafiFinaliSegmentati17_AMAX/'));
                [~, ~,  ~] = mkdir(pathAgenBefore);
                dlmwrite(strcat(pathAgenBefore,'grafogenseg_',num2str(cont),'.txt'),Fdiviso);

                pathAgenAfter=(strcat(pwd,'/','Data','/GrafiFinali17_AMAX/'));
                [~, ~,  ~] = mkdir(pathAgenAfter);
                dlmwrite(strcat(pathAgenAfter,'grafogen_',num2str(cont),'.txt'),Ggen);
                % PER STAMPA ***************************************************
            %case 3 
            [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                = initialConfigurationNodesNoLArgmax3(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut, zeta, iota, edgeExistenceThreshold,...
                distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                Ggen = removeDummy(Ggen);
                % PER STAMPA ***************************************************
                [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);
                pathAgenBefore=(strcat(pwd,'/','Data','/GrafiFinaliSegmentatiNH_AMAX/'));
                [~, ~,  ~] = mkdir(pathAgenBefore);
                dlmwrite(strcat(pathAgenBefore,'grafogenseg_',num2str(cont),'.txt'),Fdiviso);

                pathAgenAfter=(strcat(pwd,'/','Data','/GrafiFinaliNH_AMAX/'));
                [~, ~,  ~] = mkdir(pathAgenAfter);
                dlmwrite(strcat(pathAgenAfter,'grafogen_',num2str(cont),'.txt'),Ggen);
                % PER STAMPA ***************************************************
        %end
    else 
        if sampling_with_labels 
            %switch sampling_algo
                %case 1
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                    = initialConfigurationNodes1(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut,...
                    zeta, iota, edgeExistenceThreshold, distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                Ggen = removeDummy(Ggen);
                % PER STAMPA ***************************************************
                [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);
                pathAgenBefore=(strcat(pwd,'/','Data','/GrafiFinaliSegmentati162_Labels/'));
                [~, ~,  ~] = mkdir(pathAgenBefore);
                dlmwrite(strcat(pathAgenBefore,'grafogenseg_',num2str(cont),'.txt'),Fdiviso);

                pathAgenAfter=(strcat(pwd,'/','Data','/GrafiFinali162_Labels/'));
                [~, ~,  ~] = mkdir(pathAgenAfter);
                dlmwrite(strcat(pathAgenAfter,'grafogen_',num2str(cont),'.txt'),Ggen);
                % PER STAMPA ***************************************************
                %case 2 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                    = initialConfigurationNodes2(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut,...
                    zeta, iota, edgeExistenceThreshold, distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                Ggen = removeDummy(Ggen);
                % PER STAMPA ***************************************************
                [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);
                pathAgenBefore=(strcat(pwd,'/','Data','/GrafiFinaliSegmentati17_Labels/'));
                [~, ~,  ~] = mkdir(pathAgenBefore);
                dlmwrite(strcat(pathAgenBefore,'grafogenseg_',num2str(cont),'.txt'),Fdiviso);

                pathAgenAfter=(strcat(pwd,'/','Data','/GrafiFinali17_Labels/'));
                [~, ~,  ~] = mkdir(pathAgenAfter);
                dlmwrite(strcat(pathAgenAfter,'grafogen_',num2str(cont),'.txt'),Ggen);
                % PER STAMPA ***************************************************
                %case 3 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                    = initialConfigurationNodes3(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut,...
                    zeta, iota, edgeExistenceThreshold, distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
            %end
        else 
            %switch sampling_algo
            %    case 1
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                    = initialConfigurationNodesNoL1(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut,...
                    zeta, iota, edgeExistenceThreshold, distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                Ggen = removeDummy(Ggen);
                % PER STAMPA ***************************************************
                [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);
                pathAgenBefore=(strcat(pwd,'/','Data','/GrafiFinaliSegmentati162_NOL/'));
                [~, ~,  ~] = mkdir(pathAgenBefore);
                dlmwrite(strcat(pathAgenBefore,'grafogenseg_',num2str(cont),'.txt'),Fdiviso);

                pathAgenAfter=(strcat(pwd,'/','Data','/GrafiFinali162_NOL/'));
                [~, ~,  ~] = mkdir(pathAgenAfter);
                dlmwrite(strcat(pathAgenAfter,'grafogen_',num2str(cont),'.txt'),Ggen);
                % PER STAMPA ***************************************************
            %    case 2 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                    = initialConfigurationNodesNoL2(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut,...
                    zeta, iota, edgeExistenceThreshold, distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                            Ggen = removeDummy(Ggen);
                % PER STAMPA ***************************************************
                [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);
                pathAgenBefore=(strcat(pwd,'/','Data','/GrafiFinaliSegmentati17_NOL/'));
                [~, ~,  ~] = mkdir(pathAgenBefore);
                dlmwrite(strcat(pathAgenBefore,'grafogenseg_',num2str(cont),'.txt'),Fdiviso);

                pathAgenAfter=(strcat(pwd,'/','Data','/GrafiFinali17_NOL/'));
                [~, ~,  ~] = mkdir(pathAgenAfter);
                dlmwrite(strcat(pathAgenAfter,'grafogen_',num2str(cont),'.txt'),Ggen);
                % PER STAMPA ***************************************************
            %    case 3 
                [Ggen, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, P, ~]...
                    = initialConfigurationNodes3(Cgen, Fgen, numFgen, kernelDistance, kernelPar, alfa, beta, gamma, gammaCut,...
                    zeta, iota, edgeExistenceThreshold, distances, distancesCut, cutDegreeSum, [], [], [], [], corridor_label,size(label_list,1)+4,cont,skip_errors);
                                Ggen = removeDummy(Ggen);
                % PER STAMPA ***************************************************
                [Fdiviso] = reorganizeSubgraphsBeforeConnections(Fgen, numFgen, sizemax, ncluster);
                pathAgenBefore=(strcat(pwd,'/','Data','/GrafiFinaliSegmentatiNH_NOL/'));
                [~, ~,  ~] = mkdir(pathAgenBefore);
                dlmwrite(strcat(pathAgenBefore,'grafogenseg_',num2str(cont),'.txt'),Fdiviso);

                pathAgenAfter=(strcat(pwd,'/','Data','/GrafiFinaliNH_NOL/'));
                [~, ~,  ~] = mkdir(pathAgenAfter);
                dlmwrite(strcat(pathAgenAfter,'grafogen_',num2str(cont),'.txt'),Ggen);
                % PER STAMPA ***************************************************
            %end
        end
    end
    
    %funzione da eseguire se si vuol fare random walk anche per l'ultima
    %fase di campionamento per la connessione nodo-nodo
    if ~isARGMAX 
        Ggen = sampleConnectionsNodes(Ggen, P, grafi, kernelDistance, Cgen, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, kernelPar, alphaNodesConnections, iterationsNodesConnections, []);
    end
    
    Ggen = removeDummy(Ggen);


end

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