function PlotConstellation(z)
    figure;
    scatter(real(z), imag(z), 'filled');
    hold on;

    % QPSK points (-1,-1), (-1,1), (1,1), (1,-1)
    ref_points = [-1 -1; -1 1; 1 1; 1 -1];
    scatter(ref_points(:,1), ref_points(:,2), 100, 'r', 'filled', 'DisplayName', 'QPSK Points');

    % Decision lines
    xline(0, '--k', 'LineWidth', 1.5);
    yline(0, '--k', 'LineWidth', 1.5);

    xlabel('In-phase (Real)');
    ylabel('Quadrature (Imaginary)');
    title('QPSK Constellation with AWGN');
    grid on;

    axis equal;
    xlim([-2 2]);
    ylim([-2 2]);

    legend('Symbols', 'QPSK Points', 'Location', 'best');
    hold off;
end