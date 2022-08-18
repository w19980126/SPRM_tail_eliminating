function mask = EwaldMask(F,peaks,fin,fout,modle)

% 此函数用来生成一个严格中心对称的mask，这个mask只遮蔽Ewald圆环
% F是k空间图像，其实只是用他的size而已
% fin：Ewald环内部圆形掩模半径比上Ewald环的半径
% fout：Ewald环外部圆形掩模半径比上Ewald环的半径
% modle:mask遮蔽区域，'out'则表示滤掉圆环，'on'则表示只保留圆环，这是可选项，可不输入此项

    if size(peaks,1) == 2
        peaks = peaks(1,:);
    end
    
    siz = size(F);
    center = (siz+1)/2;
    c1 = peaks; % 第一个圆心
    f0 = siz(2)/siz(1);
    k0 = -1/((center(2)-c1(1))/(center(1)-c1(2)+eps));


    m_half = zeros(siz);
    m_in = zeros(siz);   % 环内掩模
    r = fin*peaks(3);
    for ii = 1:siz(1)
        for jj = 1:siz(2)
            tempr = sqrt((ii*f0-c1(2)*f0)^2+(jj-c1(1))^2);
            if tempr <= r
                m_in(ii,jj) = 1;
            end
            if jj <= k0*(ii-center(1))+center(2)
                m_half(ii,jj) = 1;
            end
        end
    end

    m_out = zeros(siz);  % 环外掩模
    r = fout*peaks(3);
    for ii = 1:siz(1)
        for jj = 1:siz(2)
            tempr = sqrt((ii*f0-c1(2)*f0)^2+(jj-c1(1))^2);
            if tempr >= r
                m_out(ii,jj) = 1;
            end
        end
    end
    
    if nargin == 4 
        mask = m_half.*(m_in + m_out);
    elseif nargin == 5 && strcmp(modle,'out')
        mask = m_half.*(m_in + m_out);
    elseif nargin == 5 && strcmp(modle,'on')
        mask = m_half.*~(m_in + m_out);
    end
end


