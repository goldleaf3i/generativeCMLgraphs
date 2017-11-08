function [ value ] = Ncut( V, A, B )
%Calcola a partire da una matrice di adiacenza V partizionata in A e B
%il valore di Ncut
%A: vettore di dimensioni |V| che ha degli 1 in corrispondenza dei veritici
%di A, idem per B

len=length(V);

%calcolo cut(A,B)
cutAB=0;
for i=1:len-1,
    for j=i+1:len
        if (A(i)==1 && B(j)==1)||(B(i)==1 && A(j)==1),
            cutAB=cutAB+V(i,j);
        end    
    end
end

%calcolo assoc(A,V)
assocAV=0;
for i=1:len-1,
    for j=i+1:len
        if A(i)==1 || A(j)==1
            assocAV=assocAV+V(i,j);
        end    
    end
end

%calcolo assoc(B,V)
assocBV=0;
for i=1:len-1,
    for j=i+1:len
        if B(i)==1 || B(j)==1
            assocBV=assocBV+V(i,j);
        end    
    end    
end

value= cutAB/assocAV + cutAB/assocBV;

end

