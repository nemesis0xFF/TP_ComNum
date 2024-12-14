function d = Bit2SymbolMappingQPSKGray(A,m)
    d=zeros(1,length(m)/2);
    %A(1+i)/sqrt(2)   == 1,1
    %A(1-i)/sqrt(2)   == 1,0
    %A(-1+i)/sqrt(2)  == 0,1
    %A(-1-i)/sqrt(2)  == 0,0
    d=A/sqrt(2)*((2*m(1:2:end)-1)+i*(2*m(2:2:end)-1));
end
