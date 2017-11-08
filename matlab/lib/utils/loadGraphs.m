function [ graphs, label_list ] = loadGraphs( graph_path, graph_name, extension, num_graphs)
%LOADGRAPHS Function to load graphs
%   Load Graphs given the input arguments
grafi_ingresso = {};
label_list = [];
for i = 1:num_graphs
    load_file = strcat(graph_path, graph_name, num2str(i), '.',num2str(extension));
    matrice = csvread(load_file);
    grafi_ingresso{i} = matrice;
    label_list = [label_list ; diag(matrice)];
    label_list = unique(label_list);
end
label_list = sort(label_list);
graphs = grafi_ingresso;

end

