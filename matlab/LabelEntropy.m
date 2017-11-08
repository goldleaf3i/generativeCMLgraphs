function label_entropy = LabelEntropy( matrice_adiacenza, number_of_labels )
%calcola la label entropy, una misura dell'incertezza delle label

[r, c] = size(matrice_adiacenza);

%creo un vettore in cui memorizzo quante volte ciascuna label compare nel
%grafo, ciascuna posizione di questo vettore corrisponde ad una delle
%label
v = zeros(1,number_of_labels);
for i = 1:r
    tmp = matrice_adiacenza(i,i);
    if(tmp == 0)
        tmp = 12;
    elseif(tmp == 100)
        tmp = 13;
    elseif(tmp == 105)
        tmp = 14;
    elseif(tmp == 1000)
        tmp = 15;
    elseif(tmp == 10000)
        tmp = 16;
    end
    v(tmp) = v(tmp) + 1;
end

%divido ogni entry del vettore v per il numero di nodi del grafo per
%trovare le probabilità di ciascuna label
v = v/r;

%gli elementi di v uguali a 0 li metto uguali a 1 altrimenti calcola il
%logaritmo di 0 (logaritmo di 1 invece non altera il risultato finale
%perchè vale 0)
for i = 1:length(v)
    if(v(i) == 0)
        v(i) = 1;
    end
end

%calcolo la label entropy
l = 0;

for i = 1:number_of_labels
    l = l + (v(i)*log(v(i)));
end

label_entropy = -l;

end

