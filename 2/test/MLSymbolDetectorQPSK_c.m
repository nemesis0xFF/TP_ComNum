function d_est = MLSymbolDetectorQPSK(A,z)
  d=A/sqrt(2)*[-1-i,-1+i,1-i,1+i];
  d_est = zeros(1, length(z));
  for k=1:length(z)
    index_array=real(conj(d)*z(k));
    index=find(index_array==max(index_array));
    d_est(k)=d(index);
  end
end
