%trova le distanze medie e le deviazioni standard delle distanze tra i
%sottografi appartenenti a cluster diversi

disp('inizio');

load_file = 'ClusterESottografiData-WLIter5Subpar0,5ClustAFFINITY0,9.mat';
load(load_file);

file_name_suffix = 'WLIter5Subpar0,5ClustAFFINITY0,9.csv';

num_cluster = length(sottografi_raggr_clust);

%inizializzo a -1000 la matrice delle distanze medie inter-cluster e
%la matrice delle deviazioni standard delle distanze inter-cluster
dist_medie_inter = zeros(num_cluster,num_cluster);
dist_medie_inter = dist_medie_inter - 1000;
devstd_inter = zeros(num_cluster,num_cluster);
devstd_inter = devstd_inter - 1000;

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
        
%       %da usare quando si usa GraphHopper come kernel
%       cluster_conv = ConvertiPerGraphHopper(cluster);
        
        similarity_matrix_NOT_norm = createWeisfeilerLehmanKernelMatrix(cluster, 5, 0);
        
        %calcolo la matrice delle DISTANZE EUCLIDEE partendo dalla matrice
        %di similarità NON normalizzata
        distance_matrix = [];
        rows = size(similarity_matrix_NOT_norm,1);
        cols = size(similarity_matrix_NOT_norm,2);
        
        for rw = 1:rows
            for cl = 1:cols
                distance_matrix(rw,cl) = sqrt((similarity_matrix_NOT_norm(rw,rw) - (2 * similarity_matrix_NOT_norm(rw,cl)) + similarity_matrix_NOT_norm(cl,cl)));
            end
        end
        
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

dlmwrite(strcat('DistMedieInterClusterDS-', file_name_suffix),dist_medie_inter,'delimiter',',','precision','%.6f');

dlmwrite(strcat('DevStdDistInterClusterDS-', file_name_suffix),devstd_inter,'delimiter',',','precision','%.6f');

disp('finito');