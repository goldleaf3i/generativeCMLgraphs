%SEGMENTATION GESTISCE LA SEGMENTAZIONE DEI SOTTOGRAFI E ARRIVA FINO ALLA CREAZIONE MATRICE SIMILARITA 

%subpar: parametro di segmentation

if ~exist('subpar')
    disp('Uso subpar di default');
    subpar=0.6;
end

%grafi: li devo avere gi? importati in matlab come cella monodimensionale
%di matrici

%tolgo nodi dummy dai grafi di input
[grafi, dimgrafo]=removeDummyNodes(grafi);

disp('Partiziono i grafi')
if exist('partitionMethod')
    if partitionMethod == 'nCut'
        disp('Uso nCut per partizionare');
        [F_e, C_e, S, numF, ngrafi, sizemax, subgraphToNodeAssociation] = graphPartitionNCut(grafi, subpar);
    else 
        disp('Partiziono usando i corridoi');
        if ~exist('corridor_labels')
            corridor_labels = [100,105,110,115];
            disp('Uso Corridor_labels di default');
        end
        [F_e, C_e, numF, ngrafi, sizemax, subgraphToNodeAssociation] = graphPartitionCorr(grafi, subpar,corridor_labels);
    end
else 
    [F_e, C_e, S, numF, ngrafi, sizemax, subgraphToNodeAssociation] = graphPartitionNCut(grafi, subpar);
end
F_e = removeDummyNodesSubgraphs(F_e);

%linearizzo la matrice F_e
[Flin, graforig, postoKI] = linearizesSubgraphStructures(F_e, numF, ngrafi);

% PER STAMPA ***************************************************
%stampo i grafi originali
pathG=(strcat(pwd,'/','Data','/GrafiOriginali/'));
[~, ~, ~] = mkdir(pathG);
for k=1:length(grafi),
    dlmwrite(strcat(pathG,'grafo_',num2str(k),'.txt'),grafi{k});
end
% PER STAMPA ***************************************************

disp('Salvo i dati della fase di segmentazione')
[~, ~,~] = mkdir('Data/matFiles')
save('Data/matFiles/SegmentationData.mat','grafi','subpar','sizemax','Flin','F_e','C_e','numF','subgraphToNodeAssociation','ngrafi','graforig');
