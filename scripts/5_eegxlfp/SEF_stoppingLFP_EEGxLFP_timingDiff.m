%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');

trl_burst_diff_lfp = {};
trl_burst_diff_lfp_shuffled = {};


%% Extract data from files
% For each session
for session_i = 14:29
    % Get the admin/details
    session = session_i;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest (just fixation here)
    alignment_i = 1;
    % Get the desired alignment
    alignmentEvent = eventAlignments{alignment_i};
    
    % Get trials of interest
    trials = []; trials_shuffled = [];
    %         trials = ttx.activeTrials{sessionIdx};
    %         trials_shuffled = trials(randperm(numel(trials)));
    
    if alignment_i == 2 % If aligning on saccade, then we will look at error trials
        trials = executiveBeh.ttx.sNC{session_i};
    else % Otherwise, we will just look at canceled trials
        trials = executiveBeh.ttx_canc{session_i};
    end
    
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
        
        % Step 2: For each LFP channel in the session, find if a burst occured.
        for lfp_i = 1:size(data_in.eeg_lfp_burst.LFP_raw{1,1},3)
            
            % Assign LFP channel to upper or lower layers
            find_laminar = cellfun(@(c) find(c == lfp_i), laminarAlignment.compart, 'uniform', false);
            find_laminar = find(~cellfun(@isempty,find_laminar));
            laminar_compart = laminarAlignment.compart_label{find_laminar};
            
            % Find the time of a burst on the same & shuffled trial
            lfp_burst_times = []; lfp_burst_times_shuffled = [];
            lfp_burst_times = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x,:,lfp_i) > 0);
            lfp_burst_times_shuffled = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x_shuf,:,lfp_i) > 0);
            
            % ... again adjusting for alignment times
            lfp_burst_times = lfp_burst_times - alignmentZero;
            lfp_burst_times_shuffled = lfp_burst_times_shuffled - alignmentZero;
            
            % If there is: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % No beta-burst in EEG, then label trial as 'no eeg burst'
            if isempty(eeg_burst_times) && ~isempty(lfp_burst_times)
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,1} = NaN;
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,2} = '-eeg, +lfp';
                
                trl_burst_diff_lfp_shuffled{session_i,lfp_i}{trl_i,1} = NaN;
                trl_burst_diff_lfp_shuffled{session_i,lfp_i}{trl_i,2} = '-eeg, +lfp';
            end
            % No beta-burst in LFP, then label trial as 'no lfp burst'
            if ~isempty(eeg_burst_times) && isempty(lfp_burst_times)
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,1} = NaN;
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,2} = '+eeg, -lfp';
            end
            if ~isempty(eeg_burst_times) && isempty(lfp_burst_times_shuffled)
                trl_burst_diff_lfp_shuffled{session_i,lfp_i}{trl_i,1} = NaN;
                trl_burst_diff_lfp_shuffled{session_i,lfp_i}{trl_i,2} = '+eeg, -lfp';
            end
            % No beta-burst in EEG or LFP, then label trial as 'no lfp or eeg burst'
            if isempty(eeg_burst_times) && isempty(lfp_burst_times)
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,1} = NaN;
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,2} = '-eeg, -lfp';
            end
            if isempty(eeg_burst_times) && isempty(lfp_burst_times_shuffled)
                trl_burst_diff_lfp_shuffled{session_i,lfp_i}{trl_i,1} = NaN;
                trl_burst_diff_lfp_shuffled{session_i,lfp_i}{trl_i,2} = '-eeg, -lfp';
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
                
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,1} = lfp_diff_burst_time;
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,2} = '+eeg, +lfp';
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
                trl_burst_diff_lfp_shuffled{session_i,lfp_i}{trl_i,1} = lfp_diff_burst_time_shuf;
                trl_burst_diff_lfp_shuffled{session_i,lfp_i}{trl_i,2} = '+eeg, +lfp';
            end
        end
    end
end

%% Analysis: get proportion of bursts that occur in EEG, LFP

% Parameterize the window
filter_window_pre = [-50 0];
filter_window_post = [0 50];

% Setup arrays
p_eeg_lfp.obs.eeg_and_lfp_all = nan(length(1:17),length(14:29));
p_eeg_lfp.obs.eeg_and_lfp_window_pre = nan(length(1:17),length(14:29));
p_eeg_lfp.obs.eeg_and_lfp_window_post = nan(length(1:17),length(14:29));
p_eeg_lfp.obs.eeg_and_nolfp = nan(length(1:17),length(14:29));
p_eeg_lfp.obs.noeeg_and_lfp = nan(length(1:17),length(14:29));
p_eeg_lfp.obs.noeeg_and_nolfp = nan(length(1:17),length(14:29));

