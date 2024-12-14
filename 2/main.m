% Parameters
K = 100
A = sqrt(2);
Delta = 1; % unused
v = 0.001;

m = randi([0 1], K, 1);
disp(["Bit sequence: ", mat2str(m)])

d = Bits2SymbolMappingQPSKGray(A, m);
disp(["Symbols: ", mat2str(d)])

m_est = Symbol2BitsDemappingQPSKGray(A, Delta, d);
disp(["Demapped bits: ", mat2str(m_est)])

z = AWGN2(Delta, v, d);
disp(z)

d_est = MLSymbolDetectorQPSK(A, z);
disp(["Estimated Symbols", mat2str(d_est)]);


PlotConstellation(z);