%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');

% Initialize arrays
%    for observed data in upper/lower layers
diff_burst_time.obs.upper = cell(1,length(14:29));
diff_burst_time.obs.lower = cell(1,length(14:29));
%    for shuffled data in upper/lower layers
diff_burst_time.shuf.upper = cell(1,length(14:29));
diff_burst_time.shuf.lower = cell(1,length(14:29));


%% Extract data from files
% For each session
for session_i = 14:29
    % Get the admin/details
    session = session_i;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest
    alignment_i = 1;
    % Get the desired alignment
    alignmentEvent = eventAlignments{alignment_i};
    
    % Get trials of interest
    trials = []; trials_shuffled = [];
    %         trials = ttx.activeTrials{sessionIdx};
    %         trials_shuffled = trials(randperm(numel(trials)));
    
    if alignmentIdx == 2
        trials = executiveBeh.ttx.sNC{session_i};
    else
        trials = executiveBeh.ttx_canc{session_i};
    end
    
    trials_shuffled = trials(randperm(numel(trials)));
    
    % Save output for each alignment on each session
    loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
    data_in = load(fullfile(loadDir, loadfile_label));
    
    % Get zero point
    alignmentZero = abs(data_in.eeg_lfp_burst.eventWindows{alignment_i}(1));
    
    % Step 1: find EEG beta-burst time on given trial %%%%%%%%%%%%%%%%%%
    for trl_i = 1:length(trials)
        %   Get trial index
        trial_x = trials(trl_i);
        trial_x_shuf = trials_shuffled(trl_i);
        
        %   Find burst flags in array row
        eeg_burst_times = find(data_in.eeg_lfp_burst.EEG{1,1}(trial_x,:) > 0);
        %   Adjust time for alignment offset
        eeg_burst_times = eeg_burst_times - alignmentZero;
        
        
        % Step 2: for each EEG burst, look find the time at which a LFP burst
        % occured %%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(eeg_burst_times)
            
            %   For each LFP channel within the session
            for lfp_i = 1:size(data_in.eeg_lfp_burst.LFP_raw{1,1},3)
                
                % Assign LFP channel to upper or lower layers
                find_laminar = cellfun(@(c) find(c == lfp_i), laminarAlignment.compart, 'uniform', false);
                find_laminar = find(~cellfun(@isempty,find_laminar));
                laminar_compart = laminarAlignment.compart_label{find_laminar};
                
                % Find the time of a burst on the same trial
                lfp_burst_times = [];
                lfp_burst_times = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x,:,lfp_i) > 0);
                lfp_burst_times_shuffled = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x_shuf,:,lfp_i) > 0);
                
                % ... again adjusting for alignment times
                lfp_burst_times = lfp_burst_times - alignmentZero;
                lfp_burst_times_shuffled = lfp_burst_times_shuffled - alignmentZero;
                
                % If there are bursts identified within the LFP,
                if ~isempty(lfp_burst_times)
                    nearest_eeg_burst_i = [];
                    lfp_diff_burst_time = [];
                    shuf_lfp_burst_i = [];
                    lfp_diff_burst_time_shuf = [];
                    
                    
                    % Find EEG burst closest to LFP burst in time.
                    for lfp_burst_i = 1:length(lfp_burst_times)
                        [~,nearest_eeg_burst_i(lfp_burst_i)] =...
                            min(abs(eeg_burst_times-lfp_burst_times(lfp_burst_i)));
                        
                        lfp_diff_burst_time(lfp_burst_i) =...
                            eeg_burst_times(nearest_eeg_burst_i(lfp_burst_i)) -...
                            lfp_burst_times(lfp_burst_i);
                    end
                    
                    % Then added them to the relevant structure for future
                    % analysis
                    diff_burst_time.obs.(laminar_compart){session_i - 13} =...
                        [diff_burst_time.obs.(laminar_compart){session_i - 13},...
                        lfp_diff_burst_time];
                    
                end
                
                % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % If there are bursts identified within the shuffled LFP condition,
                if ~isempty(lfp_burst_times_shuffled)
                    
                    % Find EEG burst closest to LFP burst in time.
                    for shuf_lfp_burst_i = 1:length(lfp_burst_times_shuffled)
                        [~,shuf_nearest_eeg_burst_i(shuf_lfp_burst_i)] =...
                            min(abs(eeg_burst_times-lfp_burst_times_shuffled(shuf_lfp_burst_i)));
                        
                        lfp_diff_burst_time_shuf(shuf_lfp_burst_i) =...
                            eeg_burst_times(shuf_nearest_eeg_burst_i(shuf_lfp_burst_i)) -...
                            lfp_burst_times_shuffled(shuf_lfp_burst_i);
                    end
                    
                    % Then added them to the relevant structure for future
                    % analysis
                    diff_burst_time.shuf.(laminar_compart){session_i - 13} =...
                        [diff_burst_time.shuf.(laminar_compart){session_i - 13},...
                        lfp_diff_burst_time_shuf];
                end
                
                
            end
            
        end
    end
    
end



%% 
eeg_x_lfp_delta.shuf.upper = []; eeg_x_lfp_delta.shuf.lower = [];
eeg_x_lfp_delta.obs.upper = [];  eeg_x_lfp_delta.obs.lower = [];

for session_i = 1:16
    eeg_x_lfp_delta.shuf.upper = [eeg_x_lfp_delta.shuf.upper; ...
        diff_burst_time.shuf.upper{session_i}'];
    
    eeg_x_lfp_delta.shuf.lower = [eeg_x_lfp_delta.shuf.lower; ...
        diff_burst_time.shuf.lower{session_i}'];    

    eeg_x_lfp_delta.obs.upper = [eeg_x_lfp_delta.obs.upper; ...
        diff_burst_time.obs.upper{session_i}'];
    
    eeg_x_lfp_delta.obs.lower = [eeg_x_lfp_delta.obs.lower; ...
        diff_burst_time.obs.lower{session_i}'];     
end

displayWindow = [-250:10:250];
NM = 'probability';
figure('Renderer', 'painters', 'Position', [100 100 400 250]); hold on
histogram(eeg_x_lfp_delta.obs.upper,displayWindow,'DisplayStyle','stairs','Normalization',NM);
histogram(eeg_x_lfp_delta.obs.lower,displayWindow,'DisplayStyle','stairs','Normalization',NM);

histogram(eeg_x_lfp_delta.shuf.upper,displayWindow,'DisplayStyle','stairs','Normalization',NM);
histogram(eeg_x_lfp_delta.shuf.lower,displayWindow,'DisplayStyle','stairs','Normalization',NM);

xlim([displayWindow(1) displayWindow(end)])
% ylim([0 0.02])
legend({'upper-obs','lower-obs','upper-shuf','lower-shuf'},'location','eastoutside')


% ylim([0.005 0.020])

nanmean(eeg_x_lfp_delta.obs.upper > -50 & eeg_x_lfp_delta.obs.upper < 0)

