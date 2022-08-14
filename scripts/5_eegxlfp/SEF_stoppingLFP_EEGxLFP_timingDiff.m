%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'fixate','target','saccade','stopSignal','tone'};
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
        eeg_burst_times = eeg_burst_times(eeg_burst_times > 0 & eeg_burst_times < 800);
        
        % Step 2: For each LFP channel in the session, find if a burst occured.
        for lfp_i = 1:size(data_in.eeg_lfp_burst.LFP_raw{1,1},3)
            
            
            % Find the time of a burst on the same & shuffled trial
            lfp_burst_times = []; lfp_burst_times_shuffled = [];
            lfp_burst_times = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x,:,lfp_i) > 0);
            lfp_burst_times_shuffled = find(data_in.eeg_lfp_burst.LFP_raw{1, 1}(trial_x_shuf,:,lfp_i) > 0);
            
            % ... again adjusting for alignment times
            lfp_burst_times = lfp_burst_times - alignmentZero;
            lfp_burst_times = lfp_burst_times(lfp_burst_times > 0 & lfp_burst_times < 800);
            
            lfp_burst_times_shuffled = lfp_burst_times_shuffled - alignmentZero;
            lfp_burst_times_shuffled = lfp_burst_times_shuffled(lfp_burst_times_shuffled > 0 & lfp_burst_times_shuffled < 800);
            
            % If there is: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % No beta-burst in EEG, then label trial as 'no eeg burst'
            if isempty(eeg_burst_times) && ~isempty(lfp_burst_times)
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,1} = NaN;
                trl_burst_diff_lfp{session_i,lfp_i}{trl_i,2} = '-eeg, +lfp';
            end
            if isempty(eeg_burst_times) && ~isempty(lfp_burst_times_shuffled)
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

bin = [-250:10:250];
pBurst_lfp_eeg.obs.upper = {}; pBurst_lfp_eeg.obs.lower = {};
pBurst_lfp_eeg.shuf.upper = {}; pBurst_lfp_eeg.shuf.lower = {};


for session_i = 14:29
    fprintf('Analysing session %i of %i. \n',session_i, 29)
    nLFP = max(find(cell2mat(cellfun(@(x) ~isempty(x),...
        trl_burst_diff_lfp(session_i,:), 'UniformOutput', false))));
    
    
    % Find total number of EEG bursts (using first contact - tested and
    % verified the EEG burst is the same across channels).
    eeg_burst_array = [];
    eeg_burst_array = ~cellfun(@isempty,regexp(trl_burst_diff_lfp{session_i, 1}(:,2),'+eeg','once'));
    nBursts_EEG = sum(eeg_burst_array);
        
        % Go through the bins defined above
    for bin_i = 1:length(bin)-1
        lfp_bin_burst = []; lfp_bin_burst_shuf = [];
        
        for lfp_i = 1:nLFP           
            % Set data up
            input = []; input = trl_burst_diff_lfp{session_i, lfp_i};
            input_shuffled = []; input_shuffled = trl_burst_diff_lfp_shuffled{session_i, lfp_i};
            
            % Define the filter window (i.e. bin edge)
            filter_window = [bin(bin_i) bin(bin_i+1)];
            
            % Find bursts within given window
            
            input_window_flag = []; input_window_flag_shuffled = [];
            
            input_window_flag = cellfun(@(x)...
                x >= filter_window(1) & x <= filter_window(2),...
                input(:,1), 'UniformOutput', false);
            
            input_window_flag_shuffled = cellfun(@(x)...
                x >= filter_window(1) & x <= filter_window(2),...
                input_shuffled(:,1), 'UniformOutput', false);
            
             % Find total number of LFP bursts in the defined window
             
            lfp_bin_burst(:,lfp_i) = cell2mat(cellfun(@(x) any((x) == 1), input_window_flag, 'UniformOutput', false));            
            lfp_bin_burst_shuf(:,lfp_i) = cell2mat(cellfun(@(x) any((x) == 1), input_window_flag_shuffled, 'UniformOutput', false));            
            
        end
                
        % Get trials with an EEG burst
        eeg_burst_trls = []; eeg_burst_trls = find(eeg_burst_array == 1);
        
        % Find p(trials) in which a burst occured in any channel in
        % upper/lower layers separately, on trials in which an EEG burst
        % was observed
        pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_i) = nanmean(sum(lfp_bin_burst(eeg_burst_trls,1:8),2) > 0);
        pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_i) = nanmean(sum(lfp_bin_burst(eeg_burst_trls,9:end),2) > 0);
        
        pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_i) = nanmean(sum(lfp_bin_burst_shuf(eeg_burst_trls,1:8),2) > 0);
        pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_i) = nanmean(sum(lfp_bin_burst_shuf(eeg_burst_trls,9:end),2) > 0);
    
        pBurst_lfp_eeg.diff.upper{session_i-13}(:,bin_i) =  pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_i) - pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_i);
        pBurst_lfp_eeg.diff.lower{session_i-13}(:,bin_i) =  pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_i) - pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_i);
    
    
    end
    
    
