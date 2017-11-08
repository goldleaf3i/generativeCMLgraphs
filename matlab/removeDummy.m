function [ Gprime ] = removeDummy( Ggen )
%Toglie i dummy vertices

dim=length(Ggen);
rimuovi=zeros(1,dim);
newpos=zeros(1,dim);
pos=0;
for i=1:dim,
    if all(Ggen(i,1:i-1)==0) && all(Ggen(i,i+1:dim)==0) 
        rimuovi(i)=1;
    else
        pos=pos+1;
        newpos(pos)=i;
    end
end
Gprime=zeros(dim-sum(rimuovi));
lnew=length(Gprime);
for p1=1:lnew,
    for p2=1:lnew,
        Gprime(p1,p2)=Ggen(newpos(p1),newpos(p2));
    end
end

% pi=1;
% pj=1;
% for i=1:dim,
%     for j=1:dim,
%         if rimuovi(i)==0 && rimuovi(j)==0,
%             Gprime(pi,pj)=Ggen(i,j);
%             if j==dim,
%                 pi=pi+1;
%                 pj=1;
%             else
%                 pj=pj+1;
%             end
%         elseif j==dim,
%             pi=pi+1;
%             pj=1;
%         elseif i==dim || j==1,
%             break;
%         end
%     end
% end

end

