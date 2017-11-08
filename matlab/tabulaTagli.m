%restituisce delle stime sul dataset:frequenza degli archi
%INPUT:  grafi - grafi di input
%        subgraphToNodeAssociation - array di celle che mantiene
%        l'associazione tra i sottografi di un grafo e i suoi nodi
%        (subgraphToNodeAssociation{k,i} è il vettore binario, lungo quanto
%        il numero di nodi del grafo k, che dice quali nodi di k si trovano
%        nel suo sottografo i)
%        kernelDistance - funzione che restituisce la distanza tra due
%        grafi
%        kernelDistanceFunction - funzione kernel distanza tra due grafi
%        kernelParameter - parametro del kernel
%OUTPUT: alfa - matrice delle frequenze dei gradi dei nodi
%        beta - matrice delle frequenze delle etichette
%        gamma - matrice di cell array contenente i sottografi indotti da coppie
%        di nodi connessi e indicizzata per etichetta e degree
%        gammaCut - array cell contenente i sottografi indotti da edge
%        tagliati nella fase di segmentazione
%        zeta - matrice delle probabilità su tutti gli edge
%        iota - matrice delle probabilità sugli edge dei tagli
%        distances - array cell delle matrici delle distanze dei sottografi
%        indotti per ogni tipo di edge
%        distancesCut - matrice delle distanze dei sottografi
%        indotti da ogni edge tagliato in fase di segmentazione
%        cutDegreeSum - somma dei gradi di tutti i nodi che fanno parte di
%        un taglio
function [alfa, beta, gamma, gammaCut, zeta, iota, distances, distancesCut, cutDegreeSum] = tabulaTagli(grafi, F_e, C_e, numF, subgraphToNodeAssociation, kernelDistanceFunction, kernelParameter,numLabel)
ngrafi = length(grafi);
maxNodesDegree = 0;
for k=1:ngrafi
    for i=1:size(grafi{k},1)
        deg = sum(grafi{k}(i,:)) - grafi{k}(i,i);
        if deg > maxNodesDegree
            maxNodesDegree = deg;
        end
    end
end
degrees = zeros(numLabel,maxNodesDegree);
labels = zeros(1,numLabel);

%calcolo le frequenze delle etichette, le frequenze dei gradi per
%etichetta, e i sottografi indotti dagli edge tagliati in fase di
%segmentazione
occorrenze = zeros(numLabel);
occorrenzeTagli = zeros(numLabel);
gammaCut = {};
cutDegreeSum = 0;
totalNodes = 0;
for k=1:ngrafi
    for i=1:size(grafi{k},1)
        node = ID2index(grafi{k}(i,i));
        labels(node) = labels(node) + 1;
        deg = sum(grafi{k}(i,:)) - grafi{k}(i,i);
        degrees(node,deg) = degrees(node,deg) + 1;
        totalNodes = totalNodes + 1;
    end
    for i=1:size(grafi{k},1)
       for j=i+1:size(grafi{k},1)
           if grafi{k}(i,j) == 1
                nodo1=ID2index(grafi{k}(i,i));
                nodo2=ID2index(grafi{k}(j,j));
                ind1=min(nodo1,nodo2);
                ind2=max(nodo1,nodo2);
                occorrenze(ind1,ind2)=occorrenze(ind1,ind2)+1;
           end
       end
    end
    for i=1:numF(k)
        for j=i+1:numF(k)
            F1=F_e{k,i};
            F2=F_e{k,j};
            C=C_e{k,i,j};
            for n=1:size(C,1)
                for m=1:size(C,2)
                    if C(n,m)
                        nodo1=ID2index(F1(n,n));
                        nodo2=ID2index(F2(m,m));
                        ind1=min(nodo1,nodo2);
                        ind2=max(nodo1,nodo2);
                        occorrenzeTagli(ind1,ind2)=occorrenzeTagli(ind1,ind2)+1;
                        
                        count = 0;
                        for nn=1:size(grafi{k},1)
                            if subgraphToNodeAssociation{k,i}(nn) == 1
                                count = count + 1;
                            end
                            if count == n
                                nodei = nn;
                                break;
                            end
                        end
                        count = 0;
                        for mm=1:size(grafi{k},1)
                            if subgraphToNodeAssociation{k,j}(mm) == 1
                                count = count + 1;
                            end
                            if count == m
                                nodej = mm;
                                break;
                            end
                        end
                        degi = sum(grafi{k}(nodei,:)) - grafi{k}(nodei,nodei);
                        degj = sum(grafi{k}(nodej,:)) - grafi{k}(nodej,nodej);
                        cutDegreeSum = cutDegreeSum + degi + degj;
                        inducedSubgraphij = inducedSubgraph(grafi{k}, nodei, nodej);
                        gammaCut = [gammaCut {inducedSubgraphij}];
                    end
                end
            end
        end
    end
end

%ricavo le frequenze delle etichette e dei gradi dei nodi
beta = labels/totalNodes;
alfa = zeros(numLabel,maxNodesDegree);
for i=1:numLabel
    somma = sum(degrees(i,:));
    for j=1:size(degrees,2)
        if somma > 0
            alfa(i,j) = degrees(i,j)/somma;
        end
    end
end

%ricavo la frequenza degli edge
totale = sum(sum(occorrenze));
totaleTagli = sum(sum(occorrenzeTagli));
zeta = zeros(numLabel);
iota = zeros(numLabel);
for i=1:numLabel
    for j=i:numLabel
        zeta(i,j) = occorrenze(i,j)/totale;
        zeta(j,i) = zeta(i,j);
        
        iota(i,j) = occorrenzeTagli(i,j)/totaleTagli;
        iota(j,i) = iota(i,j);
    end
end

%calcolo la matrice di cell array contenente i sottografi indotti da coppie
%di nodi connessi e indicizzata per etichetta e degree
gamma = cell(numLabel, numLabel);
for i=1:numLabel
   for j=i:numLabel
       degreesAccess = cell(maxNodesDegree, maxNodesDegree);
       gamma{i,j} = degreesAccess;
   end
end
for k=1:ngrafi
    for i=1:size(grafi{k},1)
        for j=i+1:size(grafi{k},1)
            if grafi{k}(i,j) == 1
                nodei = ID2index(grafi{k}(i,i));
                nodej = ID2index(grafi{k}(j,j));
                degi = sum(grafi{k}(i,:)) - grafi{k}(i,i);
                degj = sum(grafi{k}(j,:)) - grafi{k}(j,j);
                if nodei <= nodej
                    ind1 = nodei;
                    deg1 = degi;
                    ind2 = nodej;
                    deg2 = degj;
                else 
                    ind1 = nodej;
                    deg1 = degj;
                    ind2 = nodei;
                    deg2 = degi;
                end
                inducedSubgraphij = inducedSubgraph(grafi{k}, i, j);
                gamma{ind1,ind2}{deg1,deg2} = [gamma{ind1,ind2}{deg1,deg2} {inducedSubgraphij}];
            end
        end 
    end
end
for i=1:numLabel
    for j=i+1:numLabel
        gamma{j,i} = transpose(gamma{i,j});
    end
end

%determino le distanze tra i sottografi indotti per ogni tipo di edge
distances = cell(numLabel);
for labeli=1:numLabel
    for labelj=labeli:numLabel
        inducedSubgraphsij = [];
        for di=1:size(gamma{labeli,labelj},1)
            for dj=1:size(gamma{labeli,labelj},1)
                for e=1:size(gamma{labeli,labelj}{di,dj},2)
                    inducedSubgraphsij = [inducedSubgraphsij gamma{labeli,labelj}{di,dj}(e)];
                end
            end
        end
        if ~isempty(inducedSubgraphsij)
            dimij = size(inducedSubgraphsij,2);
            distanceMatrix = zeros(dimij);
            for i=1:dimij
                for j=i:dimij
                    distanceMatrix(i,j) = kernelDistanceFunction(inducedSubgraphsij{i},inducedSubgraphsij{j}, kernelParameter);
                    distanceMatrix(j,i) = distanceMatrix(i,j);
                end 
            end
            distances{labeli,labelj} = distanceMatrix;
            distances{labelj,labeli} = distances{labeli,labelj};
        end
    end
end

%determino le distanze tra i sottografi indotti dagli edge tagliati
dim = size(gammaCut,2);
distancesCut = zeros(dim);
for i=1:dim
    for j=i:dim
        distancesCut(i,j) = kernelDistanceFunction(gammaCut{i}, gammaCut{j}, kernelParameter);
        distancesCut(j,i) = distancesCut(i,j);
    end
end
end