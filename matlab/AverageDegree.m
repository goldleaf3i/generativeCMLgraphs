function average_degree = AverageDegree( matrice_adiacenza )
%calcola il grado medio di un grafo

[r, c] = size(matrice_adiacenza);
res = 0;

for i = 1:r
    for j = 1:c
        if(i ~= j)
            res = res + matrice_adiacenza(i,j);
        end
    end
end

average_degree = res/r;

end