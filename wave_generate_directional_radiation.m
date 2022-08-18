function [Ei,Es,F,I] = wave_generate(lambda,n,kapa,theta,psi,scale_factor,M_size,theta_spp,theta_res)
%% 本函数用来快速生成SPP波，散射波以及二者叠加后的k空间图像
% 说明：之前的理论需要修正，我们得到的图像中反射波和散射波的波矢都只跟出射环境有关，跟溶液侧折射率无关
% lambda:真空中波长，单位是nm
% n：玻璃折射率，因为入射光总是要下来的，所以只考虑玻璃的折射率即可
% d:各层介质厚度，单位是nm
% kapa：散射波的衰减长度，单位是um
% theta：入射角度，单位是°
% psi:人为设定的psi值，单位是弧度
% scale_factor：缩放因子，即散射波相对于平面波的振幅比
% M_size:矩阵大小
% NA:数值孔径
% theta_spp:平面波传播方向,单位是°
% Ei：出射波在界面上的分量，即SPP波
% Es：生成的散射波
% F：生成的k空间衍射环，这里的F是差减背景后的结果
% I：差减后的散射强度场
% 这是考虑辐射方向性的函数

    lambda = lambda/10^9;
    theta = theta/180*pi;
    theta_spp = theta_spp/180*pi;
    theta_res = theta_res/180*pi;   % 共振角
    
    k_i = 2*pi/lambda*n*sin(theta);   % 反射波的水平分量
    Ei = zeros(M_size);   
    Es = Ei;
    step = 1*10^(-7);    % 图像分辨率
    for ii = 1:M_size
        for jj = 1:M_size
            x = (ii-1)*step;
            y = (jj-1)*step;
            Ei(ii,jj) = exp(i*(k_i*cos(theta_spp)*x+k_i*sin(theta_spp)*y));
        end
    end
    
    kapa = kapa*10^(-6);   
    k_s = 2*pi/lambda*n*sin(theta_res);   % 散射波的水平分量
    for ii = 1:M_size
        for jj = 1:M_size
            r = sqrt((ii-ceil(M_size/2))^2+(jj-ceil(M_size/2))^2)*step;
            phi = atan((jj-ceil(M_size/2))/(ii-ceil(M_size/2)+eps))-theta_spp;
            Es(ii,jj) = (cos(phi))^2*scale_factor*exp(-r/kapa)*exp(i*(k_s*r+psi+angle(Ei(ceil(M_size/2),ceil(M_size/2))))); 
        end
    end

    E = (Ei + Es)*sin(theta);    % 干涉场
    I_detected = (abs(E)).^2 + (abs(Ei*cos(theta))).^2 + (abs(Es*cos(theta))).^2;    % 观测到的强度分布
    I_bg = (abs(Ei).^2);
    I = I_detected - I_bg;
    F = fftshift(fft2(I));

end



    
    
    