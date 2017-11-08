%ordina un array cell di vettori binari con lunghezza fissa tramite
%l'algoritmo radix sort
%INPUT:  binaryArray - array cell binario da ordinare
%OUTPUT: sortedBinaryArray - array cell binario ordinato
%        sortedIndex - array degli indici ordinati dell'array di input
function [sortedBinaryArray, sortedIndex] = radixSortBinary(binaryArray)
n = length(binaryArray);
d = length(binaryArray{1});
matrix = zeros(n, d);
for i=1:n
    matrix(i,:) = binaryArray{i};
end

sortedIndex = (1:n)';
for i=d:-1:1
    %calcola l'ordine degli indici considerando fino la i-esima colonna
    %meno significativa
    sortedIndex = sortedIndex(countingSort(matrix(sortedIndex,i),n));
end

sortedBinaryArray = cell(1, n);
for i=1:n
    sortedBinaryArray{i} = matrix(sortedIndex(i),:);
end
end

function sortedIndex = countingSort(column, n)
%calcola l'istogramma
C = zeros(2,1);
for j=1:n
    C(column(j)+1) = C(column(j)+1) + 1;
end

%istogramma cumulativo
for i=2:2
    C(i) = C(i) + C(i - 1);
end

%calcola l'array degli indici ordinati
sortedIndex = nan(n,1);
for j=n:-1:1
    sortedIndex(C(column(j)+1)) = j;
    C(column(j)+1) = C(column(j)+1) - 1;
end
end
