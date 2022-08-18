%% 每根轨迹都作图
for ii = 1:14
    figure
    plot(spr(:,ii));
    hold on
    plot(rec(:,ii));
    legend({'SPR','Rec'});
end

%% 检查轨迹位置
ii = 1;
temp = pstn{ii};
x = temp(:,2);
y = temp(:,3);
temp(1,4)/5
temp(end,4)/5

figure
im = double(imread(fullfile(tiffpath,tiffs(temp(end,4)).name)));
imagesc(im)

hold on
c = linspace(1,length(x),length(x));
% scatter(x,y,[],c);
scatter(x,y,'r');

%% 作图
figure
I1 = smooth(spr(:,14),25);
plot(I1);
hold on
I2 = smooth(rec(:,14),25);
plot(I2);

hl = findobj(gca,'type','line');
hl(1).YData = I2;
hl(2).YData = I1;

hl = findobj(gca,'type','line');
hl(1).YData = rec(:,14);
hl(2).YData = spr(:,14);

hl = findobj(gca,'type','line');
hl(1).YData = rec(2941:3000,2);
hl(2).YData = spr(2941:3000,2);

figure
plot(spr(2941:3000,2));
hold on
plot(rec(2941:3000,2));

%% 统计作图
spr = sprData;    % 未平滑的原始数据
rec = reconstructedData;  % 未平滑的原始数据
n=100;
z=zeros(n+1,n+1);
z=sparse(z);

figure
hold on
maxspr = max(spr,[],'all');
maxrec = max(rec,[],'all');
minspr = min(spr(spr~=0),[],'all');
minrec = min(rec(rec~=0),[],'all');
for ii = 1:135
    if sum(spr(:,ii) ~= 0) > 50
        continue    
    end
    d1=spr(:,ii);
    d2=rec(:,ii);
    d1(d1==0)=[];
    d2(d2==0)=[];
    d1 = d1/maxspr*n;
    d2 = d2/maxspr*n;
    s = sparse(round(d1)+1,round(d2)+1,ones(size(d1)),n+1,n+1);
    z = s+z;
end
grid on
plot([1,n+1],[1,n+1],'r');
hold on
z=full(z);
z(1,1)=0;
imagesc(z);
colormap(violet)
% plot([1,n+1],[1,n+1],'r');
axis tight
axis on
hold off
colorbar

%% 曲线拟合
[X,Y] = meshgrid(linspace(0,n+1,n+1),0:n);
w = z;
A = sum(w.*X.^2,'all');
B = sum(w.*X,'all');
C = sum(w.*X.*Y,'all');
D = sum(w.*X,'all');
E = sum(w,'all');
F = sum(w.*Y,'all');
k = (C*E-B*F)/(A*E-B*D);
b = (A*F-C*D)/(A*E-B*D);

figure
hold on
imagesc(z/sum(z,'all'))
colormap(violet)
fplot(@(x) k*x+b,[0 (n-b)/k],'r');
xlim([0 40])

N = sum(z,'all')
Y_bar = sum(w.*Y,'all')/N;
SYY = sum(w.*(Y-Y_bar).^2,'all')/N;
SSR = sum(w.*(Y-(k*X+b)).^2,'all')/N;
R2 = 1 - SSR/SYY

%% 修改图片数据

h = get(gca,'Children');
him = h(2);
set(him,'CData',z/sum(z,'all'));






