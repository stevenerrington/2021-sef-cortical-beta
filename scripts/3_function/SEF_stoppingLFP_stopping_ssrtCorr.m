dataDir = outputDir;

clear stoppingBeta

%% Get beta-burst timings

% load([outputDir 'stoppingBeta.mat']);
% Extracted by:
stoppingBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTime...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
stoppingBeta.timing.noncanceled = SEF_stoppingLFP_getAverageBurstTime...
    (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
stoppingBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTime...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);


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
            
            stoppingBeta.sessionTiming.(trialType).(varType)(session,1) = nanmean(stoppingBeta.timing.(trialType).(varType)(sessionLFPidx)); 
        end
    end
end
    
stoppingBeta.sessionTiming.canceled = struct2table(stoppingBeta.sessionTiming.canceled);
stoppingBeta.sessionTiming.noncanceled = struct2table(stoppingBeta.sessionTiming.noncanceled);
stoppingBeta.sessionTiming.nostop = struct2table(stoppingBeta.sessionTiming.nostop);

%% Find out beta-burst parameters/functional properties

canceledBurstTime = stoppingBeta.timing.canceled.mean_burstTime;
canceledBurstFreq = stoppingBeta.timing.canceled.mean_burstFreq;
canceledBurstOnset = stoppingBeta.timing.canceled.mean_burstOnset;
canceledBurstOffset = stoppingBeta.timing.canceled.mean_burstOffset;
canceledBurstDuration = stoppingBeta.timing.canceled.mean_burstDuration;
canceledBurstVolume = stoppingBeta.timing.canceled.mean_burstVolume;

noncanceledBurstTime = stoppingBeta.timing.noncanceled.mean_burstTime;
noncanceledBurstFreq = stoppingBeta.timing.noncanceled.mean_burstFreq;
noncanceledBurstOnset = stoppingBeta.timing.noncanceled.mean_burstOnset;
noncanceledBurstOffset = stoppingBeta.timing.noncanceled.mean_burstOffset;
noncanceledBurstDuration = stoppingBeta.timing.noncanceled.mean_burstDuration;
noncanceledBurstVolume = stoppingBeta.timing.noncanceled.mean_burstVolume;

nostopBurstTime = stoppingBeta.timing.nostop.mean_burstTime;
nostopBurstFreq = stoppingBeta.timing.nostop.mean_burstFreq;
nostopBurstOnset = stoppingBeta.timing.nostop.mean_burstOnset;
nostopBurstOffset = stoppingBeta.timing.nostop.mean_burstOffset;
nostopBurstDuration = stoppingBeta.timing.nostop.mean_burstDuration;
nostopBurstVolume = stoppingBeta.timing.nostop.mean_burstVolume;

monkeyLabel = sessionLFPmap.monkeyName(corticalLFPcontacts.all);

meanBurstTimeTable_old = table(canceledBurstTime, noncanceledBurstTime, nostopBurstTime,...
    canceledBurstOnset,noncanceledBurstOnset,nostopBurstOnset,...
    canceledBurstOffset, noncanceledBurstOffset, nostopBurstOffset,...
    canceledBurstDuration, noncanceledBurstDuration, nostopBurstDuration,...
    canceledBurstVolume, noncanceledBurstVolume, nostopBurstVolume,...
    canceledBurstFreq, noncanceledBurstFreq, nostopBurstFreq, monkeyLabel);

tableColumns = [1,2,3,5,6,7,9,10,11,13,14,15,17,18,19,21,22,24];
meanBurstTimeTable = ...
    [table([repmat({'Canceled'}, 509, 1); repmat({'Noncanceled'}, 509, 1); repmat({'No-stop'}, 509, 1)],'VariableName',{'TrialType'}),...
    [stoppingBeta.timing.canceled(:,tableColumns); stoppingBeta.timing.noncanceled(:,tableColumns); stoppingBeta.timing.nostop(:,tableColumns)],...
    table(repmat(monkeyLabel, 3, 1),'VariableName',{'Monkey'})];

writetable(meanBurstTimeTable,...
    'D:\projectCode\project_stoppingLFP\data\exportJASP\LFP_meanburstTime.csv','WriteRowNames',true)


%% Set up figure
clear burstParameters_stoppingBeh sessions
% close all
% Get input data:
% sessions = 1:29;
sessions = executiveBeh.nhpSessions.XSessions;

%   Mean burst time and SSRT relationship
burstParameters_stoppingBeh(1,1)=gramm('x',stoppingBeta.sessionTiming.nostop.mean_burstTime(sessions),'y',stoppingBeta.sessionTiming.nostop.mean_ssrt(sessions));
burstParameters_stoppingBeh(1,2)=gramm('x',stoppingBeta.sessionTiming.noncanceled.mean_burstTime(sessions),'y',stoppingBeta.sessionTiming.noncanceled.mean_ssrt(sessions));
burstParameters_stoppingBeh(1,3)=gramm('x',stoppingBeta.sessionTiming.canceled.mean_burstTime(sessions),'y',stoppingBeta.sessionTiming.canceled.mean_ssrt(sessions));
%   STD burst time and SSRT relationship
burstParameters_stoppingBeh(2,1)=gramm('x',stoppingBeta.sessionTiming.nostop.std_burstTime(sessions),'y',stoppingBeta.sessionTiming.nostop.std_ssrt(sessions));
burstParameters_stoppingBeh(2,2)=gramm('x',stoppingBeta.sessionTiming.noncanceled.std_burstTime(sessions),'y',stoppingBeta.sessionTiming.noncanceled.std_ssrt(sessions));
burstParameters_stoppingBeh(2,3)=gramm('x',stoppingBeta.sessionTiming.canceled.std_burstTime(sessions),'y',stoppingBeta.sessionTiming.canceled.std_ssrt(sessions));

%   p(Burst) and trigger failures
burstParameters_stoppingBeh(3,1)=gramm('x',stoppingBeta.sessionTiming.nostop.pTrials_burst(sessions),'y',stoppingBeta.sessionTiming.nostop.triggerFailures(sessions));
burstParameters_stoppingBeh(3,2)=gramm('x',stoppingBeta.sessionTiming.noncanceled.pTrials_burst(sessions),'y',stoppingBeta.sessionTiming.noncanceled.triggerFailures(sessions));
burstParameters_stoppingBeh(3,3)=gramm('x',stoppingBeta.sessionTiming.canceled.pTrials_burst(sessions),'y',stoppingBeta.sessionTiming.canceled.triggerFailures(sessions));

alphaLevel = 0.7;
%Generalized linear model fit
burstParameters_stoppingBeh(1,1).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(1,1).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(1,1).geom_abline(); burstParameters_stoppingBeh(1,1).set_color_options('map',colors.nostop);
burstParameters_stoppingBeh(1,2).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(1,2).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(1,2).geom_abline(); burstParameters_stoppingBeh(1,2).set_color_options('map',colors.noncanc);
burstParameters_stoppingBeh(1,3).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(1,3).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(1,3).geom_abline(); burstParameters_stoppingBeh(1,3).set_color_options('map',colors.canceled);

burstParameters_stoppingBeh(2,1).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(2,1).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(2,1).geom_abline(); burstParameters_stoppingBeh(2,1).set_color_options('map',colors.nostop);
burstParameters_stoppingBeh(2,2).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(2,2).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(2,2).geom_abline(); burstParameters_stoppingBeh(2,2).set_color_options('map',colors.noncanc);
burstParameters_stoppingBeh(2,3).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(2,3).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(2,3).geom_abline(); burstParameters_stoppingBeh(2,3).set_color_options('map',colors.canceled);

burstParameters_stoppingBeh(3,1).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(3,1).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(3,1).geom_abline(); burstParameters_stoppingBeh(3,1).set_color_options('map',colors.nostop);
burstParameters_stoppingBeh(3,2).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(3,2).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(3,2).geom_abline(); burstParameters_stoppingBeh(3,2).set_color_options('map',colors.noncanc);
burstParameters_stoppingBeh(3,3).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(3,3).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(3,3).geom_abline(); burstParameters_stoppingBeh(3,3).set_color_options('map',colors.canceled);

burstParameters_stoppingBeh(1,:).axe_property('XLim',[25 75]); burstParameters_stoppingBeh(1,:).axe_property('YLim',[0 150]);
burstParameters_stoppingBeh(2,:).axe_property('XLim',[10 50]); burstParameters_stoppingBeh(2,:).axe_property('YLim',[0 50]);
burstParameters_stoppingBeh(3,:).axe_property('XLim',[-0.05 0.25]); burstParameters_stoppingBeh(3,:).axe_property('YLim',[-0.05 0.25]);

burstParameters_stoppingBeh(1,:).set_names('x','Mean beta-burst time (ms)','y','Mean SSRT (ms)');
burstParameters_stoppingBeh(2,:).set_names('x','SD beta-burst time (ms)','y','SD SSRT (ms)');
burstParameters_stoppingBeh(3,:).set_names('x','p(trials with burst)','y','P(Trigger Failures)');

figure('Renderer', 'painters', 'Position', [100 100 600 600]);
burstParameters_stoppingBeh.draw();


%%
for trlIdx = 1:3
    for metricIdx = 1:3
        a_R(metricIdx,trlIdx) = burstParameters_stoppingBeh(metricIdx, trlIdx).results.stat_glm.model.Rsquared.Ordinary;
        a_P(metricIdx,trlIdx) = burstParameters_stoppingBeh(metricIdx, trlIdx).results.stat_glm.model.Coefficients.pValue(2);
        
    end
end


