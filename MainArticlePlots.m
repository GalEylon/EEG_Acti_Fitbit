%% Main Plots

%load data file
load('TotTable.mat');

var = {'Sleep Time', 'Wake Time'};
pTitle = {'Total Sleep Time (min)','Wake After Sleep Onset (min)'};
varS = {'Sensitivity', 'PPV'; 'Specificity','NPV'};
Sensors = {'FB','ACTI_CK','ACTI_S'};

% accuracy
AccuracyBarArticleAnova(TotTable,varS,{'Sleep','Wake'},Sensors,.05)
% exportgraphics(gcf,'C:\Users\galey\Desktop\sleepstudy\articles\1PSG project\040122\ACC_sup.tif','Resolution',500)
% [AC]=ConfMatArticle(TotTable,Sensors);

% TST and WASO
G = findgroups(cellstr(TotTable.Sensor));
figure('Units','normalized','Position',[.1 .2 .6 .6])
t = tiledlayout('flow','TileSpacing','compact');
nexttile;barplotsep(TotTable,'Sleep Time',G)
nexttile;barplotsep(TotTable,'Wake Time',G)
% exportgraphics(gcf,'C:\Users\galey\Desktop\sleepstudy\articles\1PSG project\040122\TST_WASO.tif','Resolution',500)


% BA - plot & stats 
[Stats] = BlandAltmanArticleNew(TotTable, var, 'EEG',Sensors, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
set(findobj('-regexp','tag','Sleep Time'),'Xtick',[300:100:600])
set(findobj('type','axes'),'Ytick',[-200 0 200])
set(findobj('-regexp','tag','Wake Time'),'Ylim',[-150 150],'Ytick',[-150 0 150])
% exportgraphics(gcf,'C:\Users\galey\Desktop\sleepstudy\articles\1PSG project\040122\TST_WASO_BA.tif','Resolution',1000)

% Specificity and NPV by subject
WASObySub(TotTable)


[Stats] = BlandAltmanArticleNew(TotTable, {'Start Time', 'End Time'}, 'EEG',Sensors, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
set(findobj('-regexp','tag','Start Time'),'Ylim',[-160 160])
set(findobj('-regexp','tag','End Time'),'Ylim',[-50 50])

TimesCor(TotTable,{'Start Time', 'End Time'})




