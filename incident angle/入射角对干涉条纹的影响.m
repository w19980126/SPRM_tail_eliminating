%% 模拟入射角度与倒空间散射环之间的关系
theta = 0:1:90;
n = [1.51,1.33];
lambda = 680;
kapa = 30;
phi = 0.1*pi;
scale_factor = 0.1;
savepath = uigetdir();
savepath = fullfile(savepath,'20211025_环离合与入射角的关系');
mkdir(savepath);
gifroute = fullfile(savepath,'散射环随入射角增加分离.gif');
for ii = 1:length(theta)
    [Ei,Es,F,I] = wave_generate(lambda,n,kapa,theta(ii),phi,scale_factor);
    imagesc(abs(F))
    axis off
    axis square
    set(0,'defaultfigurecolor','w') 
    title(['incidence theta:',num2str(theta(ii)),'^o'],'fontsize',15,'fontweight','bold');
    F = getframe(gcf);
    I = frame2im(F);
    [I,map] = rgb2ind(I,256);
    if ii == 1
        imwrite(I,map,gifroute,'gif','Loopcount',inf,'DelayTime',0.1);
    else
        imwrite(I,map,gifroute,'gif','DelayTime',0.1,'WriteMode','append');
    end
    pause(0.01)
end