end


%% Analysis: Find bursts in 50 ms
bin_preEEG = find(getMidBin(bin) > -50 & getMidBin(bin) < 0);
bin_postEEG = find(getMidBin(bin) > 0 & getMidBin(bin) < 50);

clear eeg_pre_* eeg_post_*
for session_i = 14:29
    fprintf('Analysing session %i of %i. \n',session_i, 29)

    % Pre-EEG burst period
    eeg_pre_upper(session_i-13) = sum(pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_preEEG));
    eeg_pre_lower(session_i-13) = sum(pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_preEEG));
    eeg_pre_upper_shuf(session_i-13) = sum(pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_preEEG));
    eeg_pre_lower_shuf(session_i-13) = sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_preEEG));  
    
    % Post-EEG burst period
    eeg_post_upper(session_i-13) = sum(pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_postEEG));
    eeg_post_lower(session_i-13) = sum(pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_postEEG));
    eeg_post_upper_shuf(session_i-13) = sum(pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_postEEG));
    eeg_post_lower_shuf(session_i-13) = sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_postEEG));  
    
end


%% Figure: Autocorrelogram
SEF_stoppingLFP_EEGxLFP_autocorrFig

%% Analysis: LFP x EEG co-incidence
% Note: this requires the previous script to be run.
% Here, we look at the point at which the incidence of LFP bursts observed
% exceeds that expected by chance.
lower_autocorr = temporal_diff_figure.results.stat_summary(1).yci;
upper_autocorr = temporal_diff_figure.results.stat_summary(2).yci;
bin_center = getMidBin(bin);

[LL_LCI_start, LL_LCI_len, ~] = ZeroOnesCount(lower_autocorr(2,:) > 0);
[LL_UCI_start, LL_UCI_len, ~] = ZeroOnesCount(lower_autocorr(1,:) > 0);
[UL_LCI_start, UL_LCI_len, ~] = ZeroOnesCount(upper_autocorr(2,:) > 0);
[UL_UCI_start, UL_UCI_len, ~] = ZeroOnesCount(upper_autocorr(1,:) > 0);

LL_LCI_times = bin_center(LL_LCI_start(find(LL_LCI_len >= 5)));
LL_UCI_times = bin_center(LL_UCI_start(find(LL_UCI_len >= 5)));
UL_LCI_times = bin_center(UL_LCI_start(find(UL_LCI_len >= 5)));
UL_UCI_times = bin_center(UL_UCI_start(find(UL_UCI_len >= 5)));

[LL_LCI_times,~] = min(abs(LL_LCI_times-0));
[LL_UCI_times,~] = min(abs(LL_UCI_times-0));
[UL_LCI_times,~] = min(abs(UL_LCI_times-0));
[UL_UCI_times,~] = min(abs(UL_UCI_times-0));


figure
subplot(2,1,1); hold on
plot(bin_center, upper_autocorr(1,:),'b')
plot(bin_center, upper_autocorr(2,:),'r')
hline(0,'k--')
subplot(2,1,2); hold on
plot(bin_center, lower_autocorr(1,:),'b')
plot(bin_center, lower_autocorr(2,:),'r')
hline(0,'k--')


% Visual inspection w/point inspection tool
ul_UCI_onset = -65; ul_UCI_offset = 85;
ul_LCI_onset = -35; ul_LCI_offset = 55;

ll_UCI_onset = -115; ll_UCI_offset = 145;
ll_LCI_onset = -15; ll_LCI_offset = 65;



%% Analysis: Area pre-post
bin_preEEG = find(getMidBin(bin) > -50 & getMidBin(bin) < 0);
bin_postEEG = find(getMidBin(bin) > 0 & getMidBin(bin) < 50);


clear eeg_pre_* eeg_post_*
for session_i = 14:29
    fprintf('Analysing session %i of %i. \n',session_i, 29)

    % 10 is the bin size: area is sum(bin height x bin width)
    eeg_pre_upper_obs_area(session_i-13) = sum(pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_preEEG)*10);
    eeg_pre_lower_obs_area(session_i-13) = sum(pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_preEEG)*10);
    eeg_pre_upper_shuf_area(session_i-13) = sum(pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_preEEG)*10);
    eeg_pre_lower_shuf_area(session_i-13) = sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_preEEG)*10);
    
    eeg_post_upper_obs_area(session_i-13) = sum(pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_postEEG)*10);
    eeg_post_lower_obs_area(session_i-13) = sum(pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_postEEG)*10);
    eeg_post_upper_shuf_area(session_i-13) = sum(pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_postEEG)*10);
    eeg_post_lower_shuf_area(session_i-13) = sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_postEEG)*10);
        
    
    eeg_pre_upper_diff_area(session_i-13) = eeg_pre_upper_obs_area(session_i-13) -  eeg_pre_upper_shuf_area(session_i-13);
    eeg_pre_lower_diff_area(session_i-13) = eeg_pre_lower_obs_area(session_i-13) -  eeg_pre_lower_shuf_area(session_i-13);
    eeg_post_upper_diff_area(session_i-13) = eeg_post_upper_obs_area(session_i-13) -  eeg_post_upper_shuf_area(session_i-13);
    eeg_post_lower_diff_area(session_i-13) = eeg_post_lower_obs_area(session_i-13) -  eeg_post_lower_shuf_area(session_i-13);

    eeg_prepost_upper_area_diff(session_i-13) = eeg_post_upper_diff_area(session_i-13) - eeg_pre_upper_diff_area(session_i-13);
    eeg_prepost_lower_area_diff(session_i-13) = eeg_post_lower_diff_area(session_i-13) - eeg_pre_lower_diff_area(session_i-13);
    
end

%% Figure: autocorrelation area
data = [];
data = [eeg_prepost_upper_area_diff';eeg_prepost_lower_area_diff'];

layer_label = {};
layer_label = [repmat({'Upper'},length(eeg_prepost_upper_area_diff),1);...
    repmat({'Lower'},length(eeg_prepost_lower_area_diff),1)];

monkey_label = {};
monkey_label = repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),2,1);

clear test_figure
autocorr_area_fig(1,1) = gramm('x',layer_label,'y',data,'color',layer_label);
autocorr_area_fig(1,1).stat_summary('type','sem','geom',{'point','errorbar'});
autocorr_area_fig(1,1).geom_hline('yintercept',0,'style','k-'); 

autocorr_area_fig(1,2) = gramm('x',layer_label,'y',data,'color',layer_label);
autocorr_area_fig(1,2).stat_summary('type','sem','geom',{'point','errorbar'});
autocorr_area_fig(1,2).geom_hline('yintercept',0,'style','k-'); 
autocorr_area_fig(1,2).facet_grid([],monkey_label);


figure('Renderer', 'painters', 'Position', [100 100 900 300]);
autocorr_area_fig.draw();

% Table: JASP output
autocorr_area_table = table(data,layer_label,monkey_label);

writetable(autocorr_area_table,...
    fullfile(rootDir,'results','jasp_tables','autocorr_area_table.csv'),'WriteRowNames',true)
