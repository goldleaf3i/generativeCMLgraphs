function grafi_convertiti = ConvertiPerGraphHopper( grafi )
%prende come argomento un cell array contenente dei grafi sotto forma di
%matrici di adiacenza e restituisce un cell array contenente gli stessi
%grafi convertiti nel formato usato da GraphHopper

%esempio di utilizzo delle strutture, structure array con due elementi
%formati da quattro campi ciascuno:
%
%field1 = 'f1';  value1 = zeros(1,10);
%field2 = 'f2';  value2 = {'a', 'b'}; -> fare così (stesso discorso per la riga sottostante) equivale a dire:
%field3 = 'f3';  value3 = {pi, pi.^2};   "il campo f2 del primo elemento vale 'a' e il campo f2 del secondo
%field4 = 'f4';  value4 = {'fourth'};    elemento vale 'b'"
%
%s = struct(field1,value1,field2,value2,field3,value3,field4,value4);

%controllo che grafi sia un cell array
if(iscell(grafi) == 0)
    error('input errato, non è un cell array');
end

len = length(grafi);

field1 = 'am';
value1 = {};
field2 = 'al';
value2 = {};
field3 = 'nl';
value3 = {};

for i = 1:len
    curr_graph = grafi{i};
    values = [];
    vecvalues = [];
    r = size(curr_graph,1);
    
    for j = 1:r
        label = curr_graph(j,j);
        values = [values; label];
    end
    
    s = struct('values', values, 'vecvalues', vecvalues);
    
    value3{i} = s;
    
    adj_list = adjacencyList(curr_graph);
    value2{i} = adj_list;
    
    matrice_adiacenza_pulita = curr_graph;
    
    for j = 1:r
        matrice_adiacenza_pulita(j,j) = 0;
    end
    
    value1{i} = matrice_adiacenza_pulita;    
end

grafi_convertiti = struct(field1, value1, field2, value2, field3, value3);

end

