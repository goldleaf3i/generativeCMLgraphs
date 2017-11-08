%calcola il numero di etichette distinte in un grafo
%INPUT:  rlabels - array di etichette con duplicati
%OUTPUT: labels - array delle etichette (insieme senza duplicati)
%        counterLabels - array del numero di etichette distinte
function [labels, counterLabels] = nodeLabelsCounter(rLabels)
labels = [];
counterLabels = [];
count = 0;

for i=1:length(rLabels)
    label = rLabels(i);
    indexLabel = find(labels == label);
    if isempty(indexLabel)
        count = count + 1;
        labels(count) = label;
        counterLabels(count) = 1;
    else
        counterLabels(indexLabel) =  counterLabels(indexLabel) + 1;
    end
end
end