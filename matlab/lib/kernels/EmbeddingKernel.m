function kernel_matrix = EmbeddingKernel( grafi )
%prende una lista di grafi sotto forma di cell array e restituisce la
%kernel matrix (simmetrica)

%controllo che grafi sia un cell array
if(iscell(grafi) == 0)
    error('input errato, non è un cell array');
end

len = length(grafi);
label_embeddings = [];
topol_embeddings = [];
label_kernel_matrix = eye(len);
topol_kernel_matrix = eye(len);

%costruisco le matrici label_embeddings e topol_embeddings, ciascuna riga
%di queste matrici è rispettivamente il label e il topological embedding
%dell'i-esimo grafo all'interno del cell array grafi
for i = 1:len
    matrice_adiacenza = grafi{i};
    lab_emb = LabelEmbedding(matrice_adiacenza);
    top_emb = TopologicalEmbedding(matrice_adiacenza);
    label_embeddings = [label_embeddings; lab_emb];
    topol_embeddings = [topol_embeddings; top_emb];
end

%faccio z-normalization dei label embedding dei grafi
[r1, c1] = size(label_embeddings);

for j = 1:c1
    col = label_embeddings(1:r1,j);
    media = sum(col)/size(col,1);
    varianza = var(col);
    
    % per evitare divisioni per 0
    if(varianza == 0)
        varianza = 1;
    end
    
    dev_std = sqrt(varianza);
        
    for i = 1:r1
        label_embeddings(i,j) = ((label_embeddings(i,j) - media)/dev_std);
    end
end

%faccio z-normalization dei topological embedding dei grafi
[r2, c2] = size(topol_embeddings);

for j = 1:c2
    col = topol_embeddings(1:r2,j);
    media = sum(col)/size(col,1);
    varianza = var(col);
    
    % per evitare divisioni per 0
    if(varianza == 0)
        varianza = 1;
    end
    
    dev_std = sqrt(varianza);
       
    for i = 1:r2
        topol_embeddings(i,j) = ((topol_embeddings(i,j) - media)/dev_std);
    end
end

%calcolo la matrice label_kernel_matrix facendo RBF kernel tra le righe
%della matrice label_embeddings
for i = 1:r1-1
    for j = i+1:r1
        v1 = label_embeddings(i, 1:c1);
        v2 = label_embeddings(j, 1:c1);
        v3 = v1 - v2;
        v3 = v3.^2;
        res = -(1/c1)*sum(v3);
        res = exp(res);
        label_kernel_matrix(i,j) = res;
        label_kernel_matrix(j,i) = res;
    end
end
%disp(label_kernel_matrix);

%calcolo la matrice topol_kernel_matrix facendo RBF kernel tra le righe
%della matrice topol_embeddings
for i = 1:r2-1
    for j = i+1:r2
        v1 = topol_embeddings(i, 1:c2);
        v2 = topol_embeddings(j, 1:c2);
        v3 = v1 - v2;
        v3 = v3.^2;
        res = -(1/c2)*sum(v3);
        res = exp(res);
        topol_kernel_matrix(i,j) = res;
        topol_kernel_matrix(j,i) = res;
    end
end
%disp(topol_kernel_matrix);

%calcolo la matrice kernel_matrix facendo la media tra i valori posti
%nella stessa posizione all'interno delle matrici label_kernel_matrix e
%topol_kernel_matrix
kernel_matrix = (label_kernel_matrix + topol_kernel_matrix)/2;
%disp(kernel_matrix);

end

