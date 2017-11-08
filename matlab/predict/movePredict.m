% Muove i file generati da AutonomousRobotSampling in una cartella con un
% nome significativo

%CAMBIAMI

savestring = strcat(pwd,'/','Data_',num2str(num_graphs), buildingType,num2str(ngen),partitionMethod,num2str(subpar));
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
savestring = strcat(savestring,kernelString);
% aggiungo indicazioni sul metodo usato per clustering
switch clusteringMethod
    case 'A'
        clustString ='Aff'
    case 'N'
        clustString = 'NCut'
end
savestring = strcat(savestring,clusteringMethod,num2str(clustpar));
genstring = strcat(num2str(num_graphs), buildingType,num2str(ngen),partitionMethod,num2str(subpar),kernelString,clustString);
% aggiungo indicazioni sul kernel usato per fare sampling
switch kernelSampling
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
savestring = strcat(savestring,kernelString,'_');
genstring = strcat(genstring,kernelString,'_');
% aggiungo informazioni sull'algoritmo usato per fare l'ultima fase di
% sampling
switch sampling_algo
    case 1
        samplingstring = '1.6';
    case 2
        samplingstring = '1.7';
    case 3
        samplingstring = 'NewHope';
end
switch sampling_with_labels
    case 0
        withlabelstring = 'NoL';
    case 1
        withlabelstring = 'L';
end
switch isARGMAX
    case 0
        argmaxstr = 'MCMC';
    case 1
        argmaxstr = 'ArgMax';
end
savestring = strcat(savestring,samplingstring,withlabelstring,argmaxstr,descrizione);
%genstring = strcat(genstring,samplingstring,withlabelstring,argmaxstr,descrizione);
%genstring = strcat('../../script_python/',datestr(datetime),genstring);
%mkdir(genstring);
%copyfile('./Data/GrafiFinali',strcat(genstring,'/GrafiFinali'));
%copyfile('./Data/GrafiFinaliSegmentati',strcat(genstring,'/GrafiFinaliSegmentati'));

movefile(strcat(pwd,'/','Data'),savestring);