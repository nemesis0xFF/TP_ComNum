% QPSK Error Rate Simulation Script

% Start the timer
tic

% Initialization
A = 1;
Delta =1;
k = 10000;
nb_frames = 100;

% SNR range from -2dB to 14dB with 2dB steps
EbN0_dB_range = -2:2:14;

% Simulation
for i = 1:length(EbN0_dB_range)
    % Calculate noise variance
    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^-(EbN0_dB / 10);
    v = A^2 * Delta^2 / (4 * EbN0);

    % Initialize error counters
    symbol_errors = 0;
    bit_errors = 0;

    for j = 1:nb_frames
        % Generate random bits
        bits = randi([0 1], 1, k);

        % Map bits to QPSK symbols
        symbols = Bit2SymbolMappingQPSKGray(A, bits);

        % Add noise to symbols
        z = AWGN(Delta, v, symbols);

        % Apply ML criteria for symbol decision
        decoded_symbols = MLSymbolDetectorQPSK(A,z); %Change of ML Symbol Detector

        % Decoded bits
        decoded_bits = Symbol2BitMappingQPSKGray(A,Delta,decoded_symbols);

        % Count errors
        symbol_errors = symbol_errors + sum(symbols ~= decoded_symbols);
        bit_errors = bit_errors + sum(bits ~= decoded_bits);
    end

    % Calculate error rates
    SER_simulated = symbol_errors / (nb_frames * k / 2);
    BER_simulated = bit_errors / (nb_frames * k);

    % Theoretical Bit Error Rate
    BER_theoretical = qfunc(sqrt(2*EbN0));
    % Theoretical Symbol Error Rate
    SER_theoretical = BER_theoretical*2;

    % Display results
    fprintf('Eb/N0 = %d dB\n', EbN0_dB);
    fprintf('Simulated Symbol Error Rate: %e\n', SER_simulated);
    fprintf('Theoretical Symbol Error Rate: %e\n', SER_theoretical);
    fprintf('Simulated Bit Error Rate: %e\n', BER_simulated);
    fprintf('Theoretical Bit Error Rate: %e\n\n', BER_theoretical);
end
% Stop the timer
toc
