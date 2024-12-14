clc;
%clear all;
close all;
A = 1;
Delta = 30;
v = 1;


m = [1 0 0 0 1 1 0 1 1 0 1 1 1 1 1 1 0 0 0 1]; %28 bits1 0 0 0 0 0 1 0
%m = [1 0 0 0 1 1 0 1 1 0 1 1 1 1 1 1]; %28 bits1 0 0 0 0 0 1 0
%m = randi([0, 1], 1, 48);




sym = Bit2SymbolMappingQPSKGray(A, m);
m;
%demap = Symbol2BitsDemappingQPSKGray(A, 1, sym)
%bruite = AWGN(2, 0.1, sym)
%plot(bruite, '-x', 'LineStyle', 'none', 'MarkerSize', 32, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red')
%xlabel('I')
%ylabel('Q')



sym_bruit = AWGN(1, 1, sym);

ml1 = MLSymbolDetectorQPSK(A, sym_bruit);
ml2 = MLSymbolDetectorQPSKdistance(A, sym_bruit);
ml3 = MLSymbolDetectorQPSKlowCPLX(A, sym_bruit);

result1 = (sym.' == ml1).';
result2 = (sym.' == ml2).';
result3 = (sym.' == ml3).';

result12 = (ml1 == ml2).';
result23 = (ml2 == ml3).';
result13 = (ml1 == ml3).';



m2 = [1 0 0 0 1 1 0 1 1 0 1 1 1 1 1 1 0 0 0 1];
% Encoding function
G = [1 0 0 0 1 1 1 1;
     0 1 0 0 1 1 0 1;
     0 0 1 0 1 0 1 1;
     0 0 0 1 0 1 1 1];
ListeCodeWord = GenerateListeCodeWords(G);

encoded_bits = Encode(G, m2);
sym2 = Bit2SymbolMappingQPSKGray(A, encoded_bits);
sym2_bruit = AWGN(Delta, v, sym2);
detected_sym = MLSymbolDetectorQPSK(A, sym2_bruit);
demap_bits = Symbol2BitsDemappingQPSKGray(A, Delta, detected_sym);
decoded_bits = HMLDecode(ListeCodeWord, demap_bits)






% Test error detection
%r = [0 1 0 0 1 1 1 1]; % Example received vector
%error1 = IsErrorDetection(r, H); 

%r = ListeCodeWord(1, :); % Un codeword correct sans erreur
%error2 = IsErrorDetection(r, H); % Devrait retourner false



% Test ML Decoder
%m_est = [1 0 0 1 1 0 1 1 1 0 0 1 0 1 1 0 1 0 1 0]; % Example received vector
%m_dec = HMLDecode(ListeCodeWord, m_est)
