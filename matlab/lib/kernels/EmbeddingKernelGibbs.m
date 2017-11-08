function kernel_value = EmbeddingKernelGibbs( grafo_flippato, ~, utilParameter )
%prende due grafi e ne restituisce il valore del kernel tra di loro, questa
%funzione viene usata all'interno della seconda fase di sampling;
%grafo_flippato è il grafo samplato corrente, grafo_popol è il grafo della
%popolazione che voglio confrontare con grafo_flippato per ottenere la
%loro similarità che mi serve per poi trovare la loro distanza,
%utilParameter è un parametro ausiliario; utilParameter è un cell array
%monodimensionale con all'interno: una matrice che contiene i label
%embeddings della popolazione di grafi messi nella nuova rappresentazione,
%una matrice che contiene i topological embeddings della popolazione di
%grafi messi nella nuova rappresentazione, un indice che mi identifica il
%grafo (e quindi anche il relativo embedding) della popolazione che sto
%attualmente considerando (quindi di fatto il grafo grafo_popol non mi
%serve, perchè uso l'indice per risalire al suo embedding che già ho
%calcolato, quindi nell'header della funzione metto ~) e il numero dei
%cluster, ovvero la dimensione del label set dei nodi

%controllo che utilParameter sia un cell array
if(iscell(utilParameter) == 0)
    error('parametro ausiliario errato, non è un cell array');
end

label_embeddings_pop = utilParameter{1};
topol_embeddings_pop = utilParameter{2};
index = utilParameter{3};
node_label_set_dimension = utilParameter{4};

%trovo il label e il topological embedding del grafo flippato
lab_emb_flip = LabelEmbeddingGibbs(grafo_flippato, node_label_set_dimension);
top_emb_flip = TopologicalEmbeddingGibbs(grafo_flippato, node_label_set_dimension);

%faccio range normalization considerando i label embedding dei grafi della
%popolazione e il label embedding del grafo flippato
label_embeddings_norm = [label_embeddings_pop; lab_emb_flip];

[r1, c1] = size(label_embeddings_norm);

for j = 1:c1
    col = label_embeddings_norm(1:r1,j);
    max_val = max(col);
    min_val = min(col);
    
    %per evitare divisioni per 0
    diff_max_min = max_val - min_val;
    if(diff_max_min == 0)
        diff_max_min = 1;
    end
    
    for i = 1:r1
        label_embeddings_norm(i,j) = ((label_embeddings_norm(i,j) - min_val)/diff_max_min);
    end
end

%faccio range normalization considerando i topological embedding dei grafi
%della popolazione e il topological embedding del grafo flippato
topol_embeddings_norm = [topol_embeddings_pop; top_emb_flip];

[r2, c2] = size(topol_embeddings_norm);

for j = 1:c2
    col = topol_embeddings_norm(1:r2,j);
    max_val = max(col);
    min_val = min(col);
    
    %per evitare divisioni per 0
    diff_max_min = max_val - min_val;
    if(diff_max_min == 0)
        diff_max_min = 1;
    end
    
    for i = 1:r2
        topol_embeddings_norm(i,j) = ((topol_embeddings_norm(i,j) - min_val)/diff_max_min);
    end
end

%faccio RBF kernel tra il label embedding del grafo flippato e quello del
%grafo della popolazione che sto considerando
v1 = label_embeddings_norm(r1, 1:c1);
v2 = label_embeddings_norm(index, 1:c1);
v3 = v1 - v2;
v3 = v3.^2;
res = -0.5*sum(v3);
label_RBF_value = exp(res);

%faccio RBF kernel tra il topological embedding del grafo flippato e quello
%del grafo della popolazione che sto considerando
v1 = topol_embeddings_norm(r2, 1:c2);
v2 = topol_embeddings_norm(index, 1:c2);
v3 = v1 - v2;
v3 = v3.^2;
res = -0.5*sum(v3);
topol_RBF_value = exp(res);

%calcolo il valore finale della similarità tra il grafo flippato e quello
%della popolazione facendo la media tra label_RBF_value e topol_RBF_value
kernel_value = (label_RBF_value + topol_RBF_value)/2;
%disp(kernel_value);

end

