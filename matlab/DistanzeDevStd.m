%per ogni cluster ricava la distanza media e la deviazione standard delle
%distanze dei sottografi che contiene; trova la distanza media e la
%deviazione standard delle distanze all'interno dei cluster generali
%(ovvero i cluster che contengono tutti i sottografi a prescindere dal
%grafo di appartenenza) e la distanza media e le deviazione standard delle
%distanze tra i sottografi di uno stesso grafo che appartengono allo stesso
%cluster

disp('inizio');

load_file = 'ClusterESottografiData-WLIter5Subpar0,5ClustAFFINITY0,9.mat';
load(load_file);

file_name = 'DistanzeDS-WLIter5Subpar0,5ClustAFFINITY0,9.log';
file_name_suffix = 'WLIter5Subpar0,5ClustAFFINITY0,9.csv';

fileID = fopen(file_name,'w');

%distanza media e deviazione standard delle distanze all'interno dei
%cluster generali

fprintf(fileID,'§§§§§§§§§§§§§§§ VERSIONE A PAROLE §§§§§§§§§§§§§§§\n\nDistanze medie e deviazioni standard delle distanze dei sottografi nei cluster generali:\n\n');

num_cluster = length(sottografi_raggr_clust);

configurazione_cluster = [];

%quando in questi due array compare il valore -1000 significa che la distanza
%media e la deviazione standard delle distanze non sono state calcolate
%perchè nel cluster c'è solo un sottografo e quindi non si può calcolare
%nessuna distanza e quindi nemmeno la media e la deviazione standard
distanze_medie = [];
devstd_distanze = [];

for i = 1:num_cluster
    cluster = sottografi_raggr_clust{i};
    
    if(length(cluster) < 2)
        fprintf(fileID,'Il numero di sottografi del cluster %d è pari a %d quindi non calcolo la distanza media e la deviazione standard delle distanze per questo cluster\n\n',i,length(cluster));
        configurazione_cluster = [configurazione_cluster length(cluster)];
        distanze_medie = [distanze_medie -1000];
        devstd_distanze = [devstd_distanze -1000];
    else
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
        
        %media distanze
        r = size(distance_matrix,1);
        n = (r.^2) - r;
        somma = sum(sum(distance_matrix));
        media = somma/n;
        
        %deviazione standard distanze
        distance_list = [];
        [r, c] = size(distance_matrix);
        
        for row = 1:r-1
            for col = row+1:c
                distance_list = [distance_list distance_matrix(row,col)];
            end
        end
        
        devstd = sqrt(var(distance_list));        
        
        configurazione_cluster = [configurazione_cluster length(cluster)];
        distanze_medie = [distanze_medie media];
        devstd_distanze = [devstd_distanze devstd];
        
        fprintf(fileID,'Il numero di sottografi del cluster %d è pari a %d, la loro distanza media è %f e la deviazione standard delle loro distanze è %f\n\n',i,length(cluster),media,devstd);
    end
end
    
fprintf(fileID,'-----------------------------------------------------------------------------------------\n\n');

disp('finito prima parte della versione a parole');

%distanza media e deviazione standard delle distanze tra i sottografi di
%uno stesso grafo che appartengono allo stesso cluster

fprintf(fileID,'Distanze medie e deviazioni standard delle distanze tra i sottografi di uno stesso grafo che appartengono allo stesso cluster:\n\n');

num_grafi = length(grafi_sudd_raggr_clust);

configurazione_cluster_G = zeros(num_grafi,num_cluster);

%quando in queste due matrici compare il valore -1000 significa che la
%distanza media e la deviazione standard delle distanze non sono state
%calcolate perchè nel grafo ci sono 0 oppure 1 sottografi che appartengono
%al cluster e quindi non si può calcolare nessuna distanza e quindi nemmeno
%la media e la deviazione standard, le matrici sono inizializzate a -1000
distanze_medie_G = zeros(num_grafi,num_cluster);
distanze_medie_G = distanze_medie_G - 1000;
devstd_distanze_G = zeros(num_grafi,num_cluster);
devstd_distanze_G = devstd_distanze_G - 1000;

for i = 1:num_grafi
    fprintf(fileID,'GRAFO %d:\n\n',i);
    grafo = grafi_sudd_raggr_clust{i};
    
    for j = 1:length(grafo)
        cluster = grafo{j};
        
        if(isempty(cluster) == 0)        
            if(length(cluster) < 2)
                fprintf(fileID,'Il numero di sottografi appartenenti al cluster %d è pari a %d quindi non calcolo la distanza media e la deviazione standard delle distanze per questo cluster\n\n',j,length(cluster));
                configurazione_cluster_G(i,j) = length(cluster);
            else
%               %da usare quando si usa GraphHopper come kernel
%               cluster_conv = ConvertiPerGraphHopper(cluster);
                
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
                
                %media distanze
                r = size(distance_matrix,1);
                n = (r.^2) - r;
                somma = sum(sum(distance_matrix));
                media = somma/n;
                
                %deviazione standard distanze
                distance_list = [];
                [r, c] = size(distance_matrix);
                
                for row = 1:r-1
                    for col = row+1:c
                        distance_list = [distance_list distance_matrix(row,col)];
                    end
                end
                
                devstd = sqrt(var(distance_list));
                
                configurazione_cluster_G(i,j) = length(cluster);
                distanze_medie_G(i,j) = media;
                devstd_distanze_G(i,j) = devstd;
                
                fprintf(fileID,'Il numero di sottografi appartenenti al cluster %d è pari a %d, la loro distanza media è %f e la deviazione standard delle loro distanze è %f\n',j,length(cluster),media,devstd);
                fprintf(fileID,'La distanza media dei sottografi del cluster %d è pari a %f e la deviazione standard delle loro distanze è pari a %f\n\n',j,distanze_medie(j),devstd_distanze(j));
            end
        end
    end
end

disp('finito versione a parole');

fprintf(fileID,'§§§§§§§§§§§§§§§ VERSIONE COMPATTA §§§§§§§§§§§§§§§\n\n(Se un valore di media o deviazione standard delle distanze è pari a -1000 significa che per il cluster in considerazione non è possibile calcolare media e deviazione standard delle distanze perchè contiene solo 1 sottografo oppure nessuno)\n\nNumero di sottografi contenuti da ciascun cluster:\n\n');
fclose(fileID);

configurazione_cluster = [1:num_cluster; configurazione_cluster];
distanze_medie = [1:num_cluster; distanze_medie];
devstd_distanze = [1:num_cluster; devstd_distanze];

dlmwrite(file_name,configurazione_cluster,'-append','delimiter','\t');

fileID = fopen(file_name,'a');
fprintf(fileID,'\nDistanze medie dei sottografi di ciascun cluster:\n\n');
fclose(fileID);

dlmwrite(file_name,distanze_medie,'-append','delimiter','\t','precision','%.4f');

fileID = fopen(file_name,'a');
fprintf(fileID,'\nDeviazioni standard delle distanze dei sottografi di ciascun cluster:\n\n');
fclose(fileID);

dlmwrite(file_name,devstd_distanze,'-append','delimiter','\t','precision','%.4f');

indici_righe = 0:num_grafi;
indici_righe = indici_righe.';

configurazione_cluster_G = [1:num_cluster; configurazione_cluster_G];
configurazione_cluster_G = [indici_righe configurazione_cluster_G];

distanze_medie_G = [1:num_cluster; distanze_medie_G];
distanze_medie_G = [indici_righe distanze_medie_G];

devstd_distanze_G = [1:num_cluster; devstd_distanze_G];
devstd_distanze_G = [indici_righe devstd_distanze_G];

fileID = fopen(file_name,'a');
fprintf(fileID,'\n-----------------------------------------------------------------------------------------');
fprintf(fileID,'\n\nCluster configuration di ciascun grafo (ogni riga corrisponde a un grafo e ogni colonna a un cluster):\n\n');
fclose(fileID);

dlmwrite(file_name,configurazione_cluster_G,'-append','delimiter','\t');

fileID = fopen(file_name,'a');
fprintf(fileID,'\nDistanze medie dei sottografi di ciascun grafo raggruppati a seconda del loro cluster di appartenenza (ogni riga corrisponde a un grafo e ogni colonna a un cluster):\n\n');
fclose(fileID);

dlmwrite(file_name,distanze_medie_G,'-append','delimiter','\t','precision','%.4f');

