%% %%INIT - DEFINISCO I PARAMETRI DA USARE %% %% 
!synclient HorizTwoFingerScroll=0

%% PARAMETRI GLOBALI 
% Stringa che descrive quale � l'esperimento che vien fatto
descrizione = 'TEST_ALPHASAMP=0.07_ThirdRUN';
num_parallel_cores = 2;

%% Parametro per decidere se fare predizione di tutti i grafi o di uno solo - caso
predictall=1;
% SE PREDICTALL = 0 allora posso scegliere se predirre un grafo in particolare. Il numero è quello che predico. 0 se non predico a caso
predict_select = 9;
% se predictrange � diverso da zero invece di fare ngen uso questo.
predict_range =1:50;%16:50;
% SE = 1 CERCO DI FIXARE GLI ERRORI IN MODO BRUTTO
badlyfixerrors = 0;
if badlyfixerrors 
	descrizione = strcat(descrizione, '_BADLYFIXERRORS');
end
% decide se salvare le metriche (e computare) le metriche del clustering
% per fare poi sampling. Se **NON** si fa sampling metterlo a 0 riduce del
% 90% il tempo di esecuzione del clustering
slow_stats_computation = 0;
% Se c'� errore alla fase 4 di connessione, non stampare il grafo
skip_errors = 1;

%% PARAMETRI DATASET
% numero di grafi da caricare
num_graphs = 50;
buildingType = 'SCH'; %SCH or OFF. For saving-data purposes.
graph_path = '../dataset/School/';
graph_name = 'graph_';
extension = 'csv';

%% %%%%%%%%%-PARAMETRI SEGMENTATION-CLUSTERING-%%%%%%%%%%%%%
% parametro per il clustering
clustpar = 0.55;
% parametro per scelta del metodo di segmentation, 'nCut' o 'corr'
partitionMethod = 'corr';
if partitionMethod == 'corr'
    % parametro per CORR 
    subpar = 2;
    clustpar = 0.8;
    if buildingType == 'OFF'
    	clustpar = 0.6;
    end 	
else 
    % parametro per nCut 
    subpar = 0.6;
    clustpar = 0.55;
end% parametro per il clustering
% metodo di clustering
clusteringMethod = 'A'; %A affinity N ncut
% list of corridors
corridor_labels = [100,105,110,115];
entrance_labels = [1000,5,15];


%% %%%%%%%%%-PARAMETRI KERNEL-%%%%%%%%%%%%%
% G GraphHopper, W WeisfeilerLehman, N NSPDK, S ShortestPath, M Menchetti
% WeightedDecomposition
possible_kernels = ['G','W','N','S','M'];
% scelta dei kernel
% GraphHopper
kernelClustering = 'G';
kernelSampling = 'W';
% Fisso i parametri per il kernel
% GraphHopper
graphHopperNodeKernel = 'linear';
% Weisfeiler Lehmann
WL_iter = 5;
% NSPDK
NSPDK_distance = 4;
NSPDK_radius = 3;
% MENCHETTI
MENCHETTI_extension = 0;
% OCCHIO! LE LABEL SONO DA DEFINIRE NELLA FUNZIONE APPROPRIATA (SONO
% HARD-CODED) NEL CASO SI VOGLIA USARE IL METODO EXTENSION
MENCHETTI_radius = 4;

%% %%%%%%%%%-PARAMETRI SAMPLING NUMERO DI SOTTOGRAFI-%%%%
%alphaClusterConfiguration = 0.055;
% AGGIORNAMENTO 1/9/2017
% PER SCUOLE - CORR-> alfa=0.0625; NCUT -> alfa=0.0575;
% PER UFFICI - CORR-> alfa=0.0700; NCUT -> TROVARE 
% QUELLI SEGNATI SONO I VALORI PER SAMPLING. PER PREDIZIONE 0.07 PER CORR-SCH SEMBRAVA OK.
alphaClusterConfiguration= 0.07;

%% %%%%%%%%%-PARAMETRI CONNESSIONE NODO NODO-%%%%%%%%%%%%%
% numero di grafi da generare
ngen = 50;
% threshold_di_Cut
edgeExistenceThreshold = 0.00;

%ci sono tre metodi di sampling, come definito in tesi NinoMatti (dove sono
%chiamate 1, 2 e 3) e nella cartella dropbox, dove sono 1.6.2, 1.7 e
%"newHope"
sampling_node_algorithms = [1:3];
sampling_algo = 3;
% a loro volta si pu� scegliere se usare o NON usare L (# di label) dentro
% la rete baesiana
sampling_with_labels = 0;
% e infine si pu� scegliere se fare MCMC su questo passaggio o scegliere
% solo l'argmax
isARGMAX = 1;