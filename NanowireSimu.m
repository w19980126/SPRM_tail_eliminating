
%% 生成干涉散射场
theta = 70.5;
n = 1.5;
lambda = 680;
kapa = 8;
phi = 0.1*pi;
scale_factor = 0.1;
M_size = 601;
theta_spp = -90;
theta_res = 70.5;
[Ei,Es,F,I] = wave_generate(lambda,n,kapa,theta,phi,scale_factor,M_size,theta_spp,theta_res);
imagesc(I)
figure
imagesc(abs(F))

%% 生成纳米线
%--------------------------------------
% 纳米线
S = zeros(601);
sz = size(S);
alpha = 135;     % 纳米线沿ii方向倾斜角度
L = 45;    % 纳米线长度，单位像素
width = 0.5;      % 纳米线直径，单位像素
oriP = [301,301];   % 指定原点
for ii = 1:sz(1)
    for jj = 1:sz(2)
        x0 = (ii - oriP(1));
        y0 = (jj - oriP(2));
        k0 = tan(alpha/180*pi);
        d = abs(k0*x0 - y0)/(k0^2 + 1);
        if d <= width && sqrt(x0^2+y0^2)<L
            S(ii,jj) = 1;
        end
    end
end
figure
imshow(S)

% -------------------------------------
% convolution
I1 = conv2(Es,S.*exp(i*angle(Ei)),'same');  % 复散射场
I2 = Ei;    % 平面参考波
I3 = conj(I1).*Ei + I1.*conj(Ei) + (abs(I1)).^2;    % 直流分量
I4 = conj(I1).*Ei + I1.*conj(Ei);   % 只考虑散射，忽略直流散射场项
figure
imagesc(I4)
figure
imagesc(I3)

%% 重构并读取剖面强度

Icut1 = I4;     % 成像结果

figure
imagesc(Icut1);
axis off
axis equal
colormap(sunglow)

F = fftshift(fft2(squeeze(Icut1)));
[center_raw,center_col,R,mask] = findcircle(log(abs(F)),5,0,2);
peaks = [center_col,center_raw,R];

mask = EwaldMask(F,peaks,0.85,1.15);
I_flt = ifft2(ifftshift(F.*mask));
figure
imagesc(2*real(I_flt))      % 实值
axis off
axis equal
colormap(sunglow)
figure
imagesc(2*abs(I_flt))       % 模值
axis off
axis equal
colormap(sunglow)

% -----------------------------------
% 读取剖面强度
[I0,X,Y] = LineCut(Icut1,X,Y);
[I1,X,Y] = LineCut(2*real(I_flt),X,Y);
[I2,X,Y] = LineCut(2*abs(I_flt),X,Y);

[I0,X,Y] = LineCut(Icut1);
[I2,X,Y] = LineCut(2*real(I_flt));
[I2,X,Y] = LineCut(2*abs(I_flt));

LineCut(S,X,Y);

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
par0 = [10,3,200,0];    % initial value
x0 = 1:length(yy);
par2 = lsqcurvefit(fun,par0,x0,yy');
figure
plot(x0,yy)
hold on
plot(x0,fun(par2,x0),'--');

%% 作图
figure
plot3(ones(size(I0)),1:length(I0),I2);
hold on
plot3(1.2*ones(size(I1)),1:length(I1),I1);
plot3(1.4*ones(size(I2)),1:length(I2),I0);















