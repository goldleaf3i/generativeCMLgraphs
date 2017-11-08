function [ shortvectors,meanmatr,covmatr,scarta,indice, ricorrenze] = nuovaCovarianza( ngrafi, C_r,ncluster, numF, clustref )
    
%ricorrenze mi dice per ogni grafo quanti sottografi ha in ogni cluster. 
%questo mi serve perchè ogni variabile casuale c1c2 avrà un numero
%variabile di elementi, pari ricorrenze(k,c1)*ricorrenze(k,c2) sommate su
%tutti i k
ricorrenze  = contacluster( clustref,numF );
shortvectors=cell(ncluster);

%shortvectors{a,b} mi memorizza quelle che erano le sezioni del long
%vector. E' tipo uno slice verticale della matrice completa dei long vector
%compromesso necessario: se per un grafo la coppia a-b non ha sottografi,
%segno uno zero
for a=1:ncluster
    for b=a:ncluster,
        tmpvect=[];%zeros(1,sum(ricorrenze(:,a))*sum(ricorrenze(:,b)));
        pos=1;
        for k=1:ngrafi,
            segnaposto(a,b,k)=pos;
            for i=1:numF(k)-1,
                for j=i+1:numF(k),
                    if (clustref(k,i)==a && clustref(k,j)==b) || (clustref(k,j)==a && clustref(k,i)==b),
                        tmpvect(pos)=C_r{k,i,j};
                        pos=pos+1;
                    end
                end
            end
            if pos==segnaposto(a,b,k),
                tmpvect(pos)=0;
                pos=pos+1;
            end
            dimen(a,b,k)=pos-segnaposto(a,b,k);
        end
        if isempty(tmpvect)
            shortvectors{a,b}=0;
        else
        shortvectors{a,b}=tmpvect;
        end
    end
end

%calcolo la varianza di tutti i short vector e se trovo degli zeri scarto
for a=1:ncluster,
    for b=a:ncluster,
        tmpvar=var(shortvectors{a,b});
        if tmpvar==0 && sum(shortvectors{a,b})==0,
            scarta(a,b)=1;
        end
    end
end

%salvo gli indici di riferimento e calcolo le covarianze coppia a coppia
indice=zeros(a,b);
ind=0;
for a=1:ncluster,
    for b=a:ncluster,
        %if scarta(a,b)==0,
            ind=ind+1;
            indice(a,b)=ind;
        %end
    end
end

barriera=ind;
covmatr=zeros(ind+ncluster);
meanmatr=zeros(1,ind+ncluster);
distrib=zeros(3,ind);
%calcolo le covarianze coppia a coppia
for a=1:ncluster,
    for b=a:ncluster,
        if indice(a,b)>0
            %calcolo la media
            meanmatr(indice(a,b))=mean(shortvectors{a,b});
            tmpx=shortvectors{a,b};
            for n=1:3,
                distrib(n,indice(a,b))=sum(tmpx==(n-1));
            end
            for a2=a:ncluster,
                for b2=b:ncluster,
                    if indice(a2,b2)>0,
                        pos=0;
                        v1=shortvectors{a,b};
                        v2=shortvectors{a2,b2};
                        for k=1:ngrafi,
                            for ind1=segnaposto(a,b,k):segnaposto(a,b,k)+dimen(a,b,k)-1,
                                for ind2=segnaposto(a2,b2,k):segnaposto(a2,b2,k)+dimen(a2,b2,k)-1,
                                    pos=pos+1;
                                    vect1(1,pos)=v1(1,ind1);
                                    vect2(1,pos)=v2(1,ind2);
                                end
                            end
                        end
                        tmpcov=cov(vect1,vect2);
                        covmatr(indice(a,b),indice(a2,b2))=tmpcov(1,2);
                        covmatr(indice(a2,b2),indice(a,b))=tmpcov(1,2);
                        vect1=[];
                        vect2=[];
                    end                    
                end
            end
        end
    end
end

%aggiungo a media e covarianza quelle con le ricorrenze
for c=1:ncluster,
    clustvector{c}=ricorrenze(:,c)';
end
%media
for c=1:ncluster,
    meanmatr(barriera+c)=mean(clustvector{c});
    %covarianza
    for a=1:ncluster,
        for b=a:ncluster,
            if indice(a,b)>0,
                pos=0;
                v1=shortvectors{a,b};
                v2=clustvector{c};
                for k=1:ngrafi,
                    for ind1=segnaposto(a,b,k):segnaposto(a,b,k)+dimen(a,b,k)-1,
                        pos=pos+1;
                        vect1(1,pos)=v1(1,ind1);
                        vect2(1,pos)=v2(1,k);
                    end
                end
                tmpcov=cov(vect1,vect2);
                covmatr(indice(a,b),barriera+c)=tmpcov(1,2);
                covmatr(barriera+c,indice(a,b))=tmpcov(1,2);
                vect1=[];
                vect2=[];
            end
        end
    end
    %covarianza tra gli ultimi elementi
    for c2=c:ncluster
        pos=0;
        v1=clustvector{c};
        v2=clustvector{c2};
        for k=1:ngrafi,
            pos=pos+1;
            vect1(1,pos)=v1(1,k);
            vect2(1,pos)=v2(1,k);
        end
        tmpcov=cov(vect1,vect2);
        covmatr(barriera+c2,barriera+c)=tmpcov(1,2);
        covmatr(barriera+c,barriera+c2)=tmpcov(1,2);
        vect1=[];
        vect2=[];
    end

end
                  
            



                     

end

