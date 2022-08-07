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
        
        % Step 2: For each LFP channel in the session, find if a burst occured.
        for lfp_i = 1:size(data_in.eeg_lfp_burst.LFP_raw{1,1},3)
            
            
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
    eeg_pre_lower_shuf(session_i-13) = sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_preEEG))  ;  
    
    
    % Post-EEG burst period
    eeg_post_upper(session_i-13) = sum(pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_postEEG));
    eeg_post_lower(session_i-13) = sum(pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_postEEG));
    eeg_post_upper_shuf(session_i-13) = sum(pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_postEEG));
    eeg_post_lower_shuf(session_i-13) = sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_postEEG));  
    
end


%% Figure: Autocorrelogram

clear temporal_corr_figure % clear the gramm variable, incase it already exists

% Input relevant data into the gramm function, and set the parameters
% Fixation aligned
temporal_corr_figure(1,1)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.obs.upper'; pBurst_lfp_eeg.shuf.upper';...
    pBurst_lfp_eeg.obs.lower'; pBurst_lfp_eeg.shuf.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Upper - Shuffled'},16,1);...
    repmat({'Lower'},16,1);repmat({'Lower - Shuffled'},16,1)]);
temporal_corr_figure(1,1).stat_summary();
temporal_corr_figure(1,1).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure.set_names('y','');
temporal_corr_figure.axe_property('YLim',[0.1 0.40]);


figure('Renderer', 'painters', 'Position', [100 100 500 300]);
temporal_corr_figure.draw();


% Figure: Split by monkey
monkeyLabels = {};
monkeyLabels = repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),4,1);

temporal_corr_figure_monkey(1,1)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.obs.upper'; pBurst_lfp_eeg.shuf.upper';...
    pBurst_lfp_eeg.obs.lower'; pBurst_lfp_eeg.shuf.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Upper - Shuffled'},16,1);...
    repmat({'Lower'},16,1);repmat({'Lower - Shuffled'},16,1)],...
    'subset',strcmp(monkeyLabels,'Euler'));

temporal_corr_figure_monkey(1,2)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.obs.upper'; pBurst_lfp_eeg.shuf.upper';...
    pBurst_lfp_eeg.obs.lower'; pBurst_lfp_eeg.shuf.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Upper - Shuffled'},16,1);...
    repmat({'Lower'},16,1);repmat({'Lower - Shuffled'},16,1)],...
    'subset',strcmp(monkeyLabels,'Xena'));



temporal_corr_figure_monkey(1,1).stat_summary();
temporal_corr_figure_monkey(1,2).stat_summary();
temporal_corr_figure_monkey(1,1).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure_monkey(1,2).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure_monkey.set_names('y','');
temporal_corr_figure_monkey.axe_property('YLim',[0.1 0.50]);


figure('Renderer', 'painters', 'Position', [100 100 1000 300]);
temporal_corr_figure_monkey.draw();




%% Figure: 50 ms burst window
data = [eeg_pre_upper'; eeg_pre_lower'; eeg_pre_upper_shuf'; eeg_pre_lower_shuf';...
    eeg_post_upper'; eeg_post_lower'; eeg_post_upper_shuf'; eeg_post_lower_shuf'];
nSessions = length(14:29);

label_obs_shuf = repmat([repmat({'Obs.'},nSessions*2,1);repmat({'Shuf'},nSessions*2,1)],2,1);
label_pre_post = [repmat({'1_pre-EEG'},nSessions*4,1);repmat({'2_post-EEG'},nSessions*4,1)];
label_upper_lower = repmat([repmat({'Upper'},nSessions,1);repmat({'Lower'},nSessions,1)],4,1);

pBurst_layer_epoch_plot(1,1) = gramm('x',label_pre_post,...
    'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Upper'));
pBurst_layer_epoch_plot(1,2) = gramm('x',label_pre_post,...
    'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Lower'));


pBurst_layer_epoch_plot(1,1).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
pBurst_layer_epoch_plot(1,2).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
pBurst_layer_epoch_plot(1,1).axe_property('YLim',[1.0 1.8]);
pBurst_layer_epoch_plot(1,2).axe_property('YLim',[1.0 1.8]);
figure('Renderer', 'painters', 'Position', [100 100 700 300]);
pBurst_layer_epoch_plot.draw();

% Figure: split by monkey
monkeyLabels = {};
monkeyLabels = repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),8,1);

pBurst_layer_epoch_plot(1,1) = gramm('x',label_pre_post,...
    'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Upper') & strcmp(monkeyLabels,'Euler'));
