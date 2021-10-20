errorWindow = [300 600];

%% GET BBDF
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 696. \n',lfp);
    
    % Load in beta output data for session
    loadname = ['betaBurst\saccade\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_saccade'];
    betaOutput = parload([outputDir loadname]);
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    trials = [];
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
 
    % Calculate p(trials) with burst
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6);
    
    % Convolve and get density function
    SessionBDF = BetaBurstConvolver(betaOutput.burstData.burstTime);   
        
    errorWindow = [1000:2500];
    
    a = {}; b = {};
    for trialIdx = 1:length(trials.noncanceled)
        trial = trials.noncanceled(trialIdx);
        a{trialIdx,1} = SessionBDF(trial, errorWindow);
    end
 
    for trialIdx = 1:length(trials.nostop)
        trial = trials.nostop(trialIdx);
        b{trialIdx,1} = SessionBDF(trial, errorWindow);
    end
    
    time = errorWindow-1000;
    error_figure=gramm('x',time,...
        'y',[a;b],...
        'color',[repmat({'No-stop'},length(trials.noncanceled),1);...
        repmat({'Non-canceled'},length(trials.nostop),1)]);
    error_figure.stat_summary();
    error_figure.draw(); close all

    % Find difference time
    input1 = error_figure.results.stat_summary(2).yci;  % Non-canc
    input2 = error_figure.results.stat_summary(1).yci;  % No-stop
    
    ntimeBin = length(input1)
    binaryDiff = [];
    for timeBinIdx = 1:ntimeBin
        binaryDiff(1,timeBinIdx) = input1(2,timeBinIdx) < input2(1,timeBinIdx);
    end
    
    [start, len, k1] = ZeroOnesCount(binaryDiff);
    sepIdx = find(len(1:k1) > 50);
    
    if length(sepIdx) > 1
        sepIdx = sepIdx(1);
    end
    
    if isempty(sepIdx)
        sepStart(lfpIdx,1) = NaN;
        sepEnd(lfpIdx,1) = NaN;        
    else
        sepStart(lfpIdx,1) = start(sepIdx);
        sepEnd(lfpIdx,1) = start(sepIdx)+len(sepIdx);
    end
    
end


lfpID = corticalLFPcontacts.all;
errorFlag = ~isnan(sepStart) & sepStart < 601;
errorStart = sepStart;
errorEnd = sepEnd;
errorDuration = sepEnd-sepStart;
error_pBurst = errorBeta.timing.noncanc.pTrials_burst;
error_burstMeanTime = errorBeta.timing.noncanc.mean_burstTime;

errorBBDFtable = table(lfpID,errorFlag,errorStart,errorEnd,errorDuration,...
    error_pBurst, error_burstMeanTime);

%%
sessionLFPmap_cortical = sessionLFPmap(sessionLFPmap.cortexFlag == 1,:);

mean(errorBeta.timing.noncanc.pTrials_burst)
sem(errorBeta.timing.noncanc.pTrials_burst)
mean(errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.monkeyFlag == 0))
sem(errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.monkeyFlag == 0))
mean(errorBeta.timing.nostop.pTrials_burst(sessionLFPmap_cortical.monkeyFlag == 0))
sem(errorBeta.timing.nostop.pTrials_burst(sessionLFPmap_cortical.monkeyFlag == 0))

mean(errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.monkeyFlag == 1))
sem(errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.monkeyFlag == 1))
mean(errorBeta.timing.nostop.pTrials_burst(sessionLFPmap_cortical.monkeyFlag == 1))
sem(errorBeta.timing.nostop.pTrials_burst(sessionLFPmap_cortical.monkeyFlag == 1))

data = [];label = [];
for site = [2 3 5] % Eu: 1 4; X: 2 3 5
    pBurst_site(1,site) = mean(errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.site == site));
    pBurst_site(2,site) = sem(errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.site == site));
    
    label = [label;...
        repmat({['Site ' int2str(site)]},...
        length(errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.site == site)),1)];
    data = [data; errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.site == site)];
end

[p,tbl,stats] = anova1(data,label);
c = multcompare(stats);
%% 
errorLFPcontacts = find(errorBBDFtable.errorFlag);
nErrorLFP = length(errorLFPcontacts);

ErrorLFP_EuIdx = errorLFPcontacts(sessionLFPmap_cortical.monkeyFlag(errorLFPcontacts) == 0);
ErrorLFP_XIdx = errorLFPcontacts(sessionLFPmap_cortical.monkeyFlag(errorLFPcontacts) == 1);

mean(errorBeta.timing.nostop.pTrials_burst)
sem(errorBeta.timing.nostop.pTrials_burst)

nErrorLFP_Eu = length(ErrorLFP_EuIdx)
nErrorLFP_X = length(ErrorLFP_XIdx)

mean(errorBBDFtable.errorStart(errorLFPcontacts))
sem(errorBBDFtable.errorStart(errorLFPcontacts))

mean(errorBBDFtable.errorStart(ErrorLFP_EuIdx))
sem(errorBBDFtable.errorStart(ErrorLFP_EuIdx))

mean(errorBBDFtable.errorStart(ErrorLFP_XIdx))
sem(errorBBDFtable.errorStart(ErrorLFP_XIdx))

mean(errorBBDFtable.errorEnd(ErrorLFP_EuIdx))
sem(errorBBDFtable.errorEnd(ErrorLFP_EuIdx))

mean(errorBBDFtable.errorEnd(ErrorLFP_XIdx))
sem(errorBBDFtable.errorEnd(ErrorLFP_XIdx))

mean(errorBBDFtable.errorDuration(ErrorLFP_EuIdx))
sem(errorBBDFtable.errorDuration(ErrorLFP_EuIdx))

mean(errorBBDFtable.errorDuration(ErrorLFP_XIdx))
sem(errorBBDFtable.errorDuration(ErrorLFP_XIdx))

%%
figure;
subplot(3,1,1)
histogram(errorBBDFtable.errorStart(errorBBDFtable.errorFlag == 1))
subplot(3,1,2)
histogram(errorBBDFtable.errorEnd(errorBBDFtable.errorFlag == 1))
subplot(3,1,3)
histogram(errorBBDFtable.errorDuration(errorBBDFtable.errorFlag == 1))

errorBBDFtableEu = errorBBDFtable(corticalLFPcontacts.subset.eu,:);
errorBBDFtableX = errorBBDFtable(corticalLFPcontacts.subset.x,:);

figure('Renderer', 'painters', 'Position', [100 100 350 350]);
scatter(errorBBDFtableEu.errorStart(errorBBDFtableEu.errorFlag == 1),...
    errorBBDFtableEu.errorEnd(errorBBDFtableEu.errorFlag == 1),'s')
hold on;
scatter(errorBBDFtableX.errorStart(errorBBDFtableX.errorFlag == 1),...
    errorBBDFtableX.errorEnd(errorBBDFtableX.errorFlag == 1),'^')
hold on;
plot([0:1:1600],[0:1:1600],'k')

xlim([0 1000]); ylim([0 1400])

vline(600,'k--');hline(600,'k--')




errorBBDFtable.monkey = monkeyLabel

errorBBDFtable_errorPos = errorBBDFtable(errorBBDFtable.errorFlag == 1, :)

writetable(errorBBDFtable_errorPos,...
'D:\projectCode\project_stoppingLFP\data\exportJASP\LFP_errorBBDFtable_errorPos.csv','WriteRowNames',true)







%% LAMINAR STUFF

errorLaminarAnalysis.upper.pBurst = errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.depth <= 8)
errorLaminarAnalysis.lower.pBurst = errorBeta.timing.noncanc.pTrials_burst(sessionLFPmap_cortical.depth > 8)

ttest2(errorLaminarAnalysis.upper.pBurst,errorLaminarAnalysis.lower.pBurst)
mean(errorLaminarAnalysis.upper.pBurst)
sem(errorLaminarAnalysis.upper.pBurst)
mean(errorLaminarAnalysis.lower.pBurst)
sem(errorLaminarAnalysis.lower.pBurst)

errorLaminarAnalysis.counts.EuDepths = sessionLFPmap_cortical.depth(ErrorLFP_EuIdx);
errorLaminarAnalysis.counts.XDepths = sessionLFPmap_cortical.depth(ErrorLFP_XIdx);


errorLaminarAnalysis.counts.EuLayerCounts = ...
    [sum(ismember(errorLaminarAnalysis.counts.EuDepths, 1:4));...
    sum(ismember(errorLaminarAnalysis.counts.EuDepths, 5:8));...
    sum(ismember(errorLaminarAnalysis.counts.EuDepths, 9:12));...
    sum(ismember(errorLaminarAnalysis.counts.EuDepths, 13:19))]

errorLaminarAnalysis.counts.XLayerCounts = ...
    [sum(ismember(errorLaminarAnalysis.counts.XDepths, 1:4));...
    sum(ismember(errorLaminarAnalysis.counts.XDepths, 5:8));...
    sum(ismember(errorLaminarAnalysis.counts.XDepths, 9:12));...
    sum(ismember(errorLaminarAnalysis.counts.XDepths, 13:19))]

