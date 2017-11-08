%script che esplora un grafo in ampiezza e che riconosce i sottografi;
%quando un sottografo viene riconosciuto parte la fase di predizione
%generando il grafo samplato a partire dai sottografi riconosciuti

tic;

%% QUESTO NON DOVREBBE SERVIRE PIU
%workspace_file = 'ClustAndConnManagerWORKSPACE-GHLinear10Subpar0,6ClustAFF0,5.mat';
%load(workspace_file);

subpar_str = num2str(subpar);
clustpar_str = num2str(clustpar);

suffisso_nome_file = 'txt' ;%'metti quello che vuoi tu :)';

contatore_per_salvataggi_file = 1;

%il file che contiene i dati prodotti dallo script DatiPerEsplorazioneAmpiezza
% SOSTITUITO DA LOAD
%data_file = 'DatiPerEsplorazioneAmpiezza-scuola2.mat';
%load(data_file);

%matrice di adiacenza del grafo da esplorare

grafo=graphs(number_graph);
grafo=grafo{1};
%graph_file = strcat('scuola',num2str(number_graph),'.csv');
%file_suffix = strcat('scuola',num2str(number_graph),'.mat');
%graph_file = 'scuola2.csv';
%matrice_adiacenza_grafo = csvread(graph_file);

%tolgo nodi dummy dal grafo di input
% init = {matrice_adiacenza_grafo};
% [init, ~] = removeDummyNodes(init);
% grafo = init{1};

%indice del nodo del grafo da cui cominciare l'esplorazione
labelgraphlist=diag(grafo);
EN = ismember(labelgraphlist, entrance_labels);
EN_index = find(EN);
if sum(EN_index) > 0
    % se esiste un nodo ingresso ne scelgo uno a caso
    indice_nodo_iniziale=randsample(EN_index,1);
else
    % altrimenti prendo un nodo corridoio
    EN =ismember(labelgraphlist,corridor_labels);
    EN_index=find(EN);
    indice_nodo_iniziale=randsample(EN_index,1);
end
%indice_nodo_iniziale = 20;

%un nodo è rappresentato con un array che contiene l'indice del nodo e la
%sua profondità dal nodo iniziale; un arco invece è rappresentato con un
%array che contiene l'indice del nodo sorgente, l'indice del nodo
%destinazione e la profondità del nodo sorgente rispetto al nodo iniziale
nodo_iniziale = [indice_nodo_iniziale 0];


nodi_da_visitare = {nodo_iniziale};

% %da usare quando si usa GraphHopper come kernel in BlockedSampling
disp('DA SISTEMARE SE CE GH');
%pool = parpool('local', 4);

%finchè la somma di tutti gli elementi della seconda riga di matrice_indici
%è maggiore di 0 significa che c'è ancora qualche nodo da visitare, quando
%è pari a 0 significa che tutti i nodi sono stati visitati
while(sum(matrice_indici(2,:)) > 0)
    
    %scelgo il prossimo nodo da visitare
    [prossimo_nodo, nodi_da_visitare] = ScegliProssimoNodoDaVisitare(nodi_da_visitare);
    
    %visito il nodo scelto
    nodo = prossimo_nodo;
    [archi_da_percorrere, matrice_indici, matrice_corrisp, sottografi, sottografo_riconosciuto] = VisitaNodo(nodo, grafo, matrice_indici, matrice_corrisp, matr_adiac_cut_subgraph, sottografi);
    
    %verifico se è stato riconosciuto un nuovo sottografo guardando cosa
    %contiene la variabile sottografo_riconosciuto e se è stato
    %riconosciuto un nuovo sottografo parte lo step di predizione
    if(sottografo_riconosciuto ~= -1 && sum(matrice_indici(2,:)) > 0)
        str = sprintf('ho riconosciuto il sottografo %d \n', sottografo_riconosciuto);
        disp(str);
        str = sprintf('comincia la fase di predizione \n');
        disp(str);
        
        [grafo_esplorato, archi_cut_uscenti] = ComponiGrafoEsplorato(grafo, matrice_indici, matrice_corrisp, matr_adiac_cut_subgraph, sottografi);
        
        if badlyfixerrors 
            UNBlockedSampling;
        else 
            BlockedSampling;
        end
        
        contatore_per_salvataggi_file = contatore_per_salvataggi_file + 1;
    elseif(sottografo_riconosciuto ~= -1 && sum(matrice_indici(2,:)) == 0)
        str = sprintf('ho esplorato tutto il grafo quindi, pur avendo riconosciuto il sottografo %d, non faccio nessuna predizione \n', sottografo_riconosciuto);
        disp(str);
    end
    
    %percorro gli archi restituiti da VisitaNodo
    [nodi_da_visitare, matr_adiac_cut_subgraph, sottografi, sottografo_riconosciuto] = PercorriArchi(archi_da_percorrere, nodi_da_visitare, matrice_indici, matrice_corrisp, matr_adiac_cut, matr_adiac_cut_subgraph, sottografi);
    archi_da_percorrere = {};
    
    %verifico se è stato riconosciuto un nuovo sottografo guardando cosa
    %contiene la variabile sottografo_riconosciuto e se è stato
    %riconosciuto un nuovo sottografo parte lo step di predizione
    if(sottografo_riconosciuto ~= -1 && sum(matrice_indici(2,:)) > 0)
        str = sprintf('ho riconosciuto il sottografo %d \n', sottografo_riconosciuto);
        disp(str);
        str = sprintf('comincia la fase di predizione \n');
        disp(str);
        
        [grafo_esplorato, archi_cut_uscenti] = ComponiGrafoEsplorato(grafo, matrice_indici, matrice_corrisp, matr_adiac_cut_subgraph, sottografi);
        
        BlockedSampling;
        
        contatore_per_salvataggi_file = contatore_per_salvataggi_file + 1;
    end
    
end

% %da usare quando si usa GraphHopper come kernel in BlockedSampling
% delete(pool);
% clear pool;

disp('esplorazione finita');

%salvo il workspace
tempo_esec_esplorEprediz = toc;

save(strcat('Predict/matfiles/EsplorEPredizWORKSPACE-', suffisso_nome_file, 'Subpar0,', subpar_str(3:end),'ClustAFF0,', clustpar_str(3:end)));

% pause(30);
% 
% system('shutdown -s');
