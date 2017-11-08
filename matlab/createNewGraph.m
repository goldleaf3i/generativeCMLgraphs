%crea un nuovo grafo dai gradi di connettività tra i vari sottografi
%campionati
%INPUT:  Cgen - matrice dei gradi di connettività (Cgen(a,b,i,j) è il grado
%di connettività tra il sottografo campionato i dal cluster a e il
%sottografo campionato j dal cluster b)
%        numFgen - array del numero di sottografi generati per ogni cluster
%        sizemax - numero massimo di partizionamento (di sottografi
%        ottenuti per un grafo)
%        ncluster - numero di cluster
%        cont - indice del nuovo grafo
%        Fgen - array cell delle matrici di adiacenza permutate dei
%sottografi scelti per il nuovo grafo
%        indd - matrice degli indici di riferimento delle connessioni
%        alfa - matrice delle probabilità sul numero di porte per ogni tipo
%        di stanza (alfa(i,j) è la probabilità che il tipo di stanza i
%        abbia j porte)
%        beta - matrice delle probabilità del collegamento tra coppie di
%        tipi di stanze (beta(i,j) è la probabilità che il tipo di stanza i
%        sia collegata al tipo di stanza j)
%        gamma - array cell delle matrici delle probabilità dei
%        collegamenti tra tre tipi di stanze (gamma{i}(j,h) è la
%        probabilità che il tipo di stanza i sia collegata sia al tipo di
%        stanza j che al tipo di stanza h)
%OUTPUT: Gno - array cell delle matrici di adiacenza dei nuovi grafi senza
%le connessioni
%        Gintermedia - array cell delle matrici di adiacenza dei nuovi
%        grafi intermedi
%        GvariaC - array cell delle matrici di adiacenza dei nuovi grafi

