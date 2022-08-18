%% ---------------读入图片序列---------------------------
close all
clear all
tiffpath = 'D:\work\散射场\实验数据\20220329_PsNPs_colission\Result';
tiffs = dir(fullfile(tiffpath,'*.fig'));
expname = 'A1';

%% ---------------获得mask---------------------------
N = length(tiffs)-1;
I0 = double(imread(fullfile(tiffpath,tiffs(1).name)));
temp = double(imread(fullfile(tiffpath,tiffs(N).name))) - double(imread(fullfile(tiffpath,tiffs(1).name)));

figure
imagesc(temp);
[x,y] = ginput(2);
x = round(x);y = round(y);
Lcut = round(min([abs(x(2)-x(1)),abs(y(2)-y(1))]));
Lcut = Lcut + mod(Lcut,2);
x = [min(x),min(x)+Lcut];
y = [min(y),min(y)+Lcut];
close gcf
F = fftshift(fft2(temp(y(1):y(2),x(1):x(2))));
[center_raw,center_col,R,~] = findcircle(log(abs(F)),5,0);
peaks = [center_col,center_raw,R];
mask = EwaldMask(F,peaks,0.95,1.05);
clear F

%% ---------------开始计算---------------------------
for ii = 1:N
    temp = double(imread(fullfile(tiffpath,tiffs(ii+1).name))) - double(imread(fullfile(tiffpath,tiffs(1).name)));
    I(:,:,ii) = temp(y(1):y(2),x(1):x(2));
    F(:,:,ii) = fftshift(fft2(temp(y(1):y(2),x(1):x(2))));
    Irec(:,:,ii) = 2*abs(ifft2(ifftshift(mask.*squeeze(F(:,:,ii)))));
end

% ---------------演示---------------------------
figure
for ii = 1:N
    subplot(121)
    imagesc(squeeze(I(:,:,ii)))
    axis off
    axis square
    title(num2str(ii))
    subplot(122)
    imagesc(squeeze(Irec(:,:,ii)));
    axis off
    axis square
    title(num2str(ii))
    pause(0.2)
end

% ---------------保存为gif---------------------------
savepath = 'H:\work\ScaterFeild\实验数据\20220322_colission\20220322_colission\TIFF\Result';
mkdir(savepath)
gifroute = fullfile(savepath,['A1' '.gif']);
figure
for ii = 1:N
    subplot(121)
    imagesc(squeeze(I(:,:,ii)))
    axis off
    axis square
    caxis([-500 800])
    subplot(122)
    imagesc(squeeze(Irec(:,:,ii)));
    axis off
    axis square
    caxis([100 500])
    set(0,'defaultfigurecolor','w');
    Fgif = getframe(gcf);
    Igif = frame2im(Fgif);
    [Igif,map] = rgb2ind(Igif,256);
    if ii == 1
        imwrite(Igif,map,gifroute,'gif','Loopcount',inf,'DelayTime',0.1);
    else
        imwrite(Igif,map,gifroute,'gif','DelayTime',0.1,'WriteMode','append');
    end
    pause(0.1)
end

% ---------------读取强度---------------------------
[int1,m] = gROI(I);
saveas(gcf,fullfile(savepath,[expname '_SPR']));
[int2] = gROI(Irec,m);
saveas(gcf,fullfile(savepath,[expname '_Reconstructioin']));


% ---------------保存为视频---------------------------
savepath = '‪H:\work\ScaterFeild\实验数据\20220322_colission\20220322_colission\TIFF\Result';
videoroute = fullfile(savepath,['A1' '.avi']);
myVideo = VideoWriter(videoroute);
open(myVideo)
figure
for ii = 1:N
    temp1 = squeeze(I(:,:,ii));
    temp1 = (temp1-min(temp1,[],'all'))/(max(temp1,[],'all')-min(temp1,[],'all'));
    temp1 = im2uint8(temp1);
    temp2 = squeeze(Irec(:,:,ii));
    temp2 = (temp2-min(temp2,[],'all'))/(max(temp2,[],'all')-min(temp2,[],'all'));
    temp2 = im2uint8(temp2);
    subplot(121)
    imshow(temp1)
    colormap(parula)
    caxis([0 255])
    subplot(122)
    imshow(temp2)
    colormap(parula)
    caxis([0 255])
    tempframe = getframe(gcf);
    tempframe = frame2im(tempframe);
    writeVideo(myVideo,tempframe);
end
close(myVideo);
  
% -----------------颗粒跟踪-------------------
figure
imagesc(squeeze(I(:,:,84)))
figure
imagesc(squeeze(I(:,:,84))>500)
temp = squeeze(I(:,:,100))>1800;
temp = medfilt2(temp);
figure
imagesc(temp)



temp1 = squeeze(I(:,:,84));
temp2 = imgaussfilt(temp1);
figure
imagesc(temp2)
temp3 = 1./(1+(abs(temp2)/500).^2.5);
figure
imagesc(temp3)
temp4 = temp3<0.7;
figure
imagesc(temp4)







