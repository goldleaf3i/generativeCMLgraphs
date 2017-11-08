function [e1, e2, e3, e4] = Eigenvalues( matrice_adiacenza )
%calcola il raggio spettrale della matrice di adiacenza ("pura", senza le
%label dei nodi sulla diagonale principale, raggio spettrale = autovalore
%con modulo più grande), l'autovalore con il secondo modulo più grande,
%l'energia e il numero di autovalori distinti

[r, c] = size(matrice_adiacenza);

%metto 0 su tutta la diagonale principale per eliminare le label (non ci
%sono autoanelli nei nostri grafi)
for i = 1:r
    matrice_adiacenza(i,i) = 0;
end

eigenvalues = eig(matrice_adiacenza);
eigenvalues = eigenvalues.';
unique_eigenvalues = unique(eigenvalues);
eigenvalues = abs(eigenvalues);
eigenvalues = sort(eigenvalues);

e1 = max(eigenvalues);
%disp(e1);
e2 = eigenvalues(length(eigenvalues)-1);
%disp(e2);
e3 = sum(eigenvalues.^2);
%disp(e3);
e4 = length(unique_eigenvalues);
%disp(e4);

end

