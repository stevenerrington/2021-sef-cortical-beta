%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'fixate','target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');

layerLabel = {'LFP_upper','LFP_lower'};
window_edges = {[200:50:1000],[-600:50:200],[200:50:1000],[-200:50:600],[-400:50:400]};

n_windows = length(window_edges{1})-1;

trl_burst_diff_lfp = {};
trl_burst_diff_lfp_shuffled = {};

%% Extract data from files
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
%% Analysis: extract the number of observations within each time bin, for each contact,
%            across events and sessions.

% Clear the workspace/loop variables
clear sum_eeg*

% For each alignment event
for alignment_i = 1:length(eventAlignments)
    % Get the desired alignment
    alignmentEvent = eventAlignments{alignment_i};
    
    % For each session
    for session_i = 14:29
        
        % Find the number of channels recorded within the session
        n_lfp = max(find(~cellfun(@isempty, trl_burst_diff_lfp_shuf.target(session_i,:,1))));
        
        % Loop through each channel
        for lfp_i = 1:n_lfp
            
            % At each time bin
            for window_i = 1:n_windows
                
                %.and find the number of observations in each bin (+/- EEG, +/- LFP):
                sum_eegA_lfpA.(alignmentEvent).obs(session_i-13,lfp_i,window_i) =...
                    sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}(:,2),'+eeg, +lfp'));
                sum_eegA_lfpB.(alignmentEvent).obs(session_i-13,lfp_i,window_i) =...
                    sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}(:,2),'+eeg, -lfp'));
                sum_eegB_lfpA.(alignmentEvent).obs(session_i-13,lfp_i,window_i) =...
                    sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}(:,2),'-eeg, +lfp'));
                sum_eegB_lfpB.(alignmentEvent).obs(session_i-13,lfp_i,window_i) =...
                    sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){session_i,lfp_i,window_i}(:,2),'-eeg, -lfp'));
                
                %.and find the number of observations in each bin (+/- EEG, +/- LFP):
                sum_eegA_lfpA.(alignmentEvent).shuf(session_i-13,lfp_i,window_i) =...
                    sum(strcmp(trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}(:,2),'+eeg, +lfp'));
                sum_eegA_lfpB.(alignmentEvent).shuf(session_i-13,lfp_i,window_i) =...
                    sum(strcmp(trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}(:,2),'+eeg, -lfp'));
                sum_eegB_lfpA.(alignmentEvent).shuf(session_i-13,lfp_i,window_i) =...
                    sum(strcmp(trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}(:,2),'-eeg, +lfp'));
                sum_eegB_lfpB.(alignmentEvent).shuf(session_i-13,lfp_i,window_i) =...
                    sum(strcmp(trl_burst_diff_lfp_shuf.(alignmentEvent){session_i,lfp_i,window_i}(:,2),'-eeg, -lfp'));
                
            
            end
        end
    end
end

%% Analysis: Cross-tabulate these counts, and run Fisher Exact Test

clear crosstab_lfp_eeg fisherstats

% For each session
for session_i = 14:29
    n_lfp = max(find(~cellfun(@isempty, trl_burst_diff_lfp_shuf.target(session_i,:,1))));
    
    % Loop through each channel
    for lfp_i = 1:n_lfp
        lfp_count = lfp_count + 1;
        
        % For each alignment
        for alignment_i = 1:length(eventAlignments)
            alignmentEvent = eventAlignments{alignment_i};
            
            % ... and at each time bin
            for window_i = 1:n_windows
                
                
                % Get the cross-tab for this lfp-contact.
                % Note: 1 is added to each cell to account for MATLAB issue
                % with running Fisher with 0 count in cells.
                
                crosstab_lfp_eeg.obs.(alignmentEvent){session_i,lfp_i,window_i} =...
                    table( [sum_eegA_lfpA.(alignmentEvent).obs(session_i-13,lfp_i,window_i)+1;...
                    sum_eegA_lfpB.(alignmentEvent).obs(session_i-13,lfp_i,window_i)+1],...
                    [sum_eegB_lfpA.(alignmentEvent).obs(session_i-13,lfp_i,window_i)+1;...
                    sum_eegB_lfpB.(alignmentEvent).obs(session_i-13,lfp_i,window_i)+1],...
                    'VariableNames',{'EEG_pos','EEG_neg'},'RowNames',{'LFP_pos','LFP_neg'});
                
                crosstab_lfp_eeg.shuf.(alignmentEvent){session_i,lfp_i,window_i} =...
                    table( [sum_eegA_lfpA.(alignmentEvent).shuf(session_i-13,lfp_i,window_i)+1;...
                    sum_eegA_lfpB.(alignmentEvent).shuf(session_i-13,lfp_i,window_i)+1],...
                    [sum_eegB_lfpA.(alignmentEvent).shuf(session_i-13,lfp_i,window_i)+1;...
                    sum_eegB_lfpB.(alignmentEvent).shuf(session_i-13,lfp_i,window_i)+1],...
                    'VariableNames',{'EEG_pos','EEG_neg'},'RowNames',{'LFP_pos','LFP_neg'});
                
                
                clear h_obs p_obs stats_obs h_shuf p_shuf stats_shuf
                [h_obs,p_obs,stats_obs] = fishertest(crosstab_lfp_eeg.obs.(alignmentEvent){session_i,lfp_i,window_i},...
                    'tail','right');
                [h_shuf,p_shuf,stats_shuf] = fishertest(crosstab_lfp_eeg.shuf.(alignmentEvent){session_i,lfp_i,window_i},...
                    'tail','right');
                
                fisherstats.(alignmentEvent).obs.h{session_i-13}(lfp_i,window_i) = h_obs;
                fisherstats.(alignmentEvent).obs.p{session_i-13}(lfp_i,window_i) = p_obs;
                fisherstats.(alignmentEvent).obs.odds{session_i-13}(lfp_i,window_i) = stats_obs.OddsRatio;
                
                fisherstats.(alignmentEvent).shuf.h{session_i-13}(lfp_i,window_i) = h_shuf;
                fisherstats.(alignmentEvent).shuf.p{session_i-13}(lfp_i,window_i) = p_shuf;
                fisherstats.(alignmentEvent).shuf.odds{session_i-13}(lfp_i,window_i) = stats_shuf.OddsRatio;
                
                
            end
        end
    end
    
