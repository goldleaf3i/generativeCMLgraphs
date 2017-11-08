%script che prende in input l'intero grafo da esplorare e ricava i dati che
%servono per lo script che esegue esplorazione in ampiezza e riconoscimento
%dei sottografi del grafo da esplorare

%subpar: parametro di segmentation
%subpar=0.6;


%tolgo nodi dummy dal grafo di input
%% OLD CODE NINOMATTIA
%subpar=0.6;

%load_file = 'scuola2.csv';
%file_suffix = 'scuola2.mat';
%matrice_adiacenza_grafo = csvread(load_file);
%init = {matrice_adiacenza_grafo};
%[init, ~] = removeDummyNodes(init);
%grafo = init{1};



addpath(genpath('../lib'))
addpath('..') %TODO spostare gli script principali





load_file = strcat('scuola',num2str(number_graph),'.csv');
file_suffix = strcat('scuola',num2str(number_graph),'.mat');
%% Load Graphs
disp('# Loading graphs #')
[ graphs, label_list ] = loadGraphs( graph_path, graph_name, extension, num_graphs);

[graphs, dimgrafo]=removeDummyNodes(graphs);
grafo = graphs{number_graph};
grafo = {grafo};

disp('partiziono il grafo')
if exist('partitionMethod')
    if partitionMethod == 'nCut'
        disp('Uso nCut per partizionare');
        subpar
        [F_e, C_e, S, numF, ngrafi, sizemax, subgraphToNodeAssociation] = graphPartitionNCut(grafo, subpar);
    else 
        disp('Partiziono usando i corridoi');
        if ~exist('corridor_labels')
            corridor_labels = [100,105,110,115];
            disp('Uso Corridor_labels di default');
        end
        [F_e, C_e, numF, ngrafi, sizemax, subgraphToNodeAssociation] = graphPartitionCorr(grafo, subpar,corridor_labels);
    end
else 
    [F_e, C_e, S, numF, ngrafi, sizemax, subgraphToNodeAssociation] = graphPartitionNCut(grafo, subpar);
end
F_e = removeDummyNodesSubgraphs(F_e);

grafo = grafo{1};

disp('parte 1 di 5');

%1) matrice matrice_indici e matrice matrice_corrisp
%
%-matrice_indici: dimensioni 2 x N (con N che � il numero di nodi del grafo
%da esplorare), la prima riga contiene gli indici dei nodi del grafo, la
%seconda riga � inizializzata a 1 interamente e quando un nodo con indice
%tot viene visitato dallo script che esplora in ampiezza il grafo allora
%l'elemento in posizione (2, indice_elemento_che_vale_tot) viene messo a 0
%(quando la somma di tutti gli elementi della seconda riga di questa
%matrice che si riferiscono a un certo sottografo � 0, allora vuol dire che
%hai visitato tutti i nodi di quel sottografo)
%
%-matrice_corrisp: dimensioni K x 3 (con K che � il numero di sottografi),
%il primo elemento di ogni riga contiene l'indice della colonna all'interno
%di matrice_indici da cui partire a considerare per trovare gli indici dei
%nodi che appartengono al K-esimo sottografo, il secondo elemento di ogni
%riga contiene l'indice della colonna all'interno di matrice_indici a cui
%fermarsi a considerare per trovare gli indici dei nodi che appartengono
%al K-esimo sottografo (entrambe gli estremi sono inclusi), il terzo
%elemento di ogni riga contiene 1 quando tutti i nodi del sottografo sono
%stati visitati, altrimenti 0

numero_nodi = size(grafo, 1);
numero_sottografi = size(subgraphToNodeAssociation, 2);

%inizializzo la prima riga di matrice_indici a -1 e la seconda a 1
matrice_indici = zeros(1, numero_nodi);
matrice_indici = matrice_indici - 1;
tmp = zeros(1, numero_nodi);
tmp = tmp + 1;
matrice_indici = [matrice_indici; tmp];

matrice_corrisp = [];

k = 1;

