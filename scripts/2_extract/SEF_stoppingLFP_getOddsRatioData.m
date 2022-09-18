%% Co-activation between channels in SEF
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');

layerLabel = {'LFP_upper','LFP_lower'};
window_edges = {[-600:50:200],[0:50:800],[-200:50:600],[-600:50:200]};

n_windows = length(window_edges{1})-1;


%% Extract LFP data from files
tic

% For each session
for session_i = 14:29
    trl_burst_diff_lfp = {};
    trl_burst_diff_lfp_shuf = {};
    % Get the admin/details
    session = session_i;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest (just fixation here)
    for alignment_i = 1:length(eventAlignments)
        % Get the desired alignment
        alignmentEvent = eventAlignments{alignment_i};
        fprintf(['Alignment: ' alignmentEvent '     \n'])
        
        % Save output for each alignment on each session
        loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
        data_in = load(fullfile(loadDir, loadfile_label));
        
        for window_i = 1:n_windows
            % Get analysis time epoch
            window = [];
            window = [window_edges{alignment_i}(window_i), window_edges{alignment_i}(window_i+1)];
            
            % Get trials of interest
            trials = []; trials_shuffled = [];
            
            if strcmp(alignmentEvent,'saccade')
                trials = executiveBeh.ttx.NC{session_i};
            else
                trials = executiveBeh.ttx_canc{session_i};
            end
            
            
            n_trls = length(trials);
            % We can then shuffled the conditions
            trials_shuffled = trials(randperm(numel(trials)));
            
            % Get zero point
            alignmentZero = abs(data_in.eeg_lfp_burst.eventWindows{alignment_i}(1));
            n_lfps = size(data_in.eeg_lfp_burst.LFP_raw{1,1},3);
            
            for trl_i = 1:n_trls
                %   Get trial index
                trial_x = trials(trl_i);
                trial_x_shuf = trials_shuffled(trl_i);
                
                % Step 2: For each LFP channel in the session, find if a burst occured.
                for lfp_i_i = 1:n_lfps
                    for lfp_i_j = 1:n_lfps
                        % Find the time of a burst on the same & shuffled trial
                        lfp_i_burst_times = []; lfp_i_burst_times_shuffled = [];
                        lfp_j_burst_times = []; lfp_j_burst_times_shuffled = [];
                        
                        lfp_i_burst_times = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x,:,lfp_i_i) > 0);
                        lfp_i_burst_times_shuffled = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x_shuf,:,lfp_i_i) > 0);
                        
                        lfp_j_burst_times = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x,:,lfp_i_j) > 0);
                        lfp_j_burst_times_shuffled = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x_shuf,:,lfp_i_j) > 0);
                        
                        
                        % ... again adjusting for alignment times
                        lfp_i_burst_times = lfp_i_burst_times - alignmentZero;
                        lfp_i_burst_times = lfp_i_burst_times(lfp_i_burst_times > window(1) & lfp_i_burst_times < window(2));
                        
                        lfp_j_burst_times = lfp_j_burst_times - alignmentZero;
                        lfp_j_burst_times = lfp_j_burst_times(lfp_j_burst_times > window(1) & lfp_j_burst_times < window(2));
                        
                        
                        lfp_i_burst_times_shuffled = lfp_i_burst_times_shuffled - alignmentZero;
                        lfp_i_burst_times_shuffled = lfp_i_burst_times_shuffled(lfp_i_burst_times_shuffled > window(1) & lfp_i_burst_times_shuffled < window(2));
                        
                        lfp_j_burst_times_shuffled = lfp_j_burst_times_shuffled - alignmentZero;
                        lfp_j_burst_times_shuffled = lfp_j_burst_times_shuffled(lfp_j_burst_times_shuffled > window(1) & lfp_j_burst_times_shuffled < window(2));
                        
                        
                        lfp_ij_label{lfp_i_i,lfp_i_j,window_i} = [lfp_i_i lfp_i_j];
                        
                        % If there is: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % No beta-burst in EEG, then label trial as 'no eeg burst'
                        if isempty(lfp_i_burst_times) && ~isempty(lfp_j_burst_times)
                            trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,2} = '-lfp_i, +lfp_j';
                        end
                        if isempty(lfp_i_burst_times) && ~isempty(lfp_i_burst_times_shuffled)
                            trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,2} = '-lfp_i, +lfp_j';
                        end
                        
                        % No beta-burst in LFP, then label trial as 'no lfp burst'
                        if ~isempty(lfp_i_burst_times) && isempty(lfp_j_burst_times)
                            trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,2} = '+lfp_i, -lfp_j';
                        end
                        if ~isempty(lfp_i_burst_times) && isempty(lfp_i_burst_times_shuffled)
                            trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,2} = '+lfp_i, -lfp_j';
                        end
                        
                        % No beta-burst in EEG or LFP, then label trial as 'no lfp or eeg burst'
                        if isempty(lfp_i_burst_times) && isempty(lfp_j_burst_times)
                            trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,2} = '-lfp_i, -lfp_j';
                        end
                        if isempty(lfp_i_burst_times) && isempty(lfp_i_burst_times_shuffled)
                            trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,2} = '-lfp_i, -lfp_j';
                        end
                        
                        % Otherwise, find the difference between the burst times
                        % for observed LFP bursts
                        if  ~isempty(lfp_i_burst_times) && ~isempty(lfp_j_burst_times)
                            nearest_lfp_burst_i = []; lfp_diff_burst_time = [];
                            
                            % Find EEG burst closest to LFP burst in time.
                            for lfp_burst_i = 1:length(lfp_j_burst_times)
                                [~,nearest_lfp_burst_i(lfp_burst_i)] =...
                                    min(abs(lfp_i_burst_times-lfp_j_burst_times(lfp_burst_i)));
                                
                                lfp_diff_burst_time(lfp_burst_i) =...
                                    lfp_i_burst_times(nearest_lfp_burst_i(lfp_burst_i)) -...
                                    lfp_j_burst_times(lfp_burst_i);
                            end
                            
                            trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,1} = lfp_diff_burst_time;
                            trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,2} = '+lfp_i, +lfp_j';
                        end
                        
                        % and for shuffled LFP bursts
                        if ~isempty(lfp_i_burst_times) && ~isempty(lfp_i_burst_times_shuffled)
                            shuf_nearest_eeg_burst_i = []; lfp_diff_burst_time_shuf = [];
                            % Find EEG burst closest to LFP burst in time.
                            for shuf_lfp_burst_i = 1:length(lfp_i_burst_times_shuffled)
                                [~,shuf_nearest_eeg_burst_i(shuf_lfp_burst_i)] =...
                                    min(abs(lfp_i_burst_times-lfp_i_burst_times_shuffled(shuf_lfp_burst_i)));
                                
                                lfp_diff_burst_time_shuf(shuf_lfp_burst_i) =...
                                    lfp_i_burst_times(shuf_nearest_eeg_burst_i(shuf_lfp_burst_i)) -...
                                    lfp_i_burst_times_shuffled(shuf_lfp_burst_i);
                            end
                            trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,1} = lfp_diff_burst_time_shuf;
                            trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}{trl_i,2} = '+lfp_i, +lfp_j';
                        end
                    end
                end
            end
        end
    end
    
    save(fullfile(dataDir,'eeg_lfp','intra_lfp',...
        ['trl_burst_diff_intraLFP_session_' int2str(session_i) '.mat']),'trl_burst_diff_lfp','trl_burst_diff_lfp_shuf')
end




%% Extract EEG data from files
if exist(fullfile(dataDir,'eeg_lfp','trl_burst_diff_lfp_chisquare.mat')) == 2
    load(fullfile(dataDir,'eeg_lfp','trl_burst_diff_lfp_chisquare.mat'));
else
    for window_i = 1:n_windows
        % For each session
        for session_i = 14:29
            % Get the admin/details
            session = session_i;
            if window_i == 1
                fprintf('Analysing session %i of %i. \n',session, 29)
            end
            
            % ... and for each epoch of interest (just fixation here)
            for alignment_i = 1:length(eventAlignments)
                % Get the desired alignment
                alignmentEvent = eventAlignments{alignment_i};
                
                % Get analysis time epoch
                window = [window_edges{alignment_i}(window_i), window_edges{alignment_i}(window_i+1)];
                
                % Get trials of interest
                trials = []; trials_shuffled = [];
                
                if strcmp(alignmentEvent,'saccade')
                    trials = executiveBeh.ttx.NC{session_i};
                else
                    trials = executiveBeh.ttx_canc{session_i};
                end
                
                
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
                            trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,2} = '-eeg, +lfp';
                        end
                        if isempty(eeg_burst_times) && ~isempty(lfp_burst_times_shuffled)
                            trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,2} = '-eeg, +lfp';
                        end
                        
                        % No beta-burst in LFP, then label trial as 'no lfp burst'
                        if ~isempty(eeg_burst_times) && isempty(lfp_burst_times)
                            trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,2} = '+eeg, -lfp';
                        end
                        if ~isempty(eeg_burst_times) && isempty(lfp_burst_times_shuffled)
                            trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,2} = '+eeg, -lfp';
                        end
                        
                        % No beta-burst in EEG or LFP, then label trial as 'no lfp or eeg burst'
                        if isempty(eeg_burst_times) && isempty(lfp_burst_times)
                            trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,2} = '-eeg, -lfp';
                        end
                        if isempty(eeg_burst_times) && isempty(lfp_burst_times_shuffled)
                            trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,1} = NaN;
                            trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,2} = '-eeg, -lfp';
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
                            
                            trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,1} = lfp_diff_burst_time;
                            trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,2} = '+eeg, +lfp';
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
                            trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,1} = lfp_diff_burst_time_shuf;
                            trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}{trl_i,2} = '+eeg, +lfp';
                        end
                    end
                end
            end
        end
    end
    
    save(fullfile(dataDir,'eeg_lfp','trl_burst_diff_lfp_chisquare.mat'),'trl_burst_diff_lfp','trl_burst_diff_lfp_shuf')
end



