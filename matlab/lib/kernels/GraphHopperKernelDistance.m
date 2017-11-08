function distance = GraphHopperKernelDistance( grafo_flippato, grafo_popolazione, utilParameter )
%prende due grafi e ne restituisce la distanza usando il kernel
%GraphHopper, questa funzione viene usata all'interno della seconda fase di
%sampling; grafo_flippato e grafo_popolazione sono due matrici di adiacenza
%con le etichette sulla diagonale, util parameter è un cell array che
%contiene: la stringa che dice il tipo di kernel da usare, il parametro mu
%e il parametro che dice se usare le label semplici oppure i vettori di
%valori associati ai nodi

%controllo che utilParameter sia un cell array e che abbia 3 elementi
if(iscell(utilParameter) == 0)
    error('input errato, non è un cell array');
end

if(length(utilParameter) ~= 3)
    error('input errato, dovrebbe contenere esattamente 3 elementi');
end

grafi = {grafo_flippato, grafo_popolazione};

grafi_conv = ConvertiPerGraphHopper(grafi);

node_kernel_type = utilParameter{1};
mu = utilParameter{2};
vecvalues = utilParameter{3};

[kernel_matrix, ~] = GraphHopper_dataset(grafi_conv, node_kernel_type, mu, vecvalues);

distance = sqrt(kernel_matrix(1,1) + kernel_matrix(2,2) - 2*kernel_matrix(1,2));

end

