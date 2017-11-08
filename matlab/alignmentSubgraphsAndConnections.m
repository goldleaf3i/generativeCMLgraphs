%allinea i sottografi di ogni cluster rispetto a quello di riferimento
%INPUT:  ngrafi - numero di grafi
%        numF - array del numero di sottografi di ogni grafo
%        graforig - matrice delle posizioni lineari (indici) dei sottografi
%        (elementi di F_e)
%        clustref - matrice degli indici dei cluster di ogni sottografo
%        Rorig - array delle coppie di indici (k,i)=(grafo,sottografo) dei
%sottografi di riferimento di ogni cluster
%        F_e -  array di celle delle matrici di adiacenza dei sottografi
%       (F_e{k,i} è la matrice di adiacenza del sottografo i del grafo k)
%        C_e - array di celle delle matrici di connessioni (C_e{k,i,j} è la
%        matrice di connessione tra il sottografo i e il sottografo j del
%        grafo k)
%OUTPUT: F_o -  array di celle delle matrici di adiacenza permutate dei sottografi
%       (F_o{k,i} è la matrice di adiacenza del sottografo i del grafo k)
%        C_o - array di celle delle matrici di connessioni permutate (C_o{k,i,j} è la
%        matrice di connessione tra il sottografo i e il sottografo j del
%        grafo k)
%        P - array cell delle matrici di permutazione (P{i} è la matrice di
%        permutazione del sottografo i)
function [F_o, C_o, P] = alignmentSubgraphsAndConnections(ngrafi, numF, graforig, clustref, Rorig, F_e, C_e)
F_o=F_e;
C_o=C_e;
for k=1:ngrafi,
    for i=1:numF(k),
        if graforig(k,i)>0,
        c=clustref(k,i);
        rkri=Rorig{c};
        rk=rkri(1);
        ri=rkri(2);
        if k~=rk || i~=ri,
            [F_o{k,i},P{i}]=goldmod(F_o{rk, ri},F_o{k,i});
        else
            P{i}=eye(length(F_o{rk,ri}));
        end
        end
    end
    for i=1:numF(k)-1,
        for j=i+1:numF(k),
        if graforig(k,i)>0 && graforig(k,j)>0    
            C_o{k,i,j}=P{i}*C_o{k,i,j}*P{j};
        end
        end    
    end
end
end