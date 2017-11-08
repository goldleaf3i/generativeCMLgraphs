function [] = ClusterConfigurationSamplingFunctionVersion( suffix )
%funzione per samplare le cluster configuration dei grafi

file_name_suffix = suffix;

load_file = strcat('ClustAndConnManagerWORKSPACE-', file_name_suffix);
load(load_file);

%numero di cluster configuration da samplare
n_samples = 10;

%parametro che condiziona la probabilità di flipping
alpha = 4;

%iterazioni di sampling
iterations = 200;

%matrice che uso per storare i risultati prodotti dagli n_samples run della
%funzione di sampling delle clustering configuration dei grafi
Ugen_samples = [];

for i = 1:n_samples
    str = sprintf('ITERAZIONE %d DI %d', i, n_samples);
    disp(str);
    Ugen = clusterConfigurationGibbsSampler(U, alpha, iterations);
    Ugen_samples = [Ugen_samples; Ugen];
end

%uso le info contenute nella variabile poscluster per trasformare la
%matrice Ugen_samples in una matrice con ncluster colonne, come le matrici
%G_ClustConf-... appunto

str = sprintf('converto le %d clustering configuration samplate nel formato che mi serve', n_samples);
disp(str);

%usando l'array poscluster mi ricavo un array che per ogni cluster mi dice
%il numero di colonne della matrice Ugen_samples da considerare
l = length(poscluster);
cols_Ugen_samples = size(Ugen_samples,2);
columns_for_each_cluster_inside_Ugen = [];

for i = 1:l
    if(i < l)
        columns_for_each_cluster_inside_Ugen(i) = poscluster(i+1) - poscluster(i);
    else
        columns_for_each_cluster_inside_Ugen(i) = (cols_Ugen_samples - poscluster(i)) + 1;
    end
end

Ugen_samples_formato_giusto = [];
tmp = [];
rows_Ugen_samples = n_samples;
l_C = length(columns_for_each_cluster_inside_Ugen);

for i = 1:rows_Ugen_samples
    start = 1;
    for j = 1:l_C
        n_col = columns_for_each_cluster_inside_Ugen(j);
        tmp(j) = sum(Ugen_samples(i,start:((start + n_col) - 1)));
        start = start + n_col;
    end
    
    Ugen_samples_formato_giusto = [Ugen_samples_formato_giusto; tmp];
    tmp = [];
end

%aggiungo gli indici di riga alla matrice Ugen_samples_formato_giusto
index = ((ngrafi+1):(ngrafi+n_samples));
index = index.';
Ugen_samples_formato_giusto = [index Ugen_samples_formato_giusto];

%salvo i risultati
save_file = strcat('ClustConfSampl_', 'A=', num2str(alpha), '_Iter=', num2str(iterations), '-', file_name_suffix);
save(save_file, 'Ugen_samples_formato_giusto');

end

