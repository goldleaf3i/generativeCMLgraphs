function [ dist ] = GoldSimpleDistance( M1,M2 )
%metrica semplice per la similarità (considero archi peso unitario)
n=length(M1);
dist=0;
for i=1:n-1,
    if M1(i,i)==M2(i,i),
        for j=i+1:n,
            if M1(j,j)==M2(j,j),
                dist=dist+M1(i,j)*M2(i,j);
            end    
        end
    end
end 
dist=-dist;
end

