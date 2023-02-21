%% Main Plots

%load data file

var = {'Sleep Time', 'Wake Time'};
pTitle = {'Total Sleep Time (min)','Wake After Sleep Onset (min)'};
varS = {'Sensitivity', 'PPV'; 'Specificity','NPV'};
Sensors = {'FB','ACTI_CK','ACTI_S'};

% accuracy
AccuracyBarArticleAnova(TotTable,varS,{'Sleep','Wake'},Sensors,.05)
exportgraphics(gcf,'C:\Users\galey\Desktop\sleepstudy\articles\1PSG project\040122\ACC_sup.tif','Resolution',500)
[AC]=ConfMatArticle(TotTable,Sensors);

% TST and WASO
G = findgroups(cellstr(TotTable.Sensor));
figure('Units','normalized','Position',[.1 .2 .6 .6])
subplot(1,2,1);barplotsep(TotTable,'Sleep Time',G)
subplot(1,2,2);barplotsep(TotTable,'Wake Time',G)
exportgraphics(gcf,'C:\Users\galey\Desktop\sleepstudy\articles\1PSG project\040122\TST_WASO.tif','Resolution',500)


% BA - plot & stats (change line 66 for proportional/ systemic bias)
% [Stats] = BlandAltmanArticle2(TotTable, var, 'EEG',Sensors, ...
%     {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
[Stats] = BlandAltmanArticleNew(TotTable, var, 'EEG',Sensors, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
set(findobj('-regexp','tag','Sleep Time'),'Xtick',[300:100:600])
set(findobj('type','axes'),'Ytick',[-200 0 200])
set(findobj('-regexp','tag','Wake Time'),'Ylim',[-150 150],'Ytick',[-150 0 150])
exportgraphics(gcf,'C:\Users\galey\Desktop\sleepstudy\articles\1PSG project\040122\TST_WASO_BA.tif','Resolution',1000)


WASObySub(TotTable)

TimesCor(TotTable,{'Start Time', 'End Time'})
[Stats] = BlandAltmanArticleNew(TotTable, {'Start Time', 'End Time'}, 'EEG',Sensors, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
set(findobj('-regexp','tag','Start Time'),'Ylim',[-160 160])
set(findobj('-regexp','tag','End Time'),'Ylim',[-50 50])
% BlandAltmanOnsetOffset(TotTable, {'Start Time', 'End Time'},'EEG',Sensors)
% BlandAltmanOnsetOffset2(TotTable, {'Start Time', 'End Time'},'EEG',Sensors)
% BlandAltmanOnsetOffset2({'Start Time', 'End Time'},'EEG', Sensors,...
%     {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'},TotTable)
CorPlotArticle(TotTable, {'Start Time', 'End Time'}, 'EEG',Sensors, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'})
CorPlotArticle(TotTable, var, 'EEG',Sensors, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'})
set(findobj('-regexp','tag','Sleep Time'),'Ytick',[200 400 600])
set(findobj('-regexp','tag','Wake Time'),'Ytick',[0 100 200])


%% old
[Gnew,h] = findgroups(cellstr(TotTablenew.Sensor));
barplotsep(TotTablenew,'Wake Time',Gnew)
barplotsep(TotTablenew,'Sleep Time',Gnew)

% BA - plot & stats
[Stats] = BlandAltmanArticle3(TotTablenew, var, 'EEG',{'FB','ACTI_CK','ACTI_CKr','ACTI_S','ACTI_Sr'}, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});

%%

% TST and WASO bar
G = findgroups(cellstr(TotTable.Sensor));
barplot(TotTable,{'Sleep Time','Wake Time'},G, .05)
barplot(TotTable10,{'Sleep Time','Wake Time'},G, .05)
[Gnew,h] = findgroups(cellstr(TotTablenew.Sensor));
barplot(TotTablenew,{'Sleep Time','Wake Time'},Gnew, .05)
barplotsep(TotTablenew,'Sleep Time',Gnew, .05)
barplotsep(TotTablenew,'Wake Time',Gnew)
barplotsep(TotTablenew,'Sleep Time',Gnew)


% BA - plot & stats
Sensors = {'FB','ACTI_CK','ACTI_S'};
[Stats] = BlandAltmanArticle2(TotTable, var, 'EEG',Sensors, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
[Stats10] = BlandAltmanArticle2(TotTable10, var, 'EEG',Sensors, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
[Stats] = BlandAltmanArticle3(TotTablenew, var, 'EEG',{'FB','ACTI_CK','ACTI_CKr','ACTI_S','ACTI_Sr'}, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});

% count wake
CountWakeMatfb(:,1) = CountWakeMatfb(:,1)./2;
WakeBar(CountWakeMatfb, {'PSG','Fitbit',{'Actigraph'; '(Cole-Kripke)'},{'Actigraph'; '(Sadeh)'}})



%% plots for article 
pptDate = datestr(datetime('now'),'ddmmyy');
pptname = strcat(pptDate,'Results', '.ppt');
ppt=saveppt2(fullfile(MainPath,'Results',pptname),'init');
TotTable = TotTablefb;
notes = '10min';
var = {'Sleep Time', 'Wake Time'};
% varS = {'Sensitivity', 'Specificity'}
pTitle = {'Total Sleep Time (min)','Wake After Sleep Onset (min)'};
%%
[SumTable, GSum] = MeanBySub(TotTable);
%% summmary
[RepT] = TableForReport(TotTable);
writetable(RepT,['C:\Users\galey\Desktop\sleepstudy\articles\my article\Descriptives_',C pptDate '.csv'])
% accuracy
Sensors = {'FB','ACTI_CK','ACTI_S'};
[AcTNo] = BlandAltmanArticleData(TotTableNo, var, 'EEG',Sensors, pTitle, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
[AcT10] = BlandAltmanArticleData(TotTable10, var, 'EEG',Sensors, pTitle, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
writetable(AcTNo,['C:\Users\galey\Desktop\sleepstudy\articles\my article\Descriptives_',pptDate 'ACNo.csv'])
writetable(AcT10,['C:\Users\galey\Desktop\sleepstudy\articles\my article\Descriptives_',pptDate 'AC10.csv'])
%% TST and WASO bar
G = findgroups(cellstr(TotTable.Sensor));
barplot(TotTable,{'Sleep Time','Wake Time'},G, .05)
barplot(SumTable,{'Sleep Time','Wake Time'},GSum, .05)

%% Bland Altman for TST and WASO + cor
Sensors = {'FB','ACTI_CK','ACTI_S'};
[AcT] = BlandAltmanArticleData(TotTableNo, var, 'EEG',Sensors, pTitle, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'});
writetable(AcT,['C:\Users\galey\Desktop\sleepstudy\articles\my article\Descriptives_',pptDate 'ACC.csv'])
BlandAltmanArticle(TotTable, var, 'EEG',Sensors, pTitle, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'})
[Stats] = BlandAltmanArticle2(TotTable, var, 'EEG',Sensors, ...
    {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'})
writetable(Stats,['C:\Users\galey\Desktop\sleepstudy\articles\my article\Descriptives_',pptDate 'BAstats.csv'])
% BlandAltmanArticle(SumTable, var, 'EEG',Sensors, pTitle, ...
%     {'Fitbit','Actigraph (Cole-Kripke)','Actigraph (Sadeh)'})

%% accuracy
varS = {'Sensitivity', 'PPV'};
AccuracyBarArticleAnova(TotTable,varS,{'Sleep','Wake'},Sensors,.05)
AccuracyBarArticle(TotTable,varS,{'Sleep','Wake'},Sensors,.05)
AccuracyBarArticleMean(TotTable,varS,{'Sleep','Wake'},Sensors,.05)



%% PPV and Sensitivity by subject (WASO)
WASObySub(TotTable)
WASObyAlg(TotTableN,TotTableW,TotTable10)
fobj = findobj('type','figure');
arrayfun(@(x) saveppt2('ppt',ppt,'stretch', false,...
    'notes',notes,'f',fobj(x)), 1:length(fobj));
close all;

%%
 PlotCMat(CMat)

%% plot single night
plotDataArticle(TotTable,subTable) %sub=20 (VD), i=3 (last)

%% ROC
% ROC(TotTable)
Sensors = {'EEG', 'FB','ACTI_CK','ACTI_S'};
figure()
tiledlayout(2,4)
for v = 1:length(var)
    for s = 1:length(Sensors)
        nexttile
        histogram(TotTable.(var{v})(TotTable.Sensor == Sensors{s}),10)
        set(gca,'tag',var{v})
        if v == 1; title(strrep(Sensors{s},'_','\_')); end
        if s == 1; ylabel(var{v}); end
    end
    ax = findobj('tag',var{v});
    set(ax,'YLim',[min(cellfun(@min, get(ax,'YLim'))) max(cellfun(@max, get(ax,'YLim')))], ...
        'FontName','Calibri light','FontSize',10, 'box','off');
end
sgtitle('Measures distribution','FontName','Calibri light','FontSize',14);


figure()
tiledlayout(2,3)
for v = 1:length(Sensors)
    for s = 1:length(Sensors)
        if s > v
            nexttile
            histogram([TotTable.('Wake Time')(TotTable.Sensor == Sensors{s})-...
                TotTable.('Wake Time')(TotTable.Sensor == Sensors{v})],10)
            title(strrep([Sensors{s} ' - ' Sensors{v}],'_','\_'));
        end
    end
end
sgtitle('Wake time difference distribution','FontName','Calibri light','FontSize',14);
set(findobj('type','axes'),'FontName','Calibri light','FontSize',10, 'box','off');