for i = 1:numero_sottografi
    matrice_corrisp(i,1) = k;
    matrice_corrisp(i,3) = 0;
    curr_subgraph = subgraphToNodeAssociation{1,i};
    
    if(numero_nodi ~= length(curr_subgraph))
        error('numero di nodi del grafo diverso dal numero degli elementi del vettore binario usato per dire quali nodi del grafo appartengono al sottografo');
    end
    
    for j = 1:numero_nodi
        if(curr_subgraph(j) == 1)
           matrice_indici(1,k) = j;
           matrice_corrisp(i,2) = k;
           k = k + 1;
        end
    end
end

%controllo che tutto sia a posto, ovvero che non ci siano -1 nella prima
%riga di matrice_indici
for i = 1:size(matrice_indici,2)
    if(matrice_indici(1,i) == -1)
        error('non dovrebbe esserci nessun -1 qui')
    end
end

disp('parte 2 e 3 di 5');

%2) matrice di adiacenza matr_adiac_cut di dimensione N x N simmetrica che
%contiene tutti e soli gli archi di cut tra i sottografi

%3) cell array matr_adiac_cut_subgraph che contiene K elementi, ciascuno di
%questi elementi � un cell array che contiene 2 elementi: una matrice
%N x N simmetrica che contiene tutti e soli gli archi di cut che riguardano
%il K-esimo sottografo e una variabile check che vale 1 quando sono stati
%percorsi tutti gli archi di cut del sottografo, altrimenti 0; ogni volta
%che viene visitato un arco dallo script che esplora vedi se � un arco di
%cut dalla matrice 2), facciamo ad es che c'� un arco di cut tra il nodo 1
%e il nodo 20: tramite 1) vedi a che sottografo appartiene il nodo che ha
%indice 1, facciamo ad es che appartiene al sottografo 3, quindi in
%matr_adiac_cut_subgraph vai in posizione 3 e nella matrice di adiacenza
%contenuta nel cell array che trovi prendi gli elementi (che varranno 1
%ovviamente) in posizione 1,20 e 20,1 e li metti uguali a -1 e se tutti gli
%elementi diversi da 0 sono uguali a -1 allora metti ad 1 la variabile
%check; la stessa cosa si fa per il sottografo che contiene il nodo di
%indice 20; le matrici di adiacenza contenute in matr_adiac_cut_subgraph mi
%serviranno durante l'esecuzione dello script che esplora in ampiezza,
%perch� ogni volta che riconosco un sottografo devo controllare se �
%attaccato a qualche altro sottografo che ho gi� riconosciuto e lo faccio
%appunto usando queste matrici (poi da 4) prendo i sottografi riconosciuti
%li metto in una matrice diagonale a blocchi, li unisco tramite l'arco di
%cut che condividono e questo grafo verr� usato come base di partenza per
%il sampling del nuovo grafo)

%esploro la parte superiore della matrice di adiacenza del grafo (diagonale
%esclusa) e ogni volta che trovo un edge tra due nodi di due sottografi
%diversi lo riporto in matr_adiac_cut e nelle opportune matrici di
%adiacenza all'interno di matr_adiac_cut_subgraph

%inizializzazione matr_adiac_cut
matr_adiac_cut = zeros(numero_nodi, numero_nodi);

%inizializzazione matr_adiac_cut_subgraph
matr_adiac_cut_subgraph = {};

for i = 1:numero_sottografi
    tmp1 = zeros(numero_nodi, numero_nodi);
    tmp2 = 0;
    tmp = {tmp1 tmp2};
    matr_adiac_cut_subgraph{i} = tmp;
end

