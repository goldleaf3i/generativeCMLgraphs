%controlla se il sampling relativo alla matrice di connettività è da
%scartare
%INPUT:  Cgen - matrice di connettività tra i sottografi
%OUTPUT: B - B=1 se il sample è da scartare, altrimenti 0
%        diconnectedComponents - componenti disconnesse
%        minNode - nodo disconnesso con meno connessioni
function [B, diconnectedComponents, nodes, minNode] = checkDiscardSample(Cgen)
[diconnectedComponents, nodes] = graphconncomp(sparse(Cgen));
minNode = [];
if diconnectedComponents == 1
    B = 0;
else
    B = 1;
    min = 1000;
    for i=1:diconnectedComponents
        num = sum(nodes == i);
        if num < min
            num = min;
            for j=1:length(nodes)
                if nodes(j) == i
                    minNode = j;
                    break;
                end
            end
        end
    end
end
end