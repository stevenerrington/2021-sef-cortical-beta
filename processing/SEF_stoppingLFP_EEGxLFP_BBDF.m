

%% EEG data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For each perpendicular session (as these are the only ones we can
% confidently assign layers to channels:
parfor sessionIdx = 14:29
    % Get the session admin (index, ssrt, behaviour, etc...)
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    ssrt = round(bayesianSSRT.ssrt_mean(session));
    
    % Load in EEG data
    %   Define directories:
    eegDir = 'D:\projectCode\project_stoppingEEG\data\monkeyEEG\'; % Directory of EEG data (from prev manuscript)
    eeg_target = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_target'];
    eeg_stopSignal = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_stopSignal'];
    eeg_saccade = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_saccade'];
    eeg_tone = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_tone'];
    
    %   Load in data from each epoch:
    eegBetaBurst_target = parload([eegDir eeg_target]);
    eegBetaBurst_stopSignal = parload([eegDir eeg_stopSignal]);
    eegBetaBurst_saccade = parload([eegDir eeg_saccade]);
    eegBetaBurst_tone = parload([eegDir eeg_tone]);
    
    %   Threshold bursts at 6 x median LFP power for each epoch
    [eegBetaBurst_target] = thresholdBursts_EEG(eegBetaBurst_target.betaOutput, eegBetaBurst_target.betaOutput.medianLFPpower*6);
    [eegBetaBurst_stopSignal] = thresholdBursts_EEG(eegBetaBurst_stopSignal.betaOutput, eegBetaBurst_stopSignal.betaOutput.medianLFPpower*6);
    [eegBetaBurst_saccade] = thresholdBursts_EEG(eegBetaBurst_saccade.betaOutput, eegBetaBurst_saccade.betaOutput.medianLFPpower*6);
    [eegBetaBurst_tone] = thresholdBursts_EEG(eegBetaBurst_tone.betaOutput, eegBetaBurst_tone.betaOutput.medianLFPpower*6);
    
    %   Convolve these extracted beta bursts for each epoch to get a beta
    %   burst density function (BBDF)
    EEG_SessionBDF_target = BetaBurstConvolver(eegBetaBurst_target.burstData.burstTime);
    EEG_SessionBDF_stopSignal = BetaBurstConvolver(eegBetaBurst_stopSignal.burstData.burstTime);
    EEG_SessionBDF_saccade = BetaBurstConvolver(eegBetaBurst_saccade.burstData.burstTime);
    EEG_SessionBDF_tone = BetaBurstConvolver(eegBetaBurst_tone.burstData.burstTime);
    
    %   We are then going to latency match, so let's initialise the arrays!
    c_temp_fix = []; ns_temp_fix = []; % for fixation
    c_temp_ssd = []; ns_temp_ssd = []; % for ssd
    c_temp_tone = []; ns_temp_tone = []; % for tone
    nc_temp_saccade = []; ns_temp_saccade = []; % and for saccade (error)
    c_shuffle_fix = []; ns_shuffle_fix = [];
    c_shuffle_ssd = []; ns_shuffle_ssd = [];
    c_shuffle_tone = []; ns_shuffle_tone = [];
    nc_shuffle_saccade = []; ns_shuffle_saccade = [];
    
    %   To latency match, we take the activity aligned on the event for
    %   each SSD and save it temporarily
    for ii = 1:length(executiveBeh.inh_SSD{session})
        % Regular
        c_temp_fix(ii,:) = nanmean(EEG_SessionBDF_target(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_fix(ii,:) = nanmean(EEG_SessionBDF_target(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        c_temp_ssd(ii,:) = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_ssd(ii,:) = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        c_temp_tone(ii,:) = nanmean(EEG_SessionBDF_saccade(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_tone(ii,:) = nanmean(EEG_SessionBDF_saccade(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        nc_temp_saccade(ii,:) = nanmean(EEG_SessionBDF_tone(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_temp_saccade(ii,:) = nanmean(EEG_SessionBDF_tone(executiveBeh.ttm_c.GO_NC{session,ii}.all, :));
        
        % Shuffle
        shuffled_c_trials = executiveBeh.ttm_CGO{session,ii}.C_matched(randperm(numel(executiveBeh.ttm_CGO{session,ii}.C_matched)))
        shuffled_cgo_trials = executiveBeh.ttm_CGO{session,ii}.GO_matched(randperm(numel(executiveBeh.ttm_CGO{session,ii}.GO_matched)))
        shuffled_ncgo_trials = executiveBeh.ttm_c.GO_NC{session,ii}.all(randperm(numel(executiveBeh.ttm_c.GO_NC{session,ii}.all)))
        shuffled_nc_trials = executiveBeh.ttm_c.NC{session,ii}.all(randperm(numel(executiveBeh.ttm_c.NC{session,ii}.all)))
        
        c_shuffle_fix(ii,:) = nanmean(EEG_SessionBDF_target(shuffled_c_trials, :));
        ns_shuffle_fix(ii,:) = nanmean(EEG_SessionBDF_target(shuffled_cgo_trials, :));
        
        c_shuffle_ssd(ii,:) = nanmean(EEG_SessionBDF_stopSignal(shuffled_c_trials, :));
        ns_shuffle_ssd(ii,:) = nanmean(EEG_SessionBDF_stopSignal(shuffled_cgo_trials, :));
        
        c_shuffle_tone(ii,:) = nanmean(EEG_SessionBDF_saccade(shuffled_c_trials, :));
        ns_shuffle_tone(ii,:) = nanmean(EEG_SessionBDF_saccade(shuffled_cgo_trials, :));
        
        nc_shuffle_saccade(ii,:) = nanmean(EEG_SessionBDF_tone(shuffled_nc_trials, :));
        ns_shuffle_saccade(ii,:) = nanmean(EEG_SessionBDF_tone(shuffled_ncgo_trials, :));
        
    end
    
    %   We then average across all these SSD's for:
    %   Fixation:
    EEGbbdf_canceled_fix{sessionIdx,1} = nanmean(c_temp_fix);
    EEGbbdf_nostop_fix{sessionIdx,1} = nanmean(ns_temp_fix);
    %   SSD:
    EEGbbdf_canceled_ssd{sessionIdx,1} = nanmean(c_temp_ssd);
    EEGbbdf_nostop_ssd{sessionIdx,1} = nanmean(ns_temp_ssd);
    %   Tone:
    EEGbbdf_canceled_tone{sessionIdx,1} = nanmean(c_temp_tone);
    EEGbbdf_nostop_tone{sessionIdx,1} = nanmean(ns_temp_tone);
    %   Saccade:
    EEGbbdf_noncanceled_saccade{sessionIdx,1} = nanmean(nc_temp_saccade);
    EEGbbdf_nostop_saccade{sessionIdx,1} = nanmean(ns_temp_saccade);
    
    
    %   We then repeat this for shuffled condition:
    %   Fixation
    shuffledEEGbbdf_canceled_fix{sessionIdx,1} = nanmean(c_shuffle_fix);
    shuffledEEGbbdf_nostop_fix{sessionIdx,1} = nanmean(ns_shuffle_fix);
    %   SSD:
    shuffledEEGbbdf_canceled_ssd{sessionIdx,1} = nanmean(c_shuffle_ssd);
    shuffledEEGbbdf_nostop_ssd{sessionIdx,1} = nanmean(ns_shuffle_ssd);
    %   Tone:
    shuffledEEGbbdf_canceled_tone{sessionIdx,1} = nanmean(c_shuffle_tone);
    shuffledEEGbbdf_nostop_tone{sessionIdx,1} = nanmean(ns_shuffle_tone);
    %   Saccade:
    shuffledEEGbbdf_noncanceled_saccade{sessionIdx,1} = nanmean(nc_shuffle_saccade);
    shuffledEEGbbdf_nostop_saccade{sessionIdx,1} = nanmean(ns_shuffle_saccade);
    
    
end



%% LFP data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For each channel within the cortex (across all sessions):
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    % Get the session admin (index, ssrt, behaviour, etc...)
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    ssrt = round(bayesianSSRT.ssrt_mean(session));
    
    % Load in the prior extracted beta-burst density function
    bbdf = parload(['D:\projectCode\project_stoppingLFP\data\bbdf\bbdf_' int2str(lfpIdx)]);
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    %   We are then going to latency match, so let's initialise the arrays!
    c_temp_fix = []; ns_temp_fix = []; % for fixation
    c_temp_ssd = []; ns_temp_ssd = []; % for ssd
    c_temp_tone = []; ns_temp_tone = [];% for tone
    nc_temp_saccade = []; ns_temp_saccade = []; % and for saccade
    
    c_shuffle_fix = []; ns_shuffle_fix = [];
    c_shuffle_ssd = []; ns_shuffle_ssd = [];
    c_shuffle_tone = []; ns_shuffle_tone = [];
    nc_shuffle_saccade = []; ns_shuffle_saccade = [];
        
    %   To latency match, we take the activity aligned on the event for
    %   each SSD and save it temporarily
    for ii = 1:length(executiveBeh.inh_SSD{session})
        c_temp_fix(ii,:) = nanmean(bbdf.bbdf.fixate(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_fix(ii,:) = nanmean(bbdf.bbdf.fixate(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        c_temp_ssd(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_ssd(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        c_temp_tone(ii,:) = nanmean(bbdf.bbdf.tone(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_tone(ii,:) = nanmean(bbdf.bbdf.tone(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        nc_temp_saccade(ii,:) = nanmean(bbdf.bbdf.saccade(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_temp_saccade(ii,:) = nanmean(bbdf.bbdf.saccade(executiveBeh.ttm_c.GO_NC{session,ii}.all, :));
        
        % Shuffle
        shuffled_nc_trials = []; shuffled_c_trials = []; shuffled_cgo_trials = []; shuffled_ncgo_trials = []
        shuffled_c_trials = executiveBeh.ttm_CGO{session,ii}.C_matched(randperm(numel(executiveBeh.ttm_CGO{session,ii}.C_matched)))
        shuffled_cgo_trials = executiveBeh.ttm_CGO{session,ii}.GO_matched(randperm(numel(executiveBeh.ttm_CGO{session,ii}.GO_matched)))
        shuffled_ncgo_trials = executiveBeh.ttm_c.GO_NC{session,ii}.all(randperm(numel(executiveBeh.ttm_c.GO_NC{session,ii}.all)))
        shuffled_nc_trials = executiveBeh.ttm_c.NC{session,ii}.all(randperm(numel(executiveBeh.ttm_c.NC{session,ii}.all)))
          
        c_shuffle_fix(ii,:) = nanmean(bbdf.bbdf.fixate(shuffled_c_trials, :));
        ns_shuffle_fix(ii,:) = nanmean(bbdf.bbdf.fixate(shuffled_cgo_trials, :));
        
        c_shuffle_ssd(ii,:) = nanmean(bbdf.bbdf.ssd(shuffled_c_trials, :));
        ns_shuffle_ssd(ii,:) = nanmean(bbdf.bbdf.ssd(shuffled_cgo_trials, :));
        
        c_shuffle_tone(ii,:) = nanmean(bbdf.bbdf.tone(shuffled_c_trials, :));
        ns_shuffle_tone(ii,:) = nanmean(bbdf.bbdf.tone(shuffled_cgo_trials, :));
        
        nc_shuffle_saccade(ii,:) = nanmean(bbdf.bbdf.saccade(shuffled_nc_trials, :));
        ns_shuffle_saccade(ii,:) = nanmean(bbdf.bbdf.saccade(shuffled_ncgo_trials, :));
    end
    
    %   We then average across all these SSD's for;
    %   Fixation:
    LFPbbdf_canceled_fix{lfpIdx,1} = nanmean(c_temp_fix);
    LFPbbdf_nostop_fix{lfpIdx,1} = nanmean(ns_temp_fix);
    %   SSD:
    LFPbbdf_canceled_ssd{lfpIdx,1} = nanmean(c_temp_ssd);
    LFPbbdf_nostop_ssd{lfpIdx,1} = nanmean(ns_temp_ssd);
    %   Tone:
    LFPbbdf_canceled_tone{lfpIdx,1} = nanmean(c_temp_tone);
    LFPbbdf_nostop_tone{lfpIdx,1} = nanmean(ns_temp_tone);
    %   Saccade:
    LFPbbdf_noncanceled_saccade{lfpIdx,1} = nanmean(nc_temp_saccade);
    LFPbbdf_nostop_saccade{lfpIdx,1} = nanmean(ns_temp_saccade);
    
    
    
    %   Repeating for the shuffled condition;
    %   Fixation:
    shuffledLFPbbdf_canceled_fix{lfpIdx,1} = nanmean(c_shuffle_fix);
    shuffledLFPbbdf_nostop_fix{lfpIdx,1} = nanmean(ns_shuffle_fix);
    %   SSD:
    shuffledLFPbbdf_canceled_ssd{lfpIdx,1} = nanmean(c_shuffle_ssd);
    shuffledLFPbbdf_nostop_ssd{lfpIdx,1} = nanmean(ns_shuffle_ssd);
    %   Tone:
    shuffledLFPbbdf_canceled_tone{lfpIdx,1} = nanmean(c_shuffle_tone);
    shuffledLFPbbdf_nostop_tone{lfpIdx,1} = nanmean(ns_shuffle_tone);
    %   Saccade:
    shuffledLFPbbdf_noncanceled_saccade{lfpIdx,1} = nanmean(nc_shuffle_saccade);
    shuffledLFPbbdf_nostop_saccade{lfpIdx,1} = nanmean(ns_shuffle_saccade);
end


%% Data tidying and organisation
% We can then use this new extracted data to plot the event-aligned BBDF
% for the concurrent EEG signals, and signals in the upper and lower layers

time = [-1000:2000]; % all BBDF's are convolved between -1000 and 2000 ms peri-event

% First, let's get all the EEG BBDF's - this is easy, as it's just one
% electrode we are recording from. As such, we will take the activity on
% each session from this EEG electrode
eeg_all_BBDF = EEGbbdf_canceled_fix(14:29);
% For plotting purposes, we will also provide a label for this data, noting
% it as EEG.
eeg_all_label = repmat({'1_EEG'},length(14:29),1);

% Then, for LFP's, there are a lot more of them (~8 chs per session in upper
% layers, and ~8 chs per session in lower layers). So, we will extract all
% channels in upper/lower layers in a session, and use this.

% We start by initialising arrays to concatenate into.
lfp_upper_BBDF = []; lfp_lower_BBDF = [];
lfp_upper_label = []; lfp_lower_label = [];

% Then for each session
for session = 14:29
    % We initialise a temporary array for upper and lower layers
    sessionLFPidx_upper = []; sessionLFPidx_lower = [];
    % We then find what channels within a session are in the upper...
    sessionLFPidx_upper = find(corticalLFPmap.session == session &...
        corticalLFPmap.depth <= 8);
    % ... and lower cortical layers
    sessionLFPidx_lower = find(corticalLFPmap.session == session &...
        corticalLFPmap.depth > 8);
    
    % We then take the BBDF's we previously imported, and just take those
    % in the upper...
    lfp_upper_BBDF = [lfp_upper_BBDF; LFPbbdf_canceled_ssd(sessionLFPidx_upper)];
    % ... and lower cortical layers, and concatenate them with the main
    % array. This allows for BBDF's to be collapsed across sessions
    lfp_lower_BBDF = [lfp_lower_BBDF; LFPbbdf_canceled_ssd(sessionLFPidx_lower)];
    
    % And, just like we did with the EEG, we provide labels to help with
    % plotting later.
    lfp_upper_label = [lfp_upper_label; repmat({'2_Upper'},length(sessionLFPidx_upper),1)];
    lfp_lower_label = [lfp_lower_label; repmat({'3_Lower'},length(sessionLFPidx_lower),1)];
end

%% Generate figure
%  Now we have all the data in an organised format, we can now generate
%  figures

% First, we start by making sure we have a clean space to work with
clear inputData inputLabels eeg_lfp_BBDF

% Then, we take the concatenated EEG, upper, and lower BBDF data and
% concatenate it into one array to feed into the function
inputData = [eeg_all_BBDF; lfp_upper_BBDF; lfp_lower_BBDF];
% We then do this for the labels too. Here the label matches the
% corresponding index in the BBDF inputData.
inputLabels = [eeg_all_label; lfp_upper_label; lfp_lower_label];

% Once that's all in place, we can feed it into our graph function (gramm)
eeg_lfp_BBDF(1,1)=gramm('x',time,'y',inputData,'color',inputLabels);

% and set the properties of the figure
eeg_lfp_BBDF(1,1).stat_summary();
eeg_lfp_BBDF(1,1).axe_property('XLim',[-200 800]);
eeg_lfp_BBDF(1,1).axe_property('YLim',[0 0.003]);

% Then, we're all good to go. Create the figure!
figure('Renderer', 'painters', 'Position', [100 100 400 300]);
eeg_lfp_BBDF.draw();

