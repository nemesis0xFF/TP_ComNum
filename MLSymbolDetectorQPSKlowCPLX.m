function d_est = MLSymbolDetectorQPSKlowCPLX(A,z)
     d_est=zeros(1,length(z));
     a_kre = (A/sqrt(2)) * [-1; 1];
     a_kim = (A/sqrt(2)) * [-1i; 1i];

     im = zeros(1, length(z));
     re = zeros(1, length(z));
     %detection en utilisant le symbole des parties imaginaires et reelles
     im(imag(z) > 0) = a_kim(2);
     im(imag(z) <= 0) = a_kim(1);
    
     re(real(z) > 0) = a_kre(2);
     re(real(z) <= 0) = a_kre(1);

     d_est=re+im;
     d_est = d_est.';
end