for i = 1:numero_nodi-1
    for j = i+1:numero_nodi
        if(grafo(i,j) ~= 0)
            nodo_i = i;
            nodo_j = j;
            
            %trovo l'indice di colonna a cui si trova nodo_i all'interno
            %della matrice matrice_indici
            for k = 1:size(matrice_indici,2)
                if(matrice_indici(1,k) == nodo_i)
                    indice_da_controllare_i = k;
                    break;
                end
            end
            
            %trovo l'indice di colonna a cui si trova nodo_j all'interno
            %della matrice matrice_indici
            for k = 1:size(matrice_indici,2)
                if(matrice_indici(1,k) == nodo_j)
                    indice_da_controllare_j = k;
                    break;
                end
            end
            
            %confronto indice_da_controllare_i con gli indici estremi
            %presenti in matrice_corrisp per determinare a che sottografo
            %appartiene il nodo nodo_i
            for l = 1:size(matrice_corrisp,1)
                if(indice_da_controllare_i >= matrice_corrisp(l,1) && indice_da_controllare_i <= matrice_corrisp(l,2))
                    sottografo_i = l;
                    break;
                end
            end
            
            %confronto indice_da_controllare_j con gli indici estremi
            %presenti in matrice_corrisp per determinare a che sottografo
            %appartiene il nodo nodo_j
            for l = 1:size(matrice_corrisp,1)
                if(indice_da_controllare_j >= matrice_corrisp(l,1) && indice_da_controllare_j <= matrice_corrisp(l,2))
                    sottografo_j = l;
                    break;
                end
            end
            
            if(sottografo_i ~= sottografo_j)
                matr_adiac_cut(nodo_i, nodo_j) = 1;
                matr_adiac_cut(nodo_j, nodo_i) = 1;
                
                matr_adiac_cut_subgraph{sottografo_i}{1}(nodo_i, nodo_j) = 1;
                matr_adiac_cut_subgraph{sottografo_i}{1}(nodo_j, nodo_i) = 1;
                                
                matr_adiac_cut_subgraph{sottografo_j}{1}(nodo_i, nodo_j) = 1;
                matr_adiac_cut_subgraph{sottografo_j}{1}(nodo_j, nodo_i) = 1;
            end
        end
    end
end
                
disp('parte 4 di 5');

%4) cell array sottografi che contiene K elementi, ciascuno di questi
%elementi � un cell array che contiene 2 elementi: la matrice di adiacenza
%del K-esimo sottografo e una variabile che mi dice se il sottografo � gi�
%stato riconosciuto (1) oppure no (0), questa variabile � inizializzata a 0
%per tutti i sottografi

sottografi = {};

if(size(F_e, 2) ~= numero_sottografi)
    error('numero di sottografi in F_e diverso da quello in subgraphToNodeAssociation');
end

for i = 1:size(F_e, 2)
    tmp = {F_e{1,i} 0};
    sottografi{i} = tmp;
end

disp('parte 5 di 5');

%5) matrice di celle estremi_archi_cut_coppie_sottografi triangolare
%superiore le cui righe e colonne corrispondono ai sottografi estratti dal
%grafo da esplorare, ogni elemento della matrice corrisponde quindi a una
%coppia di sottografi; in ogni elemento c'� un cell array che contiene un
%certo numero di array, uno per ogni arco di cut esistente tra la coppia
%di sottografi e questi array contengono gli indici di sottografo dei nodi
%estremi di un arco di cut che collega la coppia di sottgrafi
%corrispondente a quell'elemento della matrice; se sto considerando la
%coppia si sottografi (Si, Sj) allora il primo elemento in ciascuno degli
%array memorizzato nel cell array in posione (i,j) nella matrice di celle
%� l'indice del nodo estremo di un arco di cut che appartiene al
%sottografo Si mentre invece il secondo elemento � l'estremo contenuto nel
%sottografo Sj

%inizializzo ciascun elemento di estremi_archi_cut_coppie_sottografi con un
%cell array vuoto
estremi_archi_cut_coppie_sottografi = cell(length(sottografi), length(sottografi));
tmp = {};

for i = 1:length(sottografi)
    for j = 1:length(sottografi)
        estremi_archi_cut_coppie_sottografi{i,j} = tmp;
    end
end

