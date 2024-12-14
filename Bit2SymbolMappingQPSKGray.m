function sym = Bit2SymbolMappingQPSKGray(A,m)
    sym=zeros(1,length(m)/2);
    sym=A/sqrt(2)*(2*m(1:2:end)-1+i*(2*m(2:2:end)-1));
end
