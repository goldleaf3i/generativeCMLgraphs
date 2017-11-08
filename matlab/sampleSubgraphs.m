%seleziona i sottografi del nuovo grafo per ogni elemento positivo (=1)
%della configurazione dei cluster
%INPUT:  Ugen - array della configurazione dei cluster del nuovo grafo
%        graforig - matrice delle posizioni lineari (indici) dei sottografi
%        (elementi di F_e)
%        F_e -  array di celle delle matrici di adiacenza dei
%        sottografi (F_o{k,i} è la matrice di adiacenza del sottografo i
%        del grafo k)
%        ncluster - numero di cluster
%        clustref - matrice degli indici dei cluster di ogni sottografo
%(clustref(k,i) è l'indice del cluster dentro al quale si trova S_e{k,i},
%ossia il sottografo i del grafo k)
%        numF - array del numero di sottografi di ogni grafo
%        poscluster - array degli slot (colonne) riservati ad
%ogni cluster
%        maxsgxcluster - array dei massimi sottografi di uno stesso cluster
%che fanno parte di uno stesso grafo
%        dimBlocked - array degli indici delle dimensioni bloccate (da non
%        cambiare), può essere vuoto
%        subgraphsBlocked - array cell dei sottografi bloccati, può essere
%        vuoto
%        clustersSubgraphs - array dei cluster dei sottografi bloccati, può
%        essere vuoto
%        exploredConnections - array cell delle connessioni esplorate nei
%        sottografi bloccati, può essere vuoto
%        estremi_archi_cut_coppie_sottografi_esplorati - matrice che
%        contiene per ogni coppia di sottografi esplorati le coppie di nodi
%        che li connettono
%OUTPUT: Fgen - array cell delle matrici di adiacenza dei
%sottografi scelti per il nuovo grafo (Fgen{c,:} sono le matrici di
%adiacenza dei sottografi del cluster c)
%        numFgen - array del numero di sottografi generati per ogni cluster
%        connectedToGen - array cell con gli indici dei sottografi esplorati,
%        per memorizzare la connessione tra sottografo esplorato e un
%        sottografo campionato
%        compatibleNodesGen - array cell degli array binari che indicano i
%        nodi compatibili per sottografo scelto, con gli archi uscenti dai
%        sottografi esplorati
%        connectedToInternal - array cell con gli indici dei sottografi esplorati,
%        per memorizzare la connessione solo tra i sottografi esplorati
%        compatibleNodesInternal - array cell con le coppie di nodi
%        relativi agli archi che connettono i sottografi esplorati
%        allExploredSubgraphsGen - array cell degli indici dei sottogrfi
%        esplorati
function [Fgen, numFgen, connectedToGen, compatibleNodesGen, connectedToInternal, compatibleNodesInternal, allExploredSubgraphsGen] = sampleSubgraphs(Ugen, F_e, ncluster, clustref, numF, poscluster, maxsgxcluster, dimBlocked, subgraphsBlocked, clustersSubgraphs, exploredConnections, estremi_archi_cut_coppie_sottografi_esplorati)
    %per prima cosa ristrutturo F_e indicizzando per sottografi
    sz=size(F_e);
    ngrafi=sz(1);
    numFcluster=zeros(1,ncluster);
    for k=1:ngrafi,
        for i=1:numF(k),
            c=clustref(k,i);
            numFcluster(c)=numFcluster(c)+1;
            Fcluster{c,numFcluster(c)}=F_e{k,i};
        end
    end
    numFgen=zeros(1,ncluster);
    Fgen=cell(ncluster,max(maxsgxcluster));
        
    %scelgo in modo uniforme i sottografi da connettere ai sottografi
    %bloccati in modo consistente all'esplorazione
    connectedToGen = [];
    compatibleNodesGen = [];
    connectedToInternal = [];
    compatibleNodesInternal = [];
    allExploredSubgraphsGen = [];
    if ~isempty(dimBlocked)
        %memorizzo i sottografi bloccati
        for i=1:size(subgraphsBlocked,2)
            c = clustersSubgraphs(i);
            numFgen(c) = numFgen(c) + 1;
            Fgen{c,numFgen(c)} = subgraphsBlocked{i};
            if ~isempty(exploredConnections{i})
                exploredSubgraphsGen{i} = [c numFgen(c)];
            end
            allExploredSubgraphsGen{i} = [c numFgen(c)];
        end
        %memorizzo quanti sottografi per ogni cluster ho a disposizione
        availableClusters = zeros(1,ncluster);
        for c=1:ncluster
            for pos=poscluster(c):poscluster(c)+maxsgxcluster(c)-1,
                if Ugen(pos)==1 && ~ismember(pos,dimBlocked)
                    availableClusters(c) = availableClusters(c) + 1;
                end
            end
        end
        %cerco di soddisfare i vincoli di esplorazione
        connectedToGen=cell(ncluster,max(maxsgxcluster));
        compatibleNodesGen=cell(ncluster,max(maxsgxcluster));
        for kx=1:size(exploredConnections,2)
            for i=1:size(exploredConnections{kx},2)
                candidateSubgraphs = 0;
                node = exploredConnections{kx}{i}{2};
                degree = node(1)-1;
                label = node(2);
                for c=1:ncluster
                    if availableClusters(c) > 0
                        [~, indexFcluster, nodes] = subgraphsInCluster(Fcluster, numFcluster, c, degree, label);
                        for j=1:size(indexFcluster,2)
                            candidateSubgraphs = candidateSubgraphs + 1;
                            consistentSubgraphs{kx}{i}{candidateSubgraphs} = [c indexFcluster(j)];
                            compatible{kx}{i}{candidateSubgraphs} = nodes{j};
                        end
                    end
                end
                if candidateSubgraphs > 0
                    %scelgo un nuovo sottografo in modo uniforme tra i
                    %sottografi candidati ad essere connessi a quelli
                    %bloccati
                    chosen = fix(rand/(1/candidateSubgraphs))+1;
                    c = consistentSubgraphs{kx}{i}{chosen}(1);
                    kFcluster = consistentSubgraphs{kx}{i}{chosen}(2);
                                        
                    numFgen(c) = numFgen(c) + 1;
                    Fgen{c,numFgen(c)}=Fcluster{c,kFcluster};
                    connectedToGen{c,numFgen(c)} = {exploredSubgraphsGen{kx}};
                    cExplored = exploredSubgraphsGen{kx}(1);
                    kFgenExplored = exploredSubgraphsGen{kx}(2);
                    connectedToGen{cExplored,kFgenExplored} = {[c numFgen(c)]};
                    compatibleNodesGen{c,numFgen(c)} = {compatible{kx}{i}{chosen}};
                    nodes = zeros(1,size(Fgen{cExplored,kFgenExplored},1));
                    nodes(exploredConnections{kx}{i}{1}(1)) = 1;
                    compatibleNodesGen{cExplored,kFgenExplored} = {nodes};
                    
                    pos = poscluster(c) + availableClusters(c) - 1;
                    Ugen(pos) = Ugen(pos) - 1;
                    availableClusters(c) = availableClusters(c) - 1;
                else
                    %controllo tra i sottografi che ho già scelto
                    for c=1:ncluster
                        [~, indexFgen, nodes] = subgraphsInCluster(Fgen, numFgen, c, degree, label);
                        for j=1:size(indexFgen,2)
                            %controllo che il sottografo corrente non è un
                            %sottografo esplorato
                            sBlocked = 0;
                            for kk=1:size(allExploredSubgraphsGen,2)
                                if allExploredSubgraphsGen{kk}(1) == c && allExploredSubgraphsGen{kk}(2) == indexFgen(j)
                                    sBlocked = 1;
                                    break;
                                end
                            end
                            if sBlocked == 0
                                candidateSubgraphs = candidateSubgraphs + 1;
                                consistentSubgraphs{kx}{i}{candidateSubgraphs} = [c indexFgen(j)];
                                compatible{kx}{i}{candidateSubgraphs} = nodes{j};
                            end
                        end
                    end
                    if candidateSubgraphs > 0
                        chosen = fix(rand/(1/candidateSubgraphs))+1;
                        c = consistentSubgraphs{kx}{i}{chosen}(1);
                        kFgen = consistentSubgraphs{kx}{i}{chosen}(2);

                        connectedToGen{c,kFgen} = [connectedToGen{c,kFgen} {exploredSubgraphsGen{kx}}];
                        cExplored = exploredSubgraphsGen{kx}(1);
                        kFgenExplored = exploredSubgraphsGen{kx}(2);
                        connectedToGen{cExplored,kFgenExplored} = [connectedToGen{cExplored,kFgenExplored} {[c kFgen]}];
                        compatibleNodesGen{c,kFgen} = [compatibleNodesGen{c,kFgen} {compatible{kx}{i}{chosen}}];
                        nodes = zeros(1,size(Fgen{cExplored,kFgenExplored},1));
                        nodes(exploredConnections{kx}{i}{1}(1)) = 1;
                        compatibleNodesGen{cExplored,kFgenExplored} = [compatibleNodesGen{cExplored,kFgenExplored} {nodes}];
                    end
                end
            end
        end
        
        %memorizzo gli archi interni ai sottografi esplorati
        connectedToInternal=cell(ncluster,max(maxsgxcluster));
        compatibleNodesInternal=cell(ncluster,max(maxsgxcluster));
        for i=1:size(allExploredSubgraphsGen, 2)
            ci = allExploredSubgraphsGen{i}(1);
            kFgeni = allExploredSubgraphsGen{i}(2);
            for j=i+1:size(allExploredSubgraphsGen, 2)
                cj =  allExploredSubgraphsGen{j}(1);
                kFgenj = allExploredSubgraphsGen{j}(2);

                cuts = estremi_archi_cut_coppie_sottografi_esplorati{i,j};
                for icut=1:size(cuts,2)
                    nodei = zeros(1,size(subgraphsBlocked{i},1));
                    nodej = zeros(1,size(subgraphsBlocked{j},1));
                    nodei(cuts{icut}(1)) = 1;
                    nodej(cuts{icut}(2)) = 1;
                    connectedToInternal{ci,kFgeni} = [connectedToInternal{ci,kFgeni} {allExploredSubgraphsGen{j}}];
                    connectedToInternal{cj,kFgenj} = [connectedToInternal{cj,kFgenj} {allExploredSubgraphsGen{i}}];
                    compatibleNodesInternal{ci,kFgeni} = [compatibleNodesGen{ci,kFgeni} {nodei}];
                    compatibleNodesInternal{cj,kFgenj} = [compatibleNodesInternal{cj,kFgenj} {nodej}];
                end
            end
        end
    end
     
    %scelgo in modo uniforme i sottografi rimanenti
    for c=1:ncluster
        for pos=poscluster(c):poscluster(c)+maxsgxcluster(c)-1
            if Ugen(pos)==1 && ~ismember(pos,dimBlocked)
                %prendo un grafo in modo uniforme con cluster c
                 i=fix(rand/(1/numFcluster(c)))+1;
                 numFgen(c) = numFgen(c) + 1;
                 Fgen{c,numFgen(c)}=Fcluster{c,i};
            end
        end
    end
end