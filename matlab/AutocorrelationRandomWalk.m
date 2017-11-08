%script per verificare il mixing del processo random walk, metodo preso dal
%libro Probabilistic Graphical Models

%mixing configurazione dei cluster
K = 50;
T = 300;
M = 150;
alpha = 0.1;
f = size(1, K);
for k=1:K
    [Ugen, objFunctions] = sampleClusterConfiguration(U, alpha, T, []);
    sumObjFunctions = 0;
    for i=(T - M + 1):T
        sumObjFunctions = sumObjFunctions + objFunctions(i);
    end
    f(k) = sumObjFunctions/M;
end
fChains = sum(f)/K;
B = 0;
for k=1:K
    B = B + (f(k) - fChains).^2;
end
B = (M/(K - 1))*B;
W = 0;
for k=1:K
    for i=(T - M + 1):T
        W = W + (objFunctions(i) - f(k)).^2;
    end
end
W = (1/(K*(M - 1)))*W;
V = ((M - 1)/M)*W + (1/M)*B;
R = sqrt(V/W);


%mixing grafo di cluster
% K = 50;
% T = 2000;
% M = 1000;
% alpha = 1;
% f = size(1, K);
% for k=1:K
%     initialConfiguration = initialConfigurationConnections(ncluster, numFgen, [], [], []);
%     [Cgen, objFunctions] = sampleConnectionsSubgraphs(initialConfiguration, subgraphClusteringMs, @WeisfeilerLehmanKernelDistance, 5, alpha, T, []);
%     sumObjFunctions = 0;
%     for i=(T - M + 1):T
%         sumObjFunctions = sumObjFunctions + objFunctions(i);
%     end
%     f(k) = sumObjFunctions/M;
% end
% fChains = sum(f)/K;
% B = 0;
% for k=1:K
%     B = B + (f(k) - fChains).^2;
% end
% B = (M/(K - 1))*B;
% W = 0;
% for k=1:K
%     for i=(T - M + 1):T
%         W = W + (objFunctions(i) - f(k)).^2;
%     end
% end
% W = (1/(K*(M - 1)))*W;
% V = ((M - 1)/M)*W + (1/M)*B;
% R = sqrt(V/W);


%mixing connessione nodo-nodo
% K = 50;
% T = 200;
% M = 100;
% alpha = 1;
% f = size(1, K);
% for k=1:K
%     [nodesInitialConfiguration, FgenLin, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, ~] = initialConfigurationNodes(Cgen, Fgen, numFgen, [], [], [], []);
%     Ggen = sampleConnectionsNodes(nodesInitialConfiguration, FgenLin, grafi, @WeisfeilerLehmanKernelDistance, Cgen, maxNodes, feasibleEdgeVector, feasibilityEdgeVector, selectedEdgesIndexedByFeasibleEdgeVector, selectedEdgeIndexedByType, alfa, beta, gamma, zeta, distances, 5, alphaNodesConnections, iterationsNodesConnections, []);
%     for i=(T - M + 1):T
%         sumObjFunctions = sumObjFunctions + objFunctions(i);
%     end
%     f(k) = sumObjFunctions/M;
% end
% fChains = sum(f)/K;
% B = 0;
% for k=1:K
%     B = B + (f(k) - fChains).^2;
% end
% B = (M/(K - 1))*B;
% W = 0;
% for k=1:K
%     for i=(T - M + 1):T
%         W = W + (objFunctions(i) - f(k)).^2;
%     end
% end
% W = (1/(K*(M - 1)))*W;
% V = ((M - 1)/M)*W + (1/M)*B;
% R = sqrt(V/W);
