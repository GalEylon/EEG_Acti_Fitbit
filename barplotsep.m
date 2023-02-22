function barplotsep(DataTable,BarVars,GroupVar)
% Bar chart with error bar for TST or WASO seperated by sensor

colors = [0 .44 .74; .02 .61 1;
    1 .4 .16; .96 .6 .4;
    .4 .8 .07; .5 .2 .55];

% generate summarised matrix- first row sleep time. second row wake time.
TimeMat = splitapply(@mean,DataTable.(BarVars),GroupVar)';
stdMat = splitapply(@std,DataTable.(BarVars),GroupVar)'...
    ./sqrt(height(DataTable)/max(size(TimeMat)));

%fig = figure()
b = bar(diag(TimeMat),'Stacked','FaceColor','flat'); hold on;
errorbar([1:length(TimeMat)],TimeMat, stdMat, 'k','linestyle', 'none')
ylabel('Duration (minutes)');
set(gca,'Fontsize',14,'FontName','Times New Roman','XTickLabel',{[]},...
    'LineWidth',1,'box','off')
figAx = gca;

%% add mean and ste text to bars
xvals = [1:length(TimeMat)];
yvals = TimeMat +stdMat;

labels1 = string(arrayfun(@(x) sprintf("%0.1f ",TimeMat(x)),1:length(yvals),'uni',0));
labels2 = string(arrayfun(@(x) sprintf("(%.1f)",stdMat(x)),1:length(yvals),'uni',0));
txt = text(figAx,xvals,yvals+.05*max(yvals),labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','FontName','Times New Roman','FontSize',12);
txt = text(figAx,xvals,yvals,labels2,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','FontName','Times New Roman','FontSize',10);

%% ttest
Sensors = DataTable.Sensor(1:length(TimeMat));
for i = 1:length(Sensors)
    Sens(i) = Sensors(GroupVar(1:length(TimeMat)) == i);
end
ref = find(Sens == 'EEG');
for ii = 1:length(Sens)
    if ii ~= ref
        [~,p,~,stats] = ttest(DataTable{DataTable.Sensor == Sens(ref),BarVars}, ...
            DataTable{DataTable.Sensor == Sens(ii),BarVars});
        if p < .05
            if contains(BarVars, 'Sleep')
                pl = plot(figAx,ii,yvals(ii)+.18*yvals(ii),'*k');
            else
                pl = plot(figAx,ii,yvals(ii)+.22*yvals(ii),'*k');
            end
%             stats
        end
    end
end

%% legend
[~,I] = sort(GroupVar(1:length(TimeMat)));
forlgd = cellfun(@(x) strrep(x,'_','\_'),DataTable.Sensor(I),'Uni',0);
forlgd(contains(forlgd,'CKr')) = {sprintf('Actigraph-rescored\n(Cole-Kripke)')};
forlgd(contains(forlgd,'CK')) = {sprintf('Actigraph\n(Cole-Kripke)')};
forlgd(contains(forlgd,'Sr')) = {sprintf('Actigraph-rescored\n(Sadeh)')};
forlgd(contains(forlgd,'_S')) = {sprintf('Actigraph\n(Sadeh)')};

forlgd(contains(forlgd,'EEG')) = {'PSG'};
forlgd(contains(forlgd,'FB')) = {'FC3'};


if contains(BarVars, 'Sleep')
    title(figAx,'TST')
else
    title(figAx,'WASO')
    lg = legend(figAx,forlgd);
    lg.Layout.Tile = 'east'
end

end

