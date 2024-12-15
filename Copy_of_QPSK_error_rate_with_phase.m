% QPSK Error Rate Simulation Script with Phase and SNR Variation
% Initialization
A = 1;
Delta = 1;
k = 10000; % Number of bits
nb_frames = 100; % Number of frames
Eb_N0_dB = -2:2:14; % Range of SNR in dB
phi_range = 0:pi/6:pi; % Range of phase difference between Tx and Rx

% Derived parameters
M = 4; % QPSK modulation
bits_per_symbol = log2(M);
num_symbols = k / bits_per_symbol;

% Preallocate space for error rate results
ser = zeros(3, length(Eb_N0_dB), length(phi_range));
ber = zeros(3, length(Eb_N0_dB), length(phi_range));

% Monte Carlo Simulation for phase and SNR influence
for i_phi = 1:length(phi_range)
    phi = phi_range(i_phi); % Current phase difference
    
    for i_snr = 1:length(Eb_N0_dB)
        % Calculate noise variance based on SNR
        Eb_N0_lin = 10^(Eb_N0_dB(i_snr) / 10);
        noise_variance = ((A^2 * Delta^2) / 4) * 10^(-(Eb_N0_dB(i_snr)) / 10);
        
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
            demod_symbols_1 = MLSymbolDetectorQPSK(A, received_symbols);
            demod_bits_1 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_1);
            num_symbol_errors(1) = num_symbol_errors(1) + sum(qpsk_symbols ~= demod_symbols_1.');
            num_bit_errors(1) = num_bit_errors(1) + sum(bits ~= demod_bits_1);
            
            % Detector 2: MLSymbolDetectorQPSKdistance
            demod_symbols_2 = MLSymbolDetectorQPSKdistance(A, received_symbols);
            demod_bits_2 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_2);
            num_symbol_errors(2) = num_symbol_errors(2) + sum(qpsk_symbols ~= demod_symbols_2.');
            num_bit_errors(2) = num_bit_errors(2) + sum(bits ~= demod_bits_2);
            
            % Detector 3: MLSymbolDetectorQPSKlowCPLX
            demod_symbols_3 = MLSymbolDetectorQPSKlowCPLX(A, received_symbols);
            demod_bits_3 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_3);
            num_symbol_errors(3) = num_symbol_errors(3) + sum(qpsk_symbols ~= demod_symbols_3.');
            num_bit_errors(3) = num_bit_errors(3) + sum(bits ~= demod_bits_3);
            
            total_symbols = total_symbols + length(qpsk_symbols);
            total_bits = total_bits + length(bits);
        end
        
        % Calculate SER and BER for each detector
        for detector = 1:3
            ser(detector, i_snr, i_phi) = num_symbol_errors(detector) / total_symbols;
            ber(detector, i_snr, i_phi) = num_bit_errors(detector) / total_bits;
        end

        theoretical_ser(i_snr) = erfc(sqrt((1/2)*Eb_N0_lin))
        theoretical_ber(i_snr) = theoretical_ser(i_snr) / bits_per_symbol;
    end
end

% Plot BER vs. Eb/N0 for each phase and detector, with semilog scale
for detector = 1:3
    figure;
    hold on;
    
    % Tracer les courbes pour chaque phase
    for i_phi = 1:length(phi_range)
        semilogy(Eb_N0_dB, squeeze(ber(detector, :, i_phi)), 'LineWidth', 1.5, ...
            'DisplayName', sprintf('\\phi = %.1f°', phi_range(i_phi) * (180/pi)));
    end
    
    % Ajouter la courbe théorique (calculée dans le code principal)
    semilogy(Eb_N0_dB, theoretical_ber, 'k--', 'LineWidth', 2, 'DisplayName', 'Theoretical BER');
    
    % Ajouter les détails du graphique
    xlabel('E_b/N_0 (dB)');
    ylabel('Bit Error Rate (BER)');
    grid on;
    legend show;
    title(sprintf('QPSK BER Simulation for Detector %d with Phase Offset', detector));
    xlim([min(Eb_N0_dB), max(Eb_N0_dB)]); % Restreindre l'axe des abscisses
    ylim([1e-5, 1]); % Ajuster l'échelle pour BER en semi-log
end

