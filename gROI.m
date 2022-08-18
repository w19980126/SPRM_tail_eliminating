function [I,varargout] = gROI(Tiffs,mask)

    % 从图片序列中划取ROI并返回强度曲线
    % 必输入项是图片序列tiffs，必输出项是强度向量I
    % 可选输入项是掩膜mask，可选输出项是掩膜mask
    
    N = size(Tiffs,3); 
    I = zeros(N,1);
    first_tiff = Tiffs(:,:,round(N/2));
    
    if nargin == 1
        figure
        imagesc(first_tiff)
        axis off
        [x,y] = ginput(2);
        x = round(x);
        y = round(y);
        close gcf
        mask = zeros(size(first_tiff));
        mask(min(y):max(y),min(x):max(x)) = 1;
    end
    
    for ii = 1:N
        temp_tiff = Tiffs(:,:,ii);
        I(ii) = sum(sum((mask.*temp_tiff)))/sum(sum(mask));
    end
    figure
    plot(I,'linewidth',2);
    
    if nargout == 2
        varargout = {mask};
    end
     
end