function [Gno, Gintermedia, GvariaC] = createNewGraph(Cgen, numFgen, sizemax, ncluster, cont, Fgen, indd, alfa, beta, gamma)
    %la matrice finale prima delle cancellazioni ha dimensioni
    %sizemax*(sum(numFgen))
   
    Ggen=zeros(sizemax*(sum(numFgen)));

    %setto Fgen sulla diagonale
    pos=1;
    indice=zeros(ncluster,max(numFgen));
    for c=1:ncluster,
        for i=1:numFgen(c),
            indice(c,i)=pos;
            Ggen((indice(c,i)-1)*sizemax+1:indice(c,i)*sizemax,(indice(c,i)-1)*sizemax+1:indice(c,i)*sizemax)=Fgen{c,i};
            pos=pos+1;                           
        end
    end

    %Versione senza le connessioni
    Gno=Ggen;

    %e Cgen nelle posizioni corrispondenti
    %for Cvar=1:nvar
        Ggen=Gno;
        connesso=zeros(ncluster,max(numFgen));
        dimgruppo=ones(ncluster,max(numFgen));
        Cgruppo=zeros(ncluster,max(numFgen));
        gruppo=zeros(ncluster,max(numFgen));
        for a=1:ncluster,
            if not(isempty(Fgen{a,1})),
                connesso(a,1)=1;
                break;
            end
        end
        contg=1;
        for a=1:ncluster
            for i=1:numFgen(a),
                if not(isempty(Fgen{a,i}))
                    gruppo(a,i)=contg;
                    contg=contg+1;
                end
            end
        end
                    
                    
        for a=1:ncluster,
            for i=1:numFgen(a),
                collegato(a,i)=0;
            end
        end
            
        for a=1:ncluster,
            for b=a:ncluster
                if indd(a,b)>0
                for i=1:numFgen(a),
                    for j=1:numFgen(b),
                        if not(isempty(Fgen{a,i})) && not(isempty(Fgen{b,j})) && (a~=b || i<j)
                            x=indice(a,i);
                            y=indice(b,j);
                            %sommaC=sum(sum(Cgen{a,b,i,j}));
                            %valori empirici
                            Ctmp=Cgen(a,b,i,j);
                              if (Ctmp>=0.3 && Ctmp<0.7) %|| ((Ctmp==massimo(a,i)||Ctmp==massimo(b,j))&&Ctmp<0.7) %|| (Ctmp<0.2 && Ctmp > mean(mean(mean(mean(Ctmp)))))
                                sommaC=1;
                              elseif Ctmp>=0.7
                                sommaC=2;
                              else
                                  sommaC=0;
                              end      
                            if sommaC>0,
                                collegato(a,i)=1;
                                collegato(b,j)=1;
                                connessione=connetti(Fgen{a,i},Fgen{b,j},alfa,beta,gamma,sommaC);
                                Ggen((x-1)*sizemax+1:x*sizemax,(y-1)*sizemax+1:y*sizemax)=connessione;
                                Ggen((y-1)*sizemax+1:y*sizemax,(x-1)*sizemax+1:x*sizemax)=connessione';
                                if sum(sum(connessione))>=1                                    
                                    connesso(b,j)=max(connesso(a,i),connesso(b,j));
                                    connesso(a,i)=max(connesso(a,i),connesso(b,j));
                                    dima=dimgruppo(a,i);
                                    dimb=dimgruppo(b,j);
                                    Cnuovo=Cgruppo(a,i)+Cgruppo(b,j)+Ctmp;
                                    Cgruppo(a,i)=Cnuovo;
                                    Cgruppo(b,j)=Cnuovo;
                                    dimgruppo(a,i)=dima+dimb;
                                    dimgruppo(b,j)=dima+dimb;
                                    for c=1:ncluster,
                                        for k=1:numFgen(c),
                                            if not(isempty(Fgen{c,k})) &&(a~=c || i~=k) && gruppo(a,i)==gruppo(c,k)
                                                dimgruppo(c,k)=dima+dimb;
                                                Cgruppo(c,k)=Cnuovo;
                                            end
                                        end
                                    end
                                    for c=1:ncluster,
                                        for k=1:numFgen(c),
                                            if not(isempty(Fgen{c,k})) &&(b~=c || j~=k) && gruppo(b,j)==gruppo(c,k)
                                                dimgruppo(c,k)=dima+dimb;
                                                gruppo(c,k)=gruppo(a,i);
                                                Cgruppo(c,k)=Cnuovo;
                                            end
                                        end
                                    end
                                    gruppo(b,j)=gruppo(a,i);
                                end
                            end 
                        end
                    end
                end
                end
            end
        end
       
        Gintermedia=Ggen;    
                    
        %pezza: seleziono la giant component
        compmax=0;
        for a=1:ncluster,
            for i=1:numFgen(a),
                if not(isempty(Fgen{a,i})) && dimgruppo(a,i)==max(max(dimgruppo)) && Cgruppo(a,i)==max(max(Cgruppo))
                    compmax=gruppo(a,i);
                    break;
                end
            end
            if compmax>0,
                break
            end
        end
       
        %le componenti non massime vengono attaccate dalla connessione più
        %alta
        ngruppi=max(max(gruppo));
        maxgruppo=zeros(a,ngruppi);
            
        for a=1:ncluster,
            for i=1:numFgen(a),
                if not(isempty(Fgen{a,i})) && gruppo(a,i)~=compmax,
                    for b=1:ncluster,
                        if indd(min(a,b),max(a,b))>0
                        for j=1:numFgen(b),
                            if a>b
                                aa=b;
                                bb=a;
                                ii=j;
                                jj=i;
                            else
                                aa=a;
                                bb=b;
                                ii=i;
                                jj=j;
                            end
                            if not(isempty(Fgen{b,j})) && (a~=b || i~=j) && gruppo(b,j)==compmax && Cgen(aa,bb,ii,jj)>maxgruppo(gruppo(a,i)),
                                maxgruppo(gruppo(a,i))=Cgen(aa,bb,ii,jj);
                            end
                        end
                        end
                    end
                end
            end
        end
                            
        %attacco al giant component
        for a=1:ncluster,
            for i=1:numFgen(a),
                if not(isempty(Fgen{a,i})) && gruppo(a,i)~=compmax,
                    for b=1:ncluster,
                        if indd(min(a,b),max(a,b))>0
                        for j=1:numFgen(b),
                            if a>b
                                aa=b;
                                bb=a;
                                ii=j;
                                jj=i;
                            else
                                aa=a;
                                bb=b;
                                ii=i;
                                jj=j;
                            end
                            if not(isempty(Fgen{b,j})) && (a~=b || i~=j) && gruppo(b,j)==compmax && Cgen(aa,bb,ii,jj)==maxgruppo(gruppo(a,i)),
                                x=indice(a,i);
                                y=indice(b,j);
                                connessione=connetti(Fgen{a,i},Fgen{b,j},alfa,beta,gamma,1);
                                Ggen((x-1)*sizemax+1:x*sizemax,(y-1)*sizemax+1:y*sizemax)=connessione;
                                Ggen((y-1)*sizemax+1:y*sizemax,(x-1)*sizemax+1:x*sizemax)=connessione';
                                connesso(a,i)=1;
                                for c=a:ncluster,
                                    for k=1:numFgen(c),
                                        if not(isempty(Fgen{c,k})) &&(a~=c || i~=k) && gruppo(a,i)==gruppo(c,k)
                                            gruppo(c,k)=compmax;
                                        end
                                    end
                                end
                                gruppo(a,i)=compmax;
                            end
                        end
                        end
                    end
                end
            end
        end
                                
        GvariaC=Ggen;
    %end
end