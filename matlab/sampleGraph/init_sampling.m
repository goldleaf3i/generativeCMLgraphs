%% %%INIT - DEFINISCO I PARAMETRI DA USARE %% %% 

%% PARAMETRI GLOBALI 
% Stringa che descrive quale � l'esperimento che vien fatto
descrizione = 'FINAL_SCH_nCUT_alfa=057';
num_parallel_cores = 4;
% decide se salvare le metriche (e computare) le metriche del clustering
% per fare poi sampling. Se **NON** si fa sampling metterlo a 0 riduce del
% 90% il tempo di esecuzione del clustering
slow_stats_computation = 1;
% Se c'� errore alla fase 4 di connessione, non stampare il grafo
skip_errors = 0;

%% PARAMETRI DATASET
% numero di grafi da caricare
%num_graphs = 50;
%buildingType = 'SCH'; %SCH or OFF. For saving-data purposes.
%graph_path = '../dataset/School/';
num_graphs = 50;
buildingType = 'SCH'; %SCH or OFF. For saving-data purposes.
graph_path = '../dataset/School/';

graph_name = 'graph_';
extension = 'csv';

%% %%%%%%%%%-PARAMETRI SEGMENTATION-CLUSTERING-%%%%%%%%%%%%%
% parametro per il clustering
clustpar = 0.6;
% parametro per scelta del metodo di segmentation, 'nCut' o 'corr'
partitionMethod = 'nCut';
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
    % PROB ERA SBAGLIATO PER SCH E' 0.8
    clustpar = 0.7;
    %clustpar = 0.55;
    if buildingType == 'OFF'
    	clustpar = 0.55;
    end 
end
% metodo di clustering
clusteringMethod = 'A'; %A affinity N ncut
% list of corridors
corridor_labels = [100,105,110,115];


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
% CON CORR alphaClusterConfiguration al valore che ho usato il 1 Luglio
% 2016 da dei grafi pi� belli ma con troppi nodi e tendenzialmente non ti 
% fa ottnere dei frafi piccoli ma solo grossi. Aumentare alfaclustering
% a tipo 0.07 ti da dei risultati peggiori ma ti fa ottenere i grafi piccoli
% belli che invece non ottieni con il parametro alto. Credo che lo stesso
% ragionamento si possa fare per NCUT ma bisogna guardare meglio i dati. 
% AGGIORNAMENTO 1/9/2017
% PER SCUOLE - CORR-> alfa=0.0625; NCUT -> alfa=0.0575; - o alpha=0.055
% PER UFFICI - CORR-> alfa=0.0700; NCUT -> 0.074 
%PER SCUOLE 
%alphaClusterConfiguration = 0.575;
% PER UFFICI- con CORR - TESTARE NCUT
%alphaClusterConfiguration = 0.07;
alphaClusterConfiguration = 0.057;
%% %%%%%%%%%-PARAMETRI CONNESSIONE NODO NODO-%%%%%%%%%%%%%
% numero di grafi da generare
ngen = 200;
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
isARGMAX = 0;