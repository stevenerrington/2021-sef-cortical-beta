%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
analysisWindows = {[-400:-200],[400:600],[0:200],[-400:-200]};
eventBin = {1,1,1,1};
loadDir = 'D:\projectCode\project_stoppingLFP\data\eeg_lfp\';
printFigFlag = 0;


diff_burst_time.obs.upper = cell(1,length(14:29));
diff_burst_time.obs.lower = cell(1,length(14:29));
diff_burst_time.shuf.upper = cell(1,length(14:29));
diff_burst_time.shuf.lower = cell(1,length(14:29));


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
    trials = 1:length(executiveBeh.TrialEventTimes_Overall{session});
    trials_shuffled = trials(randperm(numel(trials)));
    
    % Save output for each alignment on each session
    loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
    data_in = load([loadDir loadfile_label]);
    
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
        for trl_burst_i = 1:length(eeg_burst_times)
            %   Get the burst time in EEG
            eeg_burst_x = eeg_burst_times(trl_burst_i);
            %   For each LFP channel
            for lfp_i = 1:size(data_in.eeg_lfp_burst.LFP_raw{1,1},3)
                % Assign LFP channel to upper or lower layers
                find_laminar = cellfun(@(c) find(c == lfp_i), laminarAlignment.compart, 'uniform', false);
                find_laminar = find(~cellfun(@isempty,find_laminar));
                
                % Find the time of a burst on the same trial
                lfp_burst_times = [];
                lfp_burst_times = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x,:,lfp_i) > 0);
                lfp_burst_times_shuffled = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x_shuf,:,lfp_i) > 0);
                % ... again adjusting for alignment times
                lfp_burst_times = lfp_burst_times - alignmentZero;
                lfp_burst_times_shuffled = lfp_burst_times_shuffled - alignmentZero;
                
                % If there are bursts identified within the LFP
                if ~isempty(lfp_burst_times)
                    % Then added them to the relevant structure for future
                    % analysis
                    diff_burst_time.obs.(laminarAlignment.compart_label{find_laminar}){session_i - 13} =...
                        [diff_burst_time.obs.(laminarAlignment.compart_label{find_laminar}){session_i - 13},...
                        lfp_burst_times-eeg_burst_x];
                end
                
                % ...same for the shuffled condition
                if ~isempty(lfp_burst_times_shuffled)
                    diff_burst_time.shuf.(laminarAlignment.compart_label{find_laminar}){session_i - 13} =...
                        [diff_burst_time.shuf.(laminarAlignment.compart_label{find_laminar}){session_i - 13},...
                        lfp_burst_times_shuffled-eeg_burst_x];
                end
                
            end
            
        end
    end
    
end


%% IN PROGRESS


exitflag = 0; stepSize = 10;
curr_time = 0; count = 0;
clear test
while exitflag ~= 1

    count = count + 1;
    curr_time = curr_time+stepSize;
    fprintf('Window size: %i ms \n',curr_time)
    
    preWindow = [-(curr_time) -1];
    postWindow = [1 curr_time];
    
for session_i = 14:29
    input_diff_times = [];
    input_diff_times = diff_burst_time.obs.(laminarAlignment.compart_label{find_laminar}){session_i - 13};
    
    nBurst_total = length(input_diff_times);
    nBurst_preWindow = length(find(input_diff_times > preWindow(1) & input_diff_times < preWindow(2)));
    nBurst_postWindow = length(find(input_diff_times > postWindow(1) & input_diff_times < postWindow(2)));
    
    pBurst_pre(session_i-13) = (nBurst_preWindow/nBurst_total);
    pBurst_post(session_i-13) = (nBurst_postWindow/nBurst_total);
    
end

test(count,:) = [curr_time, mean(pBurst_pre), mean(pBurst_post)];

if any(pBurst_pre > 0.9); exitflag = 1; end
if any(pBurst_post > 0.9); exitflag = 1; end
end

figure;
plot(test(:,1),test(:,2));




diff_burst_time.obs.(laminarAlignment.compart_label{find_laminar}){session_i - 13}