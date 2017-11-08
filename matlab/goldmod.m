function [ Gperm, P ] = goldmod( A, B )

%padding del grafo più piccolo al più grande
%NB padding qui solo per rendere il metodo autotestabile
dA=length(A);
dB=length(B);
if dA>=dB
   G = padarray(B,[dA-dB,dA-dB],'post');
   g = A;
else
    G = B;
    g = padarray(A,[dB-dA,dB-dA],'post');
end  

%parametri (modifico qui nelle prove)
beta0=0.5;
beta_fin=10;
beta_rel=1.075;
I0=4;
I1=30;

%salvo le dimensioni numero nodi di G e g
A=length(G);
I=length(g);
%parte commentata perchè ho modificato dopo semplificando con l'assunzione
%pesi unitari
%costruisco la matrice dei costi con la convenzione dei random graphs
% C=zeros(A,I,A,I);
% for a=1:A,
%     for i=1:I,
%         for b=1:A,
%             for j=1:I,
%                 if G(a,b)~=0 && g(i,j) ~=0 && G(a,a)==g(i,i) && G(b,b)==g(j,j),
%                     C(a,i,b,j)=1;%-3*abs(G(a,b)-g(i,j));
%                 end
%             end
%         end
%     end
% end
%inizializzo beta e M_slack
beta=beta0;
M_slack=zeros(A+1,I+1);
for a=1:A+1,
    for i=1:I+1,
        M_slack(a,i)=1.5;
    end
end

%inizio A
while beta<beta_fin
    %setto condizioni B
    iterB=0;
    convB=0;
    %inizio B
    while convB==0 && iterB<I0
        %salvo la matrice M in ingresso
        M_ini=M_slack(1:A,1:I);
        %formula Qai
        Q=zeros(A,I);
        for a=1:A,
            for i=1:I,
                for b=1:A,
                    for j=1:I,
                        if G(a,b)~=0 && g(i,j) ~=0 && G(a,a)==g(i,i) && G(b,b)==g(j,j) && a~=b && i~=j,
                            Q(a,i)=Q(a,i)+M_slack(b,j);%C(a,i,b,j)*M_slack(b,j);
                        end
                    end
                end
            end
        end
        %aggiorno M
        for a=1:A,
            for i=1:I,
                M_slack(a,i)=exp(beta*Q(a,i));
            end
        end
        %setto condizioni C
        iterC=0;
        convC=0;
        %inizio C
        while convC==0 && iterC<I1
            %salvo la matrice M_slack in ingresso
            M_slack_ini=M_slack;
            %normalizzo le righe
            col_sum=sum(M_slack, 2);
            for a=1:A+1,
                for i=1:I+1,
                    M_slack(a,i)=M_slack(a,i)/col_sum(a);
                end
            end
            %normalizzo le colonne
            row_sum=sum(M_slack, 1);
            for a=1:A+1,
                for i=1:I+1,
                    M_slack(a,i)=M_slack(a,i)/row_sum(i);
                end
            end
            %check convergenza
            M_slack_diff=abs(M_slack_ini-M_slack);
            if sum(M_slack_diff)<0.05
                convC=1;
            end
            %aumento contatore
            iterC=iterC+1;
        %fine C    
        end
        
        %check convergenza
        M_diff=abs(M_ini-M_slack(1:A,1:I));
        if sum(M_diff)<0.5
            convB=1;
        end
        %aumento contatore
        iterB=iterB+1;
    %fine B    
    end
    %aggiorno beta
    beta=beta*beta_rel;
%fine A    
end
M=M_slack(1:A,1:I);
%metodo ungherese scaricato da internet
P=Hungarian(-M);
Gperm=P*G*P';
end
