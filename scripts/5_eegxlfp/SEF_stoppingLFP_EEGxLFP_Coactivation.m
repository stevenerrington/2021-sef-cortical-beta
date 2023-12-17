%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
analysisWindows = {[-400:-200],[400:600],[0:200],[-400:-200]};
eventBin = {1,1,1,1};
loadDir = 'D:\projects\2021-sef-cortical-beta\data\eeg_lfp\';

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
        eeg_burst_time = find(eeg_lfp_burst.EEG{1, 1}(trial_in,:) > 0)-alignmentZero;
        
        % Observed data: ###########################################
        for LFPidx = 1:size(eeg_lfp_burst.LFP{1, 1},3)
            lfp_burst_time = [];
            lfp_burst_time = find(eeg_lfp_burst.LFP{1, 1}(trial_in,:,LFPidx))-alignmentZero;
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
                % If no burst, then it's empty
                diff_burst_time{trialIdx,LFPidx} = NaN;
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
                % If no burst, then it's empty
                diff_shuffledburst_time{trialIdx,LFPidx} = NaN;
            end
        end
        
    end
    
    % Save the differential burst time output for the session
    eeg_lfp_diffBurstTime.observed{session-13} = diff_burst_time;
    eeg_lfp_diffBurstTime.shuffled{session-13} = diff_shuffledburst_time;
    
    
    % We are then going to take these times and bin them into 50ms windows
    % ranging from -500 to 500 ms.
    
    % We start by initialising the array.
    bincount_eeg_x_lfp = [];
    bincount_eeg_x_lfp_shuffled = [];
    
    % Then for each trial
    for trialIdx = 1:length(trials)
        % and for each contact within the session
        for LFPidx = 1:size(eeg_lfp_burst.LFP{1, 1},3)
            % Get the number of beta-bursts that occur within the defined
            % bins, for both the observed data:
            [bincount_eeg_x_lfp(trialIdx,:,LFPidx)] = histcounts(diff_burst_time{trialIdx,LFPidx},windowBins);
            % and the shuffled data:
            [bincount_eeg_x_lfp_shuffled(trialIdx,:,LFPidx)] = histcounts(diff_shuffledburst_time{trialIdx,LFPidx},windowBins);
        end
    end
    
    % Saved the bin output for the session, getting rid of the unneeded dimension.    
    pBurst_eeg_lfp_binned{session-13} = squeeze(nanmean(bincount_eeg_x_lfp,1))';
    pBurst_eeg_lfp_binned_shuffled{session-13} = squeeze(nanmean(bincount_eeg_x_lfp_shuffled,1))';
    
end


% We will then collapse p(burst | contact | time bin) across sessions
% Initialise empty NaN arrays for observed and shuffle
pBurst_eeg_lfp_binned_array = nan(17,size(windowBins,2)-1,16);
pBurst_eeg_lfp_binned_array_shuffled = nan(17,size(windowBins,2)-1,16);

% For each perpendicular session
for session = 1:16
    % Input the binned p(burst) x depth values into a 3D array
    pBurst_eeg_lfp_binned_array...
        ([1:size(pBurst_eeg_lfp_binned{session},1)],:,session) =...
        pBurst_eeg_lfp_binned{session};

    % and repeat this for the shuffled condition. 
    pBurst_eeg_lfp_binned_array_shuffled...
        ([1:size(pBurst_eeg_lfp_binned_shuffled{session},1)],:,session) =...
        pBurst_eeg_lfp_binned_shuffled{session};
end



%% Figure 1: Heatmap p(LFP burst | EEG burst) x depth

% Average across all sessions for the observed and shuffled data
main_eegxlfp_average = nanmean(pBurst_eeg_lfp_binned_array(1:17,:,:),3);
main_eegxlfp_shuffled = nanmean(pBurst_eeg_lfp_binned_array_shuffled(1:17,:,:),3);

% Generate the figure
figure('Renderer', 'painters', 'Position', [100 100 1000 250]);

% Plot the observed data
subplot(1,3,1)
imagesc('XData',windowBins,'YData',1:17,'CData',main_eegxlfp_average)
set(gca,"YDir","Reverse","CLim",([min(min([main_eegxlfp_average; main_eegxlfp_shuffled]))...
    max(max([main_eegxlfp_average; main_eegxlfp_shuffled]))]))
ylim([1 17])
colormap(viridis)

% Plot the shuffled data
subplot(1,3,2)
imagesc('XData',windowBins,'YData',1:17,'CData',main_eegxlfp_shuffled)
set(gca,"YDir","Reverse","CLim",([min(min([main_eegxlfp_average; main_eegxlfp_shuffled]))...
    max(max([main_eegxlfp_average; main_eegxlfp_shuffled]))]))
ylim([1 17])
colormap(viridis)

% Plot the observed - shuffled data
subplot(1,3,3)
imagesc('XData',windowBins,'YData',1:17,'CData',main_eegxlfp_average-main_eegxlfp_shuffled)
set(gca,"YDir","Reverse")
ylim([1 17])
colormap(viridis)
