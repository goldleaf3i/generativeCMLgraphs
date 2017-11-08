%calcola la matrice di neighborhood hash kernel (Kashima)
%INPUT:  Flin - array di celle dei sottografi (linearizzazione di F_e)
%        (elementi di F_e)
%        R - massimo ordine di neighborhood hash
%OUTPUT: K - matrice di neighborhood hash kernel (Kashima)
function [K] = createNeighborhoodHashKernelMatrix(Flin, R)
dim = length(Flin);
Kr = cell(1,R);
Vsort = cell(1, dim);
for r=1:R
    Kr{r} = eye(dim);
    for i=1:dim
        F = Flin{i};
        dimF = length(F);
        
        %calcolo le bit label dei nodi
        bitLabels = cell(1, dimF);
        for l=1:dimF
            bitLabels{l} = ID2Bit(F(l,l));
        end
        
        %per ogni nodo calcolo le neighborhood hash
        Vsort{i} = cell(1, dimF);
        adjList = adjacencyList(F);
        for j=1:dimF
            adjacentNodes = adjList{j};
            adjacentBinaryNodes = cell(1, length(adjacentNodes));
            for l=1:length(adjacentBinaryNodes)
                adjacentBinaryNodes{l} = bitLabels{adjacentNodes(l)};
            end
            %se il nodo ha dei nodi vicini calcolo la count sensitive
            %neighborhood hash, altrimenti l'hash è dato solo dalla bit
            %label del nodo stesso
            if ~isempty(adjacentBinaryNodes)
                Vsort{i}{j} = countSensitiveNeighborhoodHash(bitLabels{j}, adjacentBinaryNodes);
            else
                Vsort{i}{j} = bitLabels{j};
            end
        end
        
        %ordino le neighborhood hash
        Vsort{i} = radixSortBinary(Vsort{i});
    end
    
    for i=1:dim
        for j=i:dim
            Kr{r}(i,j) = compareLabels(Vsort{i},Vsort{j});
            Kr{r}(j,i) = Kr{r}(i,j);
        end
    end
end
K = zeros(dim);
for r=1:R
    K = K + Kr{r};
end
K = K/R;

end