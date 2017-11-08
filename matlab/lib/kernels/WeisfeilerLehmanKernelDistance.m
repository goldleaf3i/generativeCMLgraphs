%calcola la distanza Weisfeiler Lehman Subtree kernel tra due grafi
%INPUT:  F1, F2 - matrici di adiacenza dei sottografi con le etichette
%sulla diagonale
%        h - numero di iterazioni
%OUTPUT: WLKdistance - distanza Weisfeiler Lehman Subtree kernel
function [WLKdistance] = WeisfeilerLehmanKernelDistance(F1, F2, h)
Flin = cell(1,2);
Flin{1} = F1;
Flin{2} = F2;
K =  createWeisfeilerLehmanKernelMatrix(Flin, h, 0);
WLKdistance = sqrt(K(1,1) + K(2,2) - 2*K(1,2));
end