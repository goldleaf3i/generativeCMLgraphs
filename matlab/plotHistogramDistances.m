function [plots] = plotHistogramDistances(grafi, kx, labelSet, gamma, kernelDistanceFunction, kernelParameter)
plots = 0;
for li=1:size(labelSet,2)
    for lj=li+1:size(labelSet,2)
        i = labelSet(li);
        j = labelSet(lj);
        indSubgraphs = [];
        labeli = ID2index(grafi{kx}(i,i));
        labelj = ID2index(grafi{kx}(j,j));
        inducedSubgraphij = inducedSubgraph(grafi{kx}, i, j);
        for di=1:size(gamma{labeli,labelj},1)
            for dj=1:size(gamma{labeli,labelj},1)
                for l=1:size(gamma{labeli,labelj}{di,dj},2)
                    indSubgraphs = [indSubgraphs gamma{labeli,labelj}{di,dj}(l)];
                end
            end
        end
        if ~isempty(indSubgraphs)
            plots = plots + 1;
            distance = [];
            for jj=1:size(indSubgraphs,2)
                distance = [distance kernelDistanceFunction(inducedSubgraphij,indSubgraphs{jj}, kernelParameter)];
            end
                    
            histogram(distance,64);
            mu = mean(distance);
            labA = strcat('Node label A: ',num2str(labeli));
            labB = strcat('Node label B: ',num2str(labelj));
            h = annotation('textbox',[0.70 0.80 0.1 0.1]);
            set(h,'String',{labA,labB});
            xlabel('Distance');
            ylabel('Frequency');
            hold on
            ylim = get(gca,'ylim');
            line([mu mu], ylim, 'Color','g');
            hold off
            plotName = strcat('histogram_', num2str(plots));
            print(plotName,'-dpng');
            delete(h);
        end
    end
end
end