%% SCRIPT PER FARE I TEST DI PREDICTION
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
init_predict;


% Carico i grafi comunque, mi servno delle variabili
predictionerrors = [];
segmentation_errors = [];
mkdir(strcat(pwd,'/Data'));
errori = {};
iterazioni = 0;

if predict_range ~= 0
    list_graph = predict_range;
else
    list_graph = 1:ngen;
	if predictall == 0
		if predict_select == 0
			cont=randsample(1:ngen,1);
		else 
			cont = predict_select
		end
		list_graph = [cont]
	end
end

for cont=list_graph
    
    clearvars -except ngen cont list_graph predictionerrors segmentation_errors errori iterazioni
    
    
    %% reinizializzo i parametri per il sampling - ho cancellato tutto 
    init_predict;

    
    %% Load Graphs
    disp('# Loading graphs #')
    [ graphs, label_list ] = loadGraphs( graph_path, graph_name, extension, num_graphs);

	try

		%% Put everything into a folder
		mkdir(strcat(pwd,'/Predict'));
		mkdir(strcat(pwd,'/Predict/matfiles'));

		%% Sampling-1
		disp('# Starting Prediction - fase 1 - loading #');
        disp(strcat('Starting predictin graph : ', num2str(cont)));
		number_graph = cont;
        aretheresegerrors = 0;
        try
            DataForBF_Exploration;
        catch ME
            ME
            segmentation_errors = [segmentation_erros,cont];
            aretheresegerrors = 1;
            
			sound(randn(4096, 1), 8192)
        end

		%% LoadVariables
		if ~aretheresegerrors
			folder_path = '../../data/matfiles';
			clusterPathFilePREDICT;
			loadString
			load(strcat(loadString,'/','ClusteringAndConnectionManagerData.mat'));

			%% Sampling2
			disp('# Starting Prediction - fase 2 - predict #')
			ExplorationBF_Prediction;
			% move all into a folder for each graph
			mkdir(strcat(pwd,'/Graph-',num2str(cont)));
			movefile(strcat(pwd,'/','Predict'),strcat(pwd,'/Graph-',num2str(cont)));

			movefile(strcat(pwd,'/Graph-',num2str(cont)),strcat(pwd,'/Data'));
		end


	catch ME
		ME
		disp(strcat('Cannot predict graph ', num2str(cont)));
		predictionerrors=[predictionerrors,cont];
        errori{cont} = ME;
        disp('Saving results');
        iterazioni
    	mkdir(strcat(pwd,'/Graph-',num2str(cont)));
		movefile(strcat(pwd,'/','Predict'),strcat(pwd,'/Graph-',num2str(cont)));

		movefile(strcat(pwd,'/Graph-',num2str(cont)),strcat(pwd,'/Data'));
        try
            sound(randn(4096, 1), 8192/8)
        catch sounderr
        end

	end
end

%% Move files in a folder with a significative name.
% if predictall = 0 data should be already moved
save('Data/errori.mat','errori','predictionerrors');
movePredict;
predictionerrors
errori
segmentation_errors