end


%% Figure
clear eeg_lfp_OR fig_data

loop_i = 0;

for alignment_i = 1:length(eventAlignments)
    alignmentEvent = eventAlignments{alignment_i};
    for session_i = 14:29
        loop_i = loop_i + 1;
        
        fig_data.alignment{loop_i,1} = alignmentEvent;
        fig_data.OR_obs{loop_i,1} = nanmean(fisherstats.(alignmentEvent).obs.odds{session_i-13});
        fig_data.H_obs{loop_i,1} = nanmean(fisherstats.(alignmentEvent).obs.h{session_i-13});
        fig_data.OR_shuf{loop_i,1} = nanmean(fisherstats.(alignmentEvent).shuf.odds{session_i-13});
        fig_data.H_shuf{loop_i,1} = nanmean(fisherstats.(alignmentEvent).shuf.h{session_i-13});
        
        fig_data.time{loop_i,1} = getMidBin(window_edges{alignment_i});
        fig_data.session{loop_i,1} = executiveBeh.nhpSessions.monkeyNameLabel{session_i};
        
        eeg_lfp_OR.(alignmentEvent){session_i-13,:} = nanmean(fisherstats.(alignmentEvent).obs.odds{session_i-13});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obs_cond_label = [repmat({'obs'},loop_i,1);repmat({'shuf'},loop_i,1)];
alignment_label = [fig_data.alignment;fig_data.alignment];
monkey_label = [fig_data.session;fig_data.session];

clear g

g(1,1)=gramm('x',[fig_data.time;fig_data.time],'y',[fig_data.H_obs;fig_data.OR_shuf],'color',obs_cond_label);
g(2,1)=gramm('x',[fig_data.time;fig_data.time],'y',[fig_data.OR_obs;fig_data.OR_shuf],'color',obs_cond_label);

g(1,1).stat_summary(); g(2,1).stat_summary(); 

g(1,1).facet_grid([],alignment_label,'scale','free_x');
g(2,1).facet_grid(monkey_label,alignment_label,'scale','free_x');

g(1,1).axe_property('YLim',[0 15]); g(2,1).axe_property('YLim',[0 20]);

g(1,1).geom_hline('yintercept',1); g(2,1).geom_hline('yintercept',1)


figure('Renderer', 'painters', 'Position', [100 100 1000 600]);
g.draw();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear g

g(1,1)=gramm('x',[fig_data.time;fig_data.time],'y',[fig_data.H_obs;fig_data.H_shuf],'color',obs_cond_label);
g(2,1)=gramm('x',[fig_data.time;fig_data.time],'y',[fig_data.H_obs;fig_data.H_shuf],'color',obs_cond_label);

g(1,1).stat_summary('geom',{'point','errorbar'}); g(2,1).stat_summary('geom',{'point','errorbar'}); 

g(1,1).facet_grid([],alignment_label,'scale','free_x');
g(2,1).facet_grid(monkey_label,alignment_label,'scale','free_x');

g(1,1).axe_property('YLim',[-0.1 0.5]); g(2,1).axe_property('YLim',[-0.1 0.5]);

g(1,1).geom_hline('yintercept',1); g(2,1).geom_hline('yintercept',1)


figure('Renderer', 'painters', 'Position', [100 100 1000 600]);
g.draw();


