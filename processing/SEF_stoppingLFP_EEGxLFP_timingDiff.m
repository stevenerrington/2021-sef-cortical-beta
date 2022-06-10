%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
analysisWindows = {[-400:-200],[400:600],[0:200],[-400:-200]};
eventBin = {1,1,1,1};
loadDir = 'D:\projectCode\project_stoppingLFP\data\eeg_lfp\';
printFigFlag = 0;


diff_burst_time.upper = cell(1,length(14:29));
diff_burst_time.lower = cell(1,length(14:29));

%% Extract data from files
% For each session
for session_i = 14:29
    % Get the admin/details
    session = session_i;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest
    alignment_i = 1; % # FOR LOOP
    % Get the desired alignment
    alignmentEvent = eventAlignments{alignment_i};
    
    % Get trials of interest
    trials = [];
    if alignment_i == 2
        trials = executiveBeh.ttx.sNC{session};
        trials_shuffled = executiveBeh.ttx.sNC{session}(randperm(numel(executiveBeh.ttx.sNC{session})));
    else
        trials = executiveBeh.ttx_canc{session};
        trials_shuffled = executiveBeh.ttx_canc{session}(randperm(numel(executiveBeh.ttx_canc{session})));
    end
    
    % Save output for each alignment on each session
    loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
    data_in = load([loadDir loadfile_label]);
    
    % Get zero point
    alignmentZero = abs(eeg_lfp_burst.eventWindows{alignment_i}(1));
    
    % Step 1: find EEG beta-burst time on given trial %%%%%%%%%%%%%%%%%%
    %   Get trial index
    for trl_i = 1:length(trials)
        trial_x = trials(trl_i);
        %   Find burst flags in array row
        eeg_burst_times = find(data_in.eeg_lfp_burst.EEG{1,1}(trial_x,:) > 0);
        %   Adjust time for alignment offset
        eeg_burst_times = eeg_burst_times - alignmentZero;
        
        % Step 2: for each EEG burst, look find the time at which a LFP burst
        % occured %%%%%%%%%%%%%%%%%%%%%%%%%%%
        for trl_burst_i = 1:length(eeg_burst_times)
            %   Get the burst time in EEG
            eeg_burst_x = eeg_burst_times(trl_burst_i);
            %   For each LFP channel
            for lfp_i = 1:size(data_in.eeg_lfp_burst.LFP{1,1},3)
                % Assign LFP channel to upper or lower layers
                find_laminar = cellfun(@(c) find(c == lfp_i), laminarAlignment.compart, 'uniform', false);
                find_laminar = find(~cellfun(@isempty,find_laminar));
                
                % Find the time of a burst on the same trial
                lfp_burst_times = find(data_in.eeg_lfp_burst.LFP{1, 1}(trial_x,:,lfp_i) > 0);
                % ... again adjusting for alignment times
                lfp_burst_times = lfp_burst_times - alignmentZero;
                
                
                if ~isempty(lfp_burst_times)
                    diff_burst_time.(laminarAlignment.compart_label{find_laminar}){session_i - 13} =...
                        [diff_burst_time.(laminarAlignment.compart_label{find_laminar}){session_i - 13},...
                        lfp_burst_times-eeg_burst_x];
                end
             
            end
            
        end
    end
    
end


%%
test_upper = [];
test_lower = [];

for session_i = 14:29
    test_upper = [test_upper, diff_burst_time.upper{session_i - 13}];
    test_lower = [test_lower, diff_burst_time.lower{session_i - 13}];
    
end
test_upper = test_upper(ismember(test_upper,-100:100));
test_lower = test_lower(ismember(test_lower,-100:100));

figure;
histogram(test_upper,-100:10:100,'normalization','probability')

