%script che prende dei file csv e li carica in un cell array

if ~exist('graph_name')
    graph_name='graph_';
end
if ~exist('formato')
    formato = 'csv';
end

if ~exist('num_grafi')
    num_grafi = 31;
end
save_name = 'grafi_scuole.mat';
nome_variabile = 'grafi_ingresso';
grafi_ingresso = {};
label_list = [];
for i = 1:num_grafi
    load_file = strcat(graph_name, num2str(i), '.',num2str(formato));
    matrice = csvread(load_file);
    grafi_ingresso{i} = matrice;
    label_list = [label_list ; diag(matrice)];
    label_list = unique(label_list);
end
label_list = sort(label_list);
grafi = grafi_ingresso;
save(save_name, nome_variabile);