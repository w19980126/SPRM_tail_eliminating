function BG = MVMExtBG(tiffpath)

% 释名：median-value method (MVM) to extract stationary background
% 输入的是原始图片序列tiffpath
% 输出的是背景BG

    tiffs = dir(fullfile(tiffpath,'*.tiff'));
    if length(tiffs) == 0
        tiffs = dir(fullfile(tiffpath,'*.tif'));
    end

    I0 = double(imread(fullfile(tiffpath,tiffs(1).name)));
    [m,n] = size(I0);
    BG = zeros(m,n);
    RawFigs = zeros([m n length(tiffs)]);
    
    for ii = 1:length(tiffs)
        RawFigs(:,:,ii) = double(imread(fullfile(tiffpath,tiffs(ii).name)));
    end

    for ii = 1:m
        for jj = 1:n
            BG(ii,jj) = median(RawFigs(ii,jj,:));
        end
    end

end

