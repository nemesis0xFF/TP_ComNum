function z = AWGN(Delta,v,d)    
    z=Delta.^2/2*d + Delta/sqrt(2)*sqrt(v)*(randn(size(d))+1i*randn(size(d)));
end