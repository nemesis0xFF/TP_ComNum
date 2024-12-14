function d_est = MLSymbolDetectorQPSKdistance(A,z)
    a_k=(A/sqrt(2))*[-1-1i;-1+1i;1-1i;1+1i];
    d_est=zeros(1,length(z));
    inter=zeros(4,length(z));

    inter(1,1:end)=pow2(abs(z-a_k(1)));
    inter(2,1:end)=pow2(abs(z-a_k(2)));
    inter(3,1:end)=pow2(abs(z-a_k(3)));
    inter(4,1:end)=pow2(abs(z-a_k(4)));
    
    [M,I]=min(inter,[],1);
    d_est=a_k(I);
end