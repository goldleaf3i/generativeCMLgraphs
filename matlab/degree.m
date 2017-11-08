function [ D ] = degree( A )
    %costruisco matrice dei gradi a partire da Adiacenza
    len=length(A);
    D=zeros(len);
    for i=1:len,
        D(i,i)=sum(A(i,:));
    end
end

