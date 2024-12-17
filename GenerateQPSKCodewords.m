function QPSKCodewords = GenerateQPSKCodewords(G, A)
    ListeCodeWords = GenerateListeCodeWords(G);
    numCodeWords = size(ListeCodeWords, 1);
    n_c = size(G, 2);  
    
    for i = 1:numCodeWords
        codeword = ListeCodeWords(i, :);
        
        qpskSymbols = Bit2SymbolMappingQPSKGray(A, codeword);
        QPSKCodewords(i, :) = qpskSymbols;
    end
end
