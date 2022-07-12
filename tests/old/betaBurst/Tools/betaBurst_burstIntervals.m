% Inter-burst interval

parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 696. \n',lfp);
    
    % Load in beta output data for session
    loadname = ['betaBurst\target\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target'];
    betaOutput = parload([outputDir loadname]);
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6);
    
    burstITI = BetaBurst_Intervals (betaOutput.burstData.burstTime)

end