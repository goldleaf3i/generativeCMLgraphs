%dato l'indice progressivo dell'elemento sopra la diagonale, restituisce
%gli indici della matrice
function [i, j] = upperDiagonalIndexToMatrixIndex(index, dim)
    %equazioni per ottenere gli indici della parte triangolare sopra la
    %diagonale
    i = dim - 1 - floor(sqrt(-8*(index-1) + 4*dim*(dim-1)-7)/2.0 - 0.5);
    j = (index-1) + i + 1 - dim*(dim-1)/2 + (dim-i+1)*((dim-i+1)-1)/2;
end