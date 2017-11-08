function [node_le, edge_le] = LabelEntropyGibbs( matrice_adiacenza, node_labels, edge_labels, edges )
%calcola la label entropy, una misura dell'incertezza delle label, la
%calcola sia per le label dei nodi, sia per le label degli archi

[r, c] = size(matrice_adiacenza);

%calcolo la node label entropy

%creo un vettore in cui memorizzo quante volte ciascuna label dei nodi
%compare nel grafo, ciascuna posizione di questo vettore corrisponde ad una
%delle label dei nodi
v = zeros(1, node_labels);

for i = 1:r
    tmp = matrice_adiacenza(i,i);
    v(tmp) = v(tmp) + 1;
end

%divido ogni entry del vettore v per il numero di nodi del grafo per
%trovare le probabilità di ciascuna label dei nodi
v = v/r;

%gli elementi di v uguali a 0 li metto uguali a 1 altrimenti calcola il
%logaritmo di 0 (logaritmo di 1 invece non altera il risultato finale
%perchè vale 0)
for i = 1:length(v)
    if(v(i) == 0)
        v(i) = 1;
    end
end

%calcolo la label entropy dei nodi
l = 0;

for i = 1:node_labels
    l = l + (v(i)*log(v(i)));
end

node_le = -l;

%calcolo la edge label entropy

%creo un vettore in cui memorizzo quante volte ciascuna label degli archi
%compare nel grafo, ciascuna posizione di questo vettore corrisponde ad una
%delle label degli archi
v = zeros(1, edge_labels);

for i = 1:r-1
    for j = i+1:c
        tmp = matrice_adiacenza(i,j);
        if(tmp > 0)
            v(tmp) = v(tmp) + 1;
        end
    end
end

%divido ogni entry del vettore v per il numero di archi del grafo per
%trovare le probabilità di ciascuna label degli archi
v = v/edges;

%gli elementi di v uguali a 0 li metto uguali a 1 altrimenti calcola il
%logaritmo di 0 (logaritmo di 1 invece non altera il risultato finale
%perchè vale 0)
for i = 1:length(v)
    if(v(i) == 0)
        v(i) = 1;
    end
end

%calcolo la label entropy degli archi
l = 0;

for i = 1:edge_labels
    l = l + (v(i)*log(v(i)));
end

edge_le = -l;

end

