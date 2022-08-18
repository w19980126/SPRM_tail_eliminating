%% 读入颗粒信息
A = readtable('F:\work\散射场\实验数据\20220413_Au_Colission\Result\Tracking data\前一千帧\First_1000_Frames_Tracking_Data.xlsx');
trackID = A.TRACK_ID;

particleNum = 0;    % 跟踪到的颗粒数目计数
particleID = zeros(size(trackID));  % 颗粒ID
for ii = 1:trackID(end)
    if ismember(ii-1,trackID)
        particleNum = particleNum + 1;  % 每多统计一个颗粒计数
        particleID(particleNum) = ii;
    end
end
particleID(particleID==0) = [];
particleID = particleID - 1;

pstn = cell(particleNum,1); % 颗粒位置信息元胞
for ii = 1:particleNum
    loc = find(trackID == particleID(ii));
    ID = A.TRACK_ID(loc); 
    x = A.POSITION_X(loc);
    y = A.POSITION_Y(loc);
    Frame = A.FRAME(loc) + 1;
    pstn{ii} = [ID x y Frame];     % particle ID/x position/y position/frame position
end

%% 将断开的轨迹接上
new_pstn = cell(size(T,1),1);
loc = zeros(size(T,1),1);
for ii = 1:size(T,1)
    for jj = 1:sum(T(ii,:) ~= 0)
        new_pstn{ii} = [new_pstn{ii};pstn{T(ii,jj)}];
    end
    if size(new_pstn{ii},1) < 100
        loc(ii) = 1;
    end
end
new_pstn(logical(loc)) = [];    % 新的pstn存到new_pstn中，将原来的pstn赋值给old_pstn，new_pstn赋值给pstn
old_pstn = pstn;
pstn = new_pstn;

%% 将前10000帧数据导出并作图
tiffpath = 'F:\work\散射场\实验数据\20220413_Au_Colission\Result\B1_reconstructed';
rawpath = 'F:\work\散射场\实验数据\20220413_Au_Colission\TIFF\B1';
Figs = zeros(480,640,100);     % 重构后的图片序列矩阵
tiffs = dir(fullfile(tiffpath,'*.tiff'));
temp = zeros(length(tiffs),1);  % 读入的tiffs排序出错，强行矫正信息排序
for ii = 1:length(temp)
    temp0 = split(tiffs(ii).name,'.');
    temp(ii) = str2double(temp0{1});
end
[~,I] = sort(temp);
tiffs = tiffs(I);
rawitffs = dir(fullfile(rawpath,'*.tiff')); 
Rawtiffs = Figs;    % spr图片序列矩阵

particleNum = length(pstn);
reconstructedData = zeros(1000,particleNum);
sprData = zeros(1000,particleNum);
h = waitbar(0);
for ii = 1:10
    for jj = 1:100
        Figs(:,:,jj) = double(imread(fullfile(tiffpath,tiffs(jj+100*(ii-1)).name)));
    end
    BG = double(imread(fullfile(rawpath,rawitffs(1250).name)));
    for jj = 1:100
        Rawtiffs(:,:,jj) = double(imread(fullfile(rawpath,rawitffs(jj+100*(ii-1)+1250).name))) - BG;
    end
    for jj = 1:particleNum
        [intensity1,m] = gROI(Figs,pstn{jj},8,ii);
        intensity2 = gROI(abs(Rawtiffs),m);
        r1 = (ii-1)*100+1;
        r2 = 100*ii;
        reconstructedData(r1:r2,jj) = intensity1;
        sprData(r1:r2,jj) = intensity2;
        processedNum = (ii - 1)*particleNum + jj;
        waitbar(processedNum/(10*particleNum),h,[num2str(processedNum) '/220']);
    end
    
end
delete(h);

savepath = 'F:\work\散射场\实验数据\20220413_Au_Colission\Result';
% save(fullfile(savepath,'First_1000F_Particle_Intensity_Tracking.mat'),'rec','spr','pstn','reconstructedData','sprData','-v7.3');
save(fullfile(savepath,'First_1000F_Particle_Intensity_Tracking.mat'),'pstn','reconstructedData','sprData','-v7.3');

%% 使用sprdata和reconstructedData作图
spr = sprData;
rec = reconstructedData;

loc = zeros(32,1);
for ii = 1:32
    if size(pstn{ii},1) <= 4000
        loc(ii) = 1;
    end
end
loc = logical(loc);
spr(:,loc) = [];
rec(:,loc) = [];

spr(:,[2 6 7 8]) = [];
res(:,[2 6 7 8]) = [];


for ii = 1:14
    [~,ind] = max(smooth(rec(:,ii),25));
    spr(:,ii) = spr(:,ii)/spr(ind,ii);
    rec(:,ii) = rec(:,ii)/rec(ind,ii);
end
% spr = spr/max(spr,[],[1 2]);
% rec = rec/max(rec,[],[1 2]);
figure
imagesc(spr)
axis square
colormap(sunglow)
caxis([0 1.2])
colorbar
figure
imagesc(rec)
axis square
colormap(sunglow)
caxis([0 1.2])
colorbar

%% 对比处理前后强度趋势
ii = 12;
plot(rec(:,ii));
hold on
plot(spr(:,ii))
hold off

%% 选取典型曲线作图
figure
plot(spr(:,29));
hold on
plot(rec(:,29));
axis square

BG = double(imread(fullfile(rawpath,rawitffs(1250).name)));
figure
Ispr = double(imread(fullfile(rawpath,rawitffs(2975 + 1250).name))) - BG;
imagesc(Ispr);
figure
Irec = double(imread(fullfile(tiffpath,tiffs(2975).name)));
imagesc(Irec);

figure
[~,rectout] = imcrop(Ispr/max(Ispr,[],'all'));
rectout = round(rectout);
r1 = rectout(2);
r2 = rectout(2) + rectout(4);
c1 = rectout(1);
c2 = rectout(1) + rectout(3);

for ii = 1:60
    Ispr = double(imread(fullfile(rawpath,rawitffs(2940+ii + 1250).name))) - BG;
    Irec = double(imread(fullfile(tiffpath,tiffs(2940+ii).name)));
    Isprcut(:,:,ii) = Ispr(r1:r2,c1:c2);
    Ireccut(:,:,ii) = Irec(r1:r2,c1:c2);
end

showSlide(Isprcut);
showSlide(Ireccut);

figure
imagesc(squeeze(Isprcut(:,:,33)));
axis equal
axis off
colormap(sunglow)

figure
imagesc(squeeze(Ireccut(:,:,33)));
axis equal
axis off
colormap(sunglow)
caxis([250 1400])

line([15 15+1000/73.8],[80 80],'color','white','linewidth',6) 




