%% Calculate proportion of trials with burst
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Beh extraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx, length(corticalLFPcontacts.all));
    
    % Load in beta output data for session
    loadname = fullfile('betaBurst','stopSignal',['lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal']);
    tempIn = parload(fullfile(fullfile(dataDir,'lfp'), loadname));
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    nTrls = [];
    for ssdIdx = 1:length(executiveBeh.inh_SSD{session})
        nTrls(session,ssdIdx) = length(executiveBeh.ttm_CGO{session,ssdIdx}.C_unmatched);
    end
    
    % Get behavioral values
    validSSDidx = find(nTrls(session,:) >= 10);
    validSSDvalue = executiveBeh.inh_SSD{session}(validSSDidx);
    validpNCvalue = 1-executiveBeh.inh_pNC{session}(validSSDidx);
    validnTrvalue = executiveBeh.inh_trcount_SSD{session}(validSSDidx);
    nSSDs = length(validSSDvalue);
    
    
    % Ephys extraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for LFPthreshold = 1:10
        [betaOutput] = thresholdBursts(tempIn.betaOutput,...
            (sessionThreshold(session)/burstThreshold)*LFPthreshold);
        
        for ssdIdx = 1:nSSDs
            ssd = validSSDidx(ssdIdx);
            trials = executiveBeh.ttm_CGO{session,ssd}.C_unmatched;
            
            burstFlag = [];
            for ii = 1:length(trials)
                burstFlag(ii,1) =...
                    sum(betaOutput.burstData.burstTime{trials(ii)} >...
                    bayesianSSRT.ssrt_mean(session)-50 &...
                    betaOutput.burstData.burstTime{trials(ii)} <= ...
                    bayesianSSRT.ssrt_mean(session)) > 0 ;
            end
            
            % Find the proportion of bursts observed at a given SSD
            lfp_neurometric_pBurst{lfpIdx,LFPthreshold}(ssdIdx) = mean(burstFlag);
            
        end
        
        % "Export" data used to create Weibull neuro- and psycho- metric
        % function
        lfp_neurometric_SSD{lfpIdx,LFPthreshold} = validSSDvalue;
        lfp_neurometric_pNC{lfpIdx,LFPthreshold} = validpNCvalue;
        lfp_neurometric_nTr{lfpIdx,LFPthreshold} = validnTrvalue;
    end
    
end


%% Run tests to compare psycho- and neuro- metric tests

% For each contact...
for lfpIdx = 1:length(corticalLFPcontacts.all)
    % ... and at each threshold
    for LFPthreshold = 1:10
        
        % Calculate the raw difference between the p(non-cancel | SSD) and
        % p(burst | SSD)
        diffTest_burstRaw {lfpIdx,LFPthreshold} = ...
            lfp_neurometric_pNC{lfpIdx,LFPthreshold}-...
            lfp_neurometric_pBurst{lfpIdx,LFPthreshold};
        
        % Calculate the raw difference between the p(non-cancel | SSD) and
        % p(burst | shuffled SSD)      
        diffTest_burstRawShuffled {lfpIdx,LFPthreshold} = ...
            lfp_neurometric_pNC{lfpIdx,LFPthreshold}-...
            lfp_neurometric_pBurst{lfpIdx,LFPthreshold}...
            (randperm(length(lfp_neurometric_pBurst{lfpIdx,LFPthreshold})));

        % Calculate the raw difference between the p(non-cancel | SSD) and
        % max normalised p(burst | SSD)             
        diffTest_burstNorm {lfpIdx,LFPthreshold} = ...
            lfp_neurometric_pNC{lfpIdx,LFPthreshold}-...
            lfp_neurometric_pBurst{lfpIdx,LFPthreshold}./...
            max(lfp_neurometric_pBurst{lfpIdx,LFPthreshold});
        
        % Calculate sum of squared difference for:
            % raw 
        testRaw(lfpIdx,LFPthreshold) = sum(diffTest_burstRaw{lfpIdx,LFPthreshold}.^2);
            % shuffled
        testRaw_shuffled(lfpIdx,LFPthreshold) = sum(diffTest_burstRawShuffled{lfpIdx,LFPthreshold}.^2);
            % normalised
        testNorm(lfpIdx,LFPthreshold) = sum(diffTest_burstNorm{lfpIdx,LFPthreshold}.^2);

    end
end

%% Run statistics to determine differences

% At each threshold
for LFPthreshold = 1:10
    
    % one-sample t-test for the sum squared difference
    [ttest_raw(LFPthreshold,1), ttest_raw_p(LFPthreshold,1), ~, ttest_raw_stats{LFPthreshold,1}] =...
        ttest(testRaw(:,LFPthreshold));
    
    % two-sample t-test for the sum-square differences observed x shuffle
    [ttest_raw_shuffled(LFPthreshold,1), ttest_raw_shuffled_p(LFPthreshold,1), ~, ttest_raw_shuffled_stats{LFPthreshold,1}] =...
        ttest2(testRaw(:,LFPthreshold),testRaw_shuffled(:,LFPthreshold));
    
end

% Print statement for the 6 x threshold
fprintf('6x threshold stats: t (%i) = %.3f, p = %.3f \n', ttest_raw_shuffled_stats{6}.df, ttest_raw_shuffled_stats{6}.tstat,ttest_raw_shuffled_p(6))

%%

clear pBurst_Threshold
for lfpIdx = 1:length(corticalLFPcontacts.all)
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    
    for LFPthreshold = 1:10
        ssdList = (find(ismember(executiveBeh.inh_SSD{session}...
            (executiveBeh.midSSDarray(session,:)),...
            lfp_neurometric_SSD{lfpIdx,LFPthreshold})));
        
        pBurst_Threshold{lfpIdx}(LFPthreshold,:) =...
            lfp_neurometric_pBurst{lfpIdx, LFPthreshold}(ssdList);
    end
end

clear pBurst_Threshold_SSD
count = 0;
for lfpIdx = 1:length(corticalLFPcontacts.all)
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    for ssdIdx = 1:3
        count = count+1;
        
        pBurst_Threshold_SSD{count,1} = pBurst_Threshold{session}(:,ssdIdx)';
        
    end
end

%%