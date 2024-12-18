function ListeCodeWord = GenerateListeCodeWords(G)
    k_c = size(G, 1);
    n_c = size(G, 2);
    messages = dec2bin(0:2^k_c-1)-48;
    ListeCodeWord = zeros(2^k_c, n_c);
    for i = 1:2^k_c
        ListeCodeWord(i, :) = mod(messages(i, :) * G, 2);
    end
end
