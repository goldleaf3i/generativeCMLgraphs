%funzione obiettivo utilizzata durante il random walk
%INPUT:  alfapar - parametro che regola la convergenza del campionamento
%        cost - valore che indica un costo
%OUTPUT: objValue - valore funzione obiettivo
function [objValue] = objectiveFunction(cost,alfapar)
    objValue = exp(-alfapar*cost);
end