%% QUESTO METODO SALVA GRAFO PER GRAFO I RISULTATI DEL CLUSTERING
mkdir(strcat(pwd,'/Data/Cluster'));

%% fase1: salvo per ogni sottografo il cluster
[clusternumber,numsubgraph] =size(riferimenti); 
clusterif =zeros(numsubgraph,1);
for i=1:numsubgraph 
    clusterif(i)=find(riferimenti(:,i));
end
% clusterif, lungo come il numero dei sottografi, indica per ogni
% sottografo il cluster di appartenenza
clusterif=clusterif';

% clustering_results contiene per ogni sottografo il cluster di
% riferimento, con formato: (sottografo cluster)\n
fileID = fopen(strcat(pwd,'/Data/Cluster/clusteringresult.txt'),'w');
savecls=[1:numsubgraph;clusterif];
fprintf(fileID,'%d %d\n',savecls);
fclose(fileID);

%% fase2: salvo per ogni nodo il sottografo
% graphsubgrapg contiene all'i-esima riga l'elenco dei sottografi che
% appartengono al grafo.
fileID = fopen(strcat(pwd,'/Data/Cluster/graphsubgraphs.txt'),'w');
for i=1:num_graphs
    % indice dei sottografi presenti nel grafo i-esimo
    subgraphlist = subgraphIds{i};
    fprintf(fileID,'%d ',subgraphlist);
    fprintf(fileID,'\n');
    nodesubgraph = zeros(1,size(subgraphToNodeAssociation{i,1},2));
    for j=1:size(subgraphlist,2)
        % indice nodo per nodo di a che sottografo appartengono
        nodesubgraph(subgraphToNodeAssociation{i,j})= subgraphlist(j);
    end
    % graph_cluster_X contiene per ogni nodo a che sottografo appartiene
    fileGRAPH= fopen(strcat(pwd,'/Data/Cluster/graphcluster_',num2str(i),'.txt'),'w');
    fprintf(fileGRAPH,'%d %d\n',[1:size(subgraphToNodeAssociation{i,1},2);nodesubgraph]);
    fclose(fileGRAPH);
end

fclose(fileID);
