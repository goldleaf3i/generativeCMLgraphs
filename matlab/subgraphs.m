function [ F_e, N, C_e, S, n, numF, nodes ] = subgraphs( G, par )

%Dato un grafo lo partiziono e ne rido la rappresentazione tramite F e C
[F,N,C,nodes]=partition(G,par);
numF=length(F);
max=0;
for i=1:numF,
    tmp=length(F{i});
    if tmp>max,
        max=tmp;
    end
end
n=max;

%<mattia> a noi non serve fare il padding dei sottografi perchè non abbiamo
%bisogno che abbiano la stessa dimensione, qui però il padding va lasciato
%altrimenti non funziona più nulla quindi, una volta trovata la lista di
%tutti i sottografi provenienti da un certo insieme di grafi, bisognerà
%rimuovere da essi i nodi dummy inseriti dalla fase di padding </mattia>

%eseguo il padding dei sottografi alla dimensione max
for i=1:numF,
    F{i} = padarray(F{i}, [n-length(F{i}),n-length(F{i})], 'post');
end

%padding anche delle matrici di connessione
for i=1:numF-1,
    for j=i+1:numF,
        sz=size(C{i,j});
        C{i,j} = padarray(C{i,j}, [n-sz(1),n-sz(2)], 'post');
    end 
end

%una volta paddate le salvo in F_e e C_e
F_e=cell(1,numF);
for i=1:length(F),
    F_e{i}=F{i};
end
C_e=cell(numF,numF);
for i=1:numF-1,
    for j=i+1:numF,
        C_e{i,j}=C{i,j};
    end
end

%creo la matrice finale
S=zeros(n*numF);
%e la popolo
for i=1:numF,
    tmp=F{i};
    for h=1:n,
        for k=1:n,
            S(n*(i-1)+h,n*(i-1)+k)=tmp(h,k);
        end
    end
end
for i=1:numF-1
    for j=i+1:numF
        tmp=C{i,j};
        for h=1:n,
            for k=1:n,
               S(n*(i-1)+h,n*(j-1)+k)=tmp(h,k);
            end
        end
    end    
end
end

