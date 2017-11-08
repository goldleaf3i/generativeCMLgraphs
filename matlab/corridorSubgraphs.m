% SCRIPT FATTO PER TESTARE IL CUT FATTO TRA CORRIDOI.

% threshold per dire se un corridoio è candidato per un taglio
mincutthreshold = 1; 
colormap colorcube
colors = colormap;

for k=1:num_grafi
    % creo il grafo
    grafo = grafi{1,k};
    disp(strcat('Inizio il grafo ',num2str(k),'.'));
    G = graph(grafo - diag([diag(grafo)]),'OmitSelfLoops');
    % trovo le label
    L = diag(grafo)';
    % trovo l'indice delle label che sono corridoi
    % 100 Corridoi, 105 Hall 110 Lobby 115 OpenSpace
    corridor_labels = [100,105,110,115];
    C = ismember(L, corridor_labels);
    C_index = find(C);
    % creo la struttura dati
    % MATCH indica a chi associo ogni nodo. Se non è associato è -1;
    match = zeros(size(L)) - 1;
    distance_corridor = zeros(size(L)) + 1000;
    deg = degree(G);

    %rimuovo dalla lista dei corridoi quelli che sono connessi solo a corridoi
    for i=C_index
        neigh_tmp = neighbors(G,i);
        neigh_labels = L(neigh_tmp);
        neigh_corr = sum(ismember(neigh_labels,corridor_labels));
        if deg(i) - neigh_corr <=1 
            C(i) = 0;
        end
    end
    % Nodi da considerae come corridoio
    C_index = find(C);
    % Nodi da non considerare come corridoio
    notC_index = find(C~=1);
    % Associo i corridoi a loro stessi
    match(C_index) = C_index;
    % Trovo per ciascun elemento il corridoio più vicino
    num_closest_C = zeros(size(L)) - 1;
    for i = notC_index
        for j = C_index 
            [path,d] = shortestpath(G,i,j);
            if d < distance_corridor(i)
                num_closest_C(i) = 1;
                distance_corridor(i) = d;
                candidate = j;
            else
                % più di un corridoio alla stessa distanza - devo assegnare in
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
   
    Uwhile(0)
    %while(sum(match==-1)~=0)
        % ordino i nodi non assegnati; prima i più distanti.
        missing = find(match==-1)
        missing_dist = distance_corridor(missing);
        temp_M = [-missing_dist;missing].';
        jnk = sortrows(temp_M);
        R_ordered_degree = jnk(:,2)';
        % indice del nodo più distante da un C
        most_distant = R_ordered_degree(1);
        max_dist = distance_corridor(most_distant);
        % trovo il Corridoio più vicino al nodo most_distant
        foundC = 0;
        for i=C_ordered_degree 
            if foundC == 0
                [path,d] = shortestpath(G,most_distant,i);
                % se è alla distanza massima allora aggiungo al path tutti
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
                %è un cut
                 highlight(h,[tmpedge(1)],[tmpedge(2)],'EdgeColor','r');
                 cuts = [cuts;tmpedge];
            else
                if num_subgraphs == 2
                    % é interno al sottografo
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
                %è un cut
                 highlight(h,[tmpedge(1)],[tmpedge(2)],'EdgeColor','r');
                 cuts = [cuts;tmpedge];
            end
        end
    end
    saveas(gcf,strcat('grafo_',num2str(k),'.pdf'));
end


