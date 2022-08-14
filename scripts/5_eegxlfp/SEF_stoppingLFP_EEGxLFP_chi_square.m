%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'fixate','target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');

layerLabel = {'LFP_upper','LFP_lower'};
window_edges = 0:30:600;
n_windows = length(window_edges)-1;

trl_burst_diff_lfp = {};
trl_burst_diff_lfp_shuffled = {};

%% Extract data from files
for window_i = 1:n_windows
    window = [window_edges(window_i), window_edges(window_i+1)];
    fprintf('Analysing window: %i to %i ms \n',window(1), window(2))
    
    % For each session
    for session_i = 14:29
        % Get the admin/details
        session = session_i;
%         fprintf('Analysing session %i of %i. \n',session, 29)
        
        % ... and for each epoch of interest (just fixation here)
        alignment_i = 1;
        % Get the desired alignment
        alignmentEvent = eventAlignments{alignment_i};
        
        % Get trials of interest
        trials = []; trials_shuffled = [];
        trials = executiveBeh.ttx.GO{session_i};
        n_trls = length(trials);
        % We can then shuffled the conditions
        trials_shuffled = trials(randperm(numel(trials)));
        
        % Save output for each alignment on each session
        loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
        data_in = load(fullfile(loadDir, loadfile_label));
        
        % Get zero point
        alignmentZero = abs(data_in.eeg_lfp_burst.eventWindows{alignment_i}(1));
        n_lfps = size(data_in.eeg_lfp_burst.LFP_raw{1,1},3);
        % Step 1: find EEG beta-burst time on given trial %%%%%%%%%%%%%%%%%%
        for trl_i = 1:n_trls
            %   Get trial index
            trial_x = trials(trl_i);
            trial_x_shuf = trials_shuffled(trl_i);
            
            %   Find burst flags in array row (% NOTE: EEG we are just taking
            %   the actual trial number, not shuffled).
            eeg_burst_times = find(data_in.eeg_lfp_burst.EEG{1,1}(trial_x,:) > 0);
            %   Adjust time for alignment offset
            eeg_burst_times = eeg_burst_times - alignmentZero;
            %   And only look at bursts during the fixation window (0 to 800 ms
            %   post-fixation).
            eeg_burst_times = eeg_burst_times(eeg_burst_times > window(1) & eeg_burst_times < window(2));
            
            % Step 2: For each LFP channel in the session, find if a burst occured.
            for lfp_i = 1:n_lfps
                % Find the time of a burst on the same & shuffled trial
                lfp_burst_times = []; lfp_burst_times_shuffled = [];
                
                lfp_burst_times = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x,:,lfp_i) > 0);
                lfp_burst_times_shuffled = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x_shuf,:,lfp_i) > 0);
                
                % ... again adjusting for alignment times
                lfp_burst_times = lfp_burst_times - alignmentZero;
                lfp_burst_times = lfp_burst_times(lfp_burst_times > window(1) & lfp_burst_times < window(2));
                
                lfp_burst_times_shuffled = lfp_burst_times_shuffled - alignmentZero;
                lfp_burst_times_shuffled = lfp_burst_times_shuffled(lfp_burst_times_shuffled > window(1) & lfp_burst_times_shuffled < window(2));
                
                % If there is: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % No beta-burst in EEG, then label trial as 'no eeg burst'
                if isempty(eeg_burst_times) && ~isempty(lfp_burst_times)
                    trl_burst_diff_lfp{session_i,lfp_i,window_i}{trl_i,1} = NaN;
                    trl_burst_diff_lfp{session_i,lfp_i,window_i}{trl_i,2} = '-eeg, +lfp';
                end
                if isempty(eeg_burst_times) && ~isempty(lfp_burst_times_shuffled)
                    trl_burst_diff_lfp_shuffled{session_i,lfp_i,window_i}{trl_i,1} = NaN;
                    trl_burst_diff_lfp_shuffled{session_i,lfp_i,window_i}{trl_i,2} = '-eeg, +lfp';
                end
                
                % No beta-burst in LFP, then label trial as 'no lfp burst'
                if ~isempty(eeg_burst_times) && isempty(lfp_burst_times)
                    trl_burst_diff_lfp{session_i,lfp_i,window_i}{trl_i,1} = NaN;
                    trl_burst_diff_lfp{session_i,lfp_i,window_i}{trl_i,2} = '+eeg, -lfp';
                end
                if ~isempty(eeg_burst_times) && isempty(lfp_burst_times_shuffled)
                    trl_burst_diff_lfp_shuffled{session_i,lfp_i,window_i}{trl_i,1} = NaN;
                    trl_burst_diff_lfp_shuffled{session_i,lfp_i,window_i}{trl_i,2} = '+eeg, -lfp';
                end
                
                % No beta-burst in EEG or LFP, then label trial as 'no lfp or eeg burst'
                if isempty(eeg_burst_times) && isempty(lfp_burst_times)
                    trl_burst_diff_lfp{session_i,lfp_i,window_i}{trl_i,1} = NaN;
                    trl_burst_diff_lfp{session_i,lfp_i,window_i}{trl_i,2} = '-eeg, -lfp';
                end
                if isempty(eeg_burst_times) && isempty(lfp_burst_times_shuffled)
                    trl_burst_diff_lfp_shuffled{session_i,lfp_i,window_i}{trl_i,1} = NaN;
                    trl_burst_diff_lfp_shuffled{session_i,lfp_i,window_i}{trl_i,2} = '-eeg, -lfp';
                end
                
                % Otherwise, find the difference between the burst times
                % for observed LFP bursts
                if  ~isempty(eeg_burst_times) && ~isempty(lfp_burst_times)
                    nearest_eeg_burst_i = []; lfp_diff_burst_time = [];
                    
                    % Find EEG burst closest to LFP burst in time.
                    for lfp_burst_i = 1:length(lfp_burst_times)
                        [~,nearest_eeg_burst_i(lfp_burst_i)] =...
                            min(abs(eeg_burst_times-lfp_burst_times(lfp_burst_i)));
                        
                        lfp_diff_burst_time(lfp_burst_i) =...
                            eeg_burst_times(nearest_eeg_burst_i(lfp_burst_i)) -...
                            lfp_burst_times(lfp_burst_i);
                    end
                    
                    trl_burst_diff_lfp{session_i,lfp_i,window_i}{trl_i,1} = lfp_diff_burst_time;
                    trl_burst_diff_lfp{session_i,lfp_i,window_i}{trl_i,2} = '+eeg, +lfp';
                end
                
                % and for shuffled LFP bursts
                if ~isempty(eeg_burst_times) && ~isempty(lfp_burst_times_shuffled)
                    shuf_nearest_eeg_burst_i = []; lfp_diff_burst_time_shuf = [];
                    % Find EEG burst closest to LFP burst in time.
                    for shuf_lfp_burst_i = 1:length(lfp_burst_times_shuffled)
                        [~,shuf_nearest_eeg_burst_i(shuf_lfp_burst_i)] =...
                            min(abs(eeg_burst_times-lfp_burst_times_shuffled(shuf_lfp_burst_i)));
                        
                        lfp_diff_burst_time_shuf(shuf_lfp_burst_i) =...
                            eeg_burst_times(shuf_nearest_eeg_burst_i(shuf_lfp_burst_i)) -...
                            lfp_burst_times_shuffled(shuf_lfp_burst_i);
                    end
                    trl_burst_diff_lfp_shuffled{session_i,lfp_i,window_i}{trl_i,1} = lfp_diff_burst_time_shuf;
                    trl_burst_diff_lfp_shuffled{session_i,lfp_i,window_i}{trl_i,2} = '+eeg, +lfp';
                end
            end
        end
        
    end
end


%%

clear p_eeg* sum_eeg* chisq_*
for session_i = 14:29
    for lfp_i = 1:2
        % Number
        sum_eegA_lfpA.obs(session_i-13,lfp_i) = sum(strcmp(trl_burst_diff_lfp{session_i, lfp_i}(:,2),'+eeg, +lfp'));
        sum_eegA_lfpB.obs(session_i-13,lfp_i) = sum(strcmp(trl_burst_diff_lfp{session_i, lfp_i}(:,2),'+eeg, -lfp'));
        sum_eegB_lfpA.obs(session_i-13,lfp_i) = sum(strcmp(trl_burst_diff_lfp{session_i, lfp_i}(:,2),'-eeg, +lfp'));
        sum_eegB_lfpB.obs(session_i-13,lfp_i) = sum(strcmp(trl_burst_diff_lfp{session_i, lfp_i}(:,2),'-eeg, -lfp'));
        
        sum_eegA_lfpA.shuf(session_i-13,lfp_i) = sum(strcmp(trl_burst_diff_lfp_shuffled{session_i, lfp_i}(:,2),'+eeg, +lfp'));
        sum_eegA_lfpB.shuf(session_i-13,lfp_i) = sum(strcmp(trl_burst_diff_lfp_shuffled{session_i, lfp_i}(:,2),'+eeg, -lfp'));
        sum_eegB_lfpA.shuf(session_i-13,lfp_i) = sum(strcmp(trl_burst_diff_lfp_shuffled{session_i, lfp_i}(:,2),'-eeg, +lfp'));
        sum_eegB_lfpB.shuf(session_i-13,lfp_i) = sum(strcmp(trl_burst_diff_lfp_shuffled{session_i, lfp_i}(:,2),'-eeg, -lfp'));
        
        % Chi-square
        chisq_conttab{session_i-13,lfp_i} =...
            [sum_eegA_lfpA.obs(session_i-13,lfp_i), sum_eegA_lfpB.obs(session_i-13,lfp_i);...
            sum_eegB_lfpA.obs(session_i-13,lfp_i), sum_eegB_lfpB.obs(session_i-13,lfp_i)];
        
        [chisq_eeg_p(session_i-13,lfp_i), chisq_eeg_x2(session_i-13,lfp_i)] =...
            chisquarecont(chisq_conttab{session_i-13,lfp_i});
    end
end

% Note: upper row of contab is +EEG, and bottom is -EEG.
% Note: left column of contab is +LFP, and right is -EEG.

% Concatenate and sum conttabs over all sessions for upper and lower layers
for session_i = 14:29
    for lfp_i = 1:2
        chi_sq_all{lfp_i}(:,:,session_i) = chisq_conttab{session_i-13,lfp_i};
    end
end
chi_sq_upper_sum = sum(chi_sq_all{1},3);
chi_sq_lower_sum = sum(chi_sq_all{2},3);


% Run Chi-square contingency test on these concatenated contabs.
[chisq_p_upper, chisq_x2_upper] =...
            chisquarecont(chi_sq_upper_sum);
[chisq_p_lower, chisq_x2_lower] =...
            chisquarecont(chi_sq_lower_sum);


