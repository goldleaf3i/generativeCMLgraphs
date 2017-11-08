function [ graforig ] = manageDummies( sim, graforig, postoKI )

%se tolgo i sottografi che non sono simili devo cambiare di conseguenza
%grafiorig

dim=length(sim);
rimuovi=zeros(1,dim);
newpos=zeros(1,dim);
pos=0;
posrim=0;
for i=1:dim,
    if all(sim(i,:)==0)
        rimuovi(i)=1;
        ki=postoKI{i};
        K=ki(1);
        I=ki(2);
        posrim=posrim+1;
        %lastcluster{posrim}=[K I];
        graforig(K,I)=0;
    else
        pos=pos+1;
        newpos(pos)=i;
        ki=postoKI{i};
        K=ki(1);
        I=ki(2);
        graforig(K,I)=pos;
    end
end

end

