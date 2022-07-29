% Clear the main variable
clear proactiveBeta

% Find the no-stop trials after no-stop, canceled, and non-canceled trials
% by session.
for ii = 1:29
    % No-stop after non-canceled
    ttx.GO_after_NC{ii} = executiveBeh.Trials.all{ii}.t_GO_after_NC;
    % No-stop after canceled
    ttx.GO_after_C{ii} = executiveBeh.Trials.all{ii}.t_GO_after_C;
    % No-stop after no-stop
    ttx.GO_after_GO{ii} = executiveBeh.Trials.all{ii}.t_GO_after_GO;
end

%% Get beta-burst timings
% Extracted by:
proactiveBeta.timing.bl_canceled = SEF_stoppingLFP_function_getBurst_baseline...
    (corticalLFPcontacts.all, ttx.GO_after_C, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, dataDir);
proactiveBeta.timing.bl_noncanceled = SEF_stoppingLFP_function_getBurst_baseline...
    (corticalLFPcontacts.all,ttx.GO_after_NC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, dataDir);
proactiveBeta.timing.bl_nostop = SEF_stoppingLFP_function_getBurst_baseline...
    (corticalLFPcontacts.all,ttx.GO_after_GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, dataDir);

%% Average beta-properties by session
% Define trial types
trlList = {'nostop','canceled','noncanceled'};
% Define variables to average
varList = {'mean_burstTime','std_burstTime','mean_burstOnset','mean_burstOffset',...
    'mean_burstDuration','mean_burstVolume','mean_burstFreq',...
    'modal_burstFreq','pTrials_burst','triggerFailures','mean_ssrt','std_ssrt'};
 
% For each session
for session = 1:29
    % Find contacts in the given session
    sessionLFPidx = find(sessionLFPmap.session(corticalLFPcontacts.all) == session);
    
    % For each trial type
    for trlIdx = 1:3
        trialType = trlList{trlIdx};
        
        % ...and each variable of interest
        for varIdx = 1:length(varList)
            varType = varList{varIdx};
            
            % Average, and save in a new structure (sessionTiming)
            proactiveBeta.sessionTiming.(trialType).(varType)(session,1) =...
                nanmean(proactiveBeta.timing.(['bl_' trialType]).(varType)(sessionLFPidx)); 
        end
    end
end
    
% Convert the structure into a table
proactiveBeta.sessionTiming.canceled = struct2table(proactiveBeta.sessionTiming.canceled);
proactiveBeta.sessionTiming.noncanceled = struct2table(proactiveBeta.sessionTiming.noncanceled);
proactiveBeta.sessionTiming.nostop = struct2table(proactiveBeta.sessionTiming.nostop);




%% Find out beta-burst parameters/functional properties and export to JASP
% Post-canceled trials
canceledpBurst = proactiveBeta.timing.bl_canceled.pTrials_burst;
canceledBurstTime = proactiveBeta.timing.bl_canceled.mean_burstTime;
canceledBurstFreq = proactiveBeta.timing.bl_canceled.mean_burstFreq;
canceledBurstOnset = proactiveBeta.timing.bl_canceled.mean_burstOnset;
canceledBurstOffset = proactiveBeta.timing.bl_canceled.mean_burstOffset;
canceledBurstDuration = proactiveBeta.timing.bl_canceled.mean_burstDuration;
canceledBurstVolume = proactiveBeta.timing.bl_canceled.mean_burstVolume;
% Post-non-canceled trials
noncanceledpBurst = proactiveBeta.timing.bl_noncanceled.pTrials_burst;
noncanceledBurstTime = proactiveBeta.timing.bl_noncanceled.mean_burstTime;
noncanceledBurstFreq = proactiveBeta.timing.bl_noncanceled.mean_burstFreq;
noncanceledBurstOnset = proactiveBeta.timing.bl_noncanceled.mean_burstOnset;
noncanceledBurstOffset = proactiveBeta.timing.bl_noncanceled.mean_burstOffset;
noncanceledBurstDuration = proactiveBeta.timing.bl_noncanceled.mean_burstDuration;
noncanceledBurstVolume = proactiveBeta.timing.bl_noncanceled.mean_burstVolume;
% Post-no-stop trials
nostoppBurst = proactiveBeta.timing.bl_nostop.pTrials_burst;
nostopBurstTime = proactiveBeta.timing.bl_nostop.mean_burstTime;
nostopBurstFreq = proactiveBeta.timing.bl_nostop.mean_burstFreq;
nostopBurstOnset = proactiveBeta.timing.bl_nostop.mean_burstOnset;
nostopBurstOffset = proactiveBeta.timing.bl_nostop.mean_burstOffset;
nostopBurstDuration = proactiveBeta.timing.bl_nostop.mean_burstDuration;
nostopBurstVolume = proactiveBeta.timing.bl_nostop.mean_burstVolume;

% Compose variables into a table
monkeyLabel = corticalLFPmap.monkeyName;
meanBurstTimeTable = table(canceledBurstTime, noncanceledBurstTime, nostopBurstTime,...
    canceledBurstOnset,noncanceledBurstOnset,nostopBurstOnset,...
    canceledBurstOffset, noncanceledBurstOffset, nostopBurstOffset,...
    canceledBurstDuration, noncanceledBurstDuration, nostopBurstDuration,...
    canceledBurstVolume, noncanceledBurstVolume, nostopBurstVolume,...
    canceledBurstFreq, noncanceledBurstFreq, nostopBurstFreq,...
    canceledpBurst, noncanceledpBurst, nostoppBurst, monkeyLabel);

% Export table for use in JASP
writetable(meanBurstTimeTable,...
   fullfile(rootDir,'results','jasp_tables','LFP_ProactiveMeanburstTime.csv'),'WriteRowNames',true)

%% Figure 1: Boxplot p(Burst) by trial history

clear proactiveBurst_figure % Clear figure
inContacts = 1:509; % Define contacts to use (all = 1:509)

% Input figure data to gramm
proactiveBurst_figure(1,1)=gramm('x',[repmat({'Canceled'},length(inContacts),1);
    repmat({'Non-canceled'},length(inContacts),1);...
    repmat({'No-stop'},length(inContacts),1)],...
    'y',[proactiveBeta.timing.bl_canceled.pTrials_burst(inContacts);...
    proactiveBeta.timing.bl_noncanceled.pTrials_burst(inContacts);...
    proactiveBeta.timing.bl_nostop.pTrials_burst(inContacts)],'color',...
    [repmat({'Canceled'},length(inContacts),1);
    repmat({'Non-canceled'},length(inContacts),1);...
    repmat({'No-stop'},length(inContacts),1)]);

% Setup figure: boxplot with points
proactiveBurst_figure(1,1).stat_boxplot();
proactiveBurst_figure(1,1).geom_point('alpha',0.1);
proactiveBurst_figure(1,1).no_legend();
proactiveBurst_figure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

% Generate figure
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
