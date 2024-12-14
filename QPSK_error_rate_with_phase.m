% QPSK Error Rate Simulation Script
% Initialization
A = 1;
Delta = 1;
k = 10000; % Number of bits
nb_frames = 100; % Number of frames
Eb_N0_dB = -2:2:14; % Range of SNR in dB
phi = pi/8; % Phase difference between Tx and Rx

% Derived parameters
M = 4; % QPSK modulation
bits_per_symbol = log2(M);
num_symbols = k / bits_per_symbol;

% Preallocate space for error rate results
ser = zeros(3, length(Eb_N0_dB));
ber = zeros(3, length(Eb_N0_dB));
theoretical_ser = zeros(1, length(Eb_N0_dB));
theoretical_ber = zeros(1, length(Eb_N0_dB));
execution_times = zeros(3, length(Eb_N0_dB)); % Store execution times for each detector

% Monte Carlo Simulation
for i_snr = 1:length(Eb_N0_dB)
    % Calculate noise variance based on SNR
    Eb_N0 = 10^(Eb_N0_dB(i_snr)/10);
    N0 = (A^2 * Delta^2) / (4 * Eb_N0);
    noise_variance = N0 / 2;
    
    num_symbol_errors = zeros(3, 1);
    num_bit_errors = zeros(3, 1);
    total_symbols = 0;
    total_bits = 0;
    
    for frame = 1:nb_frames
        % Step 1: Generate k random bits
        bits = randi([0 1], 1, k);
        
        % Step 2: Map bits to QPSK symbols using Bit2SymbolMappingQPSKGray
        qpsk_symbols = Bit2SymbolMappingQPSKGray(A, bits);
        
        % Step 3: Apply phase shift between Tx and Rx
        qpsk_symbols_shifted = qpsk_symbols * exp(1i * phi);
        
        % Step 4: Add noise to symbols using AWGN function
        received_symbols = AWGN(Delta, noise_variance, qpsk_symbols_shifted);
        
        % Step 5: Demodulate received symbols using different ML detectors
        % Detector 1: MLSymbolDetectorQPSK
        tic;
        demod_symbols_1 = MLSymbolDetectorQPSK(A, received_symbols);
        execution_times(1, i_snr) = execution_times(1, i_snr) + toc;
        demod_bits_1 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_1);
        num_symbol_errors(1) = num_symbol_errors(1) + sum(qpsk_symbols ~= demod_symbols_1.');
        num_bit_errors(1) = num_bit_errors(1) + sum(bits ~= demod_bits_1);
        
        % Detector 2: MLSymbolDetectorQPSKdistance
        tic;
        demod_symbols_2 = MLSymbolDetectorQPSKdistance(A, received_symbols);
        execution_times(2, i_snr) = execution_times(2, i_snr) + toc;
        demod_bits_2 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_2);
        num_symbol_errors(2) = num_symbol_errors(2) + sum(qpsk_symbols ~= demod_symbols_2.');
        num_bit_errors(2) = num_bit_errors(2) + sum(bits ~= demod_bits_2);
        
        % Detector 3: MLSymbolDetectorQPSKlowCPLX
        tic;
        demod_symbols_3 = MLSymbolDetectorQPSKlowCPLX(A, received_symbols);
        execution_times(3, i_snr) = execution_times(3, i_snr) + toc;
        demod_bits_3 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_3);
        num_symbol_errors(3) = num_symbol_errors(3) + sum(qpsk_symbols ~= demod_symbols_3.');
        num_bit_errors(3) = num_bit_errors(3) + sum(bits ~= demod_bits_3);
        
        total_symbols = total_symbols + length(qpsk_symbols);
        total_bits = total_bits + length(bits);
    end
    
    % Calculate SER and BER for each detector
    for detector = 1:3
        ser(detector, i_snr) = num_symbol_errors(detector) / total_symbols;
        ber(detector, i_snr) = num_bit_errors(detector) / total_bits;
    end
    
    % Theoretical SER and BER for QPSK
    %theoretical_ser(i_snr) = 2 * qfunc(sqrt(2 * Eb_N0)) * (1 - 0.5 * qfunc(sqrt(2 * Eb_N0)));
    theoretical_ber(i_snr) = erfc(sqrt((1/2)*E_N0_lin(i_snr)));
    theoretical_ber(i_snr) = theoretical_ser(i_snr) / bits_per_symbol;
end

% Plot the results
figure;
semilogy(Eb_N0_dB, ser(1, :), 'b-o', 'LineWidth', 1.5);
hold on;
semilogy(Eb_N0_dB, ser(2, :), 'g-s', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, ser(3, :), 'm-^', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, theoretical_ser, 'r--', 'LineWidth', 1.5);
xlabel('E_b/N_0 (dB)');
ylabel('Symbol Error Rate (SER)');
grid on;
legend('Simulated SER (ML Detector 1)', 'Simulated SER (ML Detector 2)', 'Simulated SER (ML Detector 3)', 'Theoretical SER');
title('QPSK Symbol Error Rate vs E_b/N_0');

figure;
semilogy(Eb_N0_dB, ber(1, :), 'b-o', 'LineWidth', 1.5);
hold on;
semilogy(Eb_N0_dB, ber(2, :), 'g-s', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, ber(3, :), 'm-^', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, theoretical_ber, 'r--', 'LineWidth', 1.5);
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
grid on;
legend('Simulated BER (ML Detector 1)', 'Simulated BER (ML Detector 2)', 'Simulated BER (ML Detector 3)', 'Theoretical BER');
title('QPSK Bit Error Rate vs E_b/N_0');
xlim([min(Eb_N0_dB), max(Eb_N0_dB)]); % Ensure the x-axis goes to the full range of -2 to 14 dB

% Plot execution times for each detector
figure;
plot(Eb_N0_dB, execution_times(1, :) / nb_frames, 'b-o', 'LineWidth', 1.5);
hold on;
plot(Eb_N0_dB, execution_times(2, :) / nb_frames, 'g-s', 'LineWidth', 1.5);
plot(Eb_N0_dB, execution_times(3, :) / nb_frames, 'm-^', 'LineWidth', 1.5);
xlabel('E_b/N_0 (dB)');
ylabel('Average Execution Time per Frame (seconds)');
grid on;
legend('ML Detector 1', 'ML Detector 2', 'ML Detector 3');
title('Average Execution Time vs E_b/N_0');
