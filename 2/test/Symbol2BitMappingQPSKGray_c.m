function m_est = Symbol2BitMappingQPSKGray(A,delta,d_est)
    m_est = zeros(1, length(d_est) * 2);
    m_est(1:2:end)=real(d_est)>0;
    m_est(2:2:end)=imag(d_est)>0;
end
