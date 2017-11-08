%campionatore MCMC per ottenere una configurazione campionata da una
%popolazione di strutture dati (vettori, grafi,...), data una
%configurazione iniziale
%DEBUG: tre fprintf commentate ne codice; decommentare per avere la printf
%di ogni iterazione se viene accettata o rifiutata.
%INPUT:  population - insieme di strutture dati, ogni riga
%è una struttura dati a disposizione nello spazio degli stati
%        distanceAndFlippingHandler - è una funzione che prende in input la
%        popolazione su cui fare sampling, una configurazione su cui fa una
%        operazione di flipping, un indice per il flip, alfapar e
%        restituisce la configurazione flippata e la distanza tra le due
%        configurazioni flippata e non flippata
%        distanceFunction - è una funzione che restituisce una distanza
%        tra le strutture dati
%        initialConfiguration - configurazione iniziale di lunghezza
%        fissata
%        configurationLength - lunghezza fissata della configurazione
%        campionata (per un vettore è la sua lunghezza)
%        alfapar - parametro che regola la convergenza del campionamento
%        numIterations - numero di iterazioni da cui dipende una buona o
%        meno copertura dello spazio degli stati
%        utilParameter - parametro di utilità, può servire ad esempio per
%        la funzione distanza
%        dimBlocked - array degli indici delle dimensioni bloccate (da non
%        cambiare), può essere vuoto
%OUTPUT: sampledConfiguration - ultima soluzione della catena MCMC
%        optimalSampledConfiguration - soluzione ottima trovata lungo la
%        catena MCMC
%        objFunctions - array dei valori delle funzioni
%        obiettivo dei vari campioni
function [sampledConfiguration, objFunctions] = MCMC(population, distanceAndFlippingHandler, distanceFunction, initialConfiguration, configurationLength, alfapar, numIterations, utilParameter, dimBlocked)
    s = initialConfiguration;
    %serve per velocizzare la computazione delle distanze nel
    %distanceAndFlippingHandler
    oldDistance = -1;
    objFunctions = size(1, numIterations);
    for count=1:numIterations
        %seleziono la componenete iniziale a caso, poi vado sequenzialmente
        flipIndex = fix(rand*configurationLength)+1;
        %itero su tutte le componenti
        for i=1:configurationLength
            sb = s;
            [sa, distanceA, distanceB] = distanceAndFlippingHandler(population, sb, flipIndex, distanceFunction, utilParameter, oldDistance, count, dimBlocked);
            acc = 0;
            if distanceA >= 0 && distanceB >= 0
                relObjectiveFunction = objectiveFunction(distanceA - distanceB,alfapar);
                probAcc = min(1, relObjectiveFunction);
                if rand <= probAcc
                    %fprintf('Iterazione %d - elemento %d aggiornato, accettato campione con probabilità %f \n', count, flipIndex, probAcc);
                    s = sa;
                    oldDistance = distanceA;
                    acc = 1;
                else
                    %fprintf('Iterazione %d - elemento %d aggiornato, rifiutato campione con probabilità %f \n', count, flipIndex, 1-probAcc);
                    s = sb;
                    oldDistance = distanceB;
                end
            else
                %fprintf('Iterazione %d - elemento %d aggiornato, rifiutato campione con probabilità %f \n', count, flipIndex, 1);
            end
            
            %aggiorno componente
            flipIndex = mod(flipIndex, configurationLength) + 1;
        end
        if acc == 1
            objFunctions(count) = objectiveFunction(distanceA,alfapar);
        else
            objFunctions(count) = objectiveFunction(distanceB,alfapar);
        end   
    end
    sampledConfiguration = s;
end