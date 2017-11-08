%% EX AUTONOMOUS-ROBOTS-SAMPLING
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

% inizializzo i parametri per il sampling
init_sampling;

tic
%% Load Graphs
disp('# Loading graphs #')
[ graphs, label_list ] = loadGraphs( graph_path, graph_name, extension, num_graphs);
%CaricaCsv;

%% Clustering
grafi = graphs;
disp('# Starting segmentation #')
Segmentation;
disp('# Starting Clustering #')
ClusteringAndConnectionManager;
toc

%% Sampling
disp('# Starting Sampling #')
Samplegraphs;

%% Move files in a folder with a significative name.
moveFiles;