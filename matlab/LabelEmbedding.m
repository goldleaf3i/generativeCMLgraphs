function label_embedding = LabelEmbedding( matrice_adiacenza )
%Prende un grafo e ne calcola l'embedding sfruttando le label

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

%creo un vettore in cui memorizzo quante volte ciascuna label compare nel
%grafo, ciascuna posizione di questo vettore corrisponde ad una delle
%label
v1 = zeros(1,length(label_set));
for i = 1:r
    tmp = matrice_adiacenza(i,i);
    if(tmp == 0)
        tmp = 21;
    elseif(tmp == 100)
        tmp = 22;
    elseif(tmp == 105)
        tmp = 23;
    elseif(tmp == 110)
        tmp = 24;
    elseif(tmp == 1000)
        tmp = 25;
    end
    v1(tmp) = v1(tmp) + 1;
end

%memorizzo quanti edge ci sono nel grafo per ogni coppia di label

%ciascun indice di riga/colonna di questa matrice di dimensione
%length(label_set) x length(label_set) corrsiponde ad una
%delle label, uso questa matrice per memorizzare il numero di edge
%esistenti tra tutte le possibili coppie di label
m = zeros(length(label_set));

%itero sulla parte superiore della matrice di adiacenza (diagonale esclusa)
%per trovare tutti gli edge e riempire la matrice m
c_start = 2;

for i = 1:r-1
    for j = c_start:c
        if(matrice_adiacenza(i,j) == 1)
            m_r = matrice_adiacenza(i,i);
            m_c = matrice_adiacenza(j,j);
            if(m_r == 0)
                m_r = 21;
            elseif(m_r == 100)
                m_r = 22;
            elseif(m_r == 105)
                m_r = 23;
            elseif(m_r == 110)
                m_r = 24;
            elseif(m_r == 1000)
                m_r = 25;
            end
            
            if(m_c == 0)
                m_c = 21;
            elseif(m_c == 100)
                m_c = 22;
            elseif(m_c == 105)
                m_c = 23;
            elseif(m_c == 110)
                m_c = 24;
            elseif(m_c == 1000)
                m_c = 25;
            end
            
            %riempio solo la parte superiore della matrice m (diagonale inclusa)
            if(m_r > m_c)
                tmp = m_r;
                m_r = m_c;
                m_c = tmp;
            end
            
            m(m_r, m_c) = m(m_r, m_c) + 1;
        end
    end
    
    c_start = c_start + 1;
end

%concateno le entry della matrice m al vettore v1 trovato prima
index = length(v1) + 1;
c_start = 1;

for i = 1:length(label_set)
    for j = c_start:length(label_set)
        v1(index) = m(i, j);
        index = index + 1;
    end
    
    c_start = c_start + 1;
end

label_embedding = v1;
%disp(label_embedding);

end

