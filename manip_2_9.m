% QPSK Coded Error Rate Simulation for Repetition and Hamming Codes
% Initialization
A = 1; 
Delta = 1; 
k = 10000; % Number of bits
nb_frames = 100; % Number of frames
Es_N0_dB = -2:2:12; % Range of SNR in dB
phi = 0; % Phase difference between Tx and Rx

% Repetition Codes and Hamming Code
Rc_rep_1_2 = 1/2; % Rate for Repetition x2
Rc_rep_1_3 = 1/3; % Rate for Repetition x3
Rc_hamming = 1/2; % Rate for Hamming Code
G_Hamming = [1 0 0 0 1 1 1 1;
             0 1 0 0 1 1 0 1;
             0 0 1 0 1 0 1 1;
             0 0 0 1 0 1 1 1];

% Preallocate BER
ber_repetition_1_2 = zeros(1, length(Es_N0_dB));
ber_repetition_1_3 = zeros(1, length(Es_N0_dB));
ber_hamming = zeros(1, length(Es_N0_dB));
ber_eml = zeros(1, length(Es_N0_dB));

% Convert Es/N0 to Eb/N0 for each code
Eb_N0_dB_rep_1_2 = Es_N0_dB;
Eb_N0_dB_rep_1_3 = Es_N0_dB - 10*log10(Rc_rep_1_3*log2(4));
Eb_N0_dB_hamming = Es_N0_dB;
Eb_N0_dB_eml = Eb_N0_dB_hamming; % Même taux que le Hamming pour comparaison

list_qpsk_codewords = GenerateQPSKCodewords(G_Hamming, A)

% Monte Carlo Simulation
for i_snr = 1:length(Es_N0_dB)
    i_snr
    Es_N0_lin = 10^(Es_N0_dB(i_snr)/10);
    noise_variance = (A^2 * Delta^2) / (2 * Es_N0_lin);
    total_bits = 0;
    errors_repetition_1_2 = 0;
    errors_repetition_1_3 = 0;
    errors_hamming = 0;
    errors_eml = 0;

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

        % Code 4: EMLDecode
        symbols_eml = Bit2SymbolMappingQPSKGray(A, encoded_bits_hamming);
        received_eml = AWGN(Delta, noise_variance, symbols_eml * exp(1i * phi));
        decoded_bits_eml = EMLDecode(A, Delta, list_qpsk_codewords, received_eml);
        errors_eml = errors_eml + sum(bits ~= decoded_bits_eml(1:k));

        
        total_bits = total_bits + k;
    end
    
    % Calculate BER
    ber_repetition_1_2(i_snr) = errors_repetition_1_2 / total_bits;
    ber_repetition_1_3(i_snr) = errors_repetition_1_3 / total_bits;
    ber_hamming(i_snr) = errors_hamming / total_bits;
    ber_eml(i_snr) = errors_eml / total_bits;

    theoretical_ser(i_snr) = erfc(sqrt((1/2)*10.^(Es_N0_dB(i_snr)/10)))
    theoretical_ber(i_snr) = theoretical_ser(i_snr) / 2;
end

% Plot the results as a function of Eb/N0
figure;
semilogy(Eb_N0_dB_rep_1_2, ber_repetition_1_2, 'b-o', 'LineWidth', 1.5, 'DisplayName', 'Repetition Code x2');
hold on;
semilogy(Eb_N0_dB_eml, ber_eml, 'c-d', 'LineWidth', 1.5, 'DisplayName', 'EML Decode');

semilogy(Eb_N0_dB_rep_1_3, ber_repetition_1_3, 'g-s', 'LineWidth', 1.5, 'DisplayName', 'Repetition Code x3');
semilogy(Eb_N0_dB_hamming, ber_hamming, 'm-^', 'LineWidth', 1.5, 'DisplayName', 'Hamming Code (8,4)');

xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
grid on;
legend show;
title('BER Comparison of Coded QPSK Schemes as a Function of E_b/N_0');