fileID = fopen(file_name,'a');
fprintf(fileID,'\nDeviazioni standard delle distanze dei sottografi di ciascun grafo raggruppati a seconda del loro cluster di appartenenza (ogni riga corrisponde a un grafo e ogni colonna a un cluster):\n\n');
fclose(fileID);

dlmwrite(file_name,devstd_distanze_G,'-append','delimiter','\t','precision','%.4f');

disp('finito versione compatta');

%stampo i dati della versione compatta anche in 6 file csv separati, un
%file per ciascun vettore/matrice

dlmwrite(strcat('C_ClustConfDS-', file_name_suffix),configurazione_cluster,'delimiter',',');

dlmwrite(strcat('C_DistMedieClustDS-', file_name_suffix),distanze_medie,'delimiter',',','precision','%.6f');

dlmwrite(strcat('C_DevStdDistClustDS-', file_name_suffix),devstd_distanze,'delimiter',',','precision','%.6f');

dlmwrite(strcat('G_ClustConfDS-', file_name_suffix),configurazione_cluster_G,'delimiter',',');

dlmwrite(strcat('G_DistMedieClustDS-', file_name_suffix),distanze_medie_G,'delimiter',',','precision','%.6f');

dlmwrite(strcat('G_DevStdDistClustDS-', file_name_suffix),devstd_distanze_G,'delimiter',',','precision','%.6f');

disp('finiti i csv');

%ordino le righe delle 3 matrici "G_..." e salvo le matrici ordinate in
%altri 3 file csv, mi servono per fare le heatmap sortate

%ordino configurazione_cluster_G

configurazione_cluster_G_sorted = [];
righe_processate = [];
configurazione_cluster_G_senza_indici = configurazione_cluster_G(2:end,2:end);

somme_lungo_le_righe = sum(configurazione_cluster_G_senza_indici, 2);
    
%trovo l'indice della riga che ha il valore della somma dei suoi elementi
%più piccolo, poi metto nella matrice finale la riga corrispondente a
%quell'indice
[~, min_index] = min(somme_lungo_le_righe);

%per la corrispondenza con le righe della matrice con gli indici
indexed_min_index = min_index + 1;

current_row = configurazione_cluster_G_senza_indici(min_index,:);
current_indexed_row = configurazione_cluster_G(indexed_min_index,:);
configurazione_cluster_G_sorted = [current_indexed_row; configurazione_cluster_G_sorted];

righe_processate = [righe_processate min_index];
distanza = Inf;
index = 0;

while(length(righe_processate) < num_grafi)
    %trovo la distanza tra current_row e le altre righe della matrice senza
    %indici che non sono ancora state processate, trovo l'indice della riga
    %che ha distanza più piccola da current_row e metto nella matrice
    %finale la riga corrispondente
    for i = 1:size(configurazione_cluster_G_senza_indici,1)
        
        if(ismember(i,righe_processate) == 0)
            tmp = current_row - configurazione_cluster_G_senza_indici(i,:);
            tmp = tmp.^2;
            tmp = sum(tmp);
            tmp = sqrt(tmp);
            
            if(tmp < distanza)
                distanza = tmp;
                index = i;
            end            
        end
    end
    
    %per la corrispondenza con le righe della matrice con gli indici
    indexed_index = index + 1;
    
    current_row = configurazione_cluster_G_senza_indici(index,:);
    current_indexed_row = configurazione_cluster_G(indexed_index,:);
    configurazione_cluster_G_sorted = [current_indexed_row; configurazione_cluster_G_sorted];
    
    righe_processate = [righe_processate index];
    distanza = Inf;
    index = 0;    
end

configurazione_cluster_G_sorted = [0:num_cluster; configurazione_cluster_G_sorted];

dlmwrite(strcat('G_ZSRT_ClustConfDS-', file_name_suffix),configurazione_cluster_G_sorted,'delimiter',',');

%ordino distanze_medie_G

distanze_medie_G_sorted = [];
righe_processate = [];
distanze_medie_G_senza_indici = distanze_medie_G(2:end,2:end);

somme_lungo_le_righe = sum(distanze_medie_G_senza_indici, 2);
    
