% Script de simulation du taux d'erreur QPSK avec variation de phase et de SNR
% initialisation
A = 1;
Delta = 1;
k = 10000; % nombre de bits
nb_frames = 100; % nombre de frames
Eb_N0_dB = -2:2:14; % eb/N0
phi_range = 0:pi/6:pi; % dephasage

M = 4; % symbole
bits_per_symbol = log2(M);
num_symbols = k / bits_per_symbol;

ser = zeros(3, length(Eb_N0_dB), length(phi_range));
ber = zeros(3, length(Eb_N0_dB), length(phi_range));

% Simulation Monte Carlo 
for i_phi = 1:length(phi_range)
    phi = phi_range(i_phi); % dephasage
    
    for i_snr = 1:length(Eb_N0_dB)
        % Calcul de la variance
        Eb_N0_lin = 10^(Eb_N0_dB(i_snr) / 10);
        noise_variance = ((A^2 * Delta^2) / 4) * 10^(-(Eb_N0_dB(i_snr)) / 10);
        
        num_symbol_errors = zeros(3, 1);
        num_bit_errors = zeros(3, 1);
        total_symbols = 0;
        total_bits = 0;
        
        for frame = 1:nb_frames
            % Étape 1 : bits aleatoires
            bits = randi([0 1], 1, k);
            
            % Étape 2 : Mapping
            qpsk_symbols = Bit2SymbolMappingQPSKGray(A, bits);
            
            % Étape 3 : decalage de phase
            qpsk_symbols_shifted = qpsk_symbols * exp(1i * phi);
            
            % Étape 4 : ajout du bruit
            received_symbols = AWGN(Delta, noise_variance, qpsk_symbols_shifted);
            
            % Étape 5 : utilisation des differents detecteur
            % Detecteur 1 : MLSymbolDetectorQPSK
            demod_symbols_1 = MLSymbolDetectorQPSK(A, received_symbols);
            demod_bits_1 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_1);
            num_symbol_errors(1) = num_symbol_errors(1) + sum(qpsk_symbols ~= demod_symbols_1.');
            num_bit_errors(1) = num_bit_errors(1) + sum(bits ~= demod_bits_1);
            
            % Detecteur 2 : MLSymbolDetectorQPSKdistance
            demod_symbols_2 = MLSymbolDetectorQPSKdistance(A, received_symbols);
            demod_bits_2 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_2);
            num_symbol_errors(2) = num_symbol_errors(2) + sum(qpsk_symbols ~= demod_symbols_2.');
            num_bit_errors(2) = num_bit_errors(2) + sum(bits ~= demod_bits_2);
            
            % Detecteur 3 : MLSymbolDetectorQPSKlowCPLX
            demod_symbols_3 = MLSymbolDetectorQPSKlowCPLX(A, received_symbols);
            demod_bits_3 = Symbol2BitsDemappingQPSKGray(A, Delta, demod_symbols_3);
            num_symbol_errors(3) = num_symbol_errors(3) + sum(qpsk_symbols ~= demod_symbols_3.');
            num_bit_errors(3) = num_bit_errors(3) + sum(bits ~= demod_bits_3);
            
            total_symbols = total_symbols + length(qpsk_symbols);
            total_bits = total_bits + length(bits);
        end
        
        % Calculer le TES et le TEB pour chaque detecteur
        for detector = 1:3
            ser(detector, i_snr, i_phi) = num_symbol_errors(detector) / total_symbols;
            ber(detector, i_snr, i_phi) = num_bit_errors(detector) / total_bits;
        end

        theoretical_ser(i_snr) = erfc(sqrt((1/2) * Eb_N0_lin));
        theoretical_ber(i_snr) = theoretical_ser(i_snr) / bits_per_symbol;
    end
end
for detector = 1:3
    figure;
    hold on;
    
    % Tracer les courbes pour chaque phase
    for i_phi = 1:length(phi_range)
        semilogy(Eb_N0_dB, squeeze(ber(detector, :, i_phi)), 'LineWidth', 1.5, ...
            'DisplayName', sprintf('\\phi = %.1f°', phi_range(i_phi) * (180/pi)));
    end
    
    % Ajouter la courbe theorique
    semilogy(Eb_N0_dB, theoretical_ber, 'k--', 'LineWidth', 2, 'DisplayName', 'BER théorique');
    

    xlabel('E_b/N_0 (dB)');
    ylabel('Taux d''erreur binaire (BER)');
    grid on;
    legend show;
    title(sprintf('Simulation TEB QPSK pour le détecteur %d avec décalage de phase', detector));
    xlim([min(Eb_N0_dB), max(Eb_N0_dB)]); 
    ylim([1e-5, 1]); % Ajuster l'echelle pour le BER en semilog
end