pBurst_layer_epoch_plot(1,2) = gramm('x',label_pre_post,...
    'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Lower') & strcmp(monkeyLabels,'Euler'));
pBurst_layer_epoch_plot(2,1) = gramm('x',label_pre_post,...
    'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Upper') & strcmp(monkeyLabels,'Euler'));
pBurst_layer_epoch_plot(2,2) = gramm('x',label_pre_post,...
    'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Lower') & strcmp(monkeyLabels,'Xena'));

pBurst_layer_epoch_plot(1,1).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
pBurst_layer_epoch_plot(1,2).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
pBurst_layer_epoch_plot(2,1).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
pBurst_layer_epoch_plot(2,2).stat_summary('type','sem','geom',{'point','line','black_errorbar'});

pBurst_layer_epoch_plot(1,1).axe_property('YLim',[1.0 2]);
pBurst_layer_epoch_plot(1,2).axe_property('YLim',[1.0 2]);
pBurst_layer_epoch_plot(2,1).axe_property('YLim',[1.0 2]);
pBurst_layer_epoch_plot(2,2).axe_property('YLim',[1.0 2]);

figure('Renderer', 'painters', 'Position', [100 100 700 600]);
pBurst_layer_epoch_plot.draw();
%% Analysis: Cumulative P(burst) through time relative to EEG burst

clear cumul_eeg_pre_* cumul_eeg_post_* bin_preEEG bin_postEEG

bin_preEEG = find(getMidBin(bin) < 0);
bin_postEEG = find(getMidBin(bin) > 0);

for session_i = 14:29
    fprintf('Analysing session %i of %i. \n',session_i, 29)
    
    for bin_i_pre = 1:length(bin_preEEG)
        cumul_eeg_pre_upper_obs{session_i - 13}(1,bin_i_pre) =...
            sum(pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_preEEG(1):bin_preEEG(bin_i_pre)));
        cumul_eeg_pre_upper_shuf{session_i - 13}(1,bin_i_pre) =...
            sum(pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_preEEG(1):bin_preEEG(bin_i_pre)));        
        cumul_eeg_pre_lower_obs{session_i - 13}(1,bin_i_pre) =...
            sum(pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_preEEG(1):bin_preEEG(bin_i_pre)));
        cumul_eeg_pre_lower_shuf{session_i - 13}(1,bin_i_pre) =...
            sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_preEEG(1):bin_preEEG(bin_i_pre)));    
    end
    
    for bin_i_post = 1:length(bin_postEEG)
        cumul_eeg_post_upper_obs{session_i - 13}(1,bin_i_post) =...
            sum(pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_postEEG(1):bin_postEEG(bin_i_post)));
        cumul_eeg_post_upper_shuf{session_i - 13}(1,bin_i_post) =...
            sum(pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_postEEG(1):bin_postEEG(bin_i_post)));        
        cumul_eeg_post_lower_obs{session_i - 13}(1,bin_i_post) =...
            sum(pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_postEEG(1):bin_postEEG(bin_i_post)));
        cumul_eeg_post_lower_shuf{session_i - 13}(1,bin_i_post) =...
            sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_postEEG(1):bin_postEEG(bin_i_post)));    
    end
    
end

%% Figure: Cumulative P(burst) through time relative to EEG burst 
clear cumul_pBurst_figure % clear the gramm variable, incase it already exists

% Input relevant data into the gramm function, and set the parameters
% Fixation aligned
cumul_pBurst_figure(1,1)=gramm('x',getMidBin(-[0:10:250]),...
    'y',[cumul_eeg_pre_upper_obs';cumul_eeg_pre_upper_shuf';...
    cumul_eeg_pre_lower_obs';cumul_eeg_pre_lower_shuf'],...
    'color',[repmat({'1_Upper'},16,1);repmat({'2_Upper - Shuffled'},16,1);...
    repmat({'3_Lower'},16,1);repmat({'4_Lower - Shuffled'},16,1)]);

cumul_pBurst_figure(1,2)=gramm('x',getMidBin([0:10:250]),...
    'y',[cumul_eeg_post_upper_obs';cumul_eeg_post_upper_shuf';...
    cumul_eeg_post_lower_obs';cumul_eeg_post_lower_shuf'],...
    'color',[repmat({'1_Upper'},16,1);repmat({'2_Upper - Shuffled'},16,1);...
    repmat({'3_Lower'},16,1);repmat({'4_Lower - Shuffled'},16,1)]);

cumul_pBurst_figure(1,1).stat_summary('type','sem','geom',{'point','errorbar'}); 
cumul_pBurst_figure(1,2).stat_summary('type','sem','geom',{'point','errorbar'}); 

cumul_pBurst_figure(1,1).set_names('x','Time before EEG burst (ms)');
 cumul_pBurst_figure(1,2).set_names('x','Time after EEG burst (ms)');
cumul_pBurst_figure.set_names('y','Cumulative P(Burst)'); 

% cumul_pBurst_figure(1,1).axe_property('XLim',[0 50]); 
%cumul_pBurst_figure(1,1).axe_property('YLim',[0 1]);
% cumul_pBurst_figure(1,2).axe_property('XLim',[0 20]); 
%cumul_pBurst_figure(1,2).axe_property('YLim',[0 1]);


figure('Renderer', 'painters', 'Position', [100 100 900 300]);
cumul_pBurst_figure.draw();


















































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
% 
% Setup arrays
% p_eeg_lfp.obs.eeg_and_lfp_all = nan(length(1:17),length(14:29));
% p_eeg_lfp.obs.eeg_and_lfp_window_pre = nan(length(1:17),length(14:29));
% p_eeg_lfp.obs.eeg_and_lfp_window_post = nan(length(1:17),length(14:29));
% p_eeg_lfp.obs.eeg_and_nolfp = nan(length(1:17),length(14:29));
% p_eeg_lfp.obs.noeeg_and_lfp = nan(length(1:17),length(14:29));
% p_eeg_lfp.obs.noeeg_and_nolfp = nan(length(1:17),length(14:29));
% 
% p_eeg_lfp.shuf.eeg_and_lfp_all = nan(length(1:17),length(14:29));
% p_eeg_lfp.shuf.eeg_and_lfp_window_pre = nan(length(1:17),length(14:29));
% p_eeg_lfp.shuf.eeg_and_lfp_window_post = nan(length(1:17),length(14:29));
% p_eeg_lfp.shuf.eeg_and_nolfp = nan(length(1:17),length(14:29));
% p_eeg_lfp.shuf.noeeg_and_lfp = nan(length(1:17),length(14:29));
% p_eeg_lfp.shuf.noeeg_and_nolfp = nan(length(1:17),length(14:29));
% 
% Define session and contact
% for session_i = 14:29
%     nLFP = max(find(cell2mat(cellfun(@(x) ~isempty(x),...
%         trl_burst_diff_lfp(session_i,:), 'UniformOutput', false))));
%     
%     for lfp_i = 1:nLFP
%         
%         Find trials in which there was a co-occurance of an EEG and LFP
%         beta-burst
%         clear input_window_pre input_window_post input_window_pre_shuf input_window_post_shuf
%         
%         Observed:
%         input = []; input = trl_burst_diff_lfp{session_i, lfp_i};
%         input_window_pre = cellfun(@(x) x > filter_window_pre(1) & x < filter_window_pre(2), input(:,1), 'UniformOutput', false);
%         input_window_post = cellfun(@(x) x > filter_window_post(1) & x < filter_window_post(2), input(:,1), 'UniformOutput', false);
%         
%         Find proportion of trials with burst in EEG, LFP, both, or
%         none.
%         p_eeg_lfp.obs.eeg_and_lfp_all(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(~isnan(x) == 1), input(:,1), 'UniformOutput', false)));
%         p_eeg_lfp.obs.eeg_and_lfp_window_pre(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(x == 1), input_window_pre, 'UniformOutput', false)));
%         p_eeg_lfp.obs.eeg_and_lfp_window_post(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(x == 1), input_window_post, 'UniformOutput', false)));
%         p_eeg_lfp.obs.eeg_and_nolfp(lfp_i, session_i-13) = nanmean(strcmp(input(:,2),'+eeg, -lfp')); % Obs EEG burst, no LFP burst;
%         p_eeg_lfp.obs.noeeg_and_lfp(lfp_i, session_i-13) = nanmean(strcmp(input(:,2),'-eeg, +lfp')); % No EEG burst, Obs LFP burst
%         p_eeg_lfp.obs.noeeg_and_nolfp(lfp_i, session_i-13) = nanmean(strcmp(input(:,2),'-eeg, -lfp')); % No EEG burst, Obs LFP burst
%         
%         Shuffled:
%         input_shuffled = []; input_shuffled = trl_burst_diff_lfp_shuffled{session_i, lfp_i};
%         
%         input_window_pre_shuf = cellfun(@(x) x > filter_window_pre(1) & x < filter_window_pre(2), input_shuffled(:,1), 'UniformOutput', false);
%         input_window_post_shuf = cellfun(@(x) x > filter_window_post(1) & x < filter_window_post(2), input_shuffled(:,1), 'UniformOutput', false);
%         
%         Find proportion of trials with burst in EEG, LFP, both, or
%         none.
%         p_eeg_lfp.shuf.eeg_and_lfp_all(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(~isnan(x) == 1), input_shuffled(:,1), 'UniformOutput', false)));
%         p_eeg_lfp.shuf.eeg_and_lfp_window_pre(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(x == 1), input_window_pre_shuf, 'UniformOutput', false)));
%         p_eeg_lfp.shuf.eeg_and_lfp_window_post(lfp_i, session_i-13) = nanmean(cell2mat(cellfun(@(x) any(x == 1), input_window_post_shuf, 'UniformOutput', false)));
%         p_eeg_lfp.shuf.eeg_and_nolfp(lfp_i,session_i-13) = nanmean(strcmp(input_shuffled(:,2),'+eeg, -lfp')); % Obs EEG burst, no LFP burst;
%         p_eeg_lfp.shuf.noeeg_and_lfp(lfp_i,session_i-13) = nanmean(strcmp(input_shuffled(:,2),'-eeg, +lfp')); % No EEG burst, Obs LFP burst
%         p_eeg_lfp.shuf.noeeg_and_nolfp(lfp_i,session_i-13) = nanmean(strcmp(input_shuffled(:,2),'-eeg, -lfp')); % No EEG burst, Obs LFP burst
%         
%     end
% end
% 
% 
% beta_burst_diffTimes.obs.upper = []; beta_burst_diffTimes.obs.lower = [];
% beta_burst_diffTimes.shuf.upper = []; beta_burst_diffTimes.shuf.lower = [];
% for session_i = 14:29
%     fprintf('Analysing session %i of %i. \n',session_i, 29)
%     
%     nLFP = max(find(cell2mat(cellfun(@(x) ~isempty(x),...
%         trl_burst_diff_lfp(session_i,:), 'UniformOutput', false))));
%     
%     for lfp_i = 1:nLFP
%         Assign LFP channel to upper or lower layers
%         find_laminar = cellfun(@(c) find(c == lfp_i), laminarAlignment.compart, 'uniform', false);
%         find_laminar = find(~cellfun(@isempty,find_laminar));
%         laminar_compart = laminarAlignment.compart_label{find_laminar};
%         
%         for trl_i = 1:length(trl_burst_diff_lfp{session_i, lfp_i})
%             beta_burst_diffTimes.obs.(laminar_compart) =...
%                 [beta_burst_diffTimes.obs.(laminar_compart), trl_burst_diff_lfp{session_i, lfp_i}{trl_i}];
%             
%             beta_burst_diffTimes.shuf.(laminar_compart) =...
%                 [beta_burst_diffTimes.shuf.(laminar_compart), trl_burst_diff_lfp_shuffled{session_i, lfp_i}{trl_i}];
%         end
%     end
% end
% 
% 
% 
% 
% clear a b c test_a test_b
% laminar_compart = 'lower';
% bins = [-200:10:200];
% 
% [a,b] = histcounts( beta_burst_diffTimes.obs.(laminar_compart), bins)
% [c,~] = histcounts( beta_burst_diffTimes.shuf.(laminar_compart), bins)
% 
% nBursts = sum(~isnan(beta_burst_diffTimes.obs.(laminar_compart)))
% nBursts_shuffled = sum(~isnan(beta_burst_diffTimes.shuf.(laminar_compart)))
% 
% a = (a/nBursts) * 100;
% b = b(2:end)-((bins(2)-bins(1))/2);
% c = (c/nBursts_shuffled) * 100;
% 
% figure; hold on
% plot(b,a)
% plot(b,c)
% 
% test_a = nanmean(nanmean(p_eeg_lfp.obs.eeg_and_lfp_window_pre(9:end,:),2))*100
% test_b = sum(a(find(b > filter_window_pre(1) & b < filter_window_pre(2))))
% 
% 
% % 
% % 
% 
%     % For each contact within the session
%     for lfp_i = 1:nLFP
%         
%             % Find the depth and which layer it corresponds to in
%             % laminarAlignment.list
%             find_laminar = cellfun(@(c) find(c == lfp_i), laminarAlignment.compart, 'uniform', false);
%             find_laminar = find(~cellfun(@isempty,find_laminar));
%             laminar_label = laminarAlignment.compart_label(find_laminar);
%             
%         % Go through the bins defined above
%         for bin_i = 1:length(bin)-1
%             % Set data up
%             input = []; input = trl_burst_diff_lfp{session_i, lfp_i};
%             input_shuffled = []; input_shuffled = trl_burst_diff_lfp_shuffled{session_i, lfp_i};
%             
%             % Define the filter window (i.e. bin edge)
%             filter_window = [bin(bin_i) bin(bin_i+1)];
%             
%             % Find bursts within given window
%             input_window_flag = cellfun(@(x)...
%                 x >= filter_window(1) & x <= filter_window(2),...
%                 input(:,1), 'UniformOutput', false);
%             
%             input_window_flag_shuffled = cellfun(@(x)...
%                 x >= filter_window(1) & x <= filter_window(2),...
%                 input_shuffled(:,1), 'UniformOutput', false);
%             
%             % Find total number of LFP bursts in the defined window
%             nBurst_LFP_window(lfp_i,bin_i) = sum(cell2mat(cellfun(@(x) any((x) == 1), input_window_flag, 'UniformOutput', false)));
%             nBurst_LFPshuf_window(lfp_i,bin_i) = sum(cell2mat(cellfun(@(x) any((x) == 1), input_window_flag_shuffled, 'UniformOutput', false)));
%             
%         end
%     end
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
% 
%         % Calculate p(trials with a EEG beta-burst) in which a burst on given LFP channel
%         % occured.
%         for bin_i = 1:length(bin)-1
%             pBurst_LFP_window.upper{session_i} = (sum(nBurst_LFP_window(1:8,:))/nBursts_EEG)
%             pBurst_LFP_window.lower{session_i} = (sum(nBurst_LFP_window(9:end,:))/nBursts_EEG)
%             
%             
%             
%             pBurst_LFP_window.upper_shuf{session_i}
%             pBurst_LFP_window.lower{session_i}
%             pBurst_LFP_window.lower_shuf{session_i}
%             
%         end
%         
%         
%         
%         
%         pBurst_LFP_window{session_i}.upper.(lfp_i,bin_i) = (nBurst_LFP_window/nBursts_EEG);
%         pBurst_LFPshuf_window{session_i}(lfp_i,bin_i) = (nBurst_LFPshuf_window/nBursts_EEG);
% % Average across layers
% pBurst_LFP_upper = {}; pBurst_LFP_lower = {};
% pBurst_LFPshuf_upper = {}; pBurst_LFPshuf_lower = {};
% 
% 
% for session_i = 14:29
%     pBurst_LFP_upper{session_i-13} = nanmean(pBurst_LFP_window{session_i}(1:8,:));
%     pBurst_LFP_lower{session_i-13} = nanmean(pBurst_LFP_window{session_i}(9:end,:));
%     
%     pBurst_LFPshuf_upper{session_i-13} = nanmean(pBurst_LFPshuf_window{session_i}(1:8,:));
%     pBurst_LFPshuf_lower{session_i-13} = nanmean(pBurst_LFPshuf_window{session_i}(9:end,:));  
%     
%     
%     pBurst_LFP_upper{session_i-13}(find(bin >= -50 & bin <= 50))
%     
% end
% 
% 
% 
% 
% 
% 
% 
% 
% figure; hold on
% plot(getMidBin(bin),nanmean(pBurst_LFP_upper),'r-')
% plot(getMidBin(bin),nanmean(pBurst_LFP_lower),'b-')
% plot(getMidBin(bin),nanmean(pBurst_LFPshuf_upper),'r--')
% plot(getMidBin(bin),nanmean(pBurst_LFPshuf_lower),'b--')
% 
% 
% 
% P(Bursts) in upper/lower layers in 0 to 50 ms period pre/post EEG burst,
% for observed and shuffled conditions.
% 
% sum(nanmean(pBurst_LFP_upper(:,find(getMidBin(bin) > -50 & getMidBin(bin) < 0))))
% sum(nanmean(pBurst_LFP_upper(:,find(getMidBin(bin) > 0 & getMidBin(bin) < 50))))
% 
% sum(nanmean(pBurst_LFP_lower(:,find(getMidBin(bin) > -50 & getMidBin(bin) < 0))))
% sum(nanmean(pBurst_LFP_lower(:,find(getMidBin(bin) > 0 & getMidBin(bin) < 50))))
% 
% 
% sum(nanmean(pBurst_LFPshuf_upper(:,find(getMidBin(bin) > -50 & getMidBin(bin) < 0))))
% sum(nanmean(pBurst_LFPshuf_upper(:,find(getMidBin(bin) > 0 & getMidBin(bin) < 50))))
% 
% sum(nanmean(pBurst_LFPshuf_lower(:,find(getMidBin(bin) > -50 & getMidBin(bin) < 0))))
% sum(nanmean(pBurst_LFPshuf_lower(:,find(getMidBin(bin) > 0 & getMidBin(bin) < 50))))
% 
% 
% 
% 
% 
