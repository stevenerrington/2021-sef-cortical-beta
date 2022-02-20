dataDir = 'D:\projectCode\project_stoppingLFP\data\monkeyLFP\';

clear proactiveBeta

%% Get beta-burst timings

for ii = 1:29
    ttx.GO_after_NC{ii} = executiveBeh.Trials.all{ii}.t_GO_after_NC;
    ttx.GO_after_C{ii} = executiveBeh.Trials.all{ii}.t_GO_after_C;
    ttx.GO_after_GO{ii} = executiveBeh.Trials.all{ii}.t_GO_after_GO;
end

% Extracted by:
proactiveBeta.timing.bl_canceled = SEF_stoppingLFP_getAverageBurstTimeTarget...
    (corticalLFPcontacts.all, ttx.GO_after_C, bayesianSSRT, sessionLFPmap);
proactiveBeta.timing.bl_noncanceled = SEF_stoppingLFP_getAverageBurstTimeTarget...
    (corticalLFPcontacts.all,ttx.GO_after_NC, bayesianSSRT, sessionLFPmap);
proactiveBeta.timing.bl_nostop = SEF_stoppingLFP_getAverageBurstTimeTarget...
    (corticalLFPcontacts.all,ttx.GO_after_GO, bayesianSSRT, sessionLFPmap);

%% Get average by session
trlList = {'nostop','canceled','noncanceled'};
varList = {'mean_burstTime','std_burstTime','mean_burstOnset','mean_burstOffset',...
    'mean_burstDuration','mean_burstVolume','mean_burstFreq',...
    'modal_burstFreq','pTrials_burst','triggerFailures','mean_ssrt','std_ssrt'};
 
for session = 1:29
    sessionLFPidx = find(sessionLFPmap.session(corticalLFPcontacts.all) == session);
    
    for trlIdx = 1:3
        trialType = trlList{trlIdx};
        for varIdx = 1:length(varList)
            varType = varList{varIdx};
            
            proactiveBeta.sessionTiming.(trialType).(varType)(session,1) = nanmean(proactiveBeta.timing.(['bl_' trialType]).(varType)(sessionLFPidx)); 
        end
    end
end
    
proactiveBeta.sessionTiming.canceled = struct2table(proactiveBeta.sessionTiming.canceled);
proactiveBeta.sessionTiming.noncanceled = struct2table(proactiveBeta.sessionTiming.noncanceled);
proactiveBeta.sessionTiming.nostop = struct2table(proactiveBeta.sessionTiming.nostop);

%% Find out beta-burst parameters/functional properties and export to JASP

canceledpBurst = proactiveBeta.sessionTiming.canceled.pTrials_burst;
canceledBurstTime = proactiveBeta.sessionTiming.canceled.mean_burstTime;
canceledBurstFreq = proactiveBeta.sessionTiming.canceled.mean_burstFreq;
canceledBurstOnset = proactiveBeta.sessionTiming.canceled.mean_burstOnset;
canceledBurstOffset = proactiveBeta.sessionTiming.canceled.mean_burstOffset;
canceledBurstDuration = proactiveBeta.sessionTiming.canceled.mean_burstDuration;
canceledBurstVolume = proactiveBeta.sessionTiming.canceled.mean_burstVolume;

noncanceledpBurst = proactiveBeta.sessionTiming.noncanceled.pTrials_burst;
noncanceledBurstTime = proactiveBeta.sessionTiming.noncanceled.mean_burstTime;
noncanceledBurstFreq = proactiveBeta.sessionTiming.noncanceled.mean_burstFreq;
noncanceledBurstOnset = proactiveBeta.sessionTiming.noncanceled.mean_burstOnset;
noncanceledBurstOffset = proactiveBeta.sessionTiming.noncanceled.mean_burstOffset;
noncanceledBurstDuration = proactiveBeta.sessionTiming.noncanceled.mean_burstDuration;
noncanceledBurstVolume = proactiveBeta.sessionTiming.noncanceled.mean_burstVolume;

nostoppBurst = proactiveBeta.sessionTiming.nostop.pTrials_burst;
nostopBurstTime = proactiveBeta.sessionTiming.nostop.mean_burstTime;
nostopBurstFreq = proactiveBeta.sessionTiming.nostop.mean_burstFreq;
nostopBurstOnset = proactiveBeta.sessionTiming.nostop.mean_burstOnset;
nostopBurstOffset = proactiveBeta.sessionTiming.nostop.mean_burstOffset;
nostopBurstDuration = proactiveBeta.sessionTiming.nostop.mean_burstDuration;
nostopBurstVolume = proactiveBeta.sessionTiming.nostop.mean_burstVolume;

monkeyLabel = executiveBeh.nhpSessions.monkeyNameLabel;

meanBurstTimeTable = table(canceledBurstTime, noncanceledBurstTime, nostopBurstTime,...
    canceledBurstOnset,noncanceledBurstOnset,nostopBurstOnset,...
    canceledBurstOffset, noncanceledBurstOffset, nostopBurstOffset,...
    canceledBurstDuration, noncanceledBurstDuration, nostopBurstDuration,...
    canceledBurstVolume, noncanceledBurstVolume, nostopBurstVolume,...
    canceledBurstFreq, noncanceledBurstFreq, nostopBurstFreq,...
    canceledpBurst, noncanceledpBurst, nostoppBurst, monkeyLabel);

writetable(meanBurstTimeTable,...
    'D:\projectCode\project_stoppingLFP\data\exportJASP\LFP_ProactiveMeanburstTime.csv','WriteRowNames',true)

%% Produce figure
clear g
inContacts = 1:509;
proactiveBurst_figure(1,1)=gramm('x',[repmat({'Canceled'},length(inContacts),1);
    repmat({'Non-canceled'},length(inContacts),1);...
    repmat({'No-stop'},length(inContacts),1)],...
    'y',[proactiveBeta.timing.bl_canceled.pTrials_burst(inContacts);...
    proactiveBeta.timing.bl_noncanceled.pTrials_burst(inContacts);...
    proactiveBeta.timing.bl_nostop.pTrials_burst(inContacts)],'color',...
    [repmat({'Canceled'},length(inContacts),1);
    repmat({'Non-canceled'},length(inContacts),1);...
    repmat({'No-stop'},length(inContacts),1)]);

proactiveBurst_figure(1,1).stat_boxplot();
proactiveBurst_figure(1,1).geom_point('alpha',0.1);
proactiveBurst_figure(1,1).no_legend();
proactiveBurst_figure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 300 300]);
proactiveBurst_figure.draw();


%% RT
for session = 1:29
    RTdist = [];
    RTdist = executiveBeh.TrialEventTimes_Overall{session}(:,4)-...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    postC_RT(session,1)  = nanmean(RTdist(ttx.GO_after_C{session}));
    postNC_RT(session,1)  = nanmean(RTdist(ttx.GO_after_NC{session}));
    postNS_RT(session,1)  = nanmean(RTdist(ttx.GO_after_GO{session}));
    
    
    postC_indexRT(session,1) =  postC_RT(session,1)/postNS_RT(session,1);
    postNC_indexRT(session,1) =  postNC_RT(session,1)/postNS_RT(session,1);
    
    
    postC_indexBurst(session,1) =  ...
        proactiveBeta.sessionTiming.canceled.pTrials_burst(session,1)/...
        proactiveBeta.sessionTiming.nostop.pTrials_burst(session,1);
    postNC_indexBurst(session,1) =  ...
        proactiveBeta.sessionTiming.noncanceled.pTrials_burst(session,1)/...
        proactiveBeta.sessionTiming.nostop.pTrials_burst(session,1);
    
end
clear pBurst_RT_proactive
pBurst_RT_proactive = [postC_RT,proactiveBeta.sessionTiming.canceled.pTrials_burst;...
    postNC_RT,proactiveBeta.sessionTiming.noncanceled.pTrials_burst;...
    postNS_RT,proactiveBeta.sessionTiming.nostop.pTrials_burst];

labels = [repmat({'Canceled'},29,1);...
    repmat({'Non-canceled'},29,1);...
    repmat({'No-stop'},29,1)];

% Example session, pNC - bursts
clear a

a(1,1)=gramm('x',pBurst_RT_proactive(:,2),...
    'y',pBurst_RT_proactive(:,1),'color',labels);

a(1,2)=gramm('x',pBurst_RT_proactive(:,2),...
    'y',pBurst_RT_proactive(:,1));
a(1,1).geom_point
a(1,2).stat_glm

a(1,1).no_legend
a.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
% Generate figure
figure('Position',[100 100 400 200]);
a.draw();

a(1, 2).results.stat_glm.model.Rsquared.Ordinary  


%% CUTTINGS

% % load([outputDir 'stoppingBeta.mat']);
% proactiveBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTime...
%     (corticalLFPcontacts.all, ttx.GO_after_C, bayesianSSRT, sessionLFPmap);
% proactiveBeta.timing.noncanceled = SEF_stoppingLFP_getAverageBurstTime...
%     (corticalLFPcontacts.all,ttx.GO_after_NC, bayesianSSRT, sessionLFPmap);
% proactiveBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTime...
%     (corticalLFPcontacts.all,ttx.GO_after_GO, bayesianSSRT, sessionLFPmap);