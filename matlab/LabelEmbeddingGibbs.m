function label_embedding_gibbs = LabelEmbeddingGibbs( matrice_adiacenza, dimension )
%Prende un grafo e ne calcola l'embedding sfruttando le label, questa è la
%versione da usare durante la seconda fase del gibbs sampling, questa
%versione tiene conto anche delle label sugli archi

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

%creo un vettore in cui memorizzo quante volte ciascuna label dei nodi
%compare nel grafo, ciascuna posizione di questo vettore corrisponde ad
%una delle label
v1 = zeros(1,length(node_label_set));
for i = 1:r
    tmp = matrice_adiacenza(i,i);
    v1(tmp) = v1(tmp) + 1;
end

%memorizzo quanti edge, con una determinata label, ci sono nel grafo per
%ogni coppia di label dei nodi

%ciascun indice di riga/colonna di questo cell array bidimensionale di
%dimensione length(node_label_set) x length(node_label_set) corrisponde ad
%una delle label dei nodi, uso questo cell array bidimensionale per
%memorizzare il numero di edge esistenti tra tutte le possibili coppie di
%label dei nodi; ciascun elemento di questo cell array bidimensionale è un
%array che contiene tre elementi, il primo è il numero di edge con label 1
%tra due nodi con due determinate node label mentre il secondo/terzo invece
%è il numero di edge con label 2/3 tra quei due nodi
m = cell(length(node_label_set));
zero = [0, 0, 0];

for i = 1:length(node_label_set)
    for j = 1:length(node_label_set)
        m{i,j} = zero;
    end
end

%itero sulla parte superiore della matrice di adiacenza (diagonale esclusa)
%per trovare tutti gli edge e riempire il cell array bidimensionale m
for i = 1:r-1
    for j = i+1:c
        if(matrice_adiacenza(i,j) == 1)
            m_r = matrice_adiacenza(i,i);
            m_c = matrice_adiacenza(j,j);
            
            %riempio solo la parte superiore del cell array bidimensionale m (diagonale inclusa)
            if(m_r > m_c) 
                tmp = m_r;
                m_r = m_c;
                m_c = tmp;
            end
            
            m{m_r, m_c}(1) = m{m_r, m_c}(1) + 1;        
        
        elseif(matrice_adiacenza(i,j) == 2)
            m_r = matrice_adiacenza(i,i);
            m_c = matrice_adiacenza(j,j);
            
            %riempio solo la parte superiore del cell array bidimensionale m (diagonale inclusa)
            if(m_r > m_c) 
                tmp = m_r;
                m_r = m_c;
                m_c = tmp;
            end
            
            m{m_r, m_c}(2) = m{m_r, m_c}(2) + 1;
            
        elseif(matrice_adiacenza(i,j) == 3)
            m_r = matrice_adiacenza(i,i);
            m_c = matrice_adiacenza(j,j);
            
            %riempio solo la parte superiore del cell array bidimensionale m (diagonale inclusa)
            if(m_r > m_c) 
                tmp = m_r;
                m_r = m_c;
                m_c = tmp;
            end
            
            m{m_r, m_c}(3) = m{m_r, m_c}(3) + 1;
        end
    end    
end

%concateno le entry del cell array bidimensionale m al vettore v1 trovato
%prima
for i = 1:length(node_label_set)
    for j = i:length(node_label_set)
        v1 = [v1 m{i,j}(1)];
    end   
end

for i = 1:length(node_label_set)
    for j = i:length(node_label_set)
        v1 = [v1 m{i,j}(2)];
    end   
end

for i = 1:length(node_label_set)
    for j = i:length(node_label_set)
        v1 = [v1 m{i,j}(3)];
    end   
end

label_embedding_gibbs = v1;
%disp(label_embedding_gibbs);

end