p_eeg_lfp.shuf.eeg_and_lfp_all = nan(length(1:17),length(14:29));
p_eeg_lfp.shuf.eeg_and_lfp_window_pre = nan(length(1:17),length(14:29));
p_eeg_lfp.shuf.eeg_and_lfp_window_post = nan(length(1:17),length(14:29));
p_eeg_lfp.shuf.eeg_and_nolfp = nan(length(1:17),length(14:29));
p_eeg_lfp.shuf.noeeg_and_lfp = nan(length(1:17),length(14:29));
p_eeg_lfp.shuf.noeeg_and_nolfp = nan(length(1:17),length(14:29));

% Define session and contact
for session_i = 14:29
    nLFP = max(find(cell2mat(cellfun(@(x) ~isempty(x),...
        trl_burst_diff_lfp(session_i,:), 'UniformOutput', false))));
    
    for lfp_i = 1:nLFP
                
        % Find trials in which there was a co-occurance of an EEG and LFP
        % beta-burst
        clear input_window_pre input_window_post input_window_pre_shuf input_window_post_shuf
        
        % Observed:
        input = []; input = trl_burst_diff_lfp{session_i, lfp_i};
        input_window_pre = cellfun(@(x) x > filter_window_pre(1) & x < filter_window_pre(2), input(:,1), 'UniformOutput', false);
        input_window_post = cellfun(@(x) x > filter_window_post(1) & x < filter_window_post(2), input(:,1), 'UniformOutput', false);
        
        % Find proportion of trials with burst in EEG, LFP, both, or
        % none.
        p_eeg_lfp.obs.eeg_and_lfp_all(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(~isnan(x) == 1), input(:,1), 'UniformOutput', false)));
        p_eeg_lfp.obs.eeg_and_lfp_window_pre(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(x == 1), input_window_pre, 'UniformOutput', false)));
        p_eeg_lfp.obs.eeg_and_lfp_window_post(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(x == 1), input_window_post, 'UniformOutput', false)));
        p_eeg_lfp.obs.eeg_and_nolfp(lfp_i, session_i-13) = nanmean(strcmp(input(:,2),'+eeg, -lfp')); % Obs EEG burst, no LFP burst;
        p_eeg_lfp.obs.noeeg_and_lfp(lfp_i, session_i-13) = nanmean(strcmp(input(:,2),'-eeg, +lfp')); % No EEG burst, Obs LFP burst
        p_eeg_lfp.obs.noeeg_and_nolfp(lfp_i, session_i-13) = nanmean(strcmp(input(:,2),'-eeg, -lfp')); % No EEG burst, Obs LFP burst
        
        % Shuffled:
        input_shuffled = []; input_shuffled = trl_burst_diff_lfp_shuffled{session_i, lfp_i};
        
        input_window_pre_shuf = cellfun(@(x) x > filter_window_pre(1) & x < filter_window_pre(2), input_shuffled(:,1), 'UniformOutput', false);
        input_window_post_shuf = cellfun(@(x) x > filter_window_post(1) & x < filter_window_post(2), input_shuffled(:,1), 'UniformOutput', false);
        
        % Find proportion of trials with burst in EEG, LFP, both, or
        % none.
        p_eeg_lfp.shuf.eeg_and_lfp_all(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(~isnan(x) == 1), input_shuffled(:,1), 'UniformOutput', false)));
        p_eeg_lfp.shuf.eeg_and_lfp_window_pre(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(x == 1), input_window_pre_shuf, 'UniformOutput', false)));
        p_eeg_lfp.shuf.eeg_and_lfp_window_post(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(x == 1), input_window_post_shuf, 'UniformOutput', false)));
        p_eeg_lfp.shuf.eeg_and_nolfp(lfp_i,session_i-13) = nanmean(strcmp(input_shuffled(:,2),'+eeg, -lfp')); % Obs EEG burst, no LFP burst;
        p_eeg_lfp.shuf.noeeg_and_lfp(lfp_i,session_i-13) = nanmean(strcmp(input_shuffled(:,2),'-eeg, +lfp')); % No EEG burst, Obs LFP burst
        p_eeg_lfp.shuf.noeeg_and_nolfp(lfp_i,session_i-13) = nanmean(strcmp(input_shuffled(:,2),'-eeg, -lfp')); % No EEG burst, Obs LFP burst
        
    end
