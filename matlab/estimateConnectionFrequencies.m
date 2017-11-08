%determina le frequenze sulle connessioni tra sottografi
function [tone] = estimateConnectionFrequencies(subgraphClusteringMs)
tone = 0;
for k=1:size(subgraphClusteringMs,2)
    one = 0;
    total = 0;
    for i=1:length(subgraphClusteringMs{k})
        for j=1:length(subgraphClusteringMs{k})
            if i ~= j
                total = total + 1;
                if subgraphClusteringMs{k}(i,j) > 0
                    one = one + 1;
                end
            end
        end
    end
    Pone = one/total;
    tone = tone + Pone;
end
tone = tone/k;

end