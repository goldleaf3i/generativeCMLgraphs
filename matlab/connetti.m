function [ Cab ] = connetti( A,B,alfa,beta,gamma,num )
sizemax=length(A);
Cab=zeros(sizemax);

%creo la matrice di probabilità per tutte le connessioni
vprob=zeros(sizemax);
for i=1:sizemax,
    for j=1:sizemax,
            vprob(i,j)=calcolaProb( A,B,i,j,alfa,beta,gamma );
    end
end
usato=zeros(sizemax);


for conta=1:num,
    trovato=0;
    for i=1:sizemax,
        for j=1:sizemax,
            if usato(i,j)==0 && vprob(i,j)==max(max(vprob)) && sum(A(i,:))>A(i,i) && sum(B(j,:))>B(j,j)
                usato(i,j)=1;
                Cab(i,j)=1;
                vprob(i,j)=0;
                trovato=1;
                break;
            end
        end
        if trovato break; end
    end
  
end

end

