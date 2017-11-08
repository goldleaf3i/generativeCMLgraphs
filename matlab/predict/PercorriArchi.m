function [ nodi_da_visitare, matr_adiac_cut_subgraph, sottografi, sottografo_riconosciuto ] = PercorriArchi( archi_da_percorrere, nodi_da_visitare, matrice_indici, matrice_corrisp, matr_adiac_cut, matr_adiac_cut_subgraph, sottografi )
%funzione che percorre gli archi che riceve in ingresso; percorre l'arco e
%arriva al nodo destinazione, aggiunge il nodo destinazione a
%nodi_da_visitare, poi verifica se l'arco percorso è un arco di cut tra due
%sottografi; se è un arco di cut allora identifica quali sono i due
%sottografi A e B da lui collegati; va in matr_adiac_cut_subgraph alle
%posizioni A e B e esamina la variabile check che trova; se vale 1
%significa che tutti gli archi di cut relativi al determinato sottografo
%sono già stati visitati se vale 0 invece no; se vale 0 allora nella
%matrice di adiacenza marca con i -1 l'arco di cut che ha percorso, poi
%controlla se gli elementi diversi da 0 della matrice sono tutti uguali a
%-1 e se si allora mette la variabile check a 1 perchè vuol dire che tutti
%gli archi di cut del sottografo sono stati visitati; ogni volta che la
%variabile check associata ad una di queste matrici di adiacenza vale 1 (o
%perchè valeva già 1 oppure perchè è stata messa a 1) si controlla se tutti
%i nodi del sottografo sono stati visitati tramite la matrice
%matrice_corrisp e se sì allora si considera il k-esimo elemento nel cell
%array sottografi e se la variabile a lui associata vale 0 allora la mette
%a 1 e segnala di aver riconosciuto un nuovo sottografo restituendo
%l'indice del sottografo riconosciuto (o gli indici dei sottografi
%riconosciuti perchè può capitare che riconosca più sottografi)

sottografo_riconosciuto = -1;
len_matr_adiac_cut = size(matr_adiac_cut, 1);

%se ci sono archi da percorrere
if(isempty(archi_da_percorrere) == 0)

    %percorro gli archi e aggiungo i nodi destinazione a nodi_da_visitare
    for i = 1:length(archi_da_percorrere)
        curr_edge = archi_da_percorrere{i};
        indice_destinazione = curr_edge(2);
        nodi_da_visitare = [nodi_da_visitare [indice_destinazione curr_edge(3)+1]];
    end
    
    for i = 1:length(archi_da_percorrere)
        curr_edge = archi_da_percorrere{i};
        indice_sorgente = curr_edge(1);
        indice_destinazione = curr_edge(2);
        arco_di_cut = 0;
        esci_dal_for_1 = 0;
        
        %per ogni arco verifico se è un arco di cut guardando in matr_adiac_cut
        for k = 1:len_matr_adiac_cut-1
            for l = i+1:len_matr_adiac_cut
                if((k == indice_sorgente && l == indice_destinazione) || (k == indice_destinazione && l == indice_sorgente))
                    if(matr_adiac_cut(k,l) == 1)
                        arco_di_cut = 1;
                    end
                    
                    esci_dal_for_1 = 1;
                    break;
                end
            end
            
            if(esci_dal_for_1 == 1)
                break;
            end
        end
        
        %se l'arco è di cut vedo quali sono i sottografi coinvolti guardando a
        %che sottografi appartengono i due nodi agli estremi dell'arco di cut
        if(arco_di_cut == 1)
            
            %trovo l'indice di colonna a cui si trova indice_sorgente
            %all'interno della matrice matrice_indici
            for k = 1:size(matrice_indici,2)
                if(matrice_indici(1,k) == indice_sorgente)
                    indice_da_controllare_sorg = k;
                    break;
                end
            end
            
            %trovo l'indice di colonna a cui si trova indice_destinazione
            %all'interno della matrice matrice_indici
            for k = 1:size(matrice_indici,2)
                if(matrice_indici(1,k) == indice_destinazione)
                    indice_da_controllare_dest = k;
                    break;
                end
            end
            
            %confronto indice_da_controllare_sorg con gli indici estremi
            %presenti in matrice_corrisp per determinare a che sottografo
            %appartiene il nodo sorgente dell'arco
            for l = 1:size(matrice_corrisp,1)
                if(indice_da_controllare_sorg >= matrice_corrisp(l,1) && indice_da_controllare_sorg <= matrice_corrisp(l,2))
                    sottografo_sorg = l;
                    break;
                end
            end
            
            %confronto indice_da_controllare_dest con gli indici estremi
            %presenti in matrice_corrisp per determinare a che sottografo
            %appartiene il nodo destinazione dell'arco
            for l = 1:size(matrice_corrisp,1)
                if(indice_da_controllare_dest >= matrice_corrisp(l,1) && indice_da_controllare_dest <= matrice_corrisp(l,2))
                    sottografo_dest = l;
                    break;
                end
            end
            
            %guardo in matr_adiac_cut_subgraph e trovo il valore delle
            %variabili check relative a sottografo_sorg e sottografo_dest
            check_sorg = matr_adiac_cut_subgraph{sottografo_sorg}{2};
            check_dest = matr_adiac_cut_subgraph{sottografo_dest}{2};
            
            if(check_sorg == 0)
                %contrassegno che ho visitato un arco di cut relativo al
                %sottografo da cui parte l'arco di cut: nella matrice di
                %adiacenza che contiene tutti e soli gli archi di cut relativi
                %al sottografo da cui parte l'arco di cut prendo i due 1 (due
                %perchè la matrice è simmetrica) corrsipondenti all'arco di cut
                %e li sostituisco con dei -1
                matrice = matr_adiac_cut_subgraph{sottografo_sorg}{1};
                matrice(indice_sorgente, indice_destinazione) = -1;
                matrice(indice_destinazione, indice_sorgente) = -1;
                matr_adiac_cut_subgraph{sottografo_sorg}{1} = matrice;
                
                %controllo gli elmenti diversi da 0 all'interno della matrice
                %che ho appena modificato e se sono tutti pari a -1 allora vuol
                %dire che ho percorso tutti gli archi di cut di questo
                %sottografo e quindi metto a 1 la variabile check a lui
                %associata
                esci_dal_for_2 = 0;
                
                for rw = 1:size(matrice,1)
                    for cl = 1:size(matrice,1)
                        if(rw ~= cl && matrice(rw,cl) ~= 0)
                            if(matrice(rw,cl) == 1)
                                esci_dal_for_2 = 1;
                                break;
                            end
                        end
                    end
                    
                    if(esci_dal_for_2 == 1)
                        break;
                    end
                end
                
                %se ho trovato solo zeri e -1 nella matrice allora gli
                %archi di cut del sottografo sono stati tutti percorsi
                if(esci_dal_for_2 == 0)
                    check_sorg = 1;
                    matr_adiac_cut_subgraph{sottografo_sorg}{2} = check_sorg;
                end
            end
            
            %se tutti gli archi di cut del sottografo da cui parte l'arco
            %di cut sono stati visitati e se anche tutti i nodi di questo
            %sottografo sono stati visitati (lo vedo usando la matrice
            %matrice_corrisp)
            if(check_sorg == 1 && matrice_corrisp(sottografo_sorg,3) == 1)
                
                %allora considero il k-esimo elemento nel cell array
                %sottografi e se la variabile a lui associata vale 0 allora
                %la metto a 1 e segnalo di aver riconosciuto un nuovo
                %sottografo restituendo il suo indice
                var = sottografi{sottografo_sorg}{2};
                
                if(var == 0)
                    sottografi{sottografo_sorg}{2} = 1;
                    
                    %se ancora non ho riconosciuto niente
                    if(sottografo_riconosciuto == -1)
                        sottografo_riconosciuto = sottografo_sorg;
                    else
                        sottografo_riconosciuto = [sottografo_riconosciuto sottografo_sorg];
                    end
                end
            end
            
            if(check_dest == 0)
                %contrassegno che ho visitato un arco di cut relativo al
                %sottografo a cui arriva l'arco di cut: nella matrice di
                %adiacenza che contiene tutti e soli gli archi di cut relativi
                %al sottografo a cui arriva l'arco di cut prendo i due 1 (due
                %perchè la matrice è simmetrica) corrsipondenti all'arco di cut
                %e li sostituisco con dei -1
                matrice = matr_adiac_cut_subgraph{sottografo_dest}{1};
                matrice(indice_sorgente, indice_destinazione) = -1;
                matrice(indice_destinazione, indice_sorgente) = -1;
                matr_adiac_cut_subgraph{sottografo_dest}{1} = matrice;
                
                %controllo gli elmenti diversi da 0 all'interno della matrice
                %che ho appena modificato e se sono tutti pari a -1 allora vuol
                %dire che ho percorso tutti gli archi di cut di questo
                %sottografo e quindi metto a 1 la variabile check a lui
                %associata
                esci_dal_for_2 = 0;
                
                for rw = 1:size(matrice,1)
                    for cl = 1:size(matrice,1)
                        if(rw ~= cl && matrice(rw,cl) ~= 0)
                            if(matrice(rw,cl) == 1)
                                esci_dal_for_2 = 1;
                                break;
                            end
                        end
                    end
                    
                    if(esci_dal_for_2 == 1)
                        break;
                    end
                end
                
                %se ho trovato solo zeri e -1 nella matrice allora gli
                %archi di cut del sottografo sono stati tutti percorsi
                if(esci_dal_for_2 == 0)
                    check_dest = 1;
                    matr_adiac_cut_subgraph{sottografo_dest}{2} = check_dest;
                end
            end  
            
            %se tutti gli archi di cut del sottografo a cui arriva l'arco
            %di cut sono stati visitati e se anche tutti i nodi di questo
            %sottografo sono stati visitati (lo vedo usando la matrice
            %matrice_corrisp)
            if(check_dest == 1 && matrice_corrisp(sottografo_dest,3) == 1)
                
                %allora considero il k-esimo elemento nel cell array
                %sottografi e se la variabile a lui associata vale 0 allora
                %la metto a 1 e segnalo di aver riconosciuto un nuovo
                %sottografo restituendo il suo indice
                var = sottografi{sottografo_dest}{2};
                
                if(var == 0)
                    sottografi{sottografo_dest}{2} = 1;
                    
                    %se ancora non ho riconosciuto niente
                    if(sottografo_riconosciuto == -1)
                        sottografo_riconosciuto = sottografo_dest;
                    else
                        sottografo_riconosciuto = [sottografo_riconosciuto sottografo_dest];
                    end
                end
            end
        end
    end
end

end

