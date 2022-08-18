function mask = EwaldMask(F,peaks,scalefactor,modle,order)
% 此函数用来生成一个严格中心对称的mask，这个mask只遮蔽Ewald圆环
% F是k空间图像，其实只是用他的size而已
% scalefactor:缩放因子，用来衡量圆环展宽的，圆环展宽宽度是R*scalefactor，其中R是圆环半径

    if size(peaks,1) == 2
        peaks = peaks(1,:);
    end
    siz = size(F);
    f0 = siz(2)/siz(1);
    
%     m_half = halfMask(siz,f0,scalefactor,peaks);
    m_half = halfMask(siz,f0,peaks);

    if strcmp(modle,'I')
        mask_ring = ILPF(siz,f0,peaks,scalefactor);
    elseif strcmp(modle,'B')
        mask_ring = BLPF(siz,f0,peaks,scalefactor,order);
    elseif strcmp(modle,'G')
        mask_ring = GLPF(siz,f0,peaks,scalefactor);
    end
    
    mask = (1 - mask_ring).*m_half;

end

%% mask to cover half of the fig
% function mask = halfMask(siz,f0,scalefactor,peaks)
%     center = (siz+1)/2;
%     k0 = -1/((center(2)-peaks(1))/(f0*(center(1)-peaks(2)+eps)));   % 真实的k0
%     A = k0;     % 对应于真实客观存在的A、B、C
%     B = -1;
%     C = center(2) - k0*center(1)*f0;    % 坐标也许要用客观坐标，而不是像素坐标
%     mask = zeros(siz);
%     for ii = 1:siz(1)
%         for jj = 1:siz(2)
%             d0 = 0.2*scalefactor*peaks(3);      % 因为peaks(3)是真实客观的R，所以这里的d0也是客观单位
%             ysign = sign(jj - (k0*f0*(ii-center(1)) +center(2)));   % 判断点落在分界线左侧还是右侧
%             d = abs(A*ii*f0 + B*jj + C)/sqrt(A^2+B^2);
%             if ysign ~= 0
%                 mask(ii,jj) = 0.5*ysign*exp(-d^2/(2*d0^2)) + (ysign < 0);
%             else
%                 mask(ii,jj) = 0.5;
%             end
%         end
%     end
% end
function mask = halfMask(siz,f0,peaks)
    center = (siz+1)/2;
    k0 = -1/((center(2)-peaks(1))/(f0*(center(1)-peaks(2)+eps)));   % 真实的k0
    [X,Y] = meshgrid(1:siz(2),1:siz(1));
    mask = sign(X - (k0*f0*(Y-center(1)) +center(2)));
    mask(mask>=0) = 0;
    mask(mask<0) = 1;
%     mask = zeros(siz);
%     mask(1:round((siz(1)-1)/2),1:round((siz(2)-1)/2)) = 1;

%     k1 = -1/k0;   % 真实的k0
%     [X,Y] = meshgrid(1:siz(2),1:siz(1));
%     mask2 = sign(X - (k1*f0*(Y-center(1)) +center(2)));
%     mask2(mask2>=0) = 0;
%     mask2(mask2<0) = 1;
% 
%     mask = mask.*mask2;
end


%% ideal lowpass filter
function mask = ILPF(siz,f0,peaks,scalefactor)
    D0 = scalefactor*peaks(3);
    mask = zeros(siz);
    for ii = 1:siz(1)
        for jj = 1:siz(2)
            D = sqrt((ii*f0-peaks(2)*f0)^2+(jj-peaks(1))^2) - peaks(3); 
            if abs(D) <= D0
                mask(ii,jj) = 1;
            end
        end
    end
end

%% Butterworth lowpass filter
function mask = BLPF(siz,f0,peaks,scalefactor,order)
    mask = zeros(siz);
    D0 = scalefactor*peaks(3);
    for ii = 1:siz(1)
        for jj = 1:siz(2)
            D = sqrt((ii*f0-peaks(2)*f0)^2+(jj-peaks(1))^2) - peaks(3); 
            mask(ii,jj) = 1/(1+(D/D0)^(2*order));
        end
    end
end

%% Gauss lowpass filter
function mask = GLPF(siz,f0,peaks,scalefactot)
    mask = zeros(siz);
    D0 = scalefactot*peaks(3);
    for ii = 1:siz(1)
        for jj = 1:siz(2)
            D = sqrt((ii*f0-peaks(2)*f0)^2+(jj-peaks(1))^2) - peaks(3); 
            mask(ii,jj) = exp(-D^2/(2*D0^2));
        end
    end
end