end

%%
beta_burst_diffTimes.obs.upper = []; beta_burst_diffTimes.obs.lower = [];
beta_burst_diffTimes.shuf.upper = []; beta_burst_diffTimes.shuf.lower = [];
for session_i = 14:29
    fprintf('Analysing session %i of %i. \n',session_i, 29)
    
    nLFP = max(find(cell2mat(cellfun(@(x) ~isempty(x),...
        trl_burst_diff_lfp(session_i,:), 'UniformOutput', false))));
    
    for lfp_i = 1:nLFP
        % Assign LFP channel to upper or lower layers
        find_laminar = cellfun(@(c) find(c == lfp_i), laminarAlignment.compart, 'uniform', false);
        find_laminar = find(~cellfun(@isempty,find_laminar));
        laminar_compart = laminarAlignment.compart_label{find_laminar};
        
        for trl_i = 1:length(trl_burst_diff_lfp{session_i, lfp_i})
            beta_burst_diffTimes.obs.(laminar_compart) =...
                [beta_burst_diffTimes.obs.(laminar_compart), trl_burst_diff_lfp{session_i, lfp_i}{trl_i}];
            
            beta_burst_diffTimes.shuf.(laminar_compart) =...
                [beta_burst_diffTimes.shuf.(laminar_compart), trl_burst_diff_lfp_shuffled{session_i, lfp_i}{trl_i}];
        end
    end
end


%% 

clear a b c test_a test_b
laminar_compart = 'lower';
bins = [-200:10:200];

[a,b] = histcounts( beta_burst_diffTimes.obs.(laminar_compart), bins)
[c,~] = histcounts( beta_burst_diffTimes.shuf.(laminar_compart), bins)

nBursts = sum(~isnan(beta_burst_diffTimes.obs.(laminar_compart)))
nBursts_shuffled = sum(~isnan(beta_burst_diffTimes.shuf.(laminar_compart)))

a = (a/nBursts) * 100;
b = b(2:end)-((bins(2)-bins(1))/2);
c = (c/nBursts_shuffled) * 100;

figure; hold on
plot(b,a)
plot(b,c)

test_a = nanmean(nanmean(p_eeg_lfp.obs.eeg_and_lfp_window_pre(9:end,:),2))*100
test_b = sum(a(find(b > filter_window_pre(1) & b < filter_window_pre(2))))







%% Annex %%
% eeg_x_lfp_delta.shuf.upper = []; eeg_x_lfp_delta.shuf.lower = [];
% eeg_x_lfp_delta.obs.upper = [];  eeg_x_lfp_delta.obs.lower = [];
%
% for session_i = 1:16
%     eeg_x_lfp_delta.shuf.upper = [eeg_x_lfp_delta.shuf.upper; ...
%         diff_burst_time.shuf.upper{session_i}'];
%
%     eeg_x_lfp_delta.shuf.lower = [eeg_x_lfp_delta.shuf.lower; ...
%         diff_burst_time.shuf.lower{session_i}'];
%
%     eeg_x_lfp_delta.obs.upper = [eeg_x_lfp_delta.obs.upper; ...
%         diff_burst_time.obs.upper{session_i}'];
%
%     eeg_x_lfp_delta.obs.lower = [eeg_x_lfp_delta.obs.lower; ...
%         diff_burst_time.obs.lower{session_i}'];
% end
%
% displayWindow = [-250:10:250];
% NM = 'probability';
% figure('Renderer', 'painters', 'Position', [100 100 400 250]); hold on
% histogram(eeg_x_lfp_delta.obs.upper,displayWindow,'DisplayStyle','stairs','Normalization',NM);
% histogram(eeg_x_lfp_delta.obs.lower,displayWindow,'DisplayStyle','stairs','Normalization',NM);
%
% histogram(eeg_x_lfp_delta.shuf.upper,displayWindow,'DisplayStyle','stairs','Normalization',NM);
% histogram(eeg_x_lfp_delta.shuf.lower,displayWindow,'DisplayStyle','stairs','Normalization',NM);
%
% xlim([displayWindow(1) displayWindow(end)])
% % ylim([0 0.02])
% legend({'upper-obs','lower-obs','upper-shuf','lower-shuf'},'location','eastoutside')
%
%
% % ylim([0.005 0.020])
%
% nanmean(eeg_x_lfp_delta.obs.upper > -50 & eeg_x_lfp_delta.obs.upper < 0)
%
