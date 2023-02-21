function [StatsTable]=BlandAltmanArticleNew(DataTable,var,sensorX, sensorY,varargin)
%Draws a Bland-Altman and correlation plots.

if ~isempty(varargin)
    SensorNames = varargin{1,1};
end

%convert times- 12 hour clock to 14 hour clock (00:00 -> 24:00)
DataTable.("Start Time")(DataTable.("Start Time")<duration(12,0,0)) =...
    DataTable.("Start Time")(DataTable.("Start Time")<duration(12,0,0))+hours(24);

%%
% FC =minutes(DataTable{DataTable.Sensor == 'FB',"Start Time"})-minutes(DataTable{DataTable.Sensor == 'EEG',"Start Time"})
% CK = minutes(DataTable{DataTable.Sensor == 'ACTI_CK',"Start Time"})-minutes(DataTable{DataTable.Sensor == 'EEG',"Start Time"})
% S = minutes(DataTable{DataTable.Sensor == 'ACTI_S',"Start Time"})-minutes(DataTable{DataTable.Sensor == 'EEG',"Start Time"})

StatsTable = table();
% fig = figure('Units','normalized','OuterPosition',[0 0 1 1]);
fig = figure('Units','normalized','Position',[.1 .2 .6 .6]);
set(fig,'Units','centimeters','color','w');
tiledlayout(2,3,'TileSpacing','loose')

