% QPSK Coded Error Rate Simulation for Repetition and Hamming Codes
% Initialization
A = 1; 
Delta = 1; 
k = 10000; % Number of bits
nb_frames = 100; % Number of frames
Es_N0_dB = -2:2:12; % Range of SNR in dB
phi = 0; % Phase difference between Tx and Rx

% Repetition Codes and Hamming Code
Rc_values = [1/2, 1/3]; % Rates for repetition codes
G_Hamming = [1 0 0 0 1 1 1 1;
             0 1 0 0 1 1 0 1;
             0 0 1 0 1 0 1 1;
             0 0 0 1 0 1 1 1];

% Preallocate BER
ber_repetition_1_2 = zeros(1, length(Es_N0_dB));
ber_repetition_1_3 = zeros(1, length(Es_N0_dB));
ber_hamming = zeros(1, length(Es_N0_dB));

% Monte Carlo Simulation
for i_snr = 1:length(Es_N0_dB)
    Es_N0_lin = 10^(Es_N0_dB(i_snr)/10);
    noise_variance = (A^2 * Delta^2) / (2 * Es_N0_lin);
    total_bits = 0;
    errors_repetition_1_2 = 0;
    errors_repetition_1_3 = 0;
    errors_hamming = 0;

    for frame = 1:nb_frames
        % Generate random bits
        bits = randi([0 1], 1, k);
        
        % Code 1: Repetition Code (Rate 1/2)
        bits_rep_1_2 = repelem(bits, 2);
        symbols_rep_1_2 = Bit2SymbolMappingQPSKGray(A, bits_rep_1_2);
        received_rep_1_2 = AWGN(Delta, noise_variance, symbols_rep_1_2 * exp(1i * phi));
        demod_bits_rep_1_2 = Symbol2BitsDemappingQPSKGray(A, Delta, received_rep_1_2);
        decoded_bits_1_2 = DecodeRepetition(demod_bits_rep_1_2, 2);
        errors_repetition_1_2 = errors_repetition_1_2 + sum(bits ~= decoded_bits_1_2(1:k));

        % Code 2: Repetition Code (Rate 1/3)
        bits_rep_1_3 = repelem(bits, 3);
        symbols_rep_1_3 = Bit2SymbolMappingQPSKGray(A, bits_rep_1_3);
        received_rep_1_3 = AWGN(Delta, noise_variance, symbols_rep_1_3 * exp(1i * phi));
        demod_bits_rep_1_3 = Symbol2BitsDemappingQPSKGray(A, Delta, received_rep_1_3);
        decoded_bits_1_3 = DecodeRepetition(demod_bits_rep_1_3, 3);
        errors_repetition_1_3 = errors_repetition_1_3 + sum(bits ~= decoded_bits_1_3(1:k));
        
        % Code 3: Hamming Code
        encoded_bits_hamming = Encode(G_Hamming, bits);
        symbols_hamming = Bit2SymbolMappingQPSKGray(A, encoded_bits_hamming);
        received_hamming = AWGN(Delta, noise_variance, symbols_hamming * exp(1i * phi));
        demod_bits_hamming = Symbol2BitsDemappingQPSKGray(A, Delta, received_hamming);
        decoded_bits_hamming = HMLDecode(GenerateListeCodeWords(G_Hamming), demod_bits_hamming);
        errors_hamming = errors_hamming + sum(bits ~= decoded_bits_hamming(1:k));
        
        total_bits = total_bits + k;
    end
    
    % Calculate BER
    ber_repetition_1_2(i_snr) = errors_repetition_1_2 / total_bits;
    ber_repetition_1_3(i_snr) = errors_repetition_1_3 / total_bits;
    ber_hamming(i_snr) = errors_hamming / total_bits;

    % Theoretical SER and BER for QPSK

end

% Plot the results
figure;
semilogy(Es_N0_dB, ber_repetition_1_2, 'b-o', 'LineWidth', 1.5);
hold on;
semilogy(Es_N0_dB, ber_repetition_1_3, 'g-s', 'LineWidth', 1.5);
semilogy(Es_N0_dB, ber_hamming, 'm-^', 'LineWidth', 1.5);
%semilogy(Eb_N0_dB, theoretical_ser, 'r--x', 'LineWidth', 1.5);
xlabel('E_s/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
grid on;
legend('Repetition Code (Rate 1/2)', 'Repetition Code (Rate 1/3)', 'Hamming Code');
title('BER Comparison of Coded QPSK Schemes');
