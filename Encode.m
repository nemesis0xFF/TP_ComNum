function c = Encode(G, b)
    k_c = size(G, 1);
    n_c = size(G, 2);
    b_reshaped = reshape(b, k_c,[]).'; 
    c = mod(b_reshaped * G, 2);
    c = reshape(c.', 1,[]);
end
