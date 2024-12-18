function m_dec = EMLDecode(A, Delta, ListeSymbWord, received_symbols)

    % dimensions mot de code
    [num_codewords, n_c] = size(ListeSymbWord); % N : nombre de codewords, n_c : longueur des mots
    % nombre de bloc 
    num_blocks = length(received_symbols) / n_c;
    
    % Reshape des symboles en bloc
    received_blocks = reshape(received_symbols, n_c, num_blocks).';

    m_dec = zeros(num_blocks, n_c);
    
    % boucle sur chaque bloc pour chercher le codeword le plus proche
    for i = 1:num_blocks
        % Bloc reçu
        received_block = received_blocks(i, :);
        
        % distance euclidienne pour les mots de code
        euclidean_distances = sum(abs(ListeSymbWord - received_block).^2, 2);
        
        % identifier le mot de code avec la plus petite distance euclidienne
        [~, min_index] = min(euclidean_distances);
        m_dec(i, :) = ListeSymbWord(min_index, :);
    end
    
    % Convertir les symboles QPSK en bits
    m_dec = reshape(m_dec.', 1, []);
    m_dec = Symbol2BitsDemappingQPSKGray(A, Delta, m_dec);
end
