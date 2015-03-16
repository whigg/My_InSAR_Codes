% hist_da
% Written by:
%  T.LI @ ISEIS, 20130703

clear;
clc;

if 1
workpath='D:\myfiles\Software\experiment\TSX_PS_Tianjin\HPA\';
dafile=[workpath,'DA'];
fid=fopen(dafile);
if fid ~= -1     
    da=fread(fid, [5000,6150],'float');
end;
da=reshape(da, 1, 5000*6150);
x=0:0.01:5;
end;

% set the figure.
hist(da, x);
set(gca,'FontSize', 20, 'XLim', [0, 1.3],'Color','w');



if 0
temperror=Var(:,4);
temperror=random('exp',[10,10]);
[M,CN]=hist(temperror,10)
bar(CN,M)
axis([-20 20 0 16])
title(['Error histogram of Velocity Comparison along Railway']);
xlabel('Error of displacement(mm)')
ylabel('#')
end;