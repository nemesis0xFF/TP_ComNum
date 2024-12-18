% QPSK_coded_error_rate.m
% initialisation
clc;
clear;

A = 15;
Delta = 10;
k_c = 4; % nombre de bit par mot de code
n_c = 8; % longueur du mot de code
num_codewords_per_frame = 100; %nombre de mot de code par frame
nb_frames = 100; % nombre de frame
Eb_N0_dB = -2:2:14; % eb/N0

% Matrice generatrice et de controle de parite
G = [1 0 0 0 1 1 1 1;
     0 1 0 0 1 1 0 1;
     0 0 1 0 1 0 1 1;
     0 0 0 1 0 1 1 1];

H = [1 1 1 0 1 0 0 0;
     1 1 0 1 0 1 0 0;
     1 0 1 1 0 0 1 0;
     1 1 1 1 0 0 0 1];

% Liste de tous les mots de code possibles
ListeCodeWord = GenerateListeCodeWords(G);
size(ListeCodeWord)

bits_per_symbol = log2(4); % QPSK
num_bits_per_frame = num_codewords_per_frame * k_c;
num_symbols = num_bits_per_frame / bits_per_symbol;
ber_coded = zeros(1, length(Eb_N0_dB));

% Simulation Monte Carlo 
for i_snr = 1:length(Eb_N0_dB)
    % Calcul de la variance de bruit en fonction du SNR
    Eb_N0_lin = 10^(Eb_N0_dB(i_snr) / 10);
    noise_variance = ((A^2 * Delta^2) / 4) * 10^(-Eb_N0_dB(i_snr) / 10);
    
    total_errors = 0;
    total_bits = 0;

    for frame = 1:nb_frames
        % Etape 1 : generation des bits aleatoires
        b = randi([0 1], 1, num_bits_per_frame);
        size(b)
        % Etape 2 : Encode
        c = Encode(G, b);
        size(c)
        % Etape 3 : Mapping des bits en symboles
        qpsk_symbols = Bit2SymbolMappingQPSKGray(A, c);

        % Etape 4 : Ajout du bruit
        received_symbols = AWGN(Delta, noise_variance, qpsk_symbols);

        % Etape 5 : Demapping symboles en bits
        demapped_bits = Symbol2BitsDemappingQPSKGray(A, Delta, received_symbols);

        % Etape 6 : Decode les bits 
        decoded_bits = HMLDecode(ListeCodeWord, demapped_bits)

        % Etape 7 : Calcul des erreurs
        total_errors = total_errors + sum(b ~= decoded_bits);
        total_bits = total_bits + length(b);
    end

    % Calcul du TEB
    ber_coded(i_snr) = total_errors / total_bits;
end

% Resultats TEB
figure;
semilogy(Eb_N0_dB, ber_coded, 'b-o', 'LineWidth', 1.5);
xlabel('E_b/N_0 (dB)');
ylabel('TEB');
grid on;
title('TEB en fonction de  E_b/N_0');
legend('TEB code');
