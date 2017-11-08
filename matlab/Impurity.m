function [neigh_impurity, link_impurity] = Impurity( matrice_adiacenza, edge_number )
%calcolo la neighbourhood impurity del grafo facendo la somma delle
%neighbourhood impurity di tutti i nodi e poi la divido per il numero di
%nodi che hanno impurity non nulla; calcolo la link impurity del grafo
%facendo la somma delle neighbourhood impurity di tutti i nodi e poi la
%divido per il numero di edge del grafo

[r, c] = size(matrice_adiacenza);

neighbours = [];
imp_local = 0;
imp_global = 0;
impure_nodes = 0;
edges = edge_number;

for i = 1:r
    label_i = matrice_adiacenza(i,i);
    
    %per ogni nodo ottengo la lista dei suoi vicini
    for j = 1:c
        if(i ~= j && matrice_adiacenza(i,j) ~= 0)
            neighbours = [neighbours j];
        end
    end
    
    for k = 1:length(neighbours)
        u = neighbours(k);
        label_u = matrice_adiacenza(u,u);
        if(label_u ~= label_i)
            imp_local = imp_local + 1;
        end
    end
    
    imp_global = imp_global + imp_local;
    
    if(imp_local > 0)
        impure_nodes = impure_nodes + 1;
    end
    
    imp_local = 0;
    neighbours = [];
end

%per evitare eventuali divisioni per 0
if(impure_nodes == 0)
    impure_nodes = 1;
end

neigh_impurity = imp_global/impure_nodes;
%disp(neigh_impurity);

%per evitare di considerare ogni edge due volte
imp_global = imp_global/2;

link_impurity = imp_global/edges;
%disp(link_impurity);
       
end

