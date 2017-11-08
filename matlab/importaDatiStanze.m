function [ alfa,gamma ] = importaDatiStanze(tipoedificio)

%ops mi sono accorto ora che andavo a prendere sempre dalla tabella
%scuole..
switch tipoedificio
    case 'scuole'
        filename='datiscuole.txt';
        fid=fopen(filename);
        campi=textscan(fid,'%c%f%d%f%d%d%d%d%d%d%d%d%d%d%d%d','Delimiter',',','EmptyValue',-Inf);
        label=campi{1};
        area=campi{2};
        numporte=campi{3};
        x=campi{4};
        corridor=campi{5};%C
        hall=campi{6};%H
        gym=campi{7};%R big function
        canteen=campi{8};%N big service
        auditorium=campi{9};%F big service
        smallroom=campi{10};%S fun
        office=campi{11};%Y service media
        class=campi{12};%M functional media
        staff=campi{13};%K service piccola
        bigroom=campi{14};%B fun
        entrance=campi{15};%E
        errore=campi{16};%|
        
            
        ncampioni=length(label);
        
        portepertipo=zeros(11, ncampioni);
        for i=5:15,
            portepertipo(i-4,:)=campi{i}';
        end
        
        %la tabella alfa contiene le probabilità sulle porte:
        %alfa(i,j)=p(numporte(c)==j)
        tmp=zeros(11,26);
        for i=1:ncampioni,
            indice=label2index(label(i));
            tmp(indice,numporte(i))=tmp(indice,numporte(i))+1;
        end
        alfa=zeros(11,26);
        for i=1:11,
            somma=sum(tmp(i,:));
            for j=1:26,
                if tmp(i,j)>0 && somma>0
                    alfa(i,j)= tmp(i,j)/somma;
                end
            end
        end
        
        %SPOSTATO IN TABULATAGLI
        %la tabella beta contiene le probabilità che due tipi di stanza
        %siano collegati
%         tmp=zeros(10);
%         for i=1:ncampioni
%             indice=label2index(label(i));
%             for j=1:10
%                 tmp(indice,j)=tmp(indice,j)+portepertipo(j,i);
%             end
%         end
%         beta=zeros(10);
%         somma=0;
%         for i=1:10,
%             for j=i:10
%                 somma=somma+tmp(i,j);
%             end
%         end
%         for i=1:10,
%             for j=i:10,
%                 beta(i,j)=tmp(i,j)/somma;
%             end
%         end
        
        %la tabella gamma calcola i percorsi a 3
        for i=1:11,
            gamma{i}=zeros(11);
        end
        contatipi=zeros(1,11);
        for i=1:ncampioni,
            indice=label2index(label(i));
            contatipi(indice)=contatipi(indice)+1;
            tmp=gamma{indice};
            for n=1:11,
                for m=n:11,
                    if (n~=m && portepertipo(n,i)>0 && portepertipo(m,i)>0) || (n==m && portepertipo(n,i)>1)  
                        tmp(n,m)=tmp(n,m)+1;
                    end
                end
            end
            gamma{indice}=tmp;
        end
        %trovo le frequenze dividendo per il numero dei campioni di quella
        %label
        for indice=1:11,
            if contatipi(indice)>0
                tmp=gamma{indice};
                tmp=tmp/contatipi(indice);
                gamma{indice}=tmp;
            end
        end
 
    %DA FINIRE    
    case 'uffici'
        filename='UfficiData2600Senza_.txt';
    case 'abitazioni'
        filename='AbitazioniData1400.txt';
end

end

