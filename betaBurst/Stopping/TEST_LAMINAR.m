pBurst_depth = nan(19, 15);
power_depth = nan(19, 15);

perpSessions = 14:29;
for sessionIdx = 1:length(perpSessions)
    session = perpSessions(sessionIdx);
    
    clear laminarLFPidx
    laminarLFPidx = find(sessionLFPmap.session == session & sessionLFPmap.laminarFlag == 1 & sessionLFPmap.cortexFlag);
    
    parfor lfpIdx = 1:length(laminarLFPidx)
        lfp = laminarLFPidx(lfpIdx);
        loadname = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
        betaOutput = parload([outputDir loadname]);
        [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6);
        
        trials = [];
        trials.canceled = executiveBeh.ttx_canc{session};
        trials.noncanceled = executiveBeh.ttx.sNC{session};
        trials.nostop = executiveBeh.ttx.GO{session};
        ssrt = bayesianSSRT.ssrt_mean(session);
        
        [pTrl_burst] = ssdBurstCount_LFP(betaOutput, ssrt, trials, session, executiveBeh);
        
        pBurst_depth(lfpIdx,sessionIdx) = pTrl_burst.ssd.canceled;
        power_depth(lfpIdx,sessionIdx) = betaOutput.medianLFPpower;
        
    end
    
end


euPerpIdx = 1:6;
xenaPerpIdx = 7:16;

clear normalisedPower normalisedBursts rawBursts
normalisedPower = power_depth./nanmax(power_depth);
normalisedBursts = pBurst_depth./nanmax(pBurst_depth);
rawBursts = pBurst_depth;

laminarAlignment.list = {[1:4],[5:8],[9:12],[13:18]};
laminarAlignment.l2 = 1:4;
laminarAlignment.l3 = 5:8;
laminarAlignment.l5 = 9:12;
laminarAlignment.l6 = 13:18;
laminarAlignment.labels = {'L2','L3','L5','L6'};


clear depthBurst depthPower label
count = 0;
for sessionIdx = 1:16
    for depthGroupIdx = 1:4
        count = count + 1;
        depthPower(count,1) = nanmean(normalisedPower...
            (laminarAlignment.list{depthGroupIdx},sessionIdx));
        
        depthBurst(count,1) = nanmean(rawBursts...
            (laminarAlignment.list{depthGroupIdx},sessionIdx));
        
        depthLabel{count,1} = laminarAlignment.labels{depthGroupIdx};
        
        if ismember(sessionIdx,euPerpIdx)
            monkeyLabel{count,1} = 'Monkey Eu';
        else
            monkeyLabel{count,1} = 'Monkey X';
        end
        
    end
end




clear g
%Averages with confidence interval
g(1,1)=gramm('x',depthLabel,'y',depthPower)%,'color',monkeyLabel);
g(1,2)=gramm('x',depthLabel,'y',depthPower,'color',monkeyLabel);
g(1,1).stat_summary('geom',{'bar','black_errorbar'});
g(1,2).stat_summary('geom',{'bar','black_errorbar'});
% g(1,1).stat_boxplot();
% g(1,2).stat_boxplot();
g.coord_flip();
% g(1,1).axe_property('YLim',[0.25 1]);
% g(1,2).axe_property('YLim',[0.25 1]);
figure('Position',[100 100 600 300]);
g.draw();












%%

timing_upperLayer = stoppingBeta.timing.canceled.mean_burstTime(corticalLFPcontacts.subset.laminar.upper);
timing_lowerLayer = stoppingBeta.timing.canceled.mean_burstTime(corticalLFPcontacts.subset.laminar.lower);

sessionLFPmapCortical = sessionLFPmap(sessionLFPmap.cortexFlag == 1,:);

timingData = [timing_upperLayer; timing_lowerLayer];
layerLabel = [repmat({'Upper'},length(timing_upperLayer),1);...
    repmat({'Lower'},length(timing_lowerLayer),1)];
monkeyLabel = [sessionLFPmapCortical.monkeyName(corticalLFPcontacts.subset.laminar.upper);...
    sessionLFPmapCortical.monkeyName(corticalLFPcontacts.subset.laminar.lower)];


clear g
%Averages with confidence interval
g(1,1)=gramm('x',layerLabel,'y',timingData);
g(2,1)=gramm('x',layerLabel,'y',timingData,'color',monkeyLabel);

g(1,1).stat_summary('geom',{'bar','black_errorbar'});
g(2,1).stat_summary('geom',{'bar','black_errorbar'});
g.coord_flip();
g(1,1).axe_property('YLim',[25 60]);
g(2,1).axe_property('YLim',[25 60]);
figure('Position',[100 100 300 500]);
g.draw();




length(timing_upperLayer)
length(timing_lowerLayer)

clear group group1
group = sessionLFPmapCortical.monkeyFlag(corticalLFPcontacts.subset.laminar.upper) == 1;
group1 = sessionLFPmapCortical.monkeyFlag(corticalLFPcontacts.subset.laminar.lower) == 1;
[h,p,~,stats] = ttest2(timing_upperLayer(group),timing_lowerLayer(group1));


%%
   test_a = bbdf_canceled(corticalLFPcontacts.subset.laminar.upper)
   test_b = bbdf_noncanceled(corticalLFPcontacts.subset.laminar.upper)
   test_c = bbdf_nostop(corticalLFPcontacts.subset.laminar.upper)

 
   test2_a = bbdf_canceled(corticalLFPcontacts.subset.laminar.lower)
   test2_b = bbdf_noncanceled(cort
   icalLFPcontacts.subset.laminar.lower)
   test2_c = bbdf_nostop(corticalLFPcontacts.subset.laminar.lower)  



% Concatenate across all sessions
clear inputContacts

% Set up figures
clear testfigure
time = [-1000:2000];

% % BBDF
testfigure(1,1)=gramm('x',time,'y',[bbdf_canceled(corticalLFPcontacts.subset.laminar.upper);...
    bbdf_nostop(corticalLFPcontacts.subset.laminar.upper);...
    bbdf_noncanceled(corticalLFPcontacts.subset.laminar.upper)],...
    'color',[repmat({'Canceled'},length(corticalLFPcontacts.subset.laminar.upper),1);...
    repmat({'No-stop'},length(corticalLFPcontacts.subset.laminar.upper),1);...
    repmat({'Non-canceled'},length(corticalLFPcontacts.subset.laminar.upper),1)]); 

testfigure(2,1)=gramm('x',time,'y',[bbdf_canceled(corticalLFPcontacts.subset.laminar.lower);...
    bbdf_nostop(corticalLFPcontacts.subset.laminar.lower);...
    bbdf_noncanceled(corticalLFPcontacts.subset.laminar.lower)],...
    'color',[repmat({'Canceled'},length(corticalLFPcontacts.subset.laminar.lower),1);...
    repmat({'No-stop'},length(corticalLFPcontacts.subset.laminar.lower),1);...
    repmat({'Non-canceled'},length(corticalLFPcontacts.subset.laminar.lower),1)]); 


testfigure(1,1).stat_summary(); testfigure(2,1).stat_summary();
testfigure(1,1).axe_property('XLim',[-250 500]); testfigure(2,1).axe_property('XLim',[-250 500]); 
testfigure(1,1).geom_vline('xintercept',0,'style','k-'); testfigure(2,1).geom_vline('xintercept',0,'style','k-')
testfigure(1,1).geom_vline('xintercept',mean(bayesianSSRT.ssrt_mean),'style','k--')
testfigure(2,1).geom_vline('xintercept',mean(bayesianSSRT.ssrt_mean),'style','k--')
testfigure(1,1).axe_property('YLim',[0.0005 0.0015]); testfigure(2,1).axe_property('YLim',[0.0005 0.0015]);
testfigure(1,1).no_legend();testfigure(2,1).no_legend();


testfigure.set_names('y','');
testfigure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 350 600]);
testfigure.draw();


%%


pBursts_laminar.upper.canc = stoppingBeta.timing.canceled.pTrials_burst(corticalLFPcontacts.subset.laminar.upper);
pBursts_laminar.upper.noncanc = stoppingBeta.timing.noncanceled.pTrials_burst(corticalLFPcontacts.subset.laminar.upper);
pBursts_laminar.upper.nostop = stoppingBeta.timing.nostop.pTrials_burst(corticalLFPcontacts.subset.laminar.upper);

pBursts_laminar.lower.canc = stoppingBeta.timing.canceled.pTrials_burst(corticalLFPcontacts.subset.laminar.lower);
pBursts_laminar.lower.noncanc = stoppingBeta.timing.noncanceled.pTrials_burst(corticalLFPcontacts.subset.laminar.lower);
pBursts_laminar.lower.nostop = stoppingBeta.timing.nostop.pTrials_burst(corticalLFPcontacts.subset.laminar.lower);


time = [-1000:2000];

clear testfigure inputLFP groupLabels epochLabels burstData

% Boxplot
groupLabels_upper = [repmat({'No-stop'},length(pBursts_laminar.upper.nostop),1);...
    repmat({'Non-canceled'},length(pBursts_laminar.upper.noncanc),1);...
    repmat({'Canceled'},length(pBursts_laminar.upper.canc),1)];
groupLabels_lower = [repmat({'No-stop'},length(pBursts_laminar.lower.nostop),1);...
    repmat({'Non-canceled'},length(pBursts_laminar.lower.noncanc),1);...
    repmat({'Canceled'},length(pBursts_laminar.lower.canc),1)];

burstData_upper = [pBursts_laminar.upper.nostop;...
    pBursts_laminar.upper.noncanc;...
    pBursts_laminar.upper.canc];
burstData_lower = [pBursts_laminar.lower.nostop;...
    pBursts_laminar.lower.noncanc;...
    pBursts_laminar.lower.canc];

testfigure(1,1)= gramm('x',groupLabels_upper,'y',burstData_upper,'color',groupLabels_upper);
testfigure(2,1)= gramm('x',groupLabels_lower,'y',burstData_lower,'color',groupLabels_lower);
testfigure(1,1).stat_boxplot();testfigure(2,1).stat_boxplot();
% testfigure(1,1).geom_jitter('alpha',0.1,'dodge',0.75);
testfigure(1,1).no_legend(); testfigure(2,1).no_legend(); 
testfigure(1,1).axe_property('YLim',[0 0.2]);testfigure(2,1).axe_property('YLim',[0 0.2]);


% Figure parameters & settings
testfigure.set_names('y','');
testfigure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Position',[100 100 350 350]);
testfigure.draw();






