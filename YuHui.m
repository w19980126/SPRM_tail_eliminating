close all
clear all
clc
tiffpath = 'F:\work\散射场\实验数据\20220407_AuNPs_AgNWs\AuNPs_60nm\A1';
tiffs = dir(fullfile(tiffpath,'*.tiff'));
BG = MVMExtBG(tiffpath);

%% 读入图片
I1 = double(imread(fullfile(tiffpath,tiffs(1).name))) - BG;
I2 = double(imread(fullfile(tiffpath,tiffs(1).name))) - BG;

Icut1 = I1(1:479,640-478:640);
Icut2 = I2(1:479,640-478:640);
Icut2 = matmove(Icut2,[240-268,240-216]);
figure
imagesc(Icut1)
axis off
axis equal
colormap(sunglow)

figure
imagesc(Icut2);
axis off
axis equal
colormap(sunglow)

F = fftshift(fft2(Icut2));
[center_raw,center_col,R,~] = findcircle((abs(F)),5,0,1);
peaks = [center_col,center_raw,R];

M1 = zeros(size(F));
M1(:,1:240) = 1;
F1 = matmove(F.*M1,[240-242,240-163]);   % 将冲激响应函数挪到视野正中央

% 生成平面波
kx = -2*pi*(peaks(1) - 240)/479;
ky = -2*pi*(peaks(2) - 240)/479;
[X,Y] = meshgrid(1:479,1:479);
E0 = exp(i*(kx*X+ky*Y));
figure
imagesc(real(E0))

% 生成散射波
ks = sqrt(kx^2+ky^2);
Es = ifft2(ifftshift(F1));
figure
imagesc(abs(Es))

%%
Es_ = Es;
E0 = E0*median(abs(Es),[],'all');
for ii = 1:100
    II = (abs(Es_+E0)).^2;
    F_ = fftshift(fft2(II));
    F_ = abs(F_).*exp(i*angle(F));
    F__ = matmove(F_.*M1,[240-242,240-163]);
    Es_ = ifft2(ifftshift(F__));
end
figure
imagesc(abs(Es_))




















