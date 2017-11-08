function average_clustering_coefficient = AverageClusteringCoefficient( matrice_adiacenza )
%calcola il coefficiente di clustering medio di un grafo

[r, c] = size(matrice_adiacenza);

neighbours = [];
clustering_coefficients = [];

for i = 1:r
    %per ogni nodo ottengo la lista dei suoi vicini
    for j = 1:c
        if(i ~= j && matrice_adiacenza(i,j) == 1)
            neighbours = [neighbours j];
        end
    end
    
    neighbours = sort(neighbours);
    len = length(neighbours);
    
    %massimo numero di edges che possono esserci tra i vicini del nodo i
    %(senza ripetizioni simmetriche e senza autoanelli)
    max_number_edges = ((len*len)-len)/2;
    actual_number_edges = 0;
    
    %guardo la parte superiore della matrice di adiacenza (diagonale esclusa)
    %per vedere quali edge esistono tra i nodi che sono vicini di i e trovo
    %il coefficiente di clustering del nodo i
    if(max_number_edges > 0)
        for k = 1:len-1
            u = neighbours(k);
            for l = k+1:len
                v = neighbours(l);
                if(matrice_adiacenza(u,v) == 1)
                    actual_number_edges = actual_number_edges + 1;
                end
            end
        end
        
        res = actual_number_edges/max_number_edges;
        clustering_coefficients = [clustering_coefficients res];
    else
        clustering_coefficients = [clustering_coefficients 0];
    end
    
    neighbours = [];
end
            
average_clustering_coefficient = sum(clustering_coefficients)/r;

end

