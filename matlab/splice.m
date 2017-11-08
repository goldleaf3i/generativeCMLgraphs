function [ A,B,C,a, value ] = splice( G )
%tolgo le label (peso ai nodi)
n=length(G);
G2=G;
for i=1:n,
    G2(i,i)=0;
end

L=laplacian(G2);    
[V,E]=eig(L,L+G2);

%C=zeros(n);
a=zeros(1,n);
b=zeros(1,n);

%come da paper calcolo il punto di splitting più giusto
%considerando che tendenzialmente si troverà tra -0.1 e 0.1
%TODO controllare se il tempo di esecuzione peggiora molto
value=2;
for k=-0.1:0.01:0.1,
    tmpa=zeros(1,n);
    tmpb=zeros(1,n);
    for i=1:n,
        if V(i,2)>=k,
            tmpa(i)=1;
        else 
            tmpb(i)=1;
        end    
    end
    tmpcut=Ncut(G,tmpa,tmpb);
    if tmpcut<value,
        value=tmpcut;
        a=tmpa;
        b=tmpb;
    end 
end

A=zeros(sum(a));
B=zeros(sum(b));
%riempio la matrice della partizione A
contR=0;
for i=1:n,
    if a(i)==1,
        contR=contR+1;
        contC=0;
        for j = 1:n,
            if a(j)==1
                contC=contC+1;
                A(contR,contC)=G(i,j);
            end
        end
    end
end
%riempio la matrice della partizione B
contR=0;
for i=1:n,
    if b(i)==1,
        contR=contR+1;
        contC=0;
        for j = 1:n,
            if b(j)==1
                contC=contC+1;
                B(contR,contC)=G(i,j);
            end
        end
    end
end
%riempio le connessioni tra A e B
C=zeros(length(A),length(B));
contR=0;
for i=1:n,
    if a(i)==1,
        contR=contR+1;
        contC=0;
        for j = 1:n,
            if b(j)==1
                contC=contC+1;
                C(contR,contC)=G(i,j);
                %parte eventuale per fare il trucco del peso
%                 Av=A(contR,contR);
%                 A(contR,:)=A(contR,:)+0.1;
%                 A(:,contR)=A(:,contR)+0.1;
%                 A(contR,contR)=Av;
%                 Bv=B(contC,contC);
%                 B(contC,:)=B(contC,:)+0.1;
%                 B(:,contC)=B(:,contC)+0.1;
%                 B(contC,contC)=Bv;               
            end
        end
    end
end
        

end

