%% Post-error slowing
for session = 1:29
    sessionRT = [];
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4)-...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    postNC_RT(session,1) = nanmean(sessionRT(executiveBeh.Trials.Hi{session}.t_GO_after_NC));
    postC_RT(session,1) = nanmean(sessionRT(executiveBeh.Trials.Hi{session}.t_GO_after_C));
    postNS_RT(session,1) = nanmean(sessionRT(executiveBeh.Trials.Hi{session}.t_GO_after_GO));
end

clear slowingFigure groupLabels epochLabels burstData
% Boxplot
groupLabels = [repmat({'No-stop'},29,1); repmat({'Non-canceled'},29,1); repmat({'Canceled'},29,1)];
burstData = [postNS_RT; postNC_RT; postC_RT];
monkeyFlag = repmat(executiveBeh.nhpSessions.monkeyNameLabel,3,1);

slowingFigure(1,1)= gramm('x',groupLabels,'y',burstData,'color',groupLabels);
slowingFigure(1,1).stat_boxplot();
slowingFigure(1,1).geom_jitter('alpha',0.01,'dodge',0.75);
slowingFigure(1,1).no_legend();
slowingFigure(1,1).axe_property('YLim',[150 550]);

slowingFigure(1,2)= gramm('x',groupLabels(strcmp(monkeyFlag,'Euler')),...
    'y',burstData(strcmp(monkeyFlag,'Euler')),...
    'color',groupLabels(strcmp(monkeyFlag,'Euler')));
slowingFigure(1,2).stat_boxplot();
slowingFigure(1,2).geom_jitter('alpha',0.01,'dodge',0.75);
slowingFigure(1,2).no_legend();
slowingFigure(1,2).axe_property('YLim',[150 550]);

slowingFigure(1,3)= gramm('x',groupLabels(strcmp(monkeyFlag,'Xena')),...
    'y',burstData(strcmp(monkeyFlag,'Xena')),...
    'color',groupLabels(strcmp(monkeyFlag,'Xena')));
slowingFigure(1,3).stat_boxplot();
slowingFigure(1,3).geom_jitter('alpha',0.01,'dodge',0.75);
slowingFigure(1,3).no_legend();
slowingFigure(1,3).axe_property('YLim',[150 550]);

% Figure parameters & settings
slowingFigure.set_names('y','');
slowingFigure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Position',[100 100 900 250]);
slowingFigure.draw();

%% RT/pSTOP fluctuation over session

STOPbins = 0.2:0.025:0.8;
nBack = 10;

clear a b
for session = 1:29
    sessionRT = []; sessionSTOPFlag = [];
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4)-...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    sessionRT(sessionRT > quantile(sessionRT, 0.95)) = NaN;
    sessionRT(sessionRT < quantile(sessionRT, 0.05)) = NaN;
    
    sessionRTnormalised = (sessionRT - min(sessionRT))/(max(sessionRT) - min(sessionRT));
    
    sessionSTOPFlag = strcmp(executiveBeh.SessionInfo{session}.Trial_type,'STOP');
    
    move_RT = movmean(sessionRTnormalised,[nBack 0],'omitnan');
    move_STOP = movmean(sessionSTOPFlag,[nBack 0],'omitnan');
    
    [~,~,bin] = histcounts(move_STOP,STOPbins);
    
    for binIdx = 1:length(STOPbins)
        a(binIdx,session) = nanmean(move_STOP(bin == binIdx));
        b(binIdx,session) = nanmean(move_RT(bin == binIdx));
    end
    
    
    
end

%%
clear rtAdjustment_pBurst
rtAdjustment_pBurst(1,1)= gramm('x',nanmean(a(:,1:29),2),...
    'y',nanmean(b(:,1:29),2));
rtAdjustment_pBurst(1,2)= gramm('x',nanmean(a(:,executiveBeh.nhpSessions.EuSessions),2),...
    'y',nanmean(b(:,executiveBeh.nhpSessions.EuSessions),2));
rtAdjustment_pBurst(1,3)= gramm('x',nanmean(a(:,executiveBeh.nhpSessions.XSessions),2),...
    'y',nanmean(b(:,executiveBeh.nhpSessions.XSessions),2));


rtAdjustment_pBurst(1,1).geom_point(); rtAdjustment_pBurst(1,2).geom_point(); rtAdjustment_pBurst(1,3).geom_point();
rtAdjustment_pBurst(1,1).stat_glm('fullrange',true,'disp_fit',true);
rtAdjustment_pBurst(1,2).stat_glm('fullrange',true,'disp_fit',true);
rtAdjustment_pBurst(1,3).stat_glm('fullrange',true,'disp_fit',true);
rtAdjustment_pBurst(1,1).axe_property('YLim',[0.15 0.5]);
rtAdjustment_pBurst(1,2).axe_property('YLim',[0.15 0.5]);
rtAdjustment_pBurst(1,3).axe_property('YLim',[0.15 0.5]);
% rtAdjustment_pBurst(1,1).axe_property('XLim',[0.475 0.55]);

figure('Renderer', 'painters', 'Position', [100 100 800 250]);
rtAdjustment_pBurst.draw();

%% Look at independence violations

for session = 1:29
    sessionRT = [];
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4)-...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    sessionRT(sessionRT > quantile(sessionRT, 0.95)) = NaN;
    sessionRT(sessionRT < quantile(sessionRT, 0.05)) = NaN;
    
    Trials.postNC_GO{session} = executiveBeh.ttx.NC{session}...
        (ismember(executiveBeh.ttx.NC{session},executiveBeh.ttx.GO{session}+1));
    
    indepViolationRT_session = [];
    indepViolationRT_session = sessionRT(Trials.postNC_GO{session})-...
        sessionRT(Trials.postNC_GO{session}-1);
    
    for ssdIdx = 1:length(executiveBeh.inh_SSD{session})
        
        ssdTrials = find(executiveBeh.SessionInfo{session}.Curr_SSD(Trials.postNC_GO{session}) ...
            == executiveBeh.inh_SSD{session}(ssdIdx));
        
        if length(ssdTrials) > 5
            indepViolationRT{session,ssdIdx} = indepViolationRT_session(ssdTrials);
            indepViolationSSD{session,ssdIdx} =  executiveBeh.inh_SSD{session}(ssdIdx);
        else
            indepViolationRT{session,ssdIdx} = NaN;
            indepViolationSSD{session,ssdIdx} = NaN;
        end
        
    end
    
end

indepViolation_table = table();
for session = 1:29
    for ssdIdx = 1:length(executiveBeh.inh_SSD{session})
        meanRT = nanmean(indepViolationRT{session,ssdIdx});
        SSD = indepViolationSSD{session,ssdIdx};
        monkey = {executiveBeh.nhpSessions.monkeyNameLabel{session}};
        session = session;
        indepViolation_table = [indepViolation_table; table(meanRT, SSD, monkey, session)];
    end
    
    figure;
    plot(indepViolation_table.SSD(indepViolation_table.session == session),...
        indepViolation_table.meanRT(indepViolation_table.session == session),'k')
    hline(0,'r');ylim([-300 300])
    title(['Session number ' int2str(session) ' - ' monkey{1}])
end

%% Look at expected SSD change w/staircase

for session = 1:29
    for ssdIdx = 1:length(executiveBeh.inh_SSD{session})-2
        expectedSSD{session}.up(ssdIdx,1) = round(nanmean(diff(executiveBeh.inh_SSD{session}([ssdIdx:ssdIdx+2]))));
    end
    for ssdIdx = 3:length(executiveBeh.inh_SSD{session})
        expectedSSD{session}.down(ssdIdx-2,1) = round(nanmean(diff(executiveBeh.inh_SSD{session}([ssdIdx-2:ssdIdx]))));
    end
end

staircaseRT_table = table();
for session = 1:29
    sessionRT = [];
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4)-...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    sessionRT(sessionRT > quantile(sessionRT, 0.95)) = NaN;
    sessionRT(sessionRT < quantile(sessionRT, 0.05)) = NaN;
    
    RT_mean = nanmean(sessionRT);
    RT_NC = nanmean(sessionRT(executiveBeh.ttx.NC{session}));
    RT_NS = nanmean(sessionRT(executiveBeh.ttx.GO{session}));
    
    
    RT_gopostgo = nanmean(sessionRT(executiveBeh.Trials.all{session}.t_GO_after_GO));
    RT_gopostc = nanmean(sessionRT(executiveBeh.Trials.all{session}.t_GO_after_C));
    RT_gopostnc = nanmean(sessionRT(executiveBeh.Trials.all{session}.t_GO_after_NC));
    
    ratio_c_go = RT_gopostc/RT_gopostgo;
    ratio_nc_go = RT_gopostnc/RT_gopostgo;
    ssd_up = mode(expectedSSD{session}.up);
    ssd_down = mode(expectedSSD{session}.down);
    monkey = strcmp(executiveBeh.nhpSessions.monkeyNameLabel{session},'Euler');
    
    ssrt_mean = bayesianSSRT.ssrt_mean(session);
    ssrt_var = bayesianSSRT.ssrt_std(session);
    ssrt_tf = bayesianSSRT.triggerFailures(session);
    
    stopTrlIdx = [];
    stopTrlIdx = strcmp(executiveBeh.SessionInfo{session}.Trial_type,'STOP');
    
    pStop_comp = mean(strcmp(executiveBeh.SessionInfo{session}.Trial_type,'STOP'));
    
    pEngagement = sum(~isnan(executiveBeh.TrialEventTimes_Overall{session}(:,2)))/...
        length(executiveBeh.TrialEventTimes_Overall{session}(:,2));
    
    
    staircaseRT_table = [staircaseRT_table; table(ratio_c_go, ratio_nc_go, ssd_up, ssd_down,...
        ssrt_mean, ssrt_var, ssrt_tf, pStop_comp, pEngagement,...
        RT_mean, RT_NC, RT_NS, monkey)];
    
