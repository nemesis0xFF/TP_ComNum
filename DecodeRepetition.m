function decoded_bits = DecodeRepetition(received_bits, n)
    len = length(received_bits);
    if mod(len, n) ~= 0
        error('La longueur des bits reçus n''est pas un multiple de %d', n);
    end

    received_matrix = reshape(received_bits, n, []); % Chaque colonne = 1 groupe

    majority_sum = sum(received_matrix, 1); 
    decoded_bits = majority_sum > (n / 2);  

    decoded_bits = double(decoded_bits);
end