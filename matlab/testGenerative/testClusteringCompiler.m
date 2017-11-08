% Script per testare UNA configurazione di clustering con vari parametri e per paragonare i due metodi di segmentazione con tale configurazione
if exist('pool')
    delete(pool)
end
clear all

addpath(genpath('../lib'))
addpath('..') %TODO spostare gli script principali
num_parallel_cores = 2;
%clc
% G GraphHopper, W WeisfeilerLehman, N NSPDK

possible_kernels = ['G','W','N'];
clusteringMethod = 'A' %A affinity N ncut
kernelClustering = 'G';
kernelSampling = 'W';
clusterParameters = [0.6,0.9];
clustpar = 0.5;
partitionMethod = 'nCut';
% salvo o non salvo i dati e pre-calcolo le matrici per il sampling
slow_stats_computation = 0;


% parametro per nCut Segmentation
subpar = 0.6;
% list of corridors
corridor_labels = [100,105,110,115];

for partitions={'nCut','Corr'}
    
    tic
    disp(strcat('Inizio con ', partitions));
    partitionMethod=partitions{1};
    %% Load Graphs
    buildingType = 'SCH'; %SCH or OFF. For saving-data purposes.
    disp('# Loading graphs #')
    graph_path = '../dataset/School/';
    graph_name = 'graph_';
    extension = 'csv';
    num_graphs = 31;
    [ graphs, label_list ] = loadGraphs( graph_path, graph_name, extension, num_graphs);
    %CaricaCsv;

    %load 'grafiscuole.mat'
    grafi = graphs;
    Segmentation;
    for t=clusterParameters
        clustpar=t;
        ClusteringAndConnectionManager;
        movefile(strcat(pwd,'/','Data'),strcat(pwd,'/','Data', partitionMethod, num2str(clustpar)));
    end
    toc
end