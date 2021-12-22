errorWindow = [-500 100];

%% GET BBDF
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 696. \n',lfp);
    
    % Load in beta output data for session
    loadname = ['betaBurst\saccade\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_saccade'];
    betaOutput = parload([outputDir loadname])
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    % Calculate p(trials) with burst
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6)
    
    % Convolve and get density function
    SessionBDF = BetaBurstConvolver(betaOutput.burstData.burstTime);
    saccade_bbdf_noncanceled{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttx.sNC{session}, :));
    saccade_bbdf_nostop{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttx.GO{session}, :));
end

%% GET INFO TABLES
stoppingBeta.timing.noncanc = SEF_stoppingLFP_getAverageBurstTimeSaccade...
    (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap);

stoppingBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTimeSaccade...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap);


