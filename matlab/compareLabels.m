%confronta gli insiemi di neighborhood hash label di due grafi calcolando
%un elemento k della neighborhood hash kernel matrix in base al numero di
%hash identiche
%INPUT:  Vsort1, Vsort2 - array cell dei vettori binari (hash) dei due
%grafi
%OUTPUT: k - elemento della neighborhood hash kernel matrix, indica la
%similarità tra i due grafi
function [k] = compareLabels(Vsort1,Vsort2)
n1 = length(Vsort1);
n2 = length(Vsort2);

c = 0;
i = 1;
j = 1;
while i <= n1 && j <= n2
    %converte da binario a numero intero per fare il confronto
    l1 = sum(Vsort1{i}.*2.^(numel(Vsort1{i})-1:-1:0));
    l2 = sum(Vsort2{j}.*2.^(numel(Vsort2{j})-1:-1:0));

    if l1 == l2
        c = c + 1;
        i = i + 1;
        j = j + 1;
    elseif l1 < l2
        i = i + 1;
    else
        j = j + 1;
    end
end
k = c/(n1 + n2 - c);
end