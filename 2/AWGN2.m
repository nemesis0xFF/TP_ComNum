function z = AWGN2(Delta, v, d)
    n_real = sqrt(v/2)*randn(size(d));
    n_imag = 1i*sqrt(v/2)*randn(size(d));

    z = d*Delta^2/2 + (n_real + n_imag);
end

