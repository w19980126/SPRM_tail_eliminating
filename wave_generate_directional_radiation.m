function [Ei,Es,F,I] = wave_generate(lambda,n,kapa,theta,psi,scale_factor,M_size,theta_spp,theta_res)
%% ������������������SPP����ɢ�䲨�Լ����ߵ��Ӻ��k�ռ�ͼ��
% ˵����֮ǰ��������Ҫ���������ǵõ���ͼ���з��䲨��ɢ�䲨�Ĳ�ʸ��ֻ�����价���йأ�����Һ���������޹�
% lambda:����в�������λ��nm
% n�����������ʣ���Ϊ���������Ҫ�����ģ�����ֻ���ǲ����������ʼ���
% d:������ʺ�ȣ���λ��nm
% kapa��ɢ�䲨��˥�����ȣ���λ��um
% theta������Ƕȣ���λ�ǡ�
% psi:��Ϊ�趨��psiֵ����λ�ǻ���
% scale_factor���������ӣ���ɢ�䲨�����ƽ�沨�������
% M_size:�����С
% NA:��ֵ�׾�
% theta_spp:ƽ�沨��������,��λ�ǡ�
% Ei�����䲨�ڽ����ϵķ�������SPP��
% Es�����ɵ�ɢ�䲨
% F�����ɵ�k�ռ����价�������F�ǲ��������Ľ��
% I��������ɢ��ǿ�ȳ�
% ���ǿ��Ƿ��䷽���Եĺ���

    lambda = lambda/10^9;
    theta = theta/180*pi;
    theta_spp = theta_spp/180*pi;
    theta_res = theta_res/180*pi;   % �����
    
    k_i = 2*pi/lambda*n*sin(theta);   % ���䲨��ˮƽ����
    Ei = zeros(M_size);   
    Es = Ei;
    step = 1*10^(-7);    % ͼ��ֱ���
    for ii = 1:M_size
        for jj = 1:M_size
            x = (ii-1)*step;
            y = (jj-1)*step;
            Ei(ii,jj) = exp(i*(k_i*cos(theta_spp)*x+k_i*sin(theta_spp)*y));
        end
    end
    
    kapa = kapa*10^(-6);   
    k_s = 2*pi/lambda*n*sin(theta_res);   % ɢ�䲨��ˮƽ����
    for ii = 1:M_size
        for jj = 1:M_size
            r = sqrt((ii-ceil(M_size/2))^2+(jj-ceil(M_size/2))^2)*step;
            phi = atan((jj-ceil(M_size/2))/(ii-ceil(M_size/2)+eps))-theta_spp;
            Es(ii,jj) = (cos(phi))^2*scale_factor*exp(-r/kapa)*exp(i*(k_s*r+psi+angle(Ei(ceil(M_size/2),ceil(M_size/2))))); 
        end
    end

    E = (Ei + Es)*sin(theta);    % ���泡
    I_detected = (abs(E)).^2 + (abs(Ei*cos(theta))).^2 + (abs(Es*cos(theta))).^2;    % �۲⵽��ǿ�ȷֲ�
    I_bg = (abs(Ei).^2);
    I = I_detected - I_bg;
    F = fftshift(fft2(I));

end



    
    
    