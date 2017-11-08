%calcola la matrice di weighted decomposition kernel (Menchetti)
%INPUT:  Flin - array di celle dei sottografi (linearizzazione di F_e)
%        radius - massimo raggio di espansione dal nodo selettore
%        type - 0=selettori con qualsiasi label, 1=selettori con label
%        contenute in un label set definito nella funzione
%        WeightedDecompositionKernelSelectorExtension
%        n - indica se normalizzare o meno la matrice di kernel
%OUTPUT: K - matrice di weighted decomposition kernel (Menchetti)
function [K] = createWeightedDecompositionKernelMatrix(Flin, radius, type, n)
dim = length(Flin);
K = zeros(dim);
for i=1:dim
    for j=i:dim
        F1=Flin{i};
        F2=Flin{j};
        
        if type == 0
            simi = WeightedDecompositionKernel(F1,F2,radius);
        else
            simi = WeightedDecompositionKernelSelectorExtension(F1,F2,radius);
            %per rispettare le proprietà del graph kernel, uso il WDK base
            %per evitare di avere zeri sulla diagonale della matrice kernel
            %che nell'estensione di WDK è una cosa possibile
            if i==j && simi == 0
                simi = WeightedDecompositionKernel(F1,F2,radius);
            end
        end
        K(i,j) = simi;
        K(j,i) = simi;
    end
end

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

