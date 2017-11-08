% Prende una matrice ed un array logico corrispodente alle rige da
% estrarre. Restituisce la sotto_matrice corrispondente. 
%INPUT: M - matrice di dimensioni nxn
%       idxs - vettore logico contenente le righe e colonne da restituire
%       come sottomatrice (0 se non deve essere restituita, 1 se deve
%       essere restituita). Se il vettore logico contiene anche dei valori
%       =2, restiuisce non la matrice diagonale a blocchi ma la matrice che
%       rappresenta le celle indicate dalle righe segnate come 1 e dalle
%       righe segnate come 2.
%       DIM - Dimensione della matrice da restituire. Se è più piccola
%       viene paddata con degli 0
%OUTPUT: R - sottomatrice di M contenente solo un insieme selezionato di
%righe e colonne
function [R] = subBlockMatrix(M,idxs,DIM)
    
    num_values = sum(idxs==1);
    num_2 = sum(idxs==2);
    %padarray(F{i}, [n-length(F{i}),n-length(F{i})], 'post');
    if DIM ~= -1
        R = zeros(DIM,DIM);
    else
        if num_2 == 0
            R = zeros(num_values,num_values);
        else
            R = zeros(num_values,num_2);
        end
    end
    ok_val = find(idxs==1); 
    if num_2 == 0
        for i=1:num_values
            for j=1:num_values
                R(i,j)=M(ok_val(i),ok_val(j));
            end
        end
    else
        ok_val2 = find(idxs==2);
        for i=1:num_values
            for j=1:num_2
                R(i,j)=M(ok_val(i),ok_val2(j));
            end
        end
    end
    
end