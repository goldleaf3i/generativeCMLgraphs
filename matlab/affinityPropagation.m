%esegue clustering dei sottografi utilizzando affinity propagation
%INPUT:  sim - matrice di similarità dei sottografi
%        dampingFactor - fattore di smorzamento, valore compreso tra 0 e 1
%        E - matrice di evidence, somma tra responsibility e availability
%        K - numero di sottografi modello per ogni cluster (numero di cluster)
%        idx - indice dei modelli per i sottografi (idx(i) è l'indice del
%        sottografo modello (cluster) del sottografo i)
%OUTPUT: riferimenti - matrice di clusterizzazione (riferimenti(c,i) è 1 se
%il sottografo i è presente nel cluster c, 0 altrimenti)
function [E, K, idx, riferimenti] = affinityPropagation(sim, dampingFactor)
    N = size(sim,1);
    med = median(sim(find(~tril(ones(size(sim))))));
    for i=1:N
        sim(i,i) = med;
    end
    A = zeros(N,N); % Availability matrix
    R = zeros(N,N); % Responsibility matrix
    
    sim = sim + 1e-12*randn(N,N)*(max(sim(:)) - min(sim(:))); % Remove degeneracies (to minimize oscillations)
    
    for iter=1:100
        % Compute responsibilities
        Rold = R;
        Asim = A + sim;
        [Y,I] = max(Asim,[],2);
        for i=1:N
            Asim(i,I(i)) = -realmax;
        end;
        [Y2,I2] = max(Asim,[],2);
        R = sim - repmat(Y,[1,N]);
        for i=1:N
            R(i,I(i)) = sim(i,I(i)) - Y2(i);
        end;
        R = (1-dampingFactor)*R + dampingFactor*Rold; % Dampen responsibilities
        
        % Compute availabilities
        Aold = A;
        Rp = max(R,0);
        for k=1:N
            Rp(k,k) = R(k,k);
        end;
        A = repmat(sum(Rp,1),[N,1]) - Rp;
        dA = diag(A);
        A = min(A,0);
        for k=1:N
            A(k,k) = dA(k);
        end;
        A = (1-dampingFactor)*A + dampingFactor*Aold; % Dampen availabilities
    end;
    
    E = R + A; % Pseudomarginals
    I = find(diag(E)>0); % Indices of exemplars
    K = length(I);
    [tmp, c] = max(sim(:,I),[],2);
    c(I) = 1:K;
    idx = I(c); % Assignments
    
    % creo la matrice di clusterizzazione
    riferimenti = zeros(K,N);
    for i=1:N
        c = find(I == idx(i));
        riferimenti(c, i) = 1;
    end
end  
