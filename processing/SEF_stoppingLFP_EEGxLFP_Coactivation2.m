%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
analysisWindows = {[-400:-200],[400:600],[0:200],[-400:-200]};
eventBin = {1,1,1,1};
loadDir = 'D:\projectCode\project_stoppingLFP\data\eeg_lfp\';

windowBins = [-500:50:500];

%% Extract data from files
% For each session
for sessionIdx = 14:29
    % Get the admin/details
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest
    alignmentIdx = 1;
    % Get the desired alignment
    alignmentEvent = eventAlignments{alignmentIdx};
    
    % Get trials of interest
    trials = [];
    trials = 1:length(executiveBeh.TrialEventTimes_Overall{session});
    trials_shuffled = trials(randperm(numel(trials)));
    
    % Save output for each alignment on each session
    loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
    load([loadDir loadfile_label]);
    
    % Get zero point
    alignmentZero = abs(eeg_lfp_burst.eventWindows{alignmentIdx}(1));
    
    for trialIdx = 1:length(trials)
        % Get the actual trial index
        trial_in = trials(trialIdx);
        trial_in_shuffled = trials_shuffled(trialIdx);
        
        % Find bursts on the trial
        eeg_burst_time = [];
        eeg_burst_time = find(eeg_lfp_burst.EEG{1, 1}(trial_in,:) > 0);
        
        % Observed data: ###########################################
        for LFPidx = 1:size(eeg_lfp_burst.LFP{1, 1},3)
            lfp_burst_time = [];
            lfp_burst_time = find(eeg_lfp_burst.LFP{1, 1}(trial_in,:,LFPidx));
            diff_burst_time{trialIdx,LFPidx} = [];
            
            % If there is a burst
            if ~isempty(eeg_burst_time) && ~isempty(lfp_burst_time)
                % For each burst within the window
                for burstIdx = 1:length(eeg_burst_time)
                    % Find the latency difference between the cortical
                    % burst and the EEG burst (-ve = cortex precedes)
                    diff_burst_time{trialIdx,LFPidx} =...
                        [diff_burst_time{trialIdx,LFPidx}, lfp_burst_time-eeg_burst_time(burstIdx)];
                end
            else
                diff_burst_time{trialIdx,LFPidx} = [];
            end
        end
        
        
        % Shuffled data: ###########################################
        for LFPidx = 1:size(eeg_lfp_burst.LFP{1, 1},3)
            lfp_shuffledburst_time = [];
            lfp_shuffledburst_time = find(eeg_lfp_burst.LFP{1, 1}(trial_in_shuffled,:,LFPidx));
            diff_shuffledburst_time{trialIdx,LFPidx} = [];
            
            % If there is a burst
            if ~isempty(eeg_burst_time) && ~isempty(lfp_shuffledburst_time)
                % For each burst within the window
                for burstIdx = 1:length(eeg_burst_time)
                    % Find the latency difference between the cortical
                    % burst and the EEG burst (-ve = cortex precedes)
                    diff_shuffledburst_time{trialIdx,LFPidx} =...
                        [diff_shuffledburst_time{trialIdx,LFPidx}, lfp_shuffledburst_time-eeg_burst_time(burstIdx)];
                end
            else
                diff_shuffledburst_time{trialIdx,LFPidx} = [];
            end
        end
        
    end
    
    bincount_eeg_x_lfp = [];
    bincount_eeg_x_lfp_shuffled = [];
    
    for trialIdx = 1:length(trials)
        for LFPidx = 1:size(eeg_lfp_burst.LFP{1, 1},3)
            [bincount_eeg_x_lfp(trialIdx,:,LFPidx)] = histcounts(diff_burst_time{trialIdx,LFPidx},windowBins);
            [bincount_eeg_x_lfp_shuffled(trialIdx,:,LFPidx)] = histcounts(diff_shuffledburst_time{trialIdx,LFPidx},windowBins);
        end
    end
    
    pBurst_eeg_lfp_binned{session-13} = squeeze(nanmean(bincount_eeg_x_lfp,1))';
    pBurst_eeg_lfp_binned_shuffled{session-13} = squeeze(nanmean(bincount_eeg_x_lfp_shuffled,1))';
    
end

pBurst_eeg_lfp_binned_array = nan(17,20,16);
pBurst_eeg_lfp_binned_array_shuffled = nan(17,20,16);

for session = 1:16
    pBurst_eeg_lfp_binned_array...
        ([1:size(pBurst_eeg_lfp_binned{session},1)],:,session) =...
        pBurst_eeg_lfp_binned{session};
    
    pBurst_eeg_lfp_binned_array_shuffled...
        ([1:size(pBurst_eeg_lfp_binned_shuffled{session},1)],:,session) =...
        pBurst_eeg_lfp_binned_shuffled{session};
end

