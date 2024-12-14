function d = Bits2SymbolMappingQPSKGray(A, m)
    d=zeros(1,length(m)/2);
    d=(2*m(1:2:end)-1+i*(2*m(2:2:end)-1))*A/sqrt(2);
end