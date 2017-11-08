%elimina nodi dummy dai grafi di input
%INPUT: grafi - array di grafi
%OUTPUT: dimgrafo - array delle dimensioni di ogni grafo
function [grafi, dimgrafo] = removeDummyNodes(grafi)
dimgrafo=zeros(1,length(grafi));
for i=1:length(grafi),
    grafi{i}=removeDummy(grafi{i});
    dimgrafo(i)=length(grafi{i});
end

end