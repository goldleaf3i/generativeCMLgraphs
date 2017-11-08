function topological_embedding = TopologicalEmbedding( matrice_adiacenza )
%Prende un grafo e ne calcola l'embedding sfruttando topologia e label

%insieme delle label, le label sono 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
%12, 13, 14, 15, 16, 17, 18, 19, 20, 0, 100, 105, 110, 1000
label_set = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 0, 100, 105, 110, 1000];

%controllo che la matrice di adiacenza passata sia quadrata e che in essa
%non ci siano label che non fanno parte del label set
[r, c] = size(matrice_adiacenza);

if(r ~= c)
    error('la matrice non è quadrata');
end

for i = 1:r
    tmp = any(label_set == matrice_adiacenza(i,i));
    if(tmp == 0)
        error('nella matrice di adiacenza compare una label che non fa parte del label set');
    end
end

%calcolo grado medio del gafo
v1 = AverageDegree(matrice_adiacenza);

%calcolo coefficiente di clustering medio del grafo
v2 = AverageClusteringCoefficient(matrice_adiacenza);

%calcolo rapporto tra numero di end points e numero dei nodi del grafo
v3 = PercentageEndPoints(matrice_adiacenza);

%numero di nodi del grafo
v4 = r;

%calcolo numero di edge del grafo
v5 = EdgeNumber(matrice_adiacenza);

%calcolo l'autovalore della matrice di adiacenza con modulo più grande,
%quello con il secondo modulo più grande, l'energia e il numero di
%autovalori distinti
[v6, v7, v8, v9] = Eigenvalues(matrice_adiacenza);

%calcolo label entropy
v10 = LabelEntropy(matrice_adiacenza, length(label_set));

%calcolo neighbourhood impurity e link impurity del grafo
[v11, v12] = Impurity(matrice_adiacenza, v5);

%concateno i risultati
topological_embedding = [v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12];
%disp(topological_embedding);

end

