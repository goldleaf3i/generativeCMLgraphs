%seleziona le connessioni tra i sottografi del nuovo grafo
%INPUT:  graphSet1 - cell array del primo insieme di grafi
%        graphSet2 - cell array del secondo insieme di grafi
%        labelSet1 - intero etichetta
%        labelSet2 - intero etichetta
%OUTPUT: K - matrice di similarità
%        unionLabelSet - insieme unione delle etichette dei nodi dei grafi
function [K,unionLabelSet] = createMixSimilarityMatrix(graphSet1,graphSet2,labelSet1,labelSet2)
    dim1 = size(graphSet1,2);
    dim2 = size(graphSet2,2);
    dim = dim1 + dim2;
    unionGraphSet = cell(1,dim);
    unionLabelSet = dim;
    for k=1:dim1
        unionGraphSet{k} = graphSet1{k};
        unionLabelSet(k) = labelSet1;
    end
    for k=1:dim2
        unionGraphSet{dim1+k} = graphSet2{k};
        unionLabelSet(dim1+k) = labelSet2;
    end
    
    %qui cambio la funzione kernel
    K = createWeisfeilerLehmanKernelMatrix(unionGraphSet, 5, 1);
    
    %Matrice di similarita' dei grafi di connessione dei cluster originali e di quelli campionati (da usare come input a TSNE)
    pathS=(strcat(pwd,'/','Data','/MatriceSimilaritaClusterOrigVsSampleTSNE/'));
    [~, ~, ~] = mkdir(pathS);
    dlmwrite(strcat(pathS,'similarity_matrix.log'),K);
    dlmwrite(strcat(pathS,'cluster_labels.log'),unionLabelSet);
end