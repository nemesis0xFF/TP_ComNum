% initialisation
A = 1;
Delta = 1;
k = 10000; % nombre de bits
nb_frames = 100; % nombre de frames
Eb_N0_dB = -2:2:14; % eb/N0

M = 4;
bits_per_symbol = log2(M);
num_symbols = k / bits_per_symbol;

ser = zeros(3, length(Eb_N0_dB));
ber = zeros(3, length(Eb_N0_dB));
theoretical_ser = zeros(1, length(Eb_N0_dB));
theoretical_ber = zeros(1, length(Eb_N0_dB));
execution_times = zeros(3, length(Eb_N0_dB));

% simulation Monte Carlo
for i_snr = 1:length(Eb_N0_dB)
    % variance du bruit
    Eb_N0_lin = 10^(Eb_N0_dB(i_snr)/10);
    noise_variance = ((A^2*Delta^2)/4)*10^(-(Eb_N0_dB(i_snr))/10); %OK
    
    num_symbol_errors = zeros(3, 1);
    num_bit_errors = zeros(3, 1);
    total_symbols = 0;
    total_bits = 0;
    
    for frame = 1:nb_frames
        bits = randi([0 1], 1, k);
        
        qpsk_symbols = Bit2SymbolMappingQPSKGray(A, bits);
        
        received_symbols = AWGN(Delta, noise_variance, qpsk_symbols);
        
        %MLSymbolDetectorQPSK
        tic;
        demod_symbols_1 = MLSymbolDetectorQPSK(A, received_symbols);
        execution_times(1, i_snr) = execution_times(1, i_snr) + toc;
        demod_bits_1 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_1);
        num_symbol_errors(1) = num_symbol_errors(1) + sum(qpsk_symbols ~= demod_symbols_1.');
        num_bit_errors(1) = num_bit_errors(1) + sum(bits ~= demod_bits_1);
        
        % MLSymbolDetectorQPSKdistance
        tic;
        demod_symbols_2 = MLSymbolDetectorQPSKdistance(A, received_symbols);
        execution_times(2, i_snr) = execution_times(2, i_snr) + toc;
        demod_bits_2 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_2);
        num_symbol_errors(2) = num_symbol_errors(2) + sum(qpsk_symbols ~= demod_symbols_2.');
        num_bit_errors(2) = num_bit_errors(2) + sum(bits ~= demod_bits_2);
        
        % MLSymbolDetectorQPSKlowCPLX
        tic;
        demod_symbols_3 = MLSymbolDetectorQPSKlowCPLX(A, received_symbols);
        execution_times(3, i_snr) = execution_times(3, i_snr) + toc;
        demod_bits_3 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_3);
        num_symbol_errors(3) = num_symbol_errors(3) + sum(qpsk_symbols ~= demod_symbols_3.');
        num_bit_errors(3) = num_bit_errors(3) + sum(bits ~= demod_bits_3);
        
        total_symbols = total_symbols + length(qpsk_symbols);
        total_bits = total_bits + length(bits);
    end
    
    % calcul TES et TEB
    for detector = 1:3
        ser(detector, i_snr) = num_symbol_errors(detector) / total_symbols;
        ber(detector, i_snr) = num_bit_errors(detector) / total_bits;
    end
    
    % courbes theoriques
    theoretical_ser(i_snr) = erfc(sqrt((1/2)*Eb_N0_lin));
    theoretical_ber(i_snr) = theoretical_ser(i_snr) / bits_per_symbol;
end

% affichages
figure;
semilogy(Eb_N0_dB, ser(1, :), 'b-o', 'LineWidth', 1.5);
hold on;
semilogy(Eb_N0_dB, ser(2, :), 'g-s', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, ser(3, :), 'm-^', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, theoretical_ser, 'r--', 'LineWidth', 1.5);
xlabel('E_b/N_0 (dB)');
ylabel('Taux erreurs symboles TES');
grid on;
legend('TES simulé (ML1)', 'TES simulé (ML2)', 'TES simulé (ML3)', 'TES theorique');
title('Taux erreurs symboles en fonction du E_b/N_0');

figure;
semilogy(Eb_N0_dB, ber(1, :), 'b-o', 'LineWidth', 1.5);
hold on;
semilogy(Eb_N0_dB, ber(2, :), 'g-s', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, ber(3, :), 'm-^', 'LineWidth', 1.5);
semilogy(Eb_N0_dB, theoretical_ber, 'r--', 'LineWidth', 1.5);
xlabel('E_b/N_0 (dB)');
ylabel('Taux erreur binaires');
grid on;
legend('TEB simulé (ML1)', 'TEB simulé (ML2)', 'TEB simulé (ML3)', 'TEB theorique');
title('Taux erreur binaire en fonction du E_b/N_0');
xlim([min(Eb_N0_dB), max(Eb_N0_dB)]);

% affichages
figure;
plot(Eb_N0_dB, execution_times(1, :) / nb_frames, 'b-o', 'LineWidth', 1.5);
hold on;
plot(Eb_N0_dB, execution_times(2, :) / nb_frames, 'g-s', 'LineWidth', 1.5);
plot(Eb_N0_dB, execution_times(3, :) / nb_frames, 'm-^', 'LineWidth', 1.5);
xlabel('E_b/N_0 (dB)');
ylabel('Temps moyen execution');
grid on;
legend('ML1', 'ML2', 'ML3');
title('Temps moyen execution en fonction du E_b/N_0');