%trovo l'indice della riga che ha il valore della somma dei suoi elementi
%più piccolo, poi metto nella matrice finale la riga corrispondente a
%quell'indice
[~, min_index] = min(somme_lungo_le_righe);

%per la corrispondenza con le righe della matrice con gli indici
indexed_min_index = min_index + 1;

current_row = distanze_medie_G_senza_indici(min_index,:);
current_indexed_row = distanze_medie_G(indexed_min_index,:);
distanze_medie_G_sorted = [current_indexed_row; distanze_medie_G_sorted];

righe_processate = [righe_processate min_index];
distanza = Inf;
index = 0;

while(length(righe_processate) < num_grafi)
    %trovo la distanza tra current_row e le altre righe della matrice senza
    %indici che non sono ancora state processate, trovo l'indice della riga
    %che ha distanza più piccola da current_row e metto nella matrice
    %finale la riga corrispondente
    for i = 1:size(distanze_medie_G_senza_indici,1)
        
        if(ismember(i,righe_processate) == 0)
            tmp = current_row - distanze_medie_G_senza_indici(i,:);
            tmp = tmp.^2;
            tmp = sum(tmp);
            tmp = sqrt(tmp);
            
            if(tmp < distanza)
                distanza = tmp;
                index = i;
            end            
        end
    end
    
    %per la corrispondenza con le righe della matrice con gli indici
    indexed_index = index + 1;
    
    current_row = distanze_medie_G_senza_indici(index,:);
    current_indexed_row = distanze_medie_G(indexed_index,:);
    distanze_medie_G_sorted = [current_indexed_row; distanze_medie_G_sorted];
    
    righe_processate = [righe_processate index];
    distanza = Inf;
    index = 0;    
end

distanze_medie_G_sorted = [0:num_cluster; distanze_medie_G_sorted];

dlmwrite(strcat('G_ZSRT_DistMedieClustDS-', file_name_suffix),distanze_medie_G_sorted,'delimiter',',','precision','%.6f');

%ordino devstd_distanze_G

devstd_distanze_G_sorted = [];
righe_processate = [];
devstd_distanze_G_senza_indici = devstd_distanze_G(2:end,2:end);

somme_lungo_le_righe = sum(devstd_distanze_G_senza_indici, 2);
    
%trovo l'indice della riga che ha il valore della somma dei suoi elementi
%più piccolo, poi metto nella matrice finale la riga corrispondente a
%quell'indice
[~, min_index] = min(somme_lungo_le_righe);

%per la corrispondenza con le righe della matrice con gli indici
indexed_min_index = min_index + 1;

current_row = devstd_distanze_G_senza_indici(min_index,:);
current_indexed_row = devstd_distanze_G(indexed_min_index,:);
devstd_distanze_G_sorted = [current_indexed_row; devstd_distanze_G_sorted];

righe_processate = [righe_processate min_index];
distanza = Inf;
index = 0;

while(length(righe_processate) < num_grafi)
    %trovo la distanza tra current_row e le altre righe della matrice senza
    %indici che non sono ancora state processate, trovo l'indice della riga
    %che ha distanza più piccola da current_row e metto nella matrice
    %finale la riga corrispondente
    for i = 1:size(devstd_distanze_G_senza_indici,1)
        
        if(ismember(i,righe_processate) == 0)
            tmp = current_row - devstd_distanze_G_senza_indici(i,:);
            tmp = tmp.^2;
            tmp = sum(tmp);
            tmp = sqrt(tmp);
            
            if(tmp < distanza)
                distanza = tmp;
                index = i;
            end            
        end
    end
    
    %per la corrispondenza con le righe della matrice con gli indici
    indexed_index = index + 1;
    
    current_row = devstd_distanze_G_senza_indici(index,:);
    current_indexed_row = devstd_distanze_G(indexed_index,:);
    devstd_distanze_G_sorted = [current_indexed_row; devstd_distanze_G_sorted];
    
    righe_processate = [righe_processate index];
    distanza = Inf;
    index = 0;    
end

devstd_distanze_G_sorted = [0:num_cluster; devstd_distanze_G_sorted];

dlmwrite(strcat('G_ZSRT_DevStdDistClustDS-', file_name_suffix),devstd_distanze_G_sorted,'delimiter',',','precision','%.6f');

disp('finito');
