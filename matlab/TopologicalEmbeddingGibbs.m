function topological_embedding_gibbs = TopologicalEmbeddingGibbs( matrice_adiacenza, dimension )
%Prende un grafo e ne calcola l'embedding sfruttando topologia e label,
%questa è la versione da usare durante la seconda fase del gibbs sampling,
%questa versione tiene conto anche delle label sugli archi

%insieme delle label dei nodi, ciascuna label corrisponde all'indice del
%cluster a cui il nodo/sottografo appartiene, considero quindi tutti gli
%indici da 1 a dimension, con dimension che corrisponde al numero dei
%cluster
node_label_set = 1:dimension;

%insieme delle label degli archi, ciascuna label corrisponde al numero di
%edge che esistono tra due sottografi, questo numero non è mai superiore a
%3, quindi nel label set ci sono solamente le label 1, 2 e 3
edge_label_set = [1, 2, 3];

%controllo che la matrice di adiacenza passata sia quadrata e che in essa
%non ci siano label che non fanno parte del label set dei nodi o del label
%set degli archi, per quel che riguarda le label sugli archi controllo solo
%la parte sopra la diagonale della matrice di adiacenza, visto che è
%simmetrica
[r, c] = size(matrice_adiacenza);

if(r ~= c)
    error('la matrice non è quadrata');
end

for i = 1:r
    tmp = any(node_label_set == matrice_adiacenza(i,i));
    if(tmp == 0)
        error('nella matrice di adiacenza compare una label che non fa parte del label set dei nodi');
    end
end

for i = 1:r-1
    for j = i+1:c
        if(matrice_adiacenza(i,j) > length(edge_label_set))
            error('nella matrice di adiacenza compare una label che non fa parte del label set degli archi');
        end
    end
end

%trovo la matrice di adiacenza senza label su nodi e archi
matrice_adiacenza_pulita = matrice_adiacenza;

for i = 1:r
    matrice_adiacenza_pulita(i,i) = 0;
    for j = 1:c
        if(matrice_adiacenza_pulita(i,j) > 1)
            matrice_adiacenza_pulita(i,j) = 1;
        end
    end
end

%calcolo grado medio del gafo
v1 = AverageDegree(matrice_adiacenza_pulita);

%calcolo coefficiente di clustering medio del grafo
v2 = AverageClusteringCoefficient(matrice_adiacenza_pulita);

%calcolo rapporto tra numero di end points e numero dei nodi del grafo
v3 = PercentageEndPoints(matrice_adiacenza_pulita);

%numero di nodi del grafo
v4 = r;

%calcolo numero di edge del grafo
v5 = EdgeNumber(matrice_adiacenza_pulita);

%calcolo l'autovalore della matrice di adiacenza con modulo più grande,
%quello con il secondo modulo più grande, l'energia e il numero di
%autovalori distinti
[v6, v7, v8, v9] = Eigenvalues(matrice_adiacenza_pulita);

%calcolo label entropy dei nodi e degli archi
[v10, v11] = LabelEntropyGibbs(matrice_adiacenza, length(node_label_set), length(edge_label_set), v5);

%calcolo neighbourhood impurity e link impurity del grafo
[v12, v13] = Impurity(matrice_adiacenza, v5);

%calcolo rapporto tra numero di nodi isolati e numero dei nodi del grafo
v14 = IsolatedPoints(matrice_adiacenza_pulita);

%concateno i risultati
topological_embedding_gibbs = [v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14];
%disp(topological_embedding);

end

