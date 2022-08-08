%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'fixate','target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');

trl_burst_diff_laminar = {};
trl_burst_diff_laminar_shuffled = {};

layerLabel = {'LFP_upper','LFP_lower'};

window = [-400 -200];

%% Extract data from files
% For each session
for session_i = 14:29
    % Get the admin/details
    session = session_i;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest (just fixation here)
    alignment_i = 2;
    % Get the desired alignment
    alignmentEvent = eventAlignments{alignment_i};
    
    % Get trials of interest
    trials = []; trials_shuffled = [];
    trials = executiveBeh.ttx.GO{session_i};
    % We can then shuffled the conditions
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
        
        %   Find burst flags in array row (% NOTE: EEG we are just taking
        %   the actual trial number, not shuffled).
        eeg_burst_times = find(data_in.eeg_lfp_burst.EEG{1,1}(trial_x,:) > 0);
        %   Adjust time for alignment offset
        eeg_burst_times = eeg_burst_times - alignmentZero;
        %   And only look at bursts during the fixation window (0 to 800 ms
        %   post-fixation).
        eeg_burst_times = eeg_burst_times(eeg_burst_times > window(1) & eeg_burst_times < window(2));
        
        % Step 2: For each LFP channel in the session, find if a burst occured.
        for laminar_i = 1:size(layerLabel,2)
            
            
            % Find the time of a burst on the same & shuffled trial
            lfp_burst_times = []; lfp_burst_times_shuffled = [];
            
            lfp_burst_times = find(data_in.eeg_lfp_burst.(layerLabel{laminar_i}){1, 1}(trial_x,:) > 0);
            lfp_burst_times_shuffled = find(data_in.eeg_lfp_burst.(layerLabel{laminar_i}){1, 1}(trial_x_shuf,:) > 0);
            
            % ... again adjusting for alignment times
            lfp_burst_times = lfp_burst_times - alignmentZero;
            lfp_burst_times = lfp_burst_times(lfp_burst_times > window(1) & lfp_burst_times < window(2));
            
            lfp_burst_times_shuffled = lfp_burst_times_shuffled - alignmentZero;
            lfp_burst_times_shuffled = lfp_burst_times_shuffled(lfp_burst_times_shuffled > window(1) & lfp_burst_times_shuffled < window(2));
            
            % If there is: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % No beta-burst in EEG, then label trial as 'no eeg burst'
            if isempty(eeg_burst_times) && ~isempty(lfp_burst_times)
                trl_burst_diff_laminar{session_i,laminar_i}{trl_i,1} = NaN;
                trl_burst_diff_laminar{session_i,laminar_i}{trl_i,2} = '-eeg, +lfp';
            end
            if isempty(eeg_burst_times) && ~isempty(lfp_burst_times_shuffled)
                trl_burst_diff_laminar_shuffled{session_i,laminar_i}{trl_i,1} = NaN;
                trl_burst_diff_laminar_shuffled{session_i,laminar_i}{trl_i,2} = '-eeg, +lfp';
            end
            
            % No beta-burst in LFP, then label trial as 'no lfp burst'
            if ~isempty(eeg_burst_times) && isempty(lfp_burst_times)
                trl_burst_diff_laminar{session_i,laminar_i}{trl_i,1} = NaN;
                trl_burst_diff_laminar{session_i,laminar_i}{trl_i,2} = '+eeg, -lfp';
            end
            if ~isempty(eeg_burst_times) && isempty(lfp_burst_times_shuffled)
                trl_burst_diff_laminar_shuffled{session_i,laminar_i}{trl_i,1} = NaN;
                trl_burst_diff_laminar_shuffled{session_i,laminar_i}{trl_i,2} = '+eeg, -lfp';
            end
            
            % No beta-burst in EEG or LFP, then label trial as 'no lfp or eeg burst'
            if isempty(eeg_burst_times) && isempty(lfp_burst_times)
                trl_burst_diff_laminar{session_i,laminar_i}{trl_i,1} = NaN;
                trl_burst_diff_laminar{session_i,laminar_i}{trl_i,2} = '-eeg, -lfp';
            end
            if isempty(eeg_burst_times) && isempty(lfp_burst_times_shuffled)
                trl_burst_diff_laminar_shuffled{session_i,laminar_i}{trl_i,1} = NaN;
                trl_burst_diff_laminar_shuffled{session_i,laminar_i}{trl_i,2} = '-eeg, -lfp';
            end
            
            % Otherwise, find the difference between the burst times
            % for observed LFP bursts
            if  ~isempty(eeg_burst_times) && ~isempty(lfp_burst_times)
                nearest_eeg_burst_i = []; lfp_diff_burst_time = [];
                shuf_lfp_burst_i = []; lfp_diff_burst_time_shuf = [];
                
                % Find EEG burst closest to LFP burst in time.
                for lfp_burst_i = 1:length(lfp_burst_times)
                    [~,nearest_eeg_burst_i(lfp_burst_i)] =...
                        min(abs(eeg_burst_times-lfp_burst_times(lfp_burst_i)));
                    
                    lfp_diff_burst_time(lfp_burst_i) =...
                        eeg_burst_times(nearest_eeg_burst_i(lfp_burst_i)) -...
                        lfp_burst_times(lfp_burst_i);
                end
                
                trl_burst_diff_laminar{session_i,laminar_i}{trl_i,1} = lfp_diff_burst_time;
                trl_burst_diff_laminar{session_i,laminar_i}{trl_i,2} = '+eeg, +lfp';
            end
            
            % and for shuffled LFP bursts
            if ~isempty(eeg_burst_times) && ~isempty(lfp_burst_times_shuffled)
                % Find EEG burst closest to LFP burst in time.
                for shuf_lfp_burst_i = 1:length(lfp_burst_times_shuffled)
                    [~,shuf_nearest_eeg_burst_i(shuf_lfp_burst_i)] =...
                        min(abs(eeg_burst_times-lfp_burst_times_shuffled(shuf_lfp_burst_i)));
                    
                    lfp_diff_burst_time_shuf(shuf_lfp_burst_i) =...
                        eeg_burst_times(shuf_nearest_eeg_burst_i(shuf_lfp_burst_i)) -...
                        lfp_burst_times_shuffled(shuf_lfp_burst_i);
                end
                trl_burst_diff_laminar_shuffled{session_i,laminar_i}{trl_i,1} = lfp_diff_burst_time_shuf;
                trl_burst_diff_laminar_shuffled{session_i,laminar_i}{trl_i,2} = '+eeg, +lfp';
            end
        end
    end
    
end

%%
clear p_eeg*
for session_i = 14:29
    for laminar_i = 1:2
        p_eegA_lfpA.obs(session_i-13,laminar_i) = nanmean(strcmp(trl_burst_diff_laminar{session_i, laminar_i}(:,2),'+eeg, +lfp'));
        p_eegA_lfpB.obs(session_i-13,laminar_i) = nanmean(strcmp(trl_burst_diff_laminar{session_i, laminar_i}(:,2),'+eeg, -lfp'));
        p_eegB_lfpA.obs(session_i-13,laminar_i) = nanmean(strcmp(trl_burst_diff_laminar{session_i, laminar_i}(:,2),'-eeg, +lfp'));
        p_eegB_lfpB.obs(session_i-13,laminar_i) = nanmean(strcmp(trl_burst_diff_laminar{session_i, laminar_i}(:,2),'-eeg, -lfp'));
        
        p_eegA_lfpA.shuf(session_i-13,laminar_i) = nanmean(strcmp(trl_burst_diff_laminar_shuffled{session_i, laminar_i}(:,2),'+eeg, +lfp'));
        p_eegA_lfpB.shuf(session_i-13,laminar_i) = nanmean(strcmp(trl_burst_diff_laminar_shuffled{session_i, laminar_i}(:,2),'+eeg, -lfp'));
        p_eegB_lfpA.shuf(session_i-13,laminar_i) = nanmean(strcmp(trl_burst_diff_laminar_shuffled{session_i, laminar_i}(:,2),'-eeg, +lfp'));
        p_eegB_lfpB.shuf(session_i-13,laminar_i) = nanmean(strcmp(trl_burst_diff_laminar_shuffled{session_i, laminar_i}(:,2),'-eeg, -lfp'));
    end
end

%% Generate figure
data = [];
data = [p_eegA_lfpA.obs(:,1); p_eegA_lfpB.obs(:,1); p_eegB_lfpA.obs(:,1); p_eegB_lfpB.obs(:,1);...
    p_eegA_lfpA.obs(:,2); p_eegA_lfpB.obs(:,2); p_eegB_lfpA.obs(:,2); p_eegB_lfpB.obs(:,2);...
    p_eegA_lfpA.shuf(:,1); p_eegA_lfpB.shuf(:,1); p_eegB_lfpA.shuf(:,1); p_eegB_lfpB.shuf(:,1);...
    p_eegA_lfpA.shuf(:,2); p_eegA_lfpB.shuf(:,2); p_eegB_lfpA.shuf(:,2); p_eegB_lfpB.shuf(:,2)];

signal_label = repmat([repmat({'+eeg,+lfp'},length(14:29),1);...
    repmat({'+eeg,-lfp'},length(14:29),1);
    repmat({'-eeg,+lfp'},length(14:29),1);
    repmat({'-eeg,-lfp'},length(14:29),1)],4,1);

layer_label = ...
    repmat([repmat({'1_upper'},length(14:29)*4,1);repmat({'2_lower'},length(14:29)*4,1)],2,1);

shuf_label = ...
    [repmat({'1_obs'},length(14:29)*8,1);repmat({'2_shuf'},length(14:29)*8,1)];

monkey_label = repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),4*4,1);

% Setup the figure in gramm
clear test % Clear the figure from matlabs memory as we're writing it new

% Input data into the gramm library:
test(1,1)= gramm('x',signal_label,'y',data,'color',shuf_label);
% Set the figure up as a point/line figure with 95% CI error bar:
test(1,1).stat_summary('type','sem','geom',{'bar','errorbar'});
% Set figure parameters:
test(1,1).axe_property('YLim',[0.0 1.00]);
test(1,1).facet_grid(layer_label,monkey_label);
%... and print it!
figure('Renderer', 'painters', 'Position', [100 100 500 600]);
test.draw();



