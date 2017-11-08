function [ F_e, C_e, n, numF, nodes ] = subgraphsCorr( grafo, par, corridor_labels, withPlot )
    G = graph(grafo - diag([diag(grafo)]),'OmitSelfLoops');
    mincutthreshold = par;
    % trovo le label
    L = diag(grafo)';
    % trovo l'indice delle label che sono corridoi
    % 100 Corridoi, 105 Hall 110 Lobby 115 OpenSpace
    %corridor_labels = [100,105,110,115];
    C = ismember(L, corridor_labels);
    C_index = find(C);
    % creo la struttura dati
    % MATCH indica a chi associo ogni nodo. Se non � associato � -1;
    match = zeros(size(L)) - 1;
    distance_corridor = zeros(size(L)) + 1000;
    deg = degree(G);

    %rimuovo dalla lista dei corridoi quelli che sono connessi solo a corridoi
    for i=C_index
        neigh_tmp = neighbors(G,i);
        neigh_labels = L(neigh_tmp);
        neigh_corr = sum(ismember(neigh_labels,corridor_labels));
        if deg(i) - neigh_corr <= mincutthreshold
            C(i) = 0;
        end
    end
    % Nodi da considerae come corridoio
    C_index = find(C);
    % Nodi da non considerare come corridoio
    notC_index = find(C~=1);
    % Associo i corridoi a loro stessi
    match(C_index) = C_index;
    % Trovo per ciascun elemento il corridoio pi� vicino
    num_closest_C = zeros(size(L)) - 1;
    for i = notC_index
        for j = C_index 
            [path,d] = shortestpath(G,i,j);
            if d < distance_corridor(i)
                num_closest_C(i) = 1;
                distance_corridor(i) = d;
                candidate = j;
            else
                % pi� di un corridoio alla stessa distanza - devo assegnare in
                % maniera diversa.
                if d == distance_corridor(i)
                    num_closest_C(i) = num_closest_C(i)+1;
                end
            end
        end
        % se esiste un solo corridoio a distanza minima lo associo al nodo
        if num_closest_C(i) == 1
            match(i) = candidate;
        end
    end

    % poi associo i nodi equidistanti da due corridoi al corridoio con degree
    % minore

    % trovo l'ordine dei corridoi per degree, da quello minore a quello
    % maggiore;
    deg_C = deg(C_index)';
    temp_M = [deg_C;C_index].';
    jnk = sortrows(temp_M);
    C_ordered_degree = jnk(:,2)';
   
    %while(0)
    numeroiterazioni = 0;
    while(sum(match==-1)~=0)
        % ordino i nodi non assegnati; prima i pi� distanti.
        numeroiterazioni = numeroiterazioni+1;
        if numeroiterazioni >= 300
            k = withPlot;
            disp(['errore usando il grafo ', num2str(k)]);
            break;
        end
        missing = find(match==-1);
        missing_dist = distance_corridor(missing);
        temp_M = [-missing_dist;missing].';
        jnk = sortrows(temp_M);
        R_ordered_degree = jnk(:,2)';
        % indice del nodo pi� distante da un C
        most_distant = R_ordered_degree(1);
        max_dist = distance_corridor(most_distant);
        % trovo il Corridoio pi� vicino al nodo most_distant
        foundC = 0;
        for i=C_ordered_degree 
            if foundC == 0
                [path,d] = shortestpath(G,most_distant,i);
                % se � alla distanza massima allora aggiungo al path tutti
                % quelli che sono rimasti senza match. Ne faccio al max uno a
                % giro
                if d == max_dist 
                    foundC = 1;
                    for j = path 
                        if (match(j) == -1)
                            match(j) = i;
                        end
                    end
                end      
            end
        end
    end

    % Ulteriore controllo: se matcho uno solo a se' stesso allora lo matcho
    % ad un corridoio vicino - a caso.
    for i=unique(match)
        if sum(match==i) == 1
            if i~=match 
                Error('Non ho capito niente')
            end
            neigh_tmp2 = neighbors(G,i);
            neigh_labels2 = L(neigh_tmp2);
            neigh_corr2 = sum(ismember(neigh_labels2,corridor_labels));
            neigh_corr2 = neigh_corr2(neigh_corr2~=i);
            match(i) = neigh_corr2(1);
            warning('Possibile problema di segmentazione ad un grafo');
            i
            C_index = C_index(C_index~=i);
            % Nodi da non considerare come corridoio
            notC_index = [notC_index,i];
        end
    end
    
    if withPlot >0 
        colormap colorcube
        colors = colormap;
        k = withPlot;
        % Plotto coi colori dei nodi diversi per vedere cosa viene fuori
        h = plot(G,'Layout','force');
        highlight(h,find(ismember(L, corridor_labels)));
        count = 1;
        e = table2array(G.Edges);
        [numedges, ~] = size(e);
        cuts = [];
        for i=C_index
            nodi_associati = find(match==i);
            % considero ora gli edge per andare a calcolare i CUT
            for j=1:numedges 
                tmpedge = e(j,:);
                tmpedge = tmpedge(1:2);
                num_subgraphs = sum(ismember(nodi_associati,tmpedge));
                if num_subgraphs == 1
                    %� un cut
                     highlight(h,[tmpedge(1)],[tmpedge(2)],'EdgeColor','r');
                     cuts = [cuts;tmpedge];
                else
                    if num_subgraphs == 2
                        % � interno al sottografo
                        highlight(h,[tmpedge(1)],[tmpedge(2)],'EdgeColor',colors(count,:));
                    end
                end
            end
            highlight(h,nodi_associati,'NodeColor',colors(count,:));
            count = count+1;
        end

        % considero ora i CUT tra due Corridoi
        for i = C_index
            for j=1:numedges
                tmpedge = e(j,:);
                tmpedge = tmpedge(1:2);
                num_subgraphs = sum(ismember(C_index,tmpedge));
                if num_subgraphs == 2
                    %� un cut
                     highlight(h,[tmpedge(1)],[tmpedge(2)],'EdgeColor','r');
                     cuts = [cuts;tmpedge];
                end
            end
        end
        saveas(gcf,strcat('grafo_',num2str(k),'.pdf'));


        %test provo ad ordinarlo    
        [n_nodi,~] = size(grafo);
        grafo_sorted = zeros(n_nodi,n_nodi);
        diagonale_sorted = match;
        tmp_sort =[diagonale_sorted;1:n_nodi].';
        jnk = sortrows(tmp_sort);
        % ORDERED nodes dovrebbe essere l'ordinamento dei nodi per sottografo
        ordered_nodes = jnk(:,2)';
        ordered_match = jnk(:,1)';
        for i=1:n_nodi
            for j=1:n_nodi
                grafo_sorted(i,j) = grafo(ordered_nodes(i),ordered_nodes(j));
            end
        end

        G2 = graph(grafo_sorted - diag([diag(grafo_sorted)]),'OmitSelfLoops');    
        h = plot(G2,'Layout','force');
        saveas(gcf,strcat('grafo_',num2str(k),'ordered.pdf'));  
    end
    
    % ORDINAMENTO FUNZIONA!
    %     COME TROVO LE STRUTTURE DATI?
    %     F_E e C_E sono rispettivamente la diagonale a blocchi della grafo_sorted e i blocchi non_diagonali
    %     S non mi serve
    %     le altre misure sono immediate
    %     l'ultimo � praticamente una versione ri-disordinata di ordered_match
    %     In pratica tutto si gioca su unique(ordered_match)
    %     for i in unique(ordered_match)numF - array del numero di sottografi di ogni grafo
    %        ngrafi - numero di grafi
    %        sizemax - numero massimo di partizionamento (di sottografi
    %        ottenuti per un grafo)
    %        subgraphToNodeAssociation - array di celle che mantiene
    %        subgraphToNodeAssociation{k,i} � il vettore binario, lungo quanto
    %        il numero di nodi del grafo k, che dice quali nodi di k si trovano
    %        nel suo sottografo i)
    F_e = {};
    C_e = {};
    subgraphToNodeAssociation = zeros(1,size(grafo,1));
    % Trovo quanto paddare
    max_sub = -1;
    for i=C_index
        tmp = sum(match == i);
        if tmp > max_sub 
            max_sub = tmp;
        end
    end
    
    nodes = {};
    for i=1:size(C_index,2)
        F_e{i} = subBlockMatrix(grafo,match==C_index(i),-1);
        for j=i:size(C_index,2)
            C_e{i,j} = subBlockMatrix(grafo,(match==C_index(i))+(match==C_index(j))*2,max_sub);
        end
        nodes{i} = match == C_index(i);
    end
    
    % restituisco i parametri
    n = max_sub;
    numF = sum(size(C_index,2));
    if withPlot 
        disp(['Finito il grafo',num2str(withPlot)]);
    end
end