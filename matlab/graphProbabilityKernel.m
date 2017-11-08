%calcola il graph probability kernel basato sull'attributo etichette,
%guarda alle loro frequenze nei grafi di input
%INPUT:  rNodesF1, rNodesF2 - array di etichette dei due grafi con duplicati
%        ro - esponente della probabilità (per ro = 1/2 si ha il
%Bhattacharyya kernel)
%OUTPUT: probabilityKernel - è il graph probability kernel
function [probabilityKernel] = graphProbabilityKernel(rNodesF1,rNodesF2,ro)
[labelsF1, counterLabelsF1] = nodeLabelsCounter(rNodesF1);
[labelsF2, counterLabelsF2] = nodeLabelsCounter(rNodesF2);
totalLabelsF1 = sum(counterLabelsF1);
totalLabelsF2 = sum(counterLabelsF2);

%calcolo le frequenze delle label per entrambi i grafi
labelFrequenciesF1 = zeros([1 length(labelsF1)]);
labelFrequenciesF2 = zeros([1 length(labelsF2)]);
dimF1 = length(labelFrequenciesF1);
dimF2 = length(labelFrequenciesF2);
for i=1:max(dimF1,dimF2)
    if i <= dimF1
        labelFrequenciesF1(i) = counterLabelsF1(i)/totalLabelsF1;
    end
    if i <= dimF2
        labelFrequenciesF2(i) = counterLabelsF2(i)/totalLabelsF2;
    end
end

%calcolo il graph probability kernel
labels = union(labelsF1,labelsF2);
probabilityKernel = 0;
for i=1:length(labels)
    indexLabelF1 = find(labelsF1 == labels(i));
    indexLabelF2 = find(labelsF2 == labels(i));
    if ~isempty(indexLabelF1) && ~isempty(indexLabelF2)
        probabilityKernel = probabilityKernel + power(labelFrequenciesF1(indexLabelF1),ro)*power(labelFrequenciesF2(indexLabelF2),ro);
    end
end
end