%% Extract beta-bursts and BBDF for all relevant trial types
tic
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    % Load in beta output data for session
    loadname_fixate = ['betaBurst\fixate\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_fixate'];
    loadname_target = ['betaBurst\target\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target'];
    loadname_saccade = ['betaBurst\saccade\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_saccade'];
    loadname_ssd = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    loadname_tone = ['betaBurst\tone\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_tone'];
    betaOutput_fixate = parload([outputDir loadname_fixate]);
    betaOutput_target = parload([outputDir loadname_target]);
    betaOutput_saccade = parload([outputDir loadname_saccade]);
    betaOutput_ssd = parload([outputDir loadname_ssd]);
    betaOutput_tone = parload([outputDir loadname_tone]);
        
    % Extract Beta-Bursts at given threshold
    [betaOutput_fixate] = thresholdBursts(betaOutput_fixate.betaOutput, sessionThreshold(session));
    [betaOutput_target] = thresholdBursts(betaOutput_target.betaOutput, sessionThreshold(session));
    [betaOutput_saccade] = thresholdBursts(betaOutput_saccade.betaOutput, sessionThreshold(session));
    [betaOutput_ssd] = thresholdBursts(betaOutput_ssd.betaOutput, sessionThreshold(session));
    [betaOutput_tone] = thresholdBursts(betaOutput_tone.betaOutput, sessionThreshold(session));
    
    % Convolve and get density function
    SessionBDF_fixate = BetaBurstConvolver(betaOutput_fixate.burstData.burstTime);
    SessionBDF_target = BetaBurstConvolver(betaOutput_target.burstData.burstTime);
    SessionBDF_saccade = BetaBurstConvolver(betaOutput_saccade.burstData.burstTime);
    SessionBDF_ssd = BetaBurstConvolver(betaOutput_ssd.burstData.burstTime);
    SessionBDF_tone = BetaBurstConvolver(betaOutput_tone.burstData.burstTime);
    
    bbdf = struct();
    bbdf.fixate = SessionBDF_fixate;
    bbdf.target = SessionBDF_target;
    bbdf.saccade = SessionBDF_saccade;
    bbdf.ssd = SessionBDF_ssd;
    bbdf.tone = SessionBDF_tone;
    
    parsave_bbdf(['D:\projectCode\project_stoppingLFP\data\bbdf\bbdf_' int2str(lfpIdx)], bbdf)
    
end
toc