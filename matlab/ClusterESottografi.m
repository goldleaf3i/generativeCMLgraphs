%ricava tutti i cluster e rappresenta ogni grafo come l'insieme dei
%sottografi che lo compongono suddivisi per cluster; per i cluster: trovo
%un cell array con ncluster elementi (che uso per raggruppare assieme tutti
%i cluster), ciascuno di questi elementi è a sua volta un cell array, che
%rappresenta l'i-esimo cluster e ciascuno di questi cell array contiene le
%matrici di adiacenza dei sottografi che appartengono a quel cluster; per i
%grafi: trovo un cell array con ngrafi elementi (che uso per raggruppare
%assieme tutti i grafi), ciascuno di questi elementi è a sua volta un cell
%array, che rappresenta l'i-esimo grafo e ciascuno di questi cell array
%contiene ncluster cell array, questi ultimi cell array rappresentano
%ciascuno uno degli ncluster cluster e saranno riempiti con i sottografi
%che compongono il grafo a seconda del cluster di appartenenza del
%sottografo

subparam_str = num2str(0.6);

clustparam = 1.03;
clustparam_str = num2str(clustparam);

load_clust_file = 'ClustAndConnManagerWORKSPACE-';

% suffisso_nome_file = 'Embedd';
% suffisso_nome_file = 'GHLinear';
% suffisso_nome_file = 'KashOrder5';
% suffisso_nome_file = 'MencRad2Type0';
% suffisso_nome_file = 'NSPDKDist3Rad2';
suffisso_nome_file = 'WLIter5';

load_clust_file = strcat(load_clust_file, suffisso_nome_file, 'Subpar0,', subparam_str(3:end), 'ClustPAR1,', clustparam_str(3:end));
load(load_clust_file);

% kernel_name = 'Kernel_Embedding';
% kernel_name = 'Kernel_GH_linear_1_0';
% kernel_name = 'Kernel_Kash_order=5';
% kernel_name = 'Kernel_Menc_r=2_t=all';
% kernel_name = 'Kernel_NSPDK_d=3_r=2';
kernel_name = 'Kernel_WL_iter=5';

[r_clustref, c_clustref] = size(clustref);

%ricavo i cluster
disp('ricavo i cluster');

%cell array che contiene ncluster elementi, ciascuno di questi ncluster
%elementi è un cell array che rappresenta un cluster e che contiene i
%sottografi facenti parte di quel cluster
sottografi_raggr_clust = cell(1, ncluster);

for i = 1:ncluster
    sottografi_raggr_clust{i} = {};
end

for i = 1:r_clustref
    for j = 1:c_clustref
        if(clustref(i,j) ~= 0)
            curr_clust = clustref(i,j);
            curr_subgraph = F_e{i,j};
            tmp1 = sottografi_raggr_clust{curr_clust};
            tmp2 = {curr_subgraph};
            tmp1 = [tmp1 tmp2];
            sottografi_raggr_clust{curr_clust} = tmp1;
        end
    end 
end     
            
%rappresento ogni grafo come insieme di sottografi suddivisi per cluster di
%appartenenza
disp('suddivido i sottografi di ciascun grafo in base al loro cluster');

%cell array che contiene ngrafi elementi, ciascuno di questi elementi è a
%sua volta un cell array, che rappresenta l'i-esimo grafo e ciascuno di
%questi cell array contiene ncluster cell array, questi ultimi cell array
%rappresentano ciascuno uno degli ncluster cluster e servono per
%raggruppare i sottografi che compongono il grafo a seconda del loro
%cluster di appartenenza
grafi_sudd_raggr_clust = cell(1, ngrafi);

for i = 1:ngrafi
    grafi_sudd_raggr_clust{i} = cell(1, ncluster);
    
    for j = 1:ncluster
        grafi_sudd_raggr_clust{i}{j} = {};
    end
end

for i = 1:r_clustref
    curr_graph = grafi_sudd_raggr_clust{i};
    
    for j = 1:c_clustref
        if(clustref(i,j) ~= 0)
            curr_clust = clustref(i,j);
            curr_subgraph = F_e{i,j};
            curr_graph_clust = curr_graph{curr_clust};
            tmp = {curr_subgraph};
            curr_graph_clust = [curr_graph_clust tmp];
            curr_graph{curr_clust} = curr_graph_clust;
        end
    end
    
    grafi_sudd_raggr_clust{i} = curr_graph;
end

disp('salvo i dati');
    
save(strcat('ClusterESottografiData-', suffisso_nome_file, 'Subpar0,', subpar_str(3:end), 'ClustPAR1,', clustpar_str(3:end)), 'sottografi_raggr_clust', 'grafi_sudd_raggr_clust', 'subpar', 'clustpar', 'subpar_str', 'clustpar_str');

main_directory = 'D:\Dropbox\GenerativeModelsOfGraphs\OUTPUTS\Run 28 scuole nuove\SPECT CLUST';

path = (strcat(main_directory, '\', kernel_name, '_subpar=', num2str(subpar), '_clustpar=', num2str(clustpar)));
mkdir(path);

save(strcat(path,'\ClusterESottografiData-', suffisso_nome_file, 'Subpar0,', subpar_str(3:end), 'ClustPAR1,', clustpar_str(3:end)), 'sottografi_raggr_clust', 'grafi_sudd_raggr_clust', 'subpar', 'clustpar', 'subpar_str', 'clustpar_str');
            