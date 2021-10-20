%% Calculate proportion of trials with burst (-200-SSRT to -200 ms pre-target)

parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 509. \n',lfpIdx);
    
    % Load in beta output data for session
    loadname_saccade = ['betaBurst\saccade\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_saccade'];
    betaOutput_saccade = parload([outputDir loadname_saccade]);
    
    % Calculate p(trials) with burst
    [betaOutput_saccade] = thresholdBursts(betaOutput_saccade.betaOutput, betaOutput_saccade.betaOutput.medianLFPpower*6)
    
    RT = []; RT = executiveBeh.TrialEventTimes_Overall{session}(:,4) - ...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    nTrls = size(betaOutput_saccade.burstData,1);
    
    validBurst =[];
    
    for trlIdx = 1:nTrls
        validBurst(trlIdx,1) = sum(betaOutput_saccade.burstData.burstOffset{trlIdx} < 0);
    end
   
    
    rt_burst_coincidence{lfpIdx} = [validBurst,RT];
    
end
