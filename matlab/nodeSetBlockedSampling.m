function [seti,setj] = nodeSetBlockedSampling(ki, kj, connectedToLin, compatibleNodesLin)
    seti = [];
    setj = [];
    listNodesi = [];
    for li=1:size(connectedToLin{ki},2)
        if connectedToLin{ki}{li} == kj
            try
                listNodesi = compatibleNodesLin{ki}{li};
            catch ME
                ME
                compatibleNodesLin
                compatibleNodesLin{ki}
                ki
                li
                load gong.mat;
                    sound(y);
                compatibleNodesLin{ki}{li}
            end

            break;
        end
    end
    listNodesj = [];
    for lj=1:size(connectedToLin{kj},2)
        if connectedToLin{kj}{lj} == ki
            listNodesj = compatibleNodesLin{kj}{lj};
            break;
        end
    end
    if ~isempty(listNodesi) && ~isempty(listNodesj)
        seti = zeros(1,sum(listNodesi > 0));
        counterList = 0;
        for li=1:size(listNodesi,2)
            if listNodesi(li) > 0
                counterList = counterList + 1;
                seti(counterList) = li;
            end
        end
        setj = zeros(1,sum(listNodesj > 0));
        counterList = 0;
        for lj=1:size(listNodesj,2)
            if listNodesj(lj) > 0
                counterList = counterList + 1;
                setj(counterList) = lj;
            end
        end
    end
end