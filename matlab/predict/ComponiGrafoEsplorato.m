function [ grafo_esplorato, archi_cut_uscenti ] = ComponiGrafoEsplorato( grafo, matrice_indici, matrice_corrisp, matr_adiac_cut_subgraph, sottografi )
%prende tutti i sottografi che sono stati riconosciuti e li mette in una
%matrice diagonale a blocchi, poi vede quali sono gli archi di cut che
%legano tra loro i sottografi riconosciuti e per ognuno di questi archi di
%cut mette un 1 nella matrice diagonale a blocchi nelle posizioni
%appropriate in modo da connettere i sottografi, restituisce (variabile
%archi_cut_uscenti) anche gli archi di cut uscenti dal grafo esplorato
%verso altri sottografi non ancora riconosciuti

%cell array i cui elementi sono cell array che contengono quattro elementi:
%un array che rappresenta un arco uscente dal grafo esplorato (con solo i
%due indici dei nodi estremi dell'arco, senza la profondità del nodo sorgente
%dell'arco), un array che contiene i tre tipi di indice del nodo che
%corrisponde all'estremo dell'arco uscente dal grafo esplorato che fa parte
%del grafo esplorato (ovvero l'indice di nodo all'interno del grafo
%originale, l'indice di nodo all'interno della matrice diagonale a blocchi
%che rappresenta il grafo esplorato e l'indice di nodo all'interno del
%sottografo che lo contiene), l'indice del sottografo che contiene il nodo
%che corrisponde all'estremo dell'arco uscente dal grafo esplorato che fa
%parte del grafo esplorato e un array che contiene il grado e la label del
%nodo che rappresenta l'estremo dell'arco di cut che non fa parte del grafo
%esplorato
archi_cut_uscenti = {};

%controllo quali sono i sottografi che sono stati riconosciuti guardando
%dentro il cell array sottografi e ogni volta che trovo un sottografo
%riconosciuto mi segno l'indice di colonna del cell array sottografi in cui
%ho trovato il sottografo riconosciuto e lo metto nell'array
%indici_sottografi_riconosciuti
indici_sottografi_riconosciuti = [];

for i = 1:length(sottografi)
    var = sottografi{i}{2};
    
    if(var == 1)
        indici_sottografi_riconosciuti = [indici_sottografi_riconosciuti i];
    end
end

%inizio a comporre la matrice diagonale a blocchi inserendo le matrici di
%adiacenza dei sottografi riconosciuti

%trovo la dimensione che avrà la matrice diagonale a blocchi
dimensione_matr_diag_blocchi = 0;

for i = indici_sottografi_riconosciuti
    matrice = sottografi{i}{1};
    dimensione_matr_diag_blocchi = dimensione_matr_diag_blocchi + size(matrice, 1);
end

matrice_diag_blocchi = zeros(dimensione_matr_diag_blocchi, dimensione_matr_diag_blocchi);

%calcolo gli offset che gli elementi di ciascun sottografo avranno una
%volta inseriti nella matrice diagonale a blocchi; offset è una matrice che
%nella prima prima riga contiene gli indici dei sottografi riconosciuti e
%nella seconda il valore dell'offset associato a ciascun sottografo
%riconosciuto
offset = zeros(1, length(indici_sottografi_riconosciuti));
offset = [indici_sottografi_riconosciuti; offset];

for i = 2:length(indici_sottografi_riconosciuti)
    indice_sottogr_ricon = indici_sottografi_riconosciuti(i-1);
    matrice = sottografi{indice_sottogr_ricon}{1};
    offset(2,i) = offset(2,i-1) + size(matrice,1);
end

%riempio la matrice diagonale a blocchi
for i = indici_sottografi_riconosciuti
    
    %trovo l'offset per il sottografo i
    for j = 1:size(offset,2)
        if(offset(1,j) == i)
            curr_offset = offset(2,j);
        end
    end
    
    matrice = sottografi{i}{1};
        
    for k = 1:size(matrice, 1)
        for l = 1:size(matrice, 1)
            matrice_diag_blocchi(k+curr_offset,l+curr_offset) = matrice(k,l);
        end
    end
end

%controllo se i sottografi riconosciuti finora sono connessi tra loro e se
%sì allora riporto il link nella matrice diagonale a blocchi mettendo un 1
%nella posizione appropriata

%se c'è un solo sottografo riconosciuto non devo fare niente
if(length(indici_sottografi_riconosciuti) > 1)
    
    %ricavo le matrici di adiacenza degli archi di cut dei due sottografi
    for i = 1:length(indici_sottografi_riconosciuti)-1
        for j = i+1:length(indici_sottografi_riconosciuti)
            indice_sottografo_i = indici_sottografi_riconosciuti(i);
            indice_sottografo_j = indici_sottografi_riconosciuti(j);
            matr_adiac_cut_sottografo_i = matr_adiac_cut_subgraph{indice_sottografo_i}{1};
            matr_adiac_cut_sottografo_j = matr_adiac_cut_subgraph{indice_sottografo_j}{1};
            
            %ricavate le matrici di adiacenza degli archi di cut di
            %entrambe i sottografi in esame guardo se hanno degli archi di
            %cut in comune
            archi_cut_in_comune = {};
            
            %guardo solo la parte superiore delle matrici diagonale esclusa
            %perchè tanto sono simmetriche
            for k = 1:size(matr_adiac_cut_sottografo_i,1)-1
                for l = k+1:size(matr_adiac_cut_sottografo_i,1)
                    elem_i = matr_adiac_cut_sottografo_i(k,l);
                    elem_j = matr_adiac_cut_sottografo_j(k,l);
                    
                    %se l'arco di cut è presente in entrambe le matrici
                    %allora lo aggiungo alla lista degli archi di cut in
                    %comune
                    if(elem_i == -1 && elem_j == -1)
                        archi_cut_in_comune = [archi_cut_in_comune [k,l]];
                    end
                end
            end
                        
            %gli indici dei nodi che rappresentano gli estremi degli archi
            %in comune che ho trovato sono gli indici dei nodi nel grafo
            %originale, quindi prima di poter aggiungere quegli archi alla
            %matrice diagonale a blocchi mi devo ricavare gli indici dei
            %nodi dei sottografi corrispondenti agli indici dei nodi del
            %grafo originale che rappresentano gli estremi degli archi
            %in comune che ho trovato
            
            %per ogni arco di cut in comune trovato
            for k = 1:length(archi_cut_in_comune)
                arco = archi_cut_in_comune{k};
                indice_nodo_grafo_primo_estremo = arco(1);
                indice_nodo_grafo_secondo_estremo = arco(2);
                
                %cerco indice_nodo_grafo_primo_estremo e
                %indice_nodo_grafo_secondo_estremo in matrice_indici e vedo a
                %che sottografo appartengono tramite matrice_corrisp                
                
                %trovo l'indice di colonna a cui si trova
                %indice_nodo_grafo_primo_estremo all'interno della matrice
                %matrice_indici
                for l = 1:size(matrice_indici,2)
                    if(matrice_indici(1,l) == indice_nodo_grafo_primo_estremo)
                        indice_da_controllare_primo_estremo = l;
                        break;
                    end
                end
                
                %trovo l'indice di colonna a cui si trova
                %indice_nodo_grafo_secondo_estremo all'interno della matrice
                %matrice_indici
                for l = 1:size(matrice_indici,2)
                    if(matrice_indici(1,l) == indice_nodo_grafo_secondo_estremo)
                        indice_da_controllare_secondo_estremo = l;
                        break;
                    end
                end
                
                %confronto indice_da_controllare_primo_estremo con gli indici
                %estremi presenti in matrice_corrisp per determinare a che
                %sottografo appartiene il nodo il cui indice è
                %indice_nodo_grafo_primo_estremo
                for l = 1:size(matrice_corrisp,1)
                    if(indice_da_controllare_primo_estremo >= matrice_corrisp(l,1) && indice_da_controllare_primo_estremo <= matrice_corrisp(l,2))
                        sottografo_primo_estremo = l;
                        break;
                    end
                end
                
                %confronto indice_da_controllare_secondo_estremo con gli indici
                %estremi presenti in matrice_corrisp per determinare a che
                %sottografo appartiene il nodo il cui indice è
                %indice_nodo_grafo_secondo_estremo
                for l = 1:size(matrice_corrisp,1)
                    if(indice_da_controllare_secondo_estremo >= matrice_corrisp(l,1) && indice_da_controllare_secondo_estremo <= matrice_corrisp(l,2))
                        sottografo_secondo_estremo = l;
                        break;
                    end
                end
                
                %ricavo gli indici di sottografo corrispondenti agli indici
                %del grafo originale
                inizio_intervallo_primo_estremo = matrice_corrisp(sottografo_primo_estremo,1);
                inizio_intervallo_secondo_estremo = matrice_corrisp(sottografo_secondo_estremo,1);
                indice_nodo_sottografo_primo_estremo = indice_da_controllare_primo_estremo - inizio_intervallo_primo_estremo + 1;
                indice_nodo_sottografo_secondo_estremo = indice_da_controllare_secondo_estremo - inizio_intervallo_secondo_estremo + 1;
                
                %ottenuti i due indici di sottografo che devo collegare
                %vado a mettere un 1 nella posizione giusta (in realtà lo
                %metto nelle due posizioni giuste, perchè la matrice è
                %simmetrica) nella matrice diagonale a blocchi usando gli
                %offset che ho calcolato prima
                
                %recupero l'offset del nodo che rappresenta il primo
                %estremo dell'arco di cut
                for l = 1:size(offset,2)
                    if(offset(1,l) == sottografo_primo_estremo)
                        offset_primo_estremo = offset(2,l);
                    end
                end
                
                %recupero l'offset del nodo che rappresenta il secondo
                %estremo dell'arco di cut
                for l = 1:size(offset,2)
                    if(offset(1,l) == sottografo_secondo_estremo)
                        offset_secondo_estremo = offset(2,l);
                    end
                end
                
                %metto l'arco nella matrice diagonale a blocchi
                riga = indice_nodo_sottografo_primo_estremo + offset_primo_estremo;
                colonna = indice_nodo_sottografo_secondo_estremo + offset_secondo_estremo;
                matrice_diag_blocchi(riga, colonna) = 1;
                matrice_diag_blocchi(colonna, riga) = 1;
            end
        end
    end
    
    grafo_esplorato = matrice_diag_blocchi;
    
elseif(length(indici_sottografi_riconosciuti) == 1)
    %è stato finora riconosciuto un solo sottografo, quindi non faccio
    %altro che restituirlo
    grafo_esplorato = sottografi{indici_sottografi_riconosciuti}{1};
end

%trovo gli archi di cut uscenti dal grafo esplorato
archi_cut_non_comune = {};

%sommo tra di loro le matrici di adiacenza contenenti gli archi di cut di
%tutti i sottografi che sono stati riconosciuti, in questo modo ottengo una
%matrice in cui gli elementi pari a -2 indicano la presenza di un arco di
%cut in comune tra due sottografi riconosciuti (e facenti quindi parte del
%grafo esplorato) mentre invece gli elementi pari a -1 corrsipondono ad
%archi di cut uscenti dal grafo finora esplorato e connessi ad altri
%sottografi non ancora riconosciuti
matrice_somma = zeros(size(matr_adiac_cut_subgraph{1}{1}, 1), size(matr_adiac_cut_subgraph{1}{1}, 1));

for k = indici_sottografi_riconosciuti
    matrice_somma = matrice_somma + matr_adiac_cut_subgraph{k}{1};
end
    
%guardo solo la parte superiore di matrice_somma, diagonale esclusa, perchè
%tanto è simmetrica
for k = 1:size(matrice_somma,1)-1
    for l = k+1:size(matrice_somma,1)
        elem_s = matrice_somma(k,l);
        
        %se l'arco di cut è presente in entrambe le matrici
        %allora elem_s varrà -2 e quindi lo ignoro, se invece
        %vale -1 lo tengo
        if(elem_s == -1)
            archi_cut_non_comune = [archi_cut_non_comune [k,l]];
        end
    end
end
    
%dei due nodi che rappresentano gli estremi degli archi non in
%comune che ho trovato mi interessa il nodo appartenente al
%grafo finora esplorato, di questo nodo restituisco (assieme al
%relativo arco non in comune) il suo indice di nodo nel grafo
%originale, il suo indice di nodo all'interno della matrice
%diagonale a blocchi che rappresenta il grafo esplorato e il
%suo indice di nodo all'interno del sottografo di cui fa parte

%per ogni arco di cut non in comune trovato
for k = 1:length(archi_cut_non_comune)
    arco = archi_cut_non_comune{k};
    indice_nodo_grafo_primo_estremo = arco(1);
    indice_nodo_grafo_secondo_estremo = arco(2);
    
    %cerco indice_nodo_grafo_primo_estremo e
    %indice_nodo_grafo_secondo_estremo in matrice_indici e vedo a
    %che sottografo appartengono tramite matrice_corrisp
    
    %trovo l'indice di colonna a cui si trova
    %indice_nodo_grafo_primo_estremo all'interno della matrice
    %matrice_indici
    for l = 1:size(matrice_indici,2)
        if(matrice_indici(1,l) == indice_nodo_grafo_primo_estremo)
            indice_da_controllare_primo_estremo = l;
            break;
        end
    end
    
    %trovo l'indice di colonna a cui si trova
    %indice_nodo_grafo_secondo_estremo all'interno della matrice
    %matrice_indici
    for l = 1:size(matrice_indici,2)
        if(matrice_indici(1,l) == indice_nodo_grafo_secondo_estremo)
            indice_da_controllare_secondo_estremo = l;
            break;
        end
    end
    
    %confronto indice_da_controllare_primo_estremo con gli indici
    %estremi presenti in matrice_corrisp per determinare a che
    %sottografo appartiene il nodo il cui indice è
    %indice_nodo_grafo_primo_estremo
    for l = 1:size(matrice_corrisp,1)
        if(indice_da_controllare_primo_estremo >= matrice_corrisp(l,1) && indice_da_controllare_primo_estremo <= matrice_corrisp(l,2))
            sottografo_primo_estremo = l;
            break;
        end
    end
    
    %confronto indice_da_controllare_secondo_estremo con gli indici
    %estremi presenti in matrice_corrisp per determinare a che
    %sottografo appartiene il nodo il cui indice è
    %indice_nodo_grafo_secondo_estremo
    for l = 1:size(matrice_corrisp,1)
        if(indice_da_controllare_secondo_estremo >= matrice_corrisp(l,1) && indice_da_controllare_secondo_estremo <= matrice_corrisp(l,2))
            sottografo_secondo_estremo = l;
            break;
        end
    end
    
    %trovo quale dei due nodi fa parte del grafo esplorato
    %andando a vedere se il sottografo di cui fa parte è uno di
    %quelli che è stato riconosciuto
    for l = indici_sottografi_riconosciuti
        if(sottografo_primo_estremo == l)
            indice_grafo_nodo_sorg_arco_uscente = indice_nodo_grafo_primo_estremo;
            sottografo_sorg_arco_uscente = l;
            indice_da_controllare_sorg_arco_uscente = indice_da_controllare_primo_estremo;
            indice_grafo_nodo_dest_arco_uscente = indice_nodo_grafo_secondo_estremo;
            break;
        elseif(sottografo_secondo_estremo == l)
            indice_grafo_nodo_sorg_arco_uscente = indice_nodo_grafo_secondo_estremo;
            sottografo_sorg_arco_uscente = l;
            indice_da_controllare_sorg_arco_uscente = indice_da_controllare_secondo_estremo;
            indice_grafo_nodo_dest_arco_uscente = indice_nodo_grafo_primo_estremo;
            break;
        end
    end
    
    %ricavo l'indice di sottografo corrispondente all'indice di
    %grafo originale del nodo sorgente dell'arco uscente dal
    %grafo esplorato
    inizio_intervallo_nodo_sorg_arco_uscente = matrice_corrisp(sottografo_sorg_arco_uscente,1);
    indice_sottografo_nodo_sorg_arco_uscente = indice_da_controllare_sorg_arco_uscente - inizio_intervallo_nodo_sorg_arco_uscente + 1;
    
    %ricavo l'indice di nodo all'interno della matrice
    %diagonale a blocchi (che rappresenta il grafo esplorato)
    %corrispondente all'indice di sottografo del nodo sorgente
    %dell'arco uscente dal grafo esplorato
    
    %recupero l'offset del nodo che rappresenta l'estremo
    %dell'arco di cut uscente facente parte del grafo esplorato
    for l = 1:size(offset,2)
        if(offset(1,l) == sottografo_sorg_arco_uscente)
            offset_sorg_arco_uscente = offset(2,l);
        end
    end
    
    indice_matr_diag_bloc_nodo_sorg_arco_uscente = indice_sottografo_nodo_sorg_arco_uscente + offset_sorg_arco_uscente;
    
    %trovo il grado e la label del nodo che rappresenta l'estremo dell'arco
    %di cut che non fa parte del grafo esplorato
    grado = 0;
    
    for l = 1:size(grafo,1)
        if(grafo(indice_grafo_nodo_dest_arco_uscente,l) == 1 && indice_grafo_nodo_dest_arco_uscente ~= l)
            grado = grado + 1;
        elseif(indice_grafo_nodo_dest_arco_uscente == l)
            label = grafo(indice_grafo_nodo_dest_arco_uscente,l);
        end
    end
    
    tmp1 = arco;
    tmp2 = [indice_grafo_nodo_sorg_arco_uscente indice_matr_diag_bloc_nodo_sorg_arco_uscente indice_sottografo_nodo_sorg_arco_uscente];
    tmp3 = sottografo_sorg_arco_uscente;
    tmp4 = [grado label];
    tmp5 = {tmp1 tmp2 tmp3 tmp4};
    tmp = {tmp5};
    archi_cut_uscenti = [archi_cut_uscenti tmp];
end
   
end

