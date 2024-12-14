function d_est = MLSymbolDetectorQPSK(A,z)
    a_k=(A/sqrt(2))*[-1-1i;-1+1i;1-1i;1+1i];
    d_est=zeros(1,length(z));
    inter=zeros(4,length(z));

    inter(1,1:end)=real(conj(a_k(1))*z);
    inter(2,1:end)=real(conj(a_k(2))*z);
    inter(3,1:end)=real(conj(a_k(3))*z);
    inter(4,1:end)=real(conj(a_k(4))*z);
    
    [M,I]=max(inter,[],1);
    d_est=a_k(I);    
end