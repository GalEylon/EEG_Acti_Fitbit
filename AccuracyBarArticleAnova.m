function AccuracyBarArticleAnova(DataTable,varS,varplot, Sensors, pval)

% functions to calculate sensitivity, specificity, PPV and NPV for all nights
ACC.Sensitivity = @(x) x(1,1)/sum(x(1,:));
ACC.Specificity = @(x) x(2,2)/sum(x(2,:));
ACC.PPV = @(x) x(1,1)/sum(x(:,1));
ACC.NPV = @(x) x(2,2)/sum(x(:,2));

%seperate values by sensor (sensitivity_wake = specificity, PPV_wake = NPV)
for i = 1:length(Sensors)
    AC.Sensitivity_Sleep(:,i) = cellfun(ACC.Sensitivity, DataTable.ConfMatAll(DataTable.Sensor == Sensors{i}));
    AC.PPV_Sleep(:,i) = cellfun(ACC.PPV, DataTable.ConfMatAll(DataTable.Sensor == Sensors{i}));
    AC.Sensitivity_Wake(:,i) = cellfun(ACC.Specificity, DataTable.ConfMatAll(DataTable.Sensor == Sensors{i}));
    AC.PPV_Wake(:,i) = cellfun(ACC.NPV, DataTable.ConfMatAll(DataTable.Sensor == Sensors{i}));
end

%get participants ID and groupby
names = DataTable.Name(DataTable.Sensor=='FB',:);
[G,ID] = findgroups(cellstr(names));

%replace missing npv values (where the sensor didn't detect any wake) with
%0.
AC.PPV_Wake = fillmissing(AC.PPV_Wake,'constant',0);

%calculate mean value for each subject
AC.Sensitivity_Sleep= splitapply(@mean,AC.Sensitivity_Sleep,G);
AC.PPV_Sleep = splitapply(@mean,AC.PPV_Sleep,G);
AC.Sensitivity_Wake = splitapply(@mean,AC.Sensitivity_Wake,G);
AC.PPV_Wake = splitapply(@mean,AC.PPV_Wake,G);


%% plot
Mainfig = figure('Units','normalized','Position',[.1 .2 .6 .6]);
t = tiledlayout(Mainfig, 1,2,'TileSpacing','tight');

ACfields = fieldnames(AC);
for st = 1:numel(varplot)
    curfields = ACfields(contains(ACfields,varplot{st}));
    % get sen and ppv for current state (sleep/wake)
    SEN = AC.(curfields{contains(curfields,'Sensitivity')});
    PPV = AC.(curfields{contains(curfields,'PPV')});

    % calculate mean, sd and se, construct vector for plot
    MeanMat = [mean(SEN,'omitnan')',mean(PPV,'omitnan')'];
    SteMat = [std(SEN,'omitnan')'./sqrt(length(SEN)),...
        std(PPV,'omitnan')'./sqrt(sum(~any(isnan(PPV),2)))];
    StdMat = [std(SEN,'omitnan')',std(PPV,'omitnan')'];

    %plot bar
    ax.(varplot{st}) = nexttile(t);
    b = bar( MeanMat',.92); hold on; box off;

    %assign color
    b(1).FaceColor= [0.4941    0.1843    0.5569];
    b(2).FaceColor= [0    0.4471    0.7412];
    b(3).FaceColor= [0.8510    0.3255    0.0980];

    %plot error bar
    errorbar(reshape([b.XEndPoints],2,3),MeanMat', SteMat',...
        'k','linestyle', 'none');
    xticklabels(varS(st,:)); ylim([0 1.2])
    StdMat2 = reshape(StdMat',1,6);
    xvals = [b.XEndPoints];
    yvals = [b.YEndPoints] +reshape(SteMat',1,6);
    yvalstxt = [b.YEndPoints];
    labels1 = string(arrayfun(@(x) sprintf("%0.2f ",yvalstxt(x)),1:6,'uni',0));
    labels2 = string(arrayfun(@(x) sprintf("(%.2f)",StdMat2(x)),1:6,'uni',0));
    txt = text(ax.(varplot{st}),xvals,yvals+.05,strrep(labels1,'0.','.'),'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','FontName','Times New Roman','FontSize',12);
    txt2 = text(ax.(varplot{st}),xvals,yvals+.01,strrep(labels2,'0.','.'),'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','FontName','Times New Roman','FontSize',8);

    xvals = reshape([b.XEndPoints],2,3);
    yvals = reshape([b.YEndPoints],2,3)+reshape(SteMat',2,3);

    % perform anova- Sensitivity/Specificity
    [~,text_tbl,stats] = anova1(SEN,Sensors,'off');
    disp([varplot{st} ' Sensitivity'])
    text_tbl
    %post hoc
    [c,~,~,~] = multcompare(stats,'Display','off')

    % find significant tests

    sigTestInd = find(c(:,end)< .05);
    for i = 1:numel(sigTestInd)
        var1 = c(sigTestInd(i),1); var2 = c(sigTestInd(i),2);
        if abs(var2-var1)<=1
            yval = .14;
        else
            yval = .2;
        end
        plot(ax.(varplot{st}),xvals(1,[var1 var2]), [1 1]*max(yvals(1,:))+yval, '-k', 'LineWidth',1.5);
        plot(ax.(varplot{st}),[1 1]*xvals(1,var1), [max(yvals(1,:))+yval max(yvals(1,:))+yval-.03], '-k', 'LineWidth',1.2);
        plot(ax.(varplot{st}),[1 1]*xvals(1,var2), [max(yvals(1,:))+yval max(yvals(1,:))+yval-.03], '-k', 'LineWidth',1.2);
        plot(ax.(varplot{st}),mean(xvals(1,[var1 var2])), max(yvals(1,:))+yval+.02, '*k');
    end

    % perform anova - PPV/NPV
    [~,text_tbl,stats] = anova1(PPV,Sensors,'off');
    disp([varplot{st} ' PPV'])
    text_tbl
    %post hoc
    [c,~,~,~] = multcompare(stats,'Display','off')


    %     % find significant tests

    sigTestInd = find(c(:,end)< .05);
    for i = 1:numel(sigTestInd)
        var1 = c(sigTestInd(i),1); var2 = c(sigTestInd(i),2);
        if abs(var2-var1)<=1
            yval = .14;
        else
            yval = .2;
        end
        plot(ax.(varplot{st}),xvals(2,[var1 var2]), [1 1]*max(yvals(2,:))+yval, '-k', 'LineWidth',1.5);
        plot(ax.(varplot{st}),[1 1]*xvals(2,var1), [max(yvals(2,:))+yval max(yvals(2,:))+yval-.03], '-k', 'LineWidth',1.2);
        plot(ax.(varplot{st}),[1 1]*xvals(2,var2), [max(yvals(2,:))+yval max(yvals(2,:))+yval-.03], '-k', 'LineWidth',1.2);
        plot(ax.(varplot{st}),mean(xvals(2,[var1 var2])), max(yvals(2,:))+yval+.02, '*k')
    end

end

legend(ax.(varplot{st}), {'Fitbit',['Actigraph' newline '(Cole-Kripke)'],['Actigraph' newline '(Sadeh)']});
set(ax.Wake, 'YAxisLocation','right','YLim',ax.Sleep.YLim);
ax.Wake.YAxis.Visible = 'off';
set(findobj(Mainfig,'type','axes'),'Fontsize',12,'FontName','Times New Roman'...
    ,'LineWidth',1,'box','off','Ylim',[0 1.25],'YTick',[0:0.2:1]);
set(findobj('type','legend'),'Fontsize',12)
axes(ax.Sleep)
ylabel('Performance')

end