for i = 1:length(sottografi)-1
    for j = i+1:length(sottografi)
        matr_adiac_cut_subgraph_i = matr_adiac_cut_subgraph{i}{1};
        matr_adiac_cut_subgraph_j = matr_adiac_cut_subgraph{j}{1};
        matrice_somma = matr_adiac_cut_subgraph_i + matr_adiac_cut_subgraph_j;
        
        %gli elementi pari a 2 in matrice_somma corrispondono a degli archi
        %di cut in comune tra due sottografi, guardo solo la parte superiore
        %perch� matrice_somma � simmetrica
        archi_cut_in_comune = {};
        
        for k = 1:size(matrice_somma,1)-1
            for l = k+1:size(matrice_somma,1)
                if(matrice_somma(k,l) == 2)
                    archi_cut_in_comune = [archi_cut_in_comune [k,l]];
                end
            end
        end
        
        %gli indici dei nodi che rappresentano gli estremi degli archi
        %in comune che ho trovato sono gli indici dei nodi nel grafo
        %originale, quindi prima di procedere mi devo ricavare gli indici
        %dei nodi dei sottografi corrispondenti agli indici dei nodi del
        %grafo originale che rappresentano gli estremi degli archi di cut
        %in comune che ho trovato
        
        %per ogni arco di cut in comune trovato
        for k = 1:length(archi_cut_in_comune)
            arco = archi_cut_in_comune{k};
            indice_nodo_grafo_primo_estremo = arco(1);
            indice_nodo_grafo_secondo_estremo = arco(2);
            
            %cerco indice_nodo_grafo_primo_estremo e
            %indice_nodo_grafo_secondo_estremo in matrice_indici e vedo a
            %che sottografo appartengono tramite matrice_corrisp
            
            %trovo l'indice di colonna a cui si trova
            %indice_nodo_grafo_primo_estremo all'interno della matrice
            %matrice_indici
            for l = 1:size(matrice_indici,2)
                if(matrice_indici(1,l) == indice_nodo_grafo_primo_estremo)
                    indice_da_controllare_primo_estremo = l;
                    break;
                end
            end
            
            %trovo l'indice di colonna a cui si trova
            %indice_nodo_grafo_secondo_estremo all'interno della matrice
            %matrice_indici
            for l = 1:size(matrice_indici,2)
                if(matrice_indici(1,l) == indice_nodo_grafo_secondo_estremo)
                    indice_da_controllare_secondo_estremo = l;
                    break;
                end
            end
            
            %confronto indice_da_controllare_primo_estremo con gli indici
            %estremi presenti in matrice_corrisp per determinare a che
            %sottografo appartiene il nodo il cui indice �
            %indice_nodo_grafo_primo_estremo
            for l = 1:size(matrice_corrisp,1)
                if(indice_da_controllare_primo_estremo >= matrice_corrisp(l,1) && indice_da_controllare_primo_estremo <= matrice_corrisp(l,2))
                    sottografo_primo_estremo = l;
                    break;
                end
            end
            
            %confronto indice_da_controllare_secondo_estremo con gli indici
            %estremi presenti in matrice_corrisp per determinare a che
            %sottografo appartiene il nodo il cui indice �
            %indice_nodo_grafo_secondo_estremo
            for l = 1:size(matrice_corrisp,1)
                if(indice_da_controllare_secondo_estremo >= matrice_corrisp(l,1) && indice_da_controllare_secondo_estremo <= matrice_corrisp(l,2))
                    sottografo_secondo_estremo = l;
                    break;
                end
            end
            
            %ricavo gli indici di sottografo corrispondenti agli indici
            %del grafo originale
            inizio_intervallo_primo_estremo = matrice_corrisp(sottografo_primo_estremo,1);
            inizio_intervallo_secondo_estremo = matrice_corrisp(sottografo_secondo_estremo,1);
            indice_nodo_sottografo_primo_estremo = indice_da_controllare_primo_estremo - inizio_intervallo_primo_estremo + 1;
            indice_nodo_sottografo_secondo_estremo = indice_da_controllare_secondo_estremo - inizio_intervallo_secondo_estremo + 1;
            
            if(sottografo_primo_estremo < sottografo_secondo_estremo)
                array = [indice_nodo_sottografo_primo_estremo indice_nodo_sottografo_secondo_estremo];
            elseif(sottografo_secondo_estremo < sottografo_primo_estremo)
                array = [indice_nodo_sottografo_secondo_estremo indice_nodo_sottografo_primo_estremo];
            end
            
            cell_array = estremi_archi_cut_coppie_sottografi{i,j};
            cell_array = [cell_array array];
            estremi_archi_cut_coppie_sottografi{i,j} = cell_array;
        end
    end
end

save(strcat('Predict/matfiles/DatiPerEsplorazioneAmpiezza-', file_suffix), 'matrice_indici', 'matrice_corrisp', 'matr_adiac_cut', 'matr_adiac_cut_subgraph', 'sottografi', 'estremi_archi_cut_coppie_sottografi');

disp('finito');