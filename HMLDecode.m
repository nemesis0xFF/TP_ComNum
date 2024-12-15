function m_dec = HMLDecode(ListeCodeWord, m_est)
    H = [1 1 1 0 1 0 0 0;
         1 1 0 1 0 1 0 0;
         1 0 1 1 0 0 1 0;
         1 1 1 1 0 0 0 1];
    % Obtenir les dimensions des mots de code
    [num_codewords, n_c] = size(ListeCodeWord);
    
    % Nombre de blocs dans m_est
    num_blocks = length(m_est) / n_c;
    
    % Reshape m_est en blocs
    m_est_reshaped = reshape(m_est, n_c, num_blocks).';
    
    % Initialisation de m_dec
    m_dec = zeros(num_blocks, n_c);

    % Initialisation du message original
    original_messages = zeros(num_blocks, size(ListeCodeWord, 1)); 
    
    % Parcourir chaque bloc
    for i = 1:num_blocks
        % Bloc reçu
        received_block = m_est_reshaped(i, :);
        
        % Vérifier les erreurs avec IsErrorDetection
        if IsErrorDetection(received_block, H)
            % Si une erreur est détectée, calculer la distance de Hamming
            hamming_distances = sum(abs(ListeCodeWord - received_block), 2);
            [~, min_index] = min(hamming_distances); % Trouver le codeword le plus proche
            m_dec(i, :) = ListeCodeWord(min_index, :); % Codeword décodé
        else
            % Pas d'erreur détectée, prendre le bloc directement
            m_dec(i, :) = received_block;
        end
    end

    % Convertir les mots de code en messages originaux
    % Récupérer les bits d'information à partir des mots de code
    original_messages = m_dec(:, 1:size(ListeCodeWord, 2) - size(H, 1)); 
    
    % Aplatir le résultat final
    m_dec = reshape(original_messages.', 1, []);
end
