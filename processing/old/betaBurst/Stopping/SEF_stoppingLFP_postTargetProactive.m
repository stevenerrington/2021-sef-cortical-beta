burstWindow = [-200 0];

%% GET BBDF
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    monkey = {executiveBeh.nhpSessions.monkeyNameLabel{session}};
    
    
    % Load in beta output data for session
    loadname = ['betaBurst\target\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target'];
    betaOutput = parload([outputDir loadname])
    
    % Get behavioral information  
    trials = [];
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    sessionRT = [];
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4)-...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    % Calculate p(trials) with burst
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6)
    
    betaBurst_target = [];
    for trl = 1:size(betaOutput.burstData.burstTime,1)
        
        betaBurst_target(trl,1) = sum(betaOutput.burstData.burstTime{trl} > burstWindow(1) &...
            betaOutput.burstData.burstTime{trl} < burstWindow(2)) > 0;
        
    end
    
    burst_RT_noncanc {lfpIdx} = table(betaBurst_target(trials.noncanceled),...
        sessionRT(trials.noncanceled), repmat('NC',length(sessionRT(trials.noncanceled)),1),...
        repmat(monkey,length(sessionRT(trials.noncanceled)),1));
    burst_RT_nostop {lfpIdx} = table(betaBurst_target(trials.nostop), sessionRT(trials.nostop),...
        repmat('NS',length(sessionRT(trials.nostop)),1),...
        repmat(monkey,length(sessionRT(trials.nostop)),1));
    
    
end

%% Collapse 
burst_RT_all = table(); burst_RT_Eu = []; burst_RT_X = [];

for lfpIdx = 1:length(corticalLFPcontacts.all)   
    burst_RT_all = [burst_RT_all; burst_RT_noncanc{lfpIdx}; burst_RT_nostop{lfpIdx}];
end

burst_RT_all.Properties.VariableNames = {'burstFlag','RT','TrialType','Monkey'};
%% Output to JASP
writetable(burst_RT_all,...
'D:\projectCode\project_stoppingLFP\data\exportJASP\LFP_betaBurst_target_RT.csv','WriteRowNames',true)

%% Figure




