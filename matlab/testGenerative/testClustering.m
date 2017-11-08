% Script per creare i una configurazione di clustering utilizzando alcune parametri per il clustering di fila.
if exist('pool')
    delete(pool)
end
clear all

num_parallel_cores = 4;
%clc
% G GraphHopper, W WeisfeilerLehman, N NSPDK
possible_kernels = ['G','W','N'];
clusteringMethod = 'N' %A affinity N ncut
kernelClustering = 'W';
kernelSampling = 'W';
clusterParameters = [0.5,0.7];
clustpar = 0.5;
partitionMethod = 'nCut';

% parametro per nCut Segmentation
subpar = 0.6;
% list of corridors
corridor_labels = [100,105,110,115];
% salvo o non salvo i dati e pre-calcolo le matrici per il sampling
slow_stats_computation = 0;

tic;
CaricaCsv;
%load 'grafiscuole.mat'
grafi = grafi_ingresso;
Segmentation;
for t=clusterParameters
    clustpar=t;
    ClusteringAndConnectionManager;
    movefile(strcat(pwd,'/','Data'),strcat(pwd,'/','Data',num2str(clustpar),'_',num2str(num_grafi)));
end
toc