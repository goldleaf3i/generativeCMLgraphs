% Script per creare i dati per autonomous Robots
% testa una serie di combinazioni di parametri e di metodi per ogni metodo
% di clustering implementato

if exist('pool')
    delete(pool)
end
clear all

addpath(genpath('../lib'))
addpath('..') %TODO spostare gli script principali
num_parallel_cores = 4;
%clc
% G GraphHopper, W WeisfeilerLehman, N NSPDK

possible_kernels = ['G','W','N'];
clusteringMethod = 'A' %A affinity N ncut
kernelClustering = 'G';
kernelSampling = 'W';
clustpar = 0.5;
partitionMethod = 'nCut';
% salvo o non salvo i dati e pre-calcolo le matrici per il sampling
slow_stats_computation = 0;


% parametro per nCut Segmentation
subpar = 0.6;
% list of corridors
corridor_labels = [100,105,110,115];
tic

for kernelUsed = ['G','W','D'] % G GH Linear; W WL, D GH Dirac
    disp(strcat('Inizio con Kernel ', kernelUsed));
    if kernelUsed == 'G'
        disp('GH LINEAR');
        kernelClustering = 'G';
        graphHopperNodeKernel = 'linear';
    else
        if kernelUsed=='W'
            disp('WL');
            kernelClustering = 'W';
        else 
            if kernelUsed == 'D'
                disp('GH DIRAC');
                kernelClustering = 'G';
                graphHopperNodeKernel = 'dirac';
            else
                disp('ERRORE!')
            end
        end
    end
    for clusteringMethod = ['A','N']
    %for clusteringMethod = ['A','N']
        disp(strcat('inizio con metodo di clustering ' ,clusteringMethod));
        % i parametri sono diversi per i diversi metodi di clustering
        if clusteringMethod =='A'
            clusterParameters = [0.5:0.1:0.9];
        else
            if clusteringMethod =='N'
                clusterParameters = [0.9:0.05:1.15];
            end
        end
        
        for partitions={'nCut'}%{'Corr','nCut'}

            if partitions{1} == 'nCut'
                subpar = 0.6
            else
                subpar = 2
            end
            disp(strcat('Inizio con  ', partitions));
            partitionMethod=partitions{1};
            %% Load Graphs
            buildingType = 'OFF'; %SCH or OFF. For saving-data purposes.
            disp('# Loading graphs #')
            graph_path = '../dataset/School/';
            graph_name = 'graph_';
            extension = 'csv';
            num_graphs = 50;
            [ graphs, label_list ] = loadGraphs( graph_path, graph_name, extension, num_graphs);
            %CaricaCsv;

            %load 'grafiscuole.mat'
            grafi = graphs;
            Segmentation;
            for t=clusterParameters
                clustpar=t;
                ClusteringAndConnectionManager;
                movefile(strcat(pwd,'/','Data'),strcat(pwd,'/','Data','_',kernelUsed,'_', partitionMethod,'_', clusteringMethod, num2str(clustpar)));
            end

        end
    end
end
toc