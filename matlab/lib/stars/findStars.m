%estrae da un grafo ricevuto in ingresso tutte le stelle di  dimensione
%stars
%INPUT:  grafo - un grafo in ingresso
%        stars - la dimensione delle stelle da ricercare
%OUTPUT: M - un array di vettori contenente al primo elemento la label del
%        nodo al centro della stella, agli altri elementi le label dei nodi
%        che compongono la stella
function [M] = findStars(grafo, stars,label_list)
M = {};
ctr  = 1;
[~,dim] = size(grafo);
[num_of_labels,~] = size(label_list);
for i=1:dim 
    if stars == sum(grafo(:,i)~=0)-1
        list_idx = find(grafo(i,:));
        ctr2 = 2;
        grafotmp = zeros(num_of_labels,stars+1);
        for j=list_idx 
            if j ~= i
                grafotmp(find(label_list==grafo(j,j)),ctr2) = 1;
                ctr2 = ctr2+1;
            end
        end
        %grafotmp = sort(grafotmp);
        grafotmp(find(label_list==grafo(i,i)),1) = 1;
        M{ctr}= grafotmp;
        ctr = ctr+1;
    end
end
                
            
        
