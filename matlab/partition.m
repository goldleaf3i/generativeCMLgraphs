function [ F,clustering, connection, nodes ] = partition( A, alfa )
%setto alcune cose per il primo splitting
exit=0;
freeindex=2;
connection{1}=0;
F{1}=A;
nodes{1}=ones(1,length(A));
stop(1)=0;
while exit==0
    %risetto change a 0
    change=0;
    %finchè non sono fermo dappertutto provo a tagliare i sottografi
    %andando in ordine di posizionamento
    for i=1:length(F),
        %se non mi ero già fermato prima provo a tagliarlo
        if stop(i)==0 &&length(F{i})>1
            [P1,P2,C,a,ncut]=splice(F{i});
            %evito i tagli inferiori al parametro o cmq al caso limite 2
            if ncut <= alfa && ncut<2, 
            %split accettato, aggiorno tutto    
                if length(connection)>i
                    %splitto tutte le matrici di C di riga i
                    for h=i+1:length(connection)
                        sz=size(connection{i,h});
                        cbig=connection{i,h};
                        c1=zeros(length(P1),sz(2));
                        c2=zeros(length(P2),sz(2));
                        pos1=1;
                        pos2=1;
                        for k=1:sz(1),
                            if a(k)==1
                                c1(pos1,:)=cbig(k,:);
                                pos1=pos1+1;
                            else
                                c2(pos2,:)=cbig(k,:);
                                pos2=pos2+1;
                            end
                        end
                        %sostituisco le matrici di connessione splittate
                        connection{i,h}=c1;
                        if h>freeindex
                            connection{freeindex,h}=c2;
                        else
                            connection{h,freeindex}=c2';
                        end    
                    end
                end
                
                if i>1
                    %splitto tutte le matrici di C di colonna i
                    for h=1:i-1
                        sz=size(connection{h,i});
                        cbig=connection{h,i};
                        c1=zeros(sz(1),length(P1));
                        c2=zeros(sz(1),length(P2));
                        pos1=1;
                        pos2=1;
                        for k=1:sz(2),
                            if a(k)==1
                                c1(:,pos1)=cbig(:,k);
                                pos1=pos1+1;
                            else
                                c2(:,pos2)=cbig(:,k);
                                pos2=pos2+1;
                            end
                        end
                        %sostituisco le matrici di connessione splittate
                        connection{h,i}=c1;
                        if freeindex>h
                            connection{h,freeindex}=c2;
                        else
                            connection{freeindex,h}=c2';
                        end    
                    end
                end
                %aggiorno le F splittate
                F{i}=P1;
                F{freeindex}=P2;
                %aggiorno i nodi di ciascuna F (per il clustering)
                nodoFi=nodes{i};
                nodoFi1=zeros(1,length(A));
                nodoFi2=zeros(1,length(A));
                ind2=1;
                for ind1=1:length(A),
                    if nodoFi(ind1)==1,
                        nodoFi1(ind1)=a(ind2);
                        nodoFi2(ind1)=not(a(ind2));
                        ind2=ind2+1;
                    end
                end
                nodes{i}=nodoFi1;
                nodes{freeindex}=nodoFi2;
                    
                %inserisco la connection tra le due nuove
                if i<freeindex
                    connection{i,freeindex}=C;
                else
                    connection{freeindex,i}=C;
                end    
                %aggiungo la variabile stop per il secondo sottografo
                stop(freeindex)=0;
                %aumento l'indice della prossima posizione libera
                freeindex=freeindex+1;
                
                %è cambiato qualcosa: continuerò nel while
                change=1;
            else
            %non mi conviene tagliare ancora questo sottografo
            %tengo traccia del fatto che qua mi sono fermato
            stop(i)=1;
            end    
        end
    end
    %aggiorno exit per vedere se esco
    exit=not(change);
end
%uso nodes per creare la matrice di clusterizzazione
clustering=zeros(length(nodes),length(A));
for i=1:length(nodes),
    clustering(i,:)=nodes{i};
end    
%pulisco connection{1}
connection{1,1}=[];        
    
end  
