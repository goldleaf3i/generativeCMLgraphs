function isolated_points = IsolatedPoints( matrice_adiacenza )
%calcolo il rapporto tra il numero di nodi isolati e il numero totale di
%nodi nel grafo

[r, c] = size(matrice_adiacenza);

res = 0;

for i = 1:r
    tmp = sum(matrice_adiacenza(i,1:c));
    
    if(tmp == 0)
        res = res + 1;
    end
end

isolated_points = res/r;

end

