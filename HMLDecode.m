function m_dec = HMLDecode(ListeCodeWord, m_est)
    H = [1 1 1 0 1 0 0 0;
         1 1 0 1 0 1 0 0;
         1 0 1 1 0 0 1 0;
         1 1 1 1 0 0 0 1];
    % dimensions des mots de code
    [num_codewords, n_c] = size(ListeCodeWord);
    
    % nombre de blocs 
    num_blocks = length(m_est) / n_c;
    
    % reshape en bloc
    m_est_reshaped = reshape(m_est, n_c, num_blocks).';

    m_dec = zeros(num_blocks, n_c);
    original_messages = zeros(num_blocks, size(ListeCodeWord, 1)); 
    
    for i = 1:num_blocks
        received_block = m_est_reshaped(i, :);
        
        % erreur dans le mot de code
        if IsErrorDetection(received_block, H)
            % s'il y a une erreur, on corrige
            hamming_distances = sum(abs(ListeCodeWord - received_block), 2);
            [~, min_index] = min(hamming_distances);
            m_dec(i, :) = ListeCodeWord(min_index, :);
        else
            m_dec(i, :) = received_block;
        end
    end
    % recuperation du message original
    original_messages = m_dec(:, 1:size(ListeCodeWord, 2) - size(H, 1)); 
    m_dec = reshape(original_messages.', 1, []);
end
