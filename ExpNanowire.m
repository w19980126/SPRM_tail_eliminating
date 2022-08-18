%% 纳米线数据处理
close all
clear all
clc
tiffpath = 'F:\work\散射场\实验数据\20220407_AuNPs_AgNWs\AgNWs\scratch';
tiffs = dir(fullfile(tiffpath,'*.tiff'));

BG = MVMExtBG(tiffpath);

I1 = double(imread(fullfile(tiffpath,tiffs(3).name))) - BG;

figure
imagesc(I1);
axis off
axis equal
colormap(gray)

F = fftshift(fft2(squeeze(I1)));
[center_raw,center_col,R,~] = findcircle(log(abs(F)),5,0,0);
peaks = [center_col,center_raw,R];
mask = EwaldMask(log(abs(F)),peaks,0.1,'G',1);

I_flt = ifft2(ifftshift(F.*mask));
figure
imagesc(2*abs(I_flt))
axis off
axis equal
colormap(gray)

X = [150 300];Y = [223 223];
[I0,X,Y] = LineCut(I1,X,Y);
[I2,X,Y] = LineCut(2*abs(I_flt),X,Y);

[I0,X,Y] = LineCut(I1);
[I2,X,Y] = LineCut(2*abs(I_flt));
[I3,X,Y] = LineCut(Icut2);

line([60 60+5000/73.8],[400 400],'color','white','linewidth',6)     % scalebar，长5um

figure
hl = get(gca,'children');
set(hl(1),'YData',I2/max(I2));
set(hl(2),'YData',I0/max(I0));

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









