%seleziona le connessioni tra i sottografi del nuovo grafo tramite
%stochastic block model
%INPUT:  initialConfiguration - configurazione iniziale di lunghezza
%        fissata
%        M - matrice stochastic block model, la si può aver già calcolata
%        subgraphClusteringMs - array cell delle matrici di connettività dei
%sottografi (subgraphClusteringMs{k}(i,j) con i diverso da j, rappresenta
%il numero di connessioni tra il sottografo i e quello j del grafo k; se i
%è uguale a j rappresenta l'indice del cluster in cui si trova il
%sottografo i
%        ncluster - numero di cluster
%OUTPUT: Cgen - matrice di connettività tra i sottografi di Fgen
%        M - matrice stochastic block model
function [Cgen, M] = sampleConnectionsStochasticBlockModel(initialConfiguration, M, subgraphClusteringMs,ncluster)
if isempty(M)
    %creo la matrice stochastic block model
    M = stochasticBlockModel(subgraphClusteringMs,ncluster);
end

%inizializzo la matrice delle connessioni
dimS = size(initialConfiguration,1);
Cgen = zeros(dimS);
for i=1:dimS
    Cgen(i,i) = initialConfiguration(i,i);
end

%ciclo fino a quando non ottengo un grafo connesso
iteration = 0;
maxIteration = 100000;
while checkDiscardSample(Cgen) == 1 && iteration <= maxIteration
    iteration = iteration + 1;
    for i=1:dimS
        for j=i+1:dimS
            Cgen(i,j) = rand < M(Cgen(i,i),Cgen(j,j));
            Cgen(j,i) = Cgen(i,j);
        end
    end
end

if iteration > maxIteration
    Cgen = [];
end
end