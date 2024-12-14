function d_est = MLSymbolDetectorQPSKdistance(A,z)
  d=A/sqrt(2)*[-1-i,-1+i,1-i,1+i];
  d_est = zeros(1, length(z));
  for k=1:length(z)
    index_array=abs(z(k)-d).^2;
    index=find(index_array==min(index_array));
    d_est(k)=d(index);
  end
end
