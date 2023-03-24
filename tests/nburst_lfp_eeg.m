%% Co-activation between SEF and MFC EEG
% Set up parameters
eventLabels = {'3_Stopping'};
eventAlignments = {'stopSignal'};
eventWindows = {[-1000 1000]};
analysisWindows = {[0:50]};
eventBin = {1};
loadDir = fullfile(dataDir,'eeg_lfp');
printFigFlag = 0;

%% Find active trials (when tone was sounded)
for sessionIdx = 1:29
    ttx.activeTrials{sessionIdx} = find(~isnan(executiveBeh.TrialEventTimes_Overall{sessionIdx}(:,6)));
end

%% Extract data from files
% For each session
for sessionIdx = 14:29
    % Get the admin/details
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest
    for alignmentIdx = 1:length(eventAlignments)
        % Get the desired alignment
        alignmentEvent = eventAlignments{alignmentIdx};
        
        % Get trials of interest
        trials = []; trials_shuffled = [];
        
        if alignmentIdx > 3 % If aligning on saccade, then we will look at error trials
            trials = executiveBeh.ttx.sNC{session};
        else % Otherwise, we will just look at canceled trials
            trials = executiveBeh.ttx_canc{session};
        end
        
        trials_shuffled = trials(randperm(numel(trials)));
        
        
        % Save output for each alignment on each session
        loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
        load(fullfile(loadDir, loadfile_label));
        
        % Get zero point: NOTE: THIS WILL NEED TO BE LESS HARDCODED -
        % CURRENTLY ALL WINDOWS ARE THE SAME, BUT WILL NEED CHANGED
        % OTHERWISE
        alignmentZero = abs(eeg_lfp_burst.eventWindows{1}(1));
        
        % Find channels in L2, L3, L5, L6
        ch_depths = []; ch_depths = corticalLFPmap.depth(corticalLFPmap.session == session);
        
 
        input = [];
        
        input = eeg_lfp_burst.LFP_raw{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,:);
                
        EEG_burst = sum(eeg_lfp_burst.EEG{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero),2) > 0;
        LFP_burst = sum(squeeze(sum(input(:,:,[1:end]) > 0,2)),2) > 0;

        EEG_LFP_coincidence{session-13} = table(trials,EEG_burst,LFP_burst);
        
    end
    
end

for session_i = 1:length([14:29])
    
   eeg_burst_i = []; eeg_burst_i = find(EEG_LFP_coincidence{session_i}.EEG_burst == 1);
   p_lfpburst_eegburst(session_i,1) = nanmean(EEG_LFP_coincidence{session_i}.LFP_burst(eeg_burst_i));
   n_lfpburst_eegburst(session_i,1) = 1/p_lfpburst_eegburst(session_i,1);
    
end

nanmean(n_lfpburst_eegburst)