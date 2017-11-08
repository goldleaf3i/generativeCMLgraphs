function [ p ] = calcolaProb( A,B,i1,i2,alfa,beta,gamma )
%mi dice la probabilità che il nodo i1 di A vada collegato al nodo i2 di B,
%facendo il prodotto delle prob ocndizionate idipendenti
iA=ID2index(A(i1,i1));
iB=ID2index(B(i2,i2));
gammaA=gamma{iA};
gammaB=gamma{iB};
contA=0;
contB=0;
pgammaA=0;
pgammaB=0;
for i=1:length(A),
    if i~=i1 && A(i1,i)==1
        ialtro=ID2index(A(i,i));
        pgammaA=pgammaA+gammaA(min(ialtro,iB),max(ialtro,iB));
        contA=contA+1;
    end
end
if pgammaA>0 && contA>0
    pgammaA=pgammaA/contA;
end
for i=1:length(B),
    if i~=i2 && B(i2,i)==1
        ialtro=ID2index(B(i,i));
        pgammaB=pgammaB+gammaB(min(ialtro,iA),max(ialtro,iA));
        contB=contB+1;
    end
end
if pgammaB>0 && contB>0
    pgammaB=pgammaB/contB;
end    
porteA=sum(A(i1,:))-A(i1,i1)+1;
porteB=sum(A(i2,:))-A(i2,i2)+1;
alfaA=alfa(iA,porteA);
alfaB=alfa(iB,porteB);
primo=min(iA,iB);
secondo=max(iA,iB);
betaAB=beta(primo,secondo);
p=alfaA*alfaB*betaAB*pgammaA*pgammaB;

end

