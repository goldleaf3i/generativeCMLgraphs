%calcola la count sensitive neighborhood hash (Kashima) di un nodo
%INPUT:  binaryNode - bit label del nodo di cui si vuole calcolare l'hash
%        adjacentBinaryNodes - array cell (lista di adiacenza) non vuota di
%        bit label del nodo di input
%OUTPUT: NH - count sensitive neighborhood hash (Kashima) del nodo di input
function [NH] = countSensitiveNeighborhoodHash(binaryNode, adjacentBinaryNodes)
dim = length(adjacentBinaryNodes);

%calcolo l'array cell con le etichette distinte e i contatori
distinctLabels = {};
distincts = 0;
adjacentBinaryNodes = radixSortBinary(adjacentBinaryNodes);
i = 1;
while i <= dim
    count = 1;
    j = i + 1;
    while j <= dim && isequal(adjacentBinaryNodes{i}, adjacentBinaryNodes{j})
        count = count + 1;
        j = j + 1;
    end

    distincts = distincts + 1;
    distinctLabels{distincts} = [i count];
    i = j;
end

%calcolo count sensitive neighborhood hash
label = distinctLabels{1};
o = label(2);
NH = circshift(bitxor(adjacentBinaryNodes{label(1)}, ID2Bit(o)), [0 -o]);
dimDistincts = length(distinctLabels);
if dimDistincts > 1
    for i=2:dimDistincts
        label = distinctLabels{i};
        o = label(2);
        NH = bitxor(NH, circshift(bitxor(adjacentBinaryNodes{label(1)}, ID2Bit(o)), [0 -o]));
    end
end
NH = bitxor(NH, circshift(binaryNode,[0 -1]));
end

