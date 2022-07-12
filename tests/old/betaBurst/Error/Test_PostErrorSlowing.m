
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 509. \n',lfp);
    
    % Load in beta output data for session
    loadname = ['betaBurst\saccade\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_saccade'];
    betaOutput = parload([outputDir loadname]);
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6);
    
    trialGO = executiveBeh.Trials.all{session}.t_GO_after_NC;
    trialNC = executiveBeh.Trials.all{session}.t_GO_after_NC-1;
    
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4) - ...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    burstFlag = []; RTslowing = [];
    
    for trlIdx = 1:length(trialGO)
        burstFlag(trlIdx,1) = double(sum((betaOutput.burstData.burstTime{trialNC(trlIdx)} < 600 &...
            betaOutput.burstData.burstTime{trialNC(trlIdx)} > 300) == 1) > 0);
        RTslowing(trlIdx,1) = sessionRT(trialNC(trlIdx))-sessionRT(trialGO(trlIdx));
    end
    
    logTable{lfpIdx} = [burstFlag, RTslowing];
    
end

rtSlow_model = [];
for lfpIdx = 1:length(corticalLFPcontacts.all)
    fprintf('Analysing LFP number %i of 509. \n',lfpIdx);
    burstFlag = logTable{lfpIdx}(:,1); RTslowing = logTable{lfpIdx}(:,2);
    regressionTable = table(burstFlag, RTslowing);
    model = fitglm(regressionTable,'burstFlag ~ RTslowing','link','logit','Distribution','binomial');
    rtSlow_model(lfpIdx,:) = [model.Rsquared.Ordinary, model.Coefficients.pValue(2)];
    rtSlow_betaValue(lfpIdx,:) = model.Coefficients.Estimate';
end

sigSlow = find(rtSlow_model(:,2) < 0.01)


for idx = 1:length(sigSlow)
    lfpIdx = sigSlow(idx);
    figure
    scatter(logTable{lfpIdx}(:,2),logTable{lfpIdx}(:,1))
    hold on
    rtSlowRange = linspace(-200,10,200);
    beta = rtSlow_betaValue(lfpIdx,:);
    plot(rtSlowRange, 1./(1+exp(-(beta(1)+beta(2)*rtSlowRange))))
    
end


%%
% Example 
contactIdx = sigSlow(1);

for lfpIdx = 1:length(corticalLFPcontacts.all)
    clear a 
    a = logTable{(lfpIdx)};
    
    [h, ~, ~, tstat_a] = ttest2(a(a(:,1) == 1,2),a(a(:,1) == 0,2));
    
    rt_ttest(lfpIdx,1) = h;
    rt_ttest(lfpIdx,2) = nanmean(a(a(:,1) == 1,2))-nanmean(a(a(:,1) == 0,2)); % +ve is greater slowing with burst
    rt_ttest(lfpIdx,3) = tstat_a.tstat; % +ve is greater slowing with burst

    
end

%%
rtAdjustment_histogram(1,1)= gramm('x',rt_ttest(:,2),...
    'color',rt_ttest(:,1));
rtAdjustment_histogram(1,1).stat_bin('edges',-100:20:100,'dodge',0,'geom','bar');
% rtAdjustment_histogram(1,1).stat_glm('fullrange',true,'disp_fit',true);
% rtAdjustment_histogram.set_('map',[colors.euler; colors.xena]);
figure('Renderer', 'painters', 'Position', [100 100 300 250]);
rtAdjustment_histogram.draw();

pContactType = [sum(rt_ttest(:,1) == 0),...
    sum(rt_ttest(:,1) == 1 & rt_ttest(:,2) > 0),...
    sum(rt_ttest(:,1) == 1 & rt_ttest(:,2) < 0)];

figure('Renderer', 'painters', 'Position', [100 100 300 250]);
explode = [1 1 1];
pie(pContactType,explode)

clear rtAdjustment_a
posIdx = find(rt_ttest(:,1) == 1);
[~,closestIndex] = sort(abs(rt_ttest(posIdx,2)-max(rt_ttest(posIdx,2))));
[~,closestIndex] = sort(abs(rt_ttest(posIdx,3)-max(rt_ttest(posIdx,3))));



lfpIdx = posIdx(closestIndex == 2) 

rtAdjustment_a(1,1)= gramm('x',logTable{(lfpIdx)}(:,1),...
    'y',logTable{(lfpIdx)}(:,2));
rtAdjustment_a(1,1).stat_summary('geom',{'bar','black_errorbar'});
rtAdjustment_a(1,1).axe_property('XLim',[-0.5 1.5]);
rtAdjustment_a(1,1).axe_property('YLim',[-200 200]);
figure('Renderer', 'painters', 'Position', [100 100 300 250]);
rtAdjustment_a.draw();


mean(logTable{(lfpIdx)}(logTable{(lfpIdx)}(:,1) == 1,2))
mean(logTable{(lfpIdx)}(logTable{(lfpIdx)}(:,1) == 0,2))







figure;
histogram(rt_ttest(rt_ttest(:,1) == 0,2),-200:10:200,'LineStyle','None')
hold on
histogram(rt_ttest(rt_ttest(:,1) == 1,2),-200:10:200,'LineStyle','None')

nSigPos = length(find(rt_ttest(:,1) == 1 & rt_ttest(:,2) > 0))

nSigPos_idx = corticalLFPcontacts.all(find(rt_ttest(:,1) == 1 & rt_ttest(:,2) > 0));

sessionLFPmap.depth(nSigPos_idx)

histogram(sessionLFPmap.depth(nSigPos_idx))




%%
for session = 1:29
    postError_slowingIdx(session, 1) =...
        nanmean(executiveBeh.RTdata.RThistory.all{session}.GO_after_NC)./...
        nanmean(executiveBeh.RTdata.RThistory.all{session}.GO_after_GO);
    
    postCancel_slowingIdx(session, 1) =...
        nanmean(executiveBeh.RTdata.RThistory.all{session}.GO_after_C)./...
        nanmean(executiveBeh.RTdata.RThistory.all{session}.GO_after_GO);
end


for session = 1:29
    trialHistoryIdx.noncanc_go{session} = executiveBeh.Trials.all{session}.t_NC_before_GO;
    trialHistoryIdx.go_go{session} = executiveBeh.Trials.all{session}.t_GO_before_GO;
end

stoppingBeta.errorSlowing.noncanc = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,trialHistoryIdx.noncanc_go, sessionLFPmap, [300 600]);
stoppingBeta.errorSlowing.nostop = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,trialHistoryIdx.go_go, sessionLFPmap, [300 600]);

for session = 1:29
    clear sessionLFPidx
    sessionLFPidx = find(sessionLFPmap.session(corticalLFPcontacts.all) == session);
    errorSlowing.pBurst_session.noncanceled(session) = ...
        mean(stoppingBeta.errorSlowing.noncanc.pTrials_burst(sessionLFPidx));
    errorSlowing.pBurst_session.nostop(session) = ...
        mean(stoppingBeta.errorSlowing.nostop.pTrials_burst(sessionLFPidx));    
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rtAdjustment_pBurst(1,1)= gramm('x',postError_slowingIdx,...
    'y',errorSlowing.pBurst_session.noncanceled,'color',...
    executiveBeh.nhpSessions.monkeyNameLabel);
rtAdjustment_pBurst(1,1).geom_point();
rtAdjustment_pBurst(1,1).stat_glm('fullrange',true,'disp_fit',true);
rtAdjustment_pBurst.set_color_options('map',[colors.euler; colors.xena]);
rtAdjustment_pBurst(1,1).axe_property('YLim',[-0.05 0.60]);
rtAdjustment_pBurst(1,1).axe_property('XLim',[0.8 1.4]);

figure('Renderer', 'painters', 'Position', [100 100 300 250]);
rtAdjustment_pBurst.draw();

