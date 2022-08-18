%% 纳米线数据处理
close all
clear all
clc
tiffpath = 'F:\work\ScaterFeild\实验数据\20220307_AgNWs\A7';
tiffs = dir(fullfile(tiffpath,'*.tiff'));

I1 = double(imread(fullfile(tiffpath,tiffs(5).name))) - double(imread(fullfile(tiffpath,tiffs(6).name)));
I1 = double(imread(fullfile(tiffpath,tiffs(5).name))) - double(imread(fullfile(tiffpath,tiffs(10).name)));

I2 = double(imread(fullfile(tiffpath,tiffs(2).name))) - double(imread(fullfile(tiffpath,tiffs(4).name)));

Icut1 = I1(1:479,76:554);
Icut2 = I2(1:479,76:554);
figure
imagesc(Icut1);
axis off
axis equal
colormap(sunglow)
figure
imagesc(Icut2);
axis off
axis equal
colormap(sunglow)
F = fftshift(fft2(squeeze(Icut1)));
[center_raw,center_col,R,mask] = findcircle(log(abs(F)),5);
peaks = [center_col,center_raw,R];

[mask,peaks,deg] = GetFourierMask(log(abs(F)),20,0,-1);
peaks = peaks(1,:);

mask1 = EwaldMask(F,peaks,0.75,1.15,'out');
mask2 = EwaldMask(F,peaks,0.75,1.15,'on');

I_flt = ifft2(ifftshift(F.*mask1));
I_spr = ifft2(ifftshift(F.*mask2));
% figure
% imagesc(2*real(I_flt))
% axis off
% axis equal
% colormap(sunglow)
figure
imagesc(2*real(I_spr))
axis off
axis equal
colormap(sunglow)
figure
imagesc(2*abs(I_flt))
axis off
axis equal
colormap(sunglow)

[I0,X,Y] = LineCut(Icut1,X,Y);
[I1,X,Y] = LineCut(2*abs(I_spr),X,Y);
[I2,X,Y] = LineCut(2*abs(I_flt),X,Y);
[I3,X,Y] = LineCut(angle(I_flt),X,Y);

[I0,X,Y] = LineCut(Icut1);
[I2,X,Y] = LineCut(2*real(I_spr));
[I2,X,Y] = LineCut(2*abs(I_flt));
[I3,X,Y] = LineCut(Icut2);

%% 曲线拟合
% -------------------------------------
% Gaussian function for profile fit 

I = I2;
yy = I2;   
yy = (yy - min(yy))/(max(yy) - min(yy));
fun = @(par,xdata) par(1).*exp(-(xdata-par(2)).^2./(2*(par(3)).^2)) + par(4);   % Gaussian function
par0 = [0.8,200,10,0];    % initial value
x0 = 1:length(yy);
par2 = lsqcurvefit(fun,par0,x0,yy');
figure
plot(x0,yy)
hold on
plot(x0,fun(par2,x0),'--');

% --------------------------------------
% Lorentzian function for profile fit
I = I2;
yy = I2;   % profile in y-direction
yy = (yy - min(yy))/(max(yy) - min(yy));
fun = @(par,xdata) par(1)./((par(2))^2+(xdata-par(3)).^2) + par(4);   % Gaussian function
par0 = [10,3,247,0];    % initial value
x0 = 1:length(yy);
par2 = lsqcurvefit(fun,par0,x0,yy');
figure
plot(x0,yy)
hold on
plot(x0,fun(par2,x0),'--');

%% 曲线作图
temp0 = I0/(max(I0));
temp1 = I1/(abs(min(I1)));
temp2 = I2/(max(I2));
figure
plot3(ones(size(I0)),1:length(I0),temp2);
hold on
plot3(1.22*ones(size(I1)),1:length(I1),temp1);
plot3(1.4*ones(size(I2)),1:length(I2),temp0);









