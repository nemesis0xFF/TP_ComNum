function sym2 = Symbol2BitsDemappingQPSKGray(A, Delta, d_est)
    sym2 = zeros(1,length(d_est)*2);
    sym2(1:2:end)=real(d_est)>0;
    sym2(2:2:end)=imag(d_est)>0;
end
