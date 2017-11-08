%inizializza il grafo delle connessioni dei cluster
%INPUT:  ncluster - numero di cluster
%        numFgen - array del numero di sottografi generati per ogni cluster
%        connectedToGen - array cell con gli indici dei sottografi esplorati,
%        per memorizzare la connessione tra sottografo esplorato e un
%        sottografo campionato
%        connectedToInternal - matrice contenente per ogni coppia di
%        sottografi gli archi che li collegano
%        exploredSubgraphsGen - array cell degli indici dei sottografi
%        esplorati
%OUTPUT: initialConfiguration - configurazione iniziale di lunghezza
%        fissata
%        dimBlocked - dimensioni bloccate
function [initialConfiguration, dimBlocked] = initialConfigurationConnections(ncluster, numFgen, connectedToGen, connectedToInternal, exploredSubgraphsGen)
    %crea la matrice di adiacenza della configurazione iniziale (solo
    %diagonale)
    dim = sum(numFgen);
    initialConfiguration = zeros(dim);
    indexSubgraph = 0;
    for c=1:ncluster
        totalClusterSubgraphs = numFgen(c);
        if totalClusterSubgraphs > 0
            for i=1:totalClusterSubgraphs
                indexSubgraph = indexSubgraph + 1;
                initialConfiguration(indexSubgraph,indexSubgraph) = c;
            end
        end
    end
    
    %inizializzo ad uno stato consistente in cui c'è solo una componente del grafo
    for i=1:size(initialConfiguration,1)-1
        initialConfiguration(i,i+1) = 1;
        initialConfiguration(i+1,i) = 1;
    end
    
    dimBlocked = [];
    if ~isempty(connectedToGen)
        %memorizzo gli indici progressivi dei sottografi dall'alto verso il basso
        counter = 0;
        for c=1:ncluster
            for i=1:numFgen(c)
                counter = counter + 1;
                FgenLin{c,i} = counter;
            end
        end
        
        dimBlocked = zeros(size(initialConfiguration,1));
        %inserisco gli archi bloccati tra i sottografi esplorati
        for i=1:size(exploredSubgraphsGen,2)
            indi = FgenLin{exploredSubgraphsGen{i}(1),exploredSubgraphsGen{i}(2)};
            for indj=1:size(initialConfiguration,1)
                if indi ~= indj
                    initialConfiguration(indi,indj) = 0;
                    initialConfiguration(indj,indi) = initialConfiguration(indi,indj);
                    
                    dimBlocked(indi,indj) = 1;
                    dimBlocked(indj,indi) = dimBlocked(indi,indj);
                end
            end
            next = indi + 1;
            prev = indi - 1;
            if next <= size(initialConfiguration,1) && prev >= 1
                con = 1;
                while prev >= 1 && con
                    for ii=1:size(exploredSubgraphsGen,2)
                        indii = FgenLin{exploredSubgraphsGen{ii}(1),exploredSubgraphsGen{ii}(2)};
                        if prev == indii
                            con = 0;
                            break;
                        end
                    end
                    if con == 0
                        prev = prev - 1;
                        con = 1;
                    else
                        break;
                    end
                 end
                 con = 1;
                 while next <= size(initialConfiguration,1) && con
                    for ii=1:size(exploredSubgraphsGen,2)
                        indii = FgenLin{exploredSubgraphsGen{ii}(1),exploredSubgraphsGen{ii}(2)};
                        if next == indii
                            con = 0;
                            break;
                        end
                    end
                    if con == 0
                        next = next + 1;
                        con = 1;
                    else
                        break;
                    end
                 end
            end
            if prev >=1 && next <= size(initialConfiguration,1) 
                initialConfiguration(prev,next) = 1;
                initialConfiguration(next,prev) = 1;
            end
        end
        for i=1:size(connectedToInternal,1)
            for j=1:size(connectedToInternal,2)
                if ~isempty(connectedToInternal{i,j})
                    indi = FgenLin{exploredSubgraphsGen{i}(1),exploredSubgraphsGen{i}(2)};
                    indj = FgenLin{exploredSubgraphsGen{j}(1),exploredSubgraphsGen{j}(2)};
                    initialConfiguration(indi,indj) = 1;
                    initialConfiguration(indj,indi) = initialConfiguration(indi,indj);
                    
                    dimBlocked(indi,indj) = 1;
                    dimBlocked(indj,indi) = dimBlocked(indi,indj);
                end
            end
        end
        
        %inserisco gli archi bloccati che escono dai sottografi esplorati
        for c=1:ncluster
            for i=1:numFgen(c)
                if ~isempty(connectedToGen{c,i})
                    for j=1:size(connectedToGen{c,i},2)
                        indi = FgenLin{c,i};
                        indj = FgenLin{connectedToGen{c,i}{j}(1),connectedToGen{c,i}{j}(2)};
                        initialConfiguration(indi,indj) = 1;
                        initialConfiguration(indj,indi) = initialConfiguration(indi,indj);
                        
                        dimBlocked(indi,indj) = 1;
                        dimBlocked(indj,indi) = dimBlocked(indi,indj);
                    end
                end
            end
        end
    end
end