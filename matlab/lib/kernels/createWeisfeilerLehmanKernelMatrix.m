%calcola la matrice di Weisfeiler Lehman Subtree kernel
%INPUT:  Flin - array di celle dei sottografi (linearizzazione di F_e)
%        radius - massimo raggio di espansione dal nodo selettore
%        h - numero di iterazioni
%        n - indica se normalizzare o meno la matrice di kernel
%OUTPUT: K - matrice di Weisfeiler Lehman Subtree kernel
function [K] = createWeisfeilerLehmanKernelMatrix(Flin, h, n)
dim = size(Flin,2);
adyacencyList = cell(1,dim);
tmpK = cell(1,h+1);
totalNodes = 0;
for k=1:dim
  adyacencyList{k} = adjacencyList(Flin{k});
  totalNodes = totalNodes + size(Flin{k},1);
end
% ogni colonna k è il vettore delle feature del grafo k. Il vettore delle
% feature associa ad ogni label distinta (elemento del vettore) il numero
% di volte in cui compare nel grafo
features = zeros(totalNodes,dim);

% mapping dalle label come stringhe alle label come interi
labelMapping = containers.Map();
numLabels = 1;

for k=1:dim
    % memorizza le label per ogni grafo sotto forma di numeri interi in
    % modo progressivo
    labels{k} = zeros(size(Flin{k},1),1);
    for j=1:size(Flin{k},1)
      stringLabel = num2str(Flin{k}(j,j));
      if ~isKey(labelMapping, stringLabel)
        labelMapping(stringLabel) = numLabels;
        labels{k}(j) = numLabels;
        numLabels = numLabels + 1;
      else
        labels{k}(j) = labelMapping(stringLabel);
      end
      % aggiorna il numero di volte in cui la label corrente compare nel
      % grafo corrente
      features(labels{k}(j),k) = features(labels{k}(j),k) + 1;
    end
end

tmpK{1} = features'*features;

iteration = 1;
newLabels = labels;
while iteration <= h
  labelMapping = containers.Map();
  numLabels = 1;
  features = zeros(totalNodes,dim);
  for k=1:dim
    for j=1:length(adyacencyList{k})
      % determino e ordino il multiset label del nodo corrente del grafo
      % corrente
      multisetLabel=[labels{k}(j), sort(labels{k}(adyacencyList{k}{j}))'];
      multisetLabelString=char(multisetLabel);
      if ~isKey(labelMapping, multisetLabelString)
        labelMapping(multisetLabelString) = numLabels;
        newLabels{k}(j) = numLabels;
        numLabels = numLabels + 1;
      else
        newLabels{k}(j) = labelMapping(multisetLabelString);
      end
    end
    % aggiorno il vettore delle feature
    aux = accumarray(newLabels{k}, ones(length(newLabels{k}),1));
    features(newLabels{k},k) = features(newLabels{k},k) + aux(newLabels{k});
  end
  tmpK{iteration+1} = tmpK{iteration} + features'*features;
  labels = newLabels;
  iteration = iteration + 1;
end
K = tmpK{iteration};

if n > 0
    %normalizzo la matrice di kernel
    diagK = diag(K);
    for k=1:dim
        for j=k:dim
            K(k,j) = K(k,j)/sqrt(diagK(k)*diagK(j));
            K(j,k) = K(k,j);
        end
    end
end
end

