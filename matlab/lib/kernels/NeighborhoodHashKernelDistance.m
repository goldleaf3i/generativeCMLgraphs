%calcola la distanza neighborhood hash kernel (Kashima) tra due grafi
%INPUT:  F1, F2 - matrici di adiacenza dei sottografi con le etichette
%sulla diagonale
%        R - massimo ordine di neighborhood hash
%OUTPUT: NHKdistance - distanza neighborhood hash kernel (Kashima)
function [NHKdistance] = NeighborhoodHashKernelDistance(F1, F2, R)
Flin = cell(1,2);
Flin{1} = F1;
Flin{2} = F2;
K = createNeighborhoodHashKernelMatrix(Flin, R);
NHKdistance = sqrt(K(1,1) + K(2,2) - 2*K(1,2));
end