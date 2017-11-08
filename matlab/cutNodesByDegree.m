function [Fseq] = cutNodesByDegree(F, degree)
dim = size(F,1);
Fnew = F;
for i=1:dim
    Fnew(i,i) = 0;
end

counter = 1;
Fseq{counter} = F;
stable = 0;
while stable == 0
    stable = 1;
    cutted = zeros(dim,1);
    for i=1:dim
        deg = sum(Fnew(i,:));
        if deg == degree
            Fnew(i,:) = 0;
            cutted(i) = 1;
            stable = 0;
        end
    end
    if stable == 0
        for i=1:dim
            if cutted(i)
                Fnew(:,i) = 0;
            end
        end
        counter = counter + 1;
        Fseq{counter} = Fnew;
        for i=1:dim
            Fseq{counter}(i,i) = F(i,i);
        end
    end
end

Fseq = removeDummyNodes(Fseq);

end

