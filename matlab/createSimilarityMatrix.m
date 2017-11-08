%crea la matrice di similarità
%INPUT:  Flin - array di celle dei sottografi (linearizzazione di F_e)
%        graforig - matrice delle posizioni lineari (indici) dei sottografi
%        (elementi di F_e)
%        postoKI - array di celle delle coppie di indici [k i] di ogni
%        sottografo
%OUTPUT: sim2 - matrice di similarità del grafo di affinità tra tutte le
%coppie di sottografi
%        scarti - 1 se ci sono dei nodi dummy nella matrice di similarità,
%        0 altrimenti
function [sim2, scarti, graforig] = createSimilarityMatrix(Flin, graforig, postoKI)
%calcolo le similarità coppia a coppia tra tutti facendo allineamento
sim=zeros(length(Flin),length(Flin));
cambiati=0;
for i=1:length(Flin)-1,
    for j=i+1:length(Flin),
        %per fare veloce prima tolgo dummy che avevo aggiunto e poi paddo
        %al più grande della coppia
        F1=removeDummy(Flin{i});
        F2=removeDummy(Flin{j});
        max12=max(length(F1),length(F2));
        F1 = padarray(F1,[max12-length(F1),max12-length(F1)],'post');
        F2 = padarray(F2,[max12-length(F2),max12-length(F2)],'post');
        [x,p]=goldmod(F1,F2);
        simi=-GoldSimpleDistance(F1,x);
        if isequal(x,F2)==0
           cambiati=cambiati+1;
        end
        sim(i,j)=simi;
        sim(j,i)=simi;
    end
end

%se ci sono scarti li tolgo dal clustering e li rimetto alla fine in un
%cluster a parte
sim2=removeDummy(sim);
scarti=0;
if length(sim2)<length(sim),
    [ graforig ] = manageDummies( sim, graforig, postoKI );
    scarti=1;
end
end