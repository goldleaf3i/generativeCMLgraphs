%% SCRIPT GEMELLO DI AUTONOMOUS-ROBOT-SAMPLING - LEGGE MATRICE DA FILE
%% Setup workspace
clc
clear
close all

addpath(genpath('../lib'))
addpath('..') %TODO spostare gli script principali



%% Sample Graphs
% Script per creare i dati per autonomous Robots
if exist('pool')
    delete(pool)
end
%clc

%% inizializzo i parametri per il sampling
init_sampling;

%% Load Graphs
disp('# Loading graphs #')
[ graphs, label_list ] = loadGraphs( graph_path, graph_name, extension, num_graphs);
%CaricaCsv;
% Carico i grafi comunque, mi servno delle variabili

%% LoadVariables
folder_path = '../../data/matfiles';
clusterPathFile;
loadString
load(strcat(loadString,'/','ClusteringAndConnectionManagerData.mat'));
tic
for alphaparam=[0.070:0.002:0.082]
%for alphaparam=[0.045:0.005:0.07]
%for alphaparam=[0.035:0.005:0.055]
    alphaClusterConfiguration = alphaparam;
    %% Sampling
    disp('# Starting Sampling #')
    Samplegraphs;
    descrizione = strcat('alfa=',num2str(alphaClusterConfiguration));
    %% Move files in a folder with a significative name.
    moveFiles;
end
toc