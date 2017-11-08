function [ archi_da_percorrere, matrice_indici, matrice_corrisp, sottografi, sottografo_riconosciuto ] = VisitaNodo( nodo, grafo, matrice_indici, matrice_corrisp, matr_adiac_cut_subgraph, sottografi )
%funzione che visita un nodo; per prima cosa controlla se il nodo è già
%stato visitato e se è già stato visitato allora non fa niente; se non è
%già stato visitato lo segna come visitato in matrice_indici e trova tutti
%gli archi che devono essere percorsi per raggiungere i nodi a lui
%adiacenti; poi controlla se tutti i nodi del sottografo k di cui fa parte
%sono stati visitati o meno e se sono stati visitati tutti allora mette un
%1 in matrice_corrisp(k,3), poi controlla se gli archi di cut del
%sottografo k sono stati percorsi tutti (tramite la variabile check
%associata al sottografo k all'interno di matr_adiac_cut_subgraph), se sì
%allora considera il k-esimo elemento nel cell array sottografi e se la
%variabile a lui associata vale 0 allora la mette a 1 e segnala di aver
%riconosciuto un nuovo sottografo restituendo l'indice del sottografo
%riconosciuto

archi_da_percorrere = {};
sottografo_riconosciuto = -1;

%controllo se il nodo è già stato visitato, se non è già stato visitato lo
%segno come visitato
for i = 1:size(matrice_indici,2)
    if(matrice_indici(1,i) == nodo(1))
        if(matrice_indici(2,i) == 0)
            nodo_gia_visitato = 1;
        elseif(matrice_indici(2,i) == 1)
            nodo_gia_visitato = 0;
            matrice_indici(2,i) = 0;
            indice_matrice_indici = i;
        end
        
        break;
    end
end

%se il nodo non è già stato visitato trovo i nodi a lui adiacenti e mi
%ricavo la lista di archi da percorrere per raggiungerli
if(nodo_gia_visitato == 0)
    for j = 1:size(grafo, 2)
       if(nodo(1) ~= j && grafo(nodo(1),j) == 1)
           archi_da_percorrere = [archi_da_percorrere [nodo(1) j nodo(2)]];
       end
    end
    
    %controllo se tutti i nodi del sottografo k di cui il nodo fa parte
    %sono stati visitati o meno e se sono stati visitati tutti allora metto
    %un 1 in matrice_corrisp(k,3)
    for k = 1:size(matrice_corrisp,1)
        if(indice_matrice_indici >= matrice_corrisp(k,1) && indice_matrice_indici <= matrice_corrisp(k,2))
            sottografo_nodo = k;
            break;
        end
    end
    
    if(sum(matrice_indici(2,matrice_corrisp(sottografo_nodo,1):matrice_corrisp(sottografo_nodo,2))) == 0)
        matrice_corrisp(sottografo_nodo,3) = 1;
    end

    %se tutti i nodi del sottografo sono stati visitati controllo se tutti gli
    %archi di cut del sottografo sono stati percorsi
    if(matrice_corrisp(sottografo_nodo,3) == 1)
        check = matr_adiac_cut_subgraph{sottografo_nodo}{2};
        
        %se tutti gli archi di cut del sottografo sono stati visitati allora
        %considero il k-esimo elemento nel cell array sottografi e se la
        %variabile a lui associata vale 0 allora la metto a 1 e segnalo di aver
        %riconosciuto un nuovo sottografo restituendo il suo indice
        if(check == 1)
            var = sottografi{sottografo_nodo}{2};
            
            if(var == 0)
                sottografi{sottografo_nodo}{2} = 1;
                sottografo_riconosciuto = sottografo_nodo;
            end
        end
    end
end

end

