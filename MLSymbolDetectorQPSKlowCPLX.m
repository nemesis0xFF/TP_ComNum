function d_est = MLSymbolDetectorQPSKlowCPLX(A,z)
     d_est=zeros(1,length(z));
     a_kre = (A/sqrt(2)) * [-1; 1];
     a_kim = (A/sqrt(2)) * [-1i; 1i];

% Initialiser les vecteurs im et re avec les mêmes dimensions que z
     im = zeros(1, length(z));
     re = zeros(1, length(z));

     im(imag(z) > 0) = a_kim(2); % Si la partie imaginaire est positive
     im(imag(z) <= 0) = a_kim(1); % Si la partie imaginaire est négative ou nulle
    
     re(real(z) > 0) = a_kre(2); % Si la partie réelle est positive
     re(real(z) <= 0) = a_kre(1); % Si la partie réelle est négative ou nulle    

     d_est=re+im;
     d_est = d_est.';
     

end