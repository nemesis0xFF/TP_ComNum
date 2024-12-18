function m_dec = EMLDecode(A, Delta, ListeSymbWord, received_symbols)
    % ListeSymbWord : Liste des séquences de symboles QPSK possibles (N x n_c)
    % received_symbols : Vecteur des symboles QPSK reçus
    % m_dec : Message binaire décodé


    G_Hamming = [1 0 0 0 1 1 1 1;
                 0 1 0 0 1 1 0 1;
                 0 0 1 0 1 0 1 1;
                 0 0 0 1 0 1 1 1];

    H = [1 1 1 0 1 0 0 0;
         1 1 0 1 0 1 0 0;
         1 0 1 1 0 0 1 0;
         1 1 1 1 0 0 0 1];
    ListeCodeWord = GenerateListeCodeWords(G_Hamming);

    % Obtenir les dimensions des mots de code
    [num_codewords, n_c] = size(ListeSymbWord); % N : nombre de codewords, n_c : longueur des mots
    % Nombre de blocs dans les symboles reçus
    num_blocks = length(received_symbols) / n_c;
    
    % Reshape des symboles reçus en blocs
    received_blocks = reshape(received_symbols, n_c, num_blocks).';
    
    % Initialisation de m_dec
    m_dec = zeros(num_blocks, n_c);
    
    % Boucle sur chaque bloc pour chercher le codeword le plus proche
    for i = 1:num_blocks
        % Bloc reçu
        received_block = received_blocks(i, :);
        
        % Calcul des distances Euclidiennes avec tous les codewords possibles
        euclidean_distances = sum(abs(ListeSymbWord - received_block).^2, 2);
        
        % Trouver le codeword avec la distance minimale
        [~, min_index] = min(euclidean_distances);
        m_dec(i, :) = ListeSymbWord(min_index, :);
    end
    
    % Convertir les symboles QPSK en bits
    m_dec = reshape(m_dec.', 1, []);
    m_dec = Symbol2BitsDemappingQPSKGray(A, Delta, m_dec);
    m_dec2=m_dec;
    m_dec = m_dec2(mod(0:length(m_dec2)-1, 8) < 4);
    
end
