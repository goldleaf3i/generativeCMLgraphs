%restituisce i sottografi appartenenti ad un certo cluster che hanno almeno
%un nodo con una certa etichetta e un certo grado
%INPUT:  Fcluster - array cell che contiene i sottografi appartenenti ad
%ogni cluster
%        numFcluster - array che contiene il numero di sottografi per ogni
%        cluster
%        c - indice del cluster
%        degree - grado del nodo
%        label - etichetta del nodo
%OUTPUT: subgraphs - sottografi ricercati in base alla presenza di un nodo
%        specificato in input
%        indexFcluster - array di indici dei sottografi in Fcluster
%        compatibleNodes - array cell per ogni sottografo con gli array
%        binari dei nodi compatibili con il nodo specificato in input
function [subgraphs, indexFcluster, compatibleNodes] = subgraphsInCluster(Fcluster, numFcluster, c, degree, label)
   counter = 0;
   subgraphs = [];
   indexFcluster = [];
   compatibleNodes = [];
   for k=1:numFcluster(c)
       s = removeDummy(Fcluster{c,k});
       nodes = zeros(1,size(s,1));
       for i=1:size(s,1)
           if s(i,i) == label && sum(s(i,:))-s(i,i) == degree
               nodes(i) = 1;
           end
       end
       if sum(nodes) > 0
            counter = counter + 1;
            subgraphs{counter} = s;
            indexFcluster(counter) = k;
            compatibleNodes{counter} = nodes;
       end
   end
end