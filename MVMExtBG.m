function BG = MVMExtBG(tiffpath,varargin)
% 释名：median-value method (MVM) to extract stationary background
% 输入的是原始图片序列tiffpath
% 输出的是背景BG

    tiffs = dir(fullfile(tiffpath,'*.tiff'));
    if isempty(tiffs)
        tiffs = dir(fullfile(tiffpath,'*.tif'));
    end

    if nargin == 1
        startFrame = 1;
        endFrame = length(tiffs);
    elseif nargin == 3
        startFrame = varargin{1};
        endFrame = varargin{2};
    end
    Num = endFrame - startFrame + 1;    % 用于求BG的图片张数

    I0 = double(imread(fullfile(tiffpath,tiffs(1).name)));
    [m,n] = size(I0);
    BG = zeros(m,n);
    RawFigs = zeros([m n Num]);
    
    for ii = 1:Num
        RawFigs(:,:,ii) = double(imread(fullfile(tiffpath,tiffs(ii).name)));
    end

    for ii = 1:m
        for jj = 1:n
            BG(ii,jj) = median(RawFigs(ii,jj,:));
        end
    end

end

