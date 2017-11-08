function [ C_r ] = riduciCon1Val( C_o,ngrafi,sizemax, F_o, numF )
    %riduco a 1 valore (somma lati)
    for k=1:ngrafi,
        for i=1:numF(k)-1,
            for j=i+1:numF(k),
                tmpC=C_o{k,i,j};
                tmpCrid=0;
                for x=1:sizemax,
                    for y=1:sizemax,
                        tmpCrid=tmpCrid+tmpC(x,y);
                    end
                end
                C_r{k,i,j}=tmpCrid;
            end
        end
    end
end

