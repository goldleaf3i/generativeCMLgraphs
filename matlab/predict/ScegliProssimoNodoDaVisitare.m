function [ prossimo_nodo, nodi_da_visitare ] = ScegliProssimoNodoDaVisitare( nodi_da_visitare )
%funzione che prende i nodi da visitare e tra quelli sceglie il prossimo
%che deve essere visitato, ovvero il nodo più vicino alla radice visto che
%stiamo facendo esplorazione in ampiezza; se più nodi si trovano alla
%profondità minore dalla radice allora sceglie il primo che ha trovato;
%fatto ciò memorizza il prossimo nodo da visitare e lo elimina dai nodi da
%visitare

len = length(nodi_da_visitare);
profondita = Inf;

%scelgo il prossimo nodo da visitare
for i = 1:len
    curr_node = nodi_da_visitare{i};
    prof_curr_node = curr_node(2);
    
    if(prof_curr_node < profondita)
        profondita = prof_curr_node;
        prossimo_nodo = curr_node;
        indice_trovato_prossimo_nodo = i;
    end
end

%elimino il nodo scelto dalla lista di nodi da visitare
tmp = {};

for i = 1:len
    if(i ~= indice_trovato_prossimo_nodo)
        tmp = [tmp nodi_da_visitare{i}];
    end
end

nodi_da_visitare = tmp;

end

