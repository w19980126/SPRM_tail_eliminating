function p = violet(m)

    if nargin < 1
        m = 256; 
    end

    xin = linspace(0, m, m)';
%     p(:, 1) = interp1([0 m], [1 0.7], xin, 'linear');
%     p(:, 2) = interp1([0 m], [1 0.3], xin, 'linear');
%     p(:, 3) = interp1([0 m], [1 1], xin, 'linear');
    
    p(:, 1) = interp1([0 m], [1 0.02], xin, 'linear');
    p(:, 2) = interp1([0 m], [1 0.49], xin, 'linear');
    p(:, 3) = interp1([0 m], [1 0.96], xin, 'linear');
end