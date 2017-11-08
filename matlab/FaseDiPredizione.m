function [ grafo_samplato ] = FaseDiPredizione( grafo_esplorato, archi_cut_uscenti, estremi_archi_cut_coppie_sottografi )
%funzione che sampla un grafo completo partendo dal grafo finora esplorato
%utilizzando i soliti script Segmentation, ClusteringAndConnectionManager,
%ecc... messi sotto forma di funzione e chiamati in sequenza; una volta
%ottenuto il grafo samplato questo viene usato per prendere un qualche tipo
%di decisione (ancora da capire come fare) in merito a come procedere con
%l'esplorazione (deve prendere una decisione su come muoversi insomma)
%oppure una volta ottenuto il grafo samplato lo restituisce e basta e la
%decisione viene presa al di fuori di questa funzione

%per il momento gli unici parametri passati sono grafo_esplorato,
%archi_cut_uscenti  e estremi_archi_cut_coppie_sottografi ma probabilmente
%ne serviranno degli altri da dare in ingresso agli script Segmentation,
%ClusteringAndConnectionManager, ecc... che vengono chiamati qui dentro

%per il momento l'unico parametro restituito è grafo_samplato ma non è
%escluso che sia necessario restituire anche altre cose o che sia inutile
%restituire grafo_samplato

%per il momento (finchè non capiamo come prendere una decisione su come
%muoversi sulla base della predizione effettuata) questa funzione non fa
%niente

grafo_samplato = 0;

dim = size(grafo_esplorato, 1);
str = sprintf('il grafo esplorato finora ha %d nodi', dim);
disp(str);

dim = length(archi_cut_uscenti);
str = sprintf('il grafo esplorato finora ha %d archi uscenti', dim);
disp(str);

str = sprintf('samplo un nuovo grafo a partire dal grafo esplorato e dalle informazioni sui suoi archi uscenti e poi decido come muovermi \n');
disp(str);

pause(3);

end

