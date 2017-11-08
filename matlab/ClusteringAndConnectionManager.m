%faccio sia componente clustering che componente ConnectionManager

% parametro di clustering per:
% 1) spectral clustering (sensibilitï¿½ di clustering)
% 2) affinity propagation (fattore di smorzamento)

if ~exist('slow_stats_computation')
    slow_stats_computation = 1;
end

if ~exist('clustpar')
    disp('Uso parametro standard di clustering');
    clustpar=0.5;
else
    disp('Uso parametro clustering definito precedentemente');
end

disp('Creo matrice similarita tra i sottografi')
% Seleziono kernel da utilizzare
if exist('kernelClustering')
    disp(['Uso kernel ',kernelClustering]);
    switch kernelClustering
        case 'W'
            disp('Sto usando WeisfeilerLehman Kernel');
            kernelDistance = @WeisfeilerLehmanKernelDistance;
            if ~exist('WL_iter')
                WL_iter = 5
            end
            kernelPar = WL_iter;
            sim = createWeisfeilerLehmanKernelMatrix(Flin, WL_iter, 1);
        case 'G'
            disp('Sto usando GraphHopper');
            kernelDistance = @GraphHopperKernelDistance;
            if ~exist('graphHopperNodeKernel')
                node_kernel_type = 'linear';
            else
                node_kernel_type = graphHopperNodeKernel;
            end
            mu = 1;
            vecvalues = 0;
            kernelPar = {node_kernel_type, mu, vecvalues};
            
            Flin_conv = ConvertiPerGraphHopper(Flin);
            if ~exist('num_parallel_cores')
                num_parallel_cores = 4;
            end
            pool = parpool('local', num_parallel_cores);

            sim = GraphHopper_dataset(Flin_conv,node_kernel_type,mu,0);
            sim = normalize_kernel(sim);

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
            sim = createNeighborhoodSubgraphPairwiseDistanceKernelMatrix(Flin,[NSPDK_distance,NSPDK_radius],1);
        case 'S'
            disp('Sto usando ShortestPath Kernel');
            kernelDistance = @ShortestPathKernelDistance;
            % Il parametro che vuole è l'alfabeto della label in ingresso.
            % andrebbe calcolato in maniera più rigorosa.
            num_max_label = 26;
            kernelPar=num_max_label;
            sim = createShortestPathKernelMatrix(Flin,num_max_label,1);
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
                sim =  createWeightedDecompositionKernelMatrix(Flin, MENCHETTI_radius, MENCHETTI_extension, n)
            else
                kernelDistance = @WeightedDecompositionKernelDistance;
                sim =  createWeightedDecompositionKernelMatrix(Flin, MENCHETTI_radius, MENCHETTI_extension, n)
            end
    end
else 
        disp('Uso kernel Standard per clustering;');
        kernelDistance = @GraphHopperKernelDistance;
        node_kernel_type = 'linear';
        mu = 1;
        vecvalues = 0;
        kernelPar = {node_kernel_type, mu, vecvalues};

        Flin_conv = ConvertiPerGraphHopper(Flin);
        if ~exist('num_parallel_cores')
            num_parallel_cores = 4;
        end
        pool = parpool('local', num_parallel_cores);

        sim = GraphHopper_dataset(Flin_conv,'linear',mu,0);
        sim = normalize_kernel(sim);
end


disp('Creo i cluster')
% utilizzare uno dei due algoritmi di clustering


if exist('clusteringMethod')
    if clusteringMethod == 'N'
        % spectral clustering
        disp('Uso NCut come metodo di clustering');
        [insCluster, riferimenti, conCluster]=partition(sim,clustpar);
    else
        % affinity propagation
        disp('Uso AffProp come metodo di clustering');
        [E, K, idx, riferimenti] = affinityPropagation(sim, clustpar);
    end
else
    disp('Uso il metodo standard di clustering, affinity propagation');
    % affinity propagation
    [E, K, idx, riferimenti] = affinityPropagation(sim, clustpar);
end

ncluster=size(riferimenti,1);

%ricordo che sottografi{k,i} -> graforig(k,i)=i2 -> riferimenti(c,i2)==1 
%a questo punto prima mi conviene salvare il cluster di sottografi{k,i}
clustref = clusterReferences(ngrafi, ncluster, numF, graforig, riferimenti);

disp('Creo le matrici di connessione di tutti i grafi')
%creo tutte le matrici di connessione dei sottografi che servono per
%la seconda fase di Gibbs sampling e ottenere il numero di connessioni
[subgraphClusteringMs, subgraphIds] = subgraphClusteringMatrices(C_e, numF, graforig, clustref);

%prima di poter posizionare F_e e C_e mi serve sapere il numero massimo
%in un grafo di sottografi per ogni cluster
maxsgxcluster = maxSubgraphsForCluster(ngrafi, ncluster, clustref, numF);

%mi serve poscluster(c) per tracciare insieme a maxsgcluster(c)
%le posizioni per ogni cluster
poscluster = slotsForCluster(ncluster, maxsgxcluster);

disp('Creo la matrice di configurazione dei cluster')
%creo anche la matrice U che mi servir? nella generazione pi? avanti
U = createClusterConfigurationMatrix(ngrafi, ncluster, clustref, numF, poscluster, sum(maxsgxcluster));

if slow_stats_computation 
    disp('Calcolo le statistiche')
    [alfa, beta, gamma, gammaCut, zeta, iota, distances, distancesCut, cutDegreeSum] = tabulaTagli(grafi, F_e, C_e, numF, subgraphToNodeAssociation, kernelDistance, kernelPar,size(label_list,1)+4);
else
    disp('Non calcolo le statistiche');
end
% PER STAMPA ***************************************************
%riorganizzo i sottografi e i cluster per la stampa, faccio il padding solo ai fini della stampa
%ottenendo F_p e C_p
[F_p, C_p] = paddingSubgraphsAndConnections(F_e, C_e, numF, ngrafi, sizemax);
[Fdivisi, Fcluster, groupCluster] = reorganizeSubgraphsAndClusters(ngrafi, sizemax, ncluster, clustref, numF, F_p);

%stampo sottografi e cluster
pathA=(strcat(pwd,'/','Data','/GrafiOriginaliSegmentati/'));
[~, ~, ~] = mkdir(pathA);
pathB=(strcat(pwd,'/','Data','/ClustersSottografi/'));
[~, ~, ~] = mkdir(pathB);
for k=1:ngrafi,
    dlmwrite(strcat(pathA,'grafoini_',num2str(k),'.txt'),Fdivisi{k});
end
for c=1:ncluster,
    dlmwrite(strcat(pathB,'cluster_',num2str(c),'.txt'),groupCluster{c});
end

%stampo la matrice di similaritï¿½ e le etichette dei cluster corrispondenti
%ai sottografi
labels = zeros(1, size(sim,1));
for c=1:ncluster
    for i=1:size(riferimenti, 2)
        if riferimenti(c, i) == 1
            labels(i) = c;
        end
    end
end

% Matrice di similarita' dei sottografi ed etichette dei cluster di appartenenza (da usare come input a TSNE)
pathS=(strcat(pwd,'/','Data','/MatriceSimilaritaClusteringTSNE/'));
[~, ~, ~] = mkdir(pathS);
dlmwrite(strcat(pathS,'similarity_matrix.log'),sim);
dlmwrite(strcat(pathS,'cluster_labels.log'),labels);
% PER STAMPA ***************************************************


if slow_stats_computation
    disp('Salvo i dati della fase di clustering e gestione connessioni')
    %salvo i dati per le fasi successive
    [~, ~, ~] = mkdir('Data/matFiles/');
    save(strcat(pwd,'/Data/matFiles/ClusteringAndConnectionManagerData'),'grafi','alfa','beta','gamma','gammaCut','zeta','iota','distances','distancesCut','cutDegreeSum','graforig','Fcluster','subpar','clustpar','sizemax','subgraphClusteringMs','subgraphIds','riferimenti','numF','F_e','U','clustref','maxsgxcluster','ncluster','poscluster');
end

if exist('kernelClustering')
    if kernelClustering == 'G'
        %da usare quando si usa GraphHopper come kernel
        if exist('pool')
            delete(pool);
        else
            disp('Sembra che Pool non esista');
        end
    end
else
    %da usare quando si usa GraphHopper come kernel
    delete(pool);
end