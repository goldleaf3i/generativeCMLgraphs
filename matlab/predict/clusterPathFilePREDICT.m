%% restituisce la cartella da cui caricare i valori del clustering
%% SIMILE A CLUSTERPATHFILE per fare sampling

loadString = strcat(folder_path,'/','Data_',num2str(num_graphs), buildingType, partitionMethod,num2str(subpar));
% aggiungo indicazioni sul kernel usato per fare clustering
% possible_kernels = ['G','W','N','S','M'];
switch kernelClustering
    case 'G'
        kernelString = 'GH';
        if exist ('graphHopperNodeKernel')
            kernelString = strcat(kernelString,graphHopperNodeKernel);
        end
    case 'W'
        kernelString = 'WL';
    case 'N'
        kernelString = 'NSPDK';
    case 'S'
        kernelString = 'SHORTPATH';
    case 'M'
        kernelString = 'MENCHWD';
end
loadString = strcat(loadString,kernelString);
% aggiungo indicazioni sul metodo usato per clustering
switch clusteringMethod
    case 'A'
        clustString ='Aff';
    case 'N'
        clustString = 'NCut';
end
loadString = strcat(loadString,clusteringMethod,num2str(clustpar));