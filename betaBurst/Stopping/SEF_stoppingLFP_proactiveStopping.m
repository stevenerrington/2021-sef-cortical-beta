%% Calculate proportion of trials with burst
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Block Method
   nBlocks = max(executiveBeh.SessionInfo{session}.Block_number);
    
    for blockIdx = 1:nBlocks
        blockTrls = find(executiveBeh.SessionInfo{session}.Block_number == blockIdx);

        % Get proportion of STOP trials
        nStop_comp = find(contains(executiveBeh.SessionInfo{session}.Trial_type(blockTrls),'STOP'));
        nStop_experienced = find(~contains(executiveBeh.SessionInfo{session}.Trial_outcome(blockTrls),'broke fixation'));       
        
        pSTOP_block_comp{lfpIdx}(blockIdx,1) = length(nStop_comp)/length(blockTrls);
        pSTOP_block_experienced{lfpIdx}(blockIdx,1) = length(nStop_experienced)/length(blockTrls);

        % Get proportion of beta-bursts
        [pTrl_burst] = genericBurstCount_LFP(betaOutput, blockTrls);
        pBurst_block_compBaseline{lfpIdx}(blockIdx,1) = pTrl_burst.baseline;
        pBurst_block_compTarget{lfpIdx}(blockIdx,1) = pTrl_burst.target;
       
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % N back method

    trlStep = 10; trlWindow = 50; nTrials = size(executiveBeh.SessionInfo{session}.Block_number,1);

    trlEdges =  trlWindow:trlStep:nTrials;
     
     for trlIdx = 1:length(trlEdges)
         windowTrls = trlEdges(trlIdx)-trlWindow+1:trlEdges(trlIdx);
         
         % Get proportion of STOP trials
         nStop_comp = find(contains(executiveBeh.SessionInfo{session}.Trial_type(windowTrls),'STOP'));
         nStop_experienced = find(~contains(executiveBeh.SessionInfo{session}.Trial_outcome(windowTrls),'broke fixation'));
         
         pSTOP_nTrlBack_comp{lfpIdx}(trlIdx,1) = length(nStop_comp)/length(windowTrls);
         pSTOP_nTrlBack_experienced{lfpIdx}(trlIdx,1) = length(nStop_experienced)/length(windowTrls);
         
         % Get proportion of beta-bursts
         [pTrl_burst] = genericBurstCount_LFP(betaOutput, windowTrls');
         pBurst_nTrlBack_compBaseline{lfpIdx}(trlIdx,1) = pTrl_burst.baseline;
         pBurst_nTrlBack_compTarget{lfpIdx}(trlIdx,1) = pTrl_burst.target;
         
     end
    
end

%% Average over contacts within session

for session = 1:29
    
    
    
end

