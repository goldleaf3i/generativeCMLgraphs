%calcola la matrice di shortest path kernel, considerando grafi etichettati
%sui nodi e con pesi sugli archi
%INPUT:  Flin - array di celle dei sottografi (linearizzazione di F_e)
%        (elementi di F_e)
%        dimLabels - è la dimensione dell'alfabeto delle etichette
%        n - indica se normalizzare o meno la matrice di kernel
%OUTPUT: K - matrice di shortest path kernel
function [K] = createShortestPathKernelMatrix(Flin, dimLabels, n)
dim = size(Flin, 2);
matrixShortestPathDistance = cell(1, dim);

%calcolo lo shortest path massimo
maxShortestPath = 0;
for i=1:dim
    F = Flin{i};
    matrixShortestPathDistance{i} = floydwarshall(F);
    tmpMax = max(matrixShortestPathDistance{i}(~isinf(matrixShortestPathDistance{i})));
    if tmpMax > maxShortestPath
        maxShortestPath = tmpMax;
    end
end

sp = sparse((maxShortestPath+1)*dimLabels*(dimLabels+1)/2, dim);
for i=1:dim
    diagMatrix = diag(Flin{i});
    labels_tmp = repmat(diagMatrix,1,length(diagMatrix));
    a = min(labels_tmp, labels_tmp');
    b = max(labels_tmp, labels_tmp');
    I = triu(~(isinf(matrixShortestPathDistance{i})));
    Ind = matrixShortestPathDistance{i}(I)*dimLabels*(dimLabels+1)/2+(a(I)-1).*(2*dimLabels+2-a(I))/2+b(I)-a(I)+1;
    tmpMax = accumarray(Ind,ones(nnz(I),1));
    sp(Ind,i) = tmpMax(Ind);
end
sp = sp(sum(sp,2)~=0,:);
K = full(sp'*sp);

if n > 0
    %normalizzo la matrice di kernel
    diagK = diag(K);
    for i=1:dim
        for j=i:dim
            K(i,j) = K(i,j)/sqrt(diagK(i)*diagK(j));
            K(j,i) = K(i,j);
        end
    end
end
end