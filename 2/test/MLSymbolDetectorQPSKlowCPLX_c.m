function d_est = MLSymbolDetectorQPSKlowCPLX(A,z)
  d=A/sqrt(2)*[-1-i,-1+i,1-i,1+i];
  d_est = zeros(1, length(z));
  real = real(z);
  imag = imag(z);
  for k=1:length(z)
    a=0;
    b=0;
    if real(k)>0
      a=1;
    end
    if imag(k)>0
      b=1;
    end
    d_est(k)=d(2*a+b+1);
  end
end
