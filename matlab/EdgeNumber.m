function edge_number = EdgeNumber( matrice_adiacenza )
%calcola il numero di edge del grafo (senza ripetizioni simmetriche)

[r, c] = size(matrice_adiacenza);
res = 0;

for i = 1:r
    for j = 1:c
        if(i ~= j)
            res = res + matrice_adiacenza(i,j);
        end
    end
end

edge_number = res/2;

end

