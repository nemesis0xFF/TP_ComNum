% QPSK_coded_error_rate.m
% Initialization
clc;
clear;

A = 15;
Delta = 10;
k_c = 4; % Number of bits per codeword
n_c = 8; % Length of codeword
num_codewords_per_frame = 100; % Number of codewords per frame
nb_frames = 100; % Number of frames
Eb_N0_dB = -2:2:14; % Range of SNR in dB

% Generator and parity-check matrices
G = [1 0 0 0 1 1 1 1;
     0 1 0 0 1 1 0 1;
     0 0 1 0 1 0 1 1;
     0 0 0 1 0 1 1 1];

H = [1 1 1 0 1 0 0 0;
     1 1 0 1 0 1 0 0;
     1 0 1 1 0 0 1 0;
     1 1 1 1 0 0 0 1];

% Generate the list of codewords
ListeCodeWord = GenerateListeCodeWords(G);
size(ListeCodeWord)
% Derived parameters
bits_per_symbol = log2(4); % QPSK
num_bits_per_frame = num_codewords_per_frame * k_c;
num_symbols = num_bits_per_frame / bits_per_symbol;

% Preallocate space for error rate results
ber_coded = zeros(1, length(Eb_N0_dB));

% Monte Carlo Simulation
for i_snr = 1:length(Eb_N0_dB)
    % Calculate noise variance based on SNR
    Eb_N0_lin = 10^(Eb_N0_dB(i_snr) / 10);
    noise_variance = ((A^2 * Delta^2) / 4) * 10^(-Eb_N0_dB(i_snr) / 10);
    
    total_errors = 0;
    total_bits = 0;

    for frame = 1:nb_frames
        % Step 1: Generate random bits for the frame
        b = randi([0 1], 1, num_bits_per_frame);
        size(b)
        % Step 2: Encode the bits
        c = Encode(G, b);
        size(c)
        % Step 3: Map encoded bits to QPSK symbols
        qpsk_symbols = Bit2SymbolMappingQPSKGray(A, c);

        % Step 4: Add AWGN noise
        received_symbols = AWGN(Delta, noise_variance, qpsk_symbols);

        % Step 5: Demodulate received symbols
        demapped_bits = Symbol2BitsDemappingQPSKGray(A, Delta, received_symbols);

        % Step 6: Decode the demapped bits
        decoded_bits = HMLDecode(ListeCodeWord, demapped_bits)

        % Step 7: Calculate errors
        total_errors = total_errors + sum(b ~= decoded_bits);
        total_bits = total_bits + length(b);
    end

    % Calculate Bit Error Rate (BER)
    ber_coded(i_snr) = total_errors / total_bits;
end

% Plot the BER results
figure;
semilogy(Eb_N0_dB, ber_coded, 'b-o', 'LineWidth', 1.5);
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
grid on;
title('QPSK Coded BER vs E_b/N_0');
legend('Coded BER');
