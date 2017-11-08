%trova le distanze medie e le devstd delle distanze tra i sottografi
%appartenenti a cluster diversi

disp('inizio');

subparam_str = num2str(0.6);

clustparam = 1.03;
clustparam_str = num2str(clustparam);

load_clustEsottogr_file = 'ClusterESottografiData-';

% suffisso_nome_file = 'Embedd';
% suffisso_nome_file = 'GHLinear10';
% suffisso_nome_file = 'KashOrder5';
% suffisso_nome_file = 'MencRad2Type0';
% suffisso_nome_file = 'NSPDKDist3Rad2';
suffisso_nome_file = 'WLIter5';

load_clustEsottogr_file = strcat(load_clustEsottogr_file, suffisso_nome_file, 'Subpar0,', subparam_str(3:end), 'ClustPAR1,', clustparam_str(3:end), '.mat');
load(load_clustEsottogr_file);

file_name_suffix = strcat(suffisso_nome_file, 'Subpar0,', subpar_str(3:end), 'ClustPAR1,', clustpar_str(3:end), '.csv');

main_directory = 'D:\Dropbox\GenerativeModelsOfGraphs\OUTPUTS\Run 28 scuole nuove\SPECT CLUST';

% kernel_name = 'Kernel_Embedding';
% kernel_name = 'Kernel_GH_linear_1_0';
% kernel_name = 'Kernel_Kash_order=5';
% kernel_name = 'Kernel_Menc_r=2_t=all';
% kernel_name = 'Kernel_NSPDK_d=3_r=2';
kernel_name = 'Kernel_WL_iter=5';

pathmain = (strcat(main_directory, '\', kernel_name, '_subpar=', num2str(subpar), '_clustpar=', num2str(clustpar), '\Inter cluster'));
mkdir(pathmain);

num_cluster = length(sottografi_raggr_clust);

%inizializzo a -1 la matrice delle distanze medie inter-cluster e
%la matrice delle devstd delle distazne inter-cluster
dist_medie_inter = zeros(num_cluster,num_cluster);
dist_medie_inter = dist_medie_inter - 1;
devstd_inter = zeros(num_cluster,num_cluster);
devstd_inter = devstd_inter - 1;

cont = 1;
iterazioni = ((num_cluster-1)*num_cluster)/2;

for i = 1:num_cluster-1
    for j = i+1:num_cluster
        str = sprintf('iterazione %d di %d', cont, iterazioni);
        disp(str);
        cont = cont + 1;
        
        clust1 = sottografi_raggr_clust{i};
        clust2 = sottografi_raggr_clust{j};
        len1 = length(clust1);
        len2 = length(clust2);
        cluster = [clust1 clust2];
        
%         %da usare quando si usa GraphHopper come kernel
%         cluster_conv = ConvertiPerGraphHopper(cluster);
        
        similarity_matrix = createWeisfeilerLehmanKernelMatrix(cluster, 5, 1);
        
%         %da usare quando si usa GraphHopper come kernel
%         similarity_matrix = normalize_kernel(similarity_matrix);
        
        distance_matrix = similarity_matrix - 1;
        distance_matrix = distance_matrix * -1;
        
        %seleziono solamente le distanze tra sottografi appartenenti a
        %cluster diversi
        distance_matrix_inter = distance_matrix(1:len1,len1+1:end);
        
        distance_matrix_inter_lin = [];
        
        for k = 1:len1
            tmp = distance_matrix_inter(k,:);
            distance_matrix_inter_lin = [distance_matrix_inter_lin tmp];            
        end
        
        somma = sum(distance_matrix_inter_lin);
        
        dist_media = somma/(len1*len2);
        devstd = sqrt(var(distance_matrix_inter_lin));
        
        dist_medie_inter(i,j) = dist_media;
        dist_medie_inter(j,i) = dist_media;
        
        devstd_inter(i,j) = devstd;
        devstd_inter(j,i) = devstd;       
    end
end

indici_righe = 0:num_cluster;
indici_righe = indici_righe.';
indici_colonne = 1:num_cluster;

dist_medie_inter = [indici_colonne; dist_medie_inter];
dist_medie_inter = [indici_righe dist_medie_inter];

devstd_inter = [indici_colonne; devstd_inter];
devstd_inter = [indici_righe devstd_inter];

dlmwrite(strcat(pathmain, '\', 'DistMedieInterCluster-', file_name_suffix),dist_medie_inter,'delimiter',',','precision','%.6f');

dlmwrite(strcat(pathmain, '\', 'VarDistInterCluster-', file_name_suffix),devstd_inter,'delimiter',',','precision','%.6f');

disp('finito');