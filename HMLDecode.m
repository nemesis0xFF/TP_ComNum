function m_dec = HMLDecode(ListCodeWord, m_est)
    % Calculate the Hamming distance between m_est and each codeword in List
    H = [1 1 1 0 1 0 0 0;
         1 1 0 1 0 1 0 0;
         1 0 1 1 0 0 1 0;
         1 1 1 1 0 0 0 1];
    G = [1 0 0 0 1 1 1 1;
         0 1 0 0 1 1 0 1;
         0 0 1 0 1 0 1 1;
         0 0 0 1 0 1 1 1];


    [num_codewords, n_c] = size(ListCodeWord);
    num_blocks = length(m_est) / n_c;
    m_est;
    
    m_est_reshaped = reshape(m_est, n_c, num_blocks).'
    messages = dec2bin(0:2^k_c-1)-48

    ListCodeWord
    if any(IsErrorDetection(m_est, H)) == 1
        1;
    end
    for i = 1:size(ListCodeWord, 1)
        for j = 1:size(m_est_reshaped, 1)
            if isequal(m_est_reshaped(j, :), ListCodeWord(i, :))
                m_decode(j, :) = 1
            end
        end
    end
               
    
    
        
    
    

    m_dec = zeros(size(m_est_reshaped));
    
    
    
    m_dec = m_dec(:).'; % Reshape into a vector
end
