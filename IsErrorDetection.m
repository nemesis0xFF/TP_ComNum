function error = IsErrorDetection(r, H)
    reshaped_r = reshape(r, size(H, 2), []).';
    syndrome = mod(reshaped_r * H.', 2); % Calculate the syndrome
    error = any(syndrome, 2); % If the syndrome is not all zeros, there's an error
end
