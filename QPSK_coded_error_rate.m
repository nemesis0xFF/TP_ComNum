% QPSK Coded Error Rate Simulation Script
% initialisation
A = 1; 
Delta = 1; 
k = 10000; % nombre de bits
nb_frames = 100; % nombre de frames
Eb_N0_dB = -2:2:14; % eb/N0
phi = pi/10; % dephasage

M = 4; 
bits_per_symbol = log2(M);
num_symbols = k / bits_per_symbol;
k_block = 4; % nombre de bit par mot de code
n_block = 7; % longueur du bloc codee
num_codewords_per_frame = k / k_block;

% matrice generatrice et parity check 
G = [1 0 0 0 1 1 1 1;
     0 1 0 0 1 1 0 1;
     0 0 1 0 1 0 1 1;
     0 0 0 1 0 1 1 1];

H = [1 1 1 0 1 0 0 0;
     1 1 0 1 0 1 0 0;
     1 0 1 1 0 0 1 0;
     1 1 1 1 0 0 0 1];

% liste des mots de code
List = GenerateListeCodeWords(G);

ber_coded = zeros(3, length(Eb_N0_dB));
execution_times = zeros(3, length(Eb_N0_dB)); 

% simulation Monte Carlo 
for i_snr = 1:length(Eb_N0_dB)
    % variance du bruit
    Eb_N0_lin = 10^(Eb_N0_dB(i_snr)/10);
    noise_variance = ((A^2*Delta^2)/4)*10^(-(Eb_N0_dB(i_snr))/10); %OK
    
    num_bit_errors = zeros(3, 1);
    total_bits = 0;
    
    for frame = 1:nb_frames
        % Etape 1 : generation des bits aleatoires
        bits = randi([0 1], 1, k);
        encoded_bits = Encode(G, bits);
        
        % Etape 2 : Mapping
        qpsk_symbols = Bit2SymbolMappingQPSKGray(A, encoded_bits);
        
        % Etape 3 : dephasage 
        qpsk_symbols_shifted = qpsk_symbols * exp(1i * phi);
        
        % Etape 4 : ajout du bruit
        received_symbols = AWGN(Delta, noise_variance, qpsk_symbols_shifted);
        
        % utilisation des differents detecteurs
        %MLSymbolDetectorQPSK
        tic;
        demod_symbols_1 = MLSymbolDetectorQPSK(A, received_symbols);
        demod_bits_1 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_1);
        decoded_bits_1 = HMLDecode(List, demod_bits_1);
        execution_times(1, i_snr) = execution_times(1, i_snr) + toc;
        len_bits = min(length(bits), length(decoded_bits_1));
        num_bit_errors(1) = num_bit_errors(1) + sum(bits(1:len_bits) ~= decoded_bits_1(1:len_bits));
        
        %MLSymbolDetectorQPSKdistance
        tic;
        demod_symbols_2 = MLSymbolDetectorQPSKdistance(A, received_symbols);
        demod_bits_2 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_2);
        decoded_bits_2 = HMLDecode(List, demod_bits_2);
        execution_times(2, i_snr) = execution_times(2, i_snr) + toc;
        len_bits = min(length(bits), length(decoded_bits_2));
        num_bit_errors(2) = num_bit_errors(2) + sum(bits(1:len_bits) ~= decoded_bits_2(1:len_bits));
        
        %MLSymbolDetectorQPSKlowCPLX
        tic;
        demod_symbols_3 = MLSymbolDetectorQPSKlowCPLX(A, received_symbols);
        demod_bits_3 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_3);
        decoded_bits_3 = HMLDecode(List, demod_bits_3);
        execution_times(3, i_snr) = execution_times(3, i_snr) + toc;
        len_bits = min(length(bits), length(decoded_bits_3));
        num_bit_errors(3) = num_bit_errors(3) + sum(bits(1:len_bits) ~= decoded_bits_3(1:len_bits));
        
        total_bits = total_bits + len_bits;
    end
    
    % calcul TEB
    for detector = 1:3
        ber_coded(detector, i_snr) = num_bit_errors(detector) / total_bits;
    end

    % courbes theoriques
    theoretical_ser(i_snr) = erfc(sqrt((1/2)*Eb_N0_lin))
    theoretical_ber(i_snr) = theoretical_ser(i_snr) / bits_per_symbol;
end

% affichages
figure;
semilogy(Eb_N0_dB, ber_coded(1, :), 'b-o', 'LineWidth', 1.5);
hold on;
semilogy(Eb_N0_dB, ber_coded(2, :), 'g-s', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, ber_coded(3, :), 'm-^', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, theoretical_ber, 'r--x', 'LineWidth', 1.5);

xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
grid on;
legend('Simulated BER (ML Detector 1)', 'Simulated BER (ML Detector 2)', 'Simulated BER (ML Detector 3)', 'Theoretical BER');
title('QPSK Coded Bit Error Rate vs E_b/N_0');
xlim([min(Eb_N0_dB), max(Eb_N0_dB)]); % Ensure the x-axis goes to the full range of -2 to 14 dB

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