for f = 1:numel(var) %TST and WASO/ sleep onset-offset

    for i = 1:numel(sensorY) % devices
        Data1 = DataTable{DataTable.Sensor == sensorX,var{f}};
        Data2 = DataTable{DataTable.Sensor == sensorY{i},var{f}};

        % for sleep onset/offset
        if isduration(Data1)
            Data1 = minutes(Data1); Data2 = minutes(Data2);
        end
        [G] = findgroups(cellstr(DataTable{DataTable.Sensor == sensorY{i},'Name'}));
        [cnt_unique, unique_a] = hist(G,unique(G));

        %data for BA
        Xmean = mean([Data1,Data2],2);
        Ydif = [Data2 - Data1];
        difMean = mean(Ydif);
        difSTD = std(Ydif);


        %% linear model
        %check for proportional bias
        lm = fitlm(Data1,Ydif);
        slope = lm.Coefficients.Estimate(2);
        intcpt = lm.Coefficients.Estimate(1);
        % check for heteroscedasticity
        lmRes = fitlm(Data1,lm.Residuals.Raw); % check heteroscedasticity

        % plot data (x axis - PSG, y axis - difference)
        nexttile;
        scatter(Data1,Ydif,40,"black"); hold on;
        %         xlabel('PSG'); ylabel('Device-PSG');
        set(gca,'FontName','Times New Roman', 'Tag', [var{f} num2str(i)],'FontSize',12);
        pbaspect([1 1 1]);



        %% Bland Altman parameters
        BAax = axis(gca);

        % mean line
        bLine = refline([0 difMean]);
        bLine.Color = 'k'; bLine.LineWidth = 1;

        %% (repeated measures anova 061122) - calculations according to Hagheyegh's article
        [~,tbl,~] = anova1(Ydif,G,'off');
        mh = max(G)/sum(arrayfun(@(x) 1/x,cnt_unique));
        Stot2 = tbl{2,4}+(1-1/mh)*tbl{3,4};
        Sb2 = tbl{2,4}; Sw2 = tbl{3,4};
        t = tinv(.975,numel(cnt_unique));

        % CI of the bias
        CIbias = [difMean - t*(sqrt(Stot2)/sqrt(numel(cnt_unique))),...
            difMean + t*(sqrt(Stot2)/sqrt(numel(cnt_unique)))];
        %lower and upper LOAs
        LOA = [difMean - 1.96*(sqrt(Stot2)),...
            difMean + 1.96*(sqrt(Stot2))];
        %CI of lower and upper LOAs
        CILOAL = [LOA(1)-t*...
            sqrt( (Stot2/numel(cnt_unique)) +((1.96^2)/(2*Stot2))*...
            (((Sb2^2)/(numel(cnt_unique)-1)) +((1-1/mh)^2)*((Sw2^2)/(length(G)-numel(cnt_unique))))),...
            LOA(1)+t*...
            sqrt( (Stot2/numel(cnt_unique)) +((1.96^2)/(2*Stot2))*...
            (((Sb2^2)/(numel(cnt_unique)-1)) +((1-1/mh)^2)*((Sw2^2)/(length(G)-numel(cnt_unique)))))];

        CILOAU = [LOA(2)-t*...
            sqrt( (Stot2/numel(cnt_unique)) +((1.96^2)/(2*Stot2))*...
            (((Sb2^2)/(numel(cnt_unique)-1)) +((1-1/mh)^2)*((Sw2^2)/(length(G)-numel(cnt_unique))))),...
            LOA(2)+t*...
            sqrt( (Stot2/numel(cnt_unique)) +((1.96^2)/(2*Stot2))*...
            (((Sb2^2)/(numel(cnt_unique)-1)) +((1-1/mh)^2)*((Sw2^2)/(length(G)-numel(cnt_unique)))))];

        %display CI of the bias as shaded area
        CIbiasPlot = patch([bLine.XData flip(bLine.XData)],[CIbias(1) CIbias(1) CIbias(2) CIbias(2)],[.5 .5 .5],'FaceAlpha',0.3, ...
            'EdgeColor','none');

        %plot LOAs
        LOAplot = plot(bLine.XData,LOA(1) + [0 0], '--r','LineWidth',1, 'Tag',['LOALine' num2str(i)]);
        LOAplot = plot(bLine.XData,LOA(2) + [0 0], '--r','LineWidth',1,'Tag',['LOALine' num2str(i)]);
        
        % display CI of LOAs as shaded area
        LOAbiasPlot = patch([bLine.XData flip(bLine.XData)],[CILOAU(1) CILOAU(1) CILOAU(2) CILOAU(2)],'r','FaceAlpha',0.1, ...
            'EdgeColor','none');

        LOAbiasPlot = patch([bLine.XData flip(bLine.XData)],[CILOAL(1) CILOAL(1) CILOAL(2) CILOAL(2)],'r','FaceAlpha',0.1, ...
            'EdgeColor','none');

        %construct table with all parameters for later use
        StatsTable = [StatsTable;table({var{f}},sensorY(i),{difMean}, {CIbias},...
            {LOA(1)},{CILOAL},{LOA(2)},{CILOAU})];
%                 [~,pp,~,st] = ttest(Ydif)




    end
end
StatsTable.Properties.VariableNames =  {'metric','device','bias','ci bias','LOA L','ci LOA L','LOA U','ci LOA U'};

%adjust columns limits and ticks
for j = 1:length(var)
    ind = find(ismember(StatsTable.metric,var{j}));
    ax = findobj(gcf,'-regexp','Tag',var{j});
    minlim = min(cellfun(@min,StatsTable.("ci LOA L")(ind)));
    maxlim = max(cellfun(@max,StatsTable.("ci LOA U")(ind)));
    set(ax,'Ylim',[floor(minlim/100)*100 ceil(maxlim/100)*100]);
    if isduration(DataTable{DataTable.Sensor == sensorX,var{f}})
        if j == 1
            ticks = minutes(duration(22,0,0)):120:minutes(duration(26,0,0));
            labels = datestr(duration(0,0,0)+minutes(ticks),'HH:MM');
        else
            ticks = minutes(duration(5,0,0)):180:minutes(duration(11,0,0));
            labels = datestr(duration(0,0,0)+minutes(ticks),'HH:MM');
        end
        set(ax,'XTick',ticks,'XTickLabel',labels);
    end

end

set(findobj('type','axes'),'FontName','Times New Roman','FontSize',18)

end