end


%%

%%
expectedSSDhistogram(1,1)= gramm('x',staircaseRT_table.ssd_up,...
    'color',staircaseRT_table.monkey);
expectedSSDhistogram(1,1).stat_density();
% rtAdjustment_histogram(1,1).stat_glm('fullrange',true,'disp_fit',true);
% rtAdjustment_histogram.set_('map',[colors.euler; colors.xena]);
figure('Renderer', 'painters', 'Position', [100 100 300 250]);
expectedSSDhistogram.draw();


%% 
clear staircaseRT
staircaseRT(1,1)= gramm('x',staircaseRT_table.ratio_c_go(1:29),...
    'y',staircaseRT_table.ssd_up(1:29));
staircaseRT(1,2)= gramm('x',staircaseRT_table.ratio_c_go(executiveBeh.nhpSessions.EuSessions),...
    'y',staircaseRT_table.ssd_up(executiveBeh.nhpSessions.EuSessions));
staircaseRT(1,3)= gramm('x',staircaseRT_table.ratio_c_go(executiveBeh.nhpSessions.XSessions),...
    'y',staircaseRT_table.ssd_up(executiveBeh.nhpSessions.XSessions));
staircaseRT(2,1)= gramm('x',staircaseRT_table.ratio_nc_go(1:29),...
    'y',staircaseRT_table.ssd_up(1:29));
staircaseRT(2,2)= gramm('x',staircaseRT_table.ratio_nc_go(executiveBeh.nhpSessions.EuSessions),...
    'y',staircaseRT_table.ssd_up(executiveBeh.nhpSessions.EuSessions));
staircaseRT(2,3)= gramm('x',staircaseRT_table.ratio_nc_go(executiveBeh.nhpSessions.XSessions),...
    'y',staircaseRT_table.ssd_up(executiveBeh.nhpSessions.XSessions));

staircaseRT(1,1).geom_point(); staircaseRT(1,2).geom_point(); staircaseRT(1,3).geom_point();
staircaseRT(2,1).geom_point(); staircaseRT(2,2).geom_point(); staircaseRT(2,3).geom_point();
staircaseRT(1,1).stat_glm('fullrange',true,'disp_fit',true); staircaseRT(1,2).stat_glm('fullrange',true,'disp_fit',true); staircaseRT(1,3).stat_glm('fullrange',true,'disp_fit',true);
staircaseRT(2,1).stat_glm('fullrange',true,'disp_fit',true); staircaseRT(2,2).stat_glm('fullrange',true,'disp_fit',true); staircaseRT(2,3).stat_glm('fullrange',true,'disp_fit',true);


staircaseRT(1,1).axe_property('XLim',[0.9 1.5]); staircaseRT(1,2).axe_property('XLim',[0.9 1.5]); staircaseRT(1,3).axe_property('XLim',[0.9 1.5]);
staircaseRT(1,1).axe_property('YLim',[10 160]); staircaseRT(1,2).axe_property('YLim',[10 160]); staircaseRT(1,3).axe_property('YLim',[10 160]);
staircaseRT(2,1).axe_property('XLim',[0.9 1.5]); staircaseRT(2,2).axe_property('XLim',[0.9 1.5]); staircaseRT(2,3).axe_property('XLim',[0.9 1.5]);
staircaseRT(2,1).axe_property('YLim',[10 160]); staircaseRT(2,2).axe_property('YLim',[10 160]); staircaseRT(2,3).axe_property('YLim',[10 160]);

figure('Renderer', 'painters', 'Position', [100 100 800 400]);
staircaseRT.draw();


%% Behavioral PCA/kMeans clustering
behArray = table2array( staircaseRT_table(:,1:13) );
figure(2)
[~,score,~,~,explainedVar] = pca(behArray);
bar(explainedVar)
ylabel('PC')

behPC = score(:,1:4)./max(score(:,1:4));

figure(3)
[clusters, centroid] = kmeans(behPC,2);
gscatter(behPC(:,1),behPC(:,2),clusters)
legend('location','southeast')
xlabel('First Principal Component');
ylabel('Second Principal Component');
title('Principal Component Scatter Plot with Colored Clusters');

% Label one gene in each cluster
[~, r] = unique(clusters);

