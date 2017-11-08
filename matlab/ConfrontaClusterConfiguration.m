%prende le clustering configuration dei grafi originali, le unisce a quelle
%samplate, le sorta e salva il risultato in un file csv

%estensione del file ESCLUSA
file_name_suffix = '';

%parametro che condiziona la probabilità di flipping
alpha = 1;

%iterazioni di sampling
iterations = 200;

load_file_original = strcat('G_ClustConf-', file_name_suffix, '.csv');
original_clust_conf = csvread(load_file_original);

load_file_sampled = strcat('ClustConfSampl_', 'A=', num2str(alpha), '_Iter=', num2str(iterations), '-', file_name_suffix, '.mat');
load(load_file_sampled);
sampled_clust_conf = Ugen_samples_formato_giusto;

clust_conf = [original_clust_conf; sampled_clust_conf];

%ordino clust_conf

clust_conf_sorted = [];
righe_processate = [];
clust_conf_senza_indici = clust_conf(2:end,2:end);

somme_lungo_le_righe = sum(clust_conf_senza_indici, 2);
    
%trovo l'indice della riga che ha il valore della somma dei suoi elementi
%più piccolo, poi metto nella matrice finale la riga corrispondente a
%quell'indice
[~, min_index] = min(somme_lungo_le_righe);

%per la corrispondenza con le righe della matrice con gli indici
indexed_min_index = min_index + 1;

current_row = clust_conf_senza_indici(min_index,:);
current_indexed_row = clust_conf(indexed_min_index,:);
clust_conf_sorted = [current_indexed_row; clust_conf_sorted];

righe_processate = [righe_processate min_index];
distanza = Inf;
index = 0;

num_grafi = size(clust_conf_senza_indici, 1);
num_cluster = size(clust_conf_senza_indici, 2);

while(length(righe_processate) < num_grafi)
    %trovo la distanza tra current_row e le altre righe della matrice senza
    %indici che non sono ancora state processate, trovo l'indice della riga
    %che ha distanza più piccola da current_row e metto nella matrice
    %finale la riga corrispondente
    for i = 1:size(clust_conf_senza_indici,1)
        
        if(ismember(i,righe_processate) == 0)
            tmp = current_row - clust_conf_senza_indici(i,:);
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
    
    current_row = clust_conf_senza_indici(index,:);
    current_indexed_row = clust_conf(indexed_index,:);
    clust_conf_sorted = [current_indexed_row; clust_conf_sorted];
    
    righe_processate = [righe_processate index];
    distanza = Inf;
    index = 0;    
end

clust_conf_sorted = [0:num_cluster; clust_conf_sorted];

dlmwrite(strcat('ConfrClustConf_', 'A=', num2str(alpha), '_Iter=', num2str(iterations), '-', file_name_suffix, '.csv'), clust_conf_sorted, 'delimiter', ',');
