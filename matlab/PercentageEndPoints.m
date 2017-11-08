function percentage_end_points = PercentageEndPoints( matrice_adiacenza )
%calcola la percentuale di end points di un grafo

[r, c] = size(matrice_adiacenza);
tmp = 0;
res = 0;

for i = 1:r
    for j = 1:c
        if(i ~= j)
            tmp = tmp + matrice_adiacenza(i,j);
        end
    end
    
    if(tmp == 1)
        res = res + 1;
    end
    
    tmp = 0;
end

percentage_end_points = res/r;

end

