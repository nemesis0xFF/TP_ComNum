function z = AWGN(Delta, v, d)
    % Input:
    %   Delta: Scaling factor for QPSK symbols
    %   v: Variance of the Gaussian noise
    %   d: Input vector of QPSK symbols

    % Calculate the standard deviation of the Gaussian noise
    sigma = sqrt(v);

    % Generate random noise with zero mean and variance v for both real and imaginary parts
    noise_real = sigma * randn(size(d));
    noise_imag = sigma * randn(size(d));

    % Add the noise to the QPSK symbols multiplied by Δ^2/2
    z = Delta^2/2 * d + Delta/sqrt(2) * (noise_real + 1i*noise_imag);
end
