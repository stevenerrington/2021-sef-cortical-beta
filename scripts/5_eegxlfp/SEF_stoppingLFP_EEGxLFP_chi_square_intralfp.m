%% Co-activation between channels in SEF
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');

layerLabel = {'LFP_upper','LFP_lower'};
window_edges = {[-600:50:200],[0:50:800],[-200:50:600],[-600:50:200]};

n_windows = length(window_edges{1})-1;


%% Extract data from files
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

toc


%% Analysis: extract the number of observations within each time bin, for each contact,
%            across events and sessions.

% Clear the workspace/loop variables
clear sum_eeg*
% For each session
for session_i = 14:29
    fprintf('Analysing session %i of %i. \n',session_i, 29)

    load(fullfile(dataDir,'eeg_lfp','intra_lfp',...
        ['trl_burst_diff_intraLFP_session_' int2str(session_i) '.mat']));

    % For each alignment event
    for alignment_i = 1:length(eventAlignments)
        % Get the desired alignment
        alignmentEvent = eventAlignments{alignment_i};

        % Find the number of channels recorded within the session
        n_lfp = size(trl_burst_diff_lfp_shuf.target,1);
        
        % Loop through each channel
        for lfp_i_i = 1:n_lfp
            for lfp_i_j = 1:n_lfp
                
                % At each time bin
                for window_i = 1:n_windows
                    
                    %.and find the number of observations in each bin (+/- EEG, +/- LFP):
                    sum_eegA_lfpA.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'+lfp_i, +lfp_j'));
                    sum_eegA_lfpB.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'+lfp_i, -lfp_j'));
                    sum_eegB_lfpA.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'-lfp_i, +lfp_j'));
                    sum_eegB_lfpB.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'-lfp_i, -lfp_j'));
                    
                    %.and find the number of observations in each bin (+/- EEG, +/- LFP):
                    sum_eegA_lfpA.(alignmentEvent).shuf(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'+lfp_i, +lfp_j'));
                    sum_eegA_lfpB.(alignmentEvent).shuf(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'+lfp_i, -lfp_j'));
                    sum_eegB_lfpA.(alignmentEvent).shuf(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'-lfp_i, +lfp_j'));
                    sum_eegB_lfpB.(alignmentEvent).shuf(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp_shuf.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'-lfp_i, -lfp_j'));
                    
                end
            end
        end
    end
end


%% Analysis: Cross-tabulate these counts, and run Fisher Exact Test

clear crosstab_lfpi_lfpj fisherstats
lfp_count = 0;
% For each session
for session_i = 14:29
        n_lfp = size(sum_eegA_lfpA.target.obs,2);
    fprintf('Analysing session %i of %i. \n',session_i, 29)
    
    % Loop through each channel
    for lfp_i_i = 1:n_lfp
        lfp_count = lfp_count + 1;
        
        for lfp_i_j = 1:n_lfp
            % For each alignment
            for alignment_i = 1:length(eventAlignments)
                alignmentEvent = eventAlignments{alignment_i};
                
                % ... and at each time bin
                for window_i = 1:n_windows
                    
                    
                    % Get the cross-tab for this lfp-contact.
                    % Note: 1 is added to each cell to account for MATLAB issue
                    % with running Fisher with 0 count in cells.
                    
                    crosstab_lfpi_lfpj.obs.(alignmentEvent){session_i,lfp_i_i,lfp_i_j,window_i} =...
                        table( [sum_eegA_lfpA.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i)+1;...
                        sum_eegA_lfpB.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i)+1],...
                        [sum_eegB_lfpA.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i)+1;...
                        sum_eegB_lfpB.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i)+1],...
                        'VariableNames',{'LFP_i_pos','LFP_i_neg'},'RowNames',{'LFP_j_pos','LFP_j_neg'});
                    
                    crosstab_lfpi_lfpj.shuf.(alignmentEvent){session_i,lfp_i_i,lfp_i_j,window_i} =...
                        table( [sum_eegA_lfpA.(alignmentEvent).shuf(session_i-13,lfp_i_i,lfp_i_j,window_i)+1;...
                        sum_eegA_lfpB.(alignmentEvent).shuf(session_i-13,lfp_i_i,lfp_i_j,window_i)+1],...
                        [sum_eegB_lfpA.(alignmentEvent).shuf(session_i-13,lfp_i_i,lfp_i_j,window_i)+1;...
                        sum_eegB_lfpB.(alignmentEvent).shuf(session_i-13,lfp_i_i,lfp_i_j,window_i)+1],...
                        'VariableNames',{'LFP_i_pos','LFP_i_neg'},'RowNames',{'LFP_j_pos','LFP_j_neg'});
                    
                    
                    clear h_obs p_obs stats_obs h_shuf p_shuf stats_shuf
                    [h_obs,p_obs,stats_obs] = fishertest(crosstab_lfpi_lfpj.obs.(alignmentEvent){session_i,lfp_i_i,lfp_i_j,window_i},...
                        'tail','right','alpha',0.05/n_windows);
                    [h_shuf,p_shuf,stats_shuf] = fishertest(crosstab_lfpi_lfpj.shuf.(alignmentEvent){session_i,lfp_i_i,lfp_i_j,window_i},...
                        'tail','right','alpha',0.05/n_windows);
                    
                    fisherstats.(alignmentEvent).obs.h{session_i-13}(lfp_i_i,lfp_i_j,window_i) = h_obs;
                    fisherstats.(alignmentEvent).obs.p{session_i-13}(lfp_i_i,lfp_i_j,window_i) = p_obs;
                    fisherstats.(alignmentEvent).obs.odds{session_i-13}(lfp_i_i,lfp_i_j,window_i) = stats_obs.OddsRatio;
                    
                    fisherstats.(alignmentEvent).shuf.h{session_i-13}(lfp_i_i,lfp_i_j,window_i) = h_shuf;
                    fisherstats.(alignmentEvent).shuf.p{session_i-13}(lfp_i_i,lfp_i_j,window_i) = p_shuf;
                    fisherstats.(alignmentEvent).shuf.odds{session_i-13}(lfp_i_i,lfp_i_j,window_i) = stats_shuf.OddsRatio;
                    
                end
            end
        end
    end
    
end

save('D:\projectCode\project_stoppingLFP\data\eeg_lfp\lfpxlfp_fisher_crosstab.mat','fisherstats','crosstab_lfpi_lfpj')

%%
load('D:\projectCode\project_stoppingLFP\data\eeg_lfp\lfpxlfp_fisher_crosstab.mat', 'fisherstats')


clear odd_ratio_intracontact h_intracontact
alignmentEvent_list = {'target','saccade','stopSignal','tone'};
figure('Renderer', 'painters', 'Position', [100 100 1500 800]);
for alignmentEvent_i = 1:length(alignmentEvent_list)
    alignmentEvent = alignmentEvent_list{alignmentEvent_i};
    
    for session_i = 14:29
        for window_i = 1:n_windows
            for lfp_i_i = 1:18
                for lfp_i_j = 1:18
                    if lfp_i_i == lfp_i_j
                        odd_ratio_intracontact.(alignmentEvent)(lfp_i_i,lfp_i_j,session_i-13,window_i) = NaN;
                    else
                        try
                            h_intracontact.(alignmentEvent)(lfp_i_i,lfp_i_j,session_i-13,window_i) = ...
                                fisherstats.(alignmentEvent).obs.h{session_i-13}(lfp_i_i,lfp_i_j,window_i) > ...
                                fisherstats.(alignmentEvent).shuf.h{session_i-13}(lfp_i_i,lfp_i_j,window_i);
                            
                            odd_ratio_intracontact.(alignmentEvent)(lfp_i_i,lfp_i_j,session_i-13,window_i) = ...
                                fisherstats.(alignmentEvent).obs.odds{session_i-13}(lfp_i_i,lfp_i_j,window_i) - ...
                                fisherstats.(alignmentEvent).shuf.odds{session_i-13}(lfp_i_i,lfp_i_j,window_i);
                        catch
                        end
                    end
                end
            end
        end
        
        mean_or_upper_upper_all = [];  mean_or_lower_lower_all = [];
        mean_or_upper_lower_all = [];  mean_or_lower_upper_all = [];
        
        mean_or_upper_upper_all = nanmean(squeeze(odd_ratio_intracontact.(alignmentEvent)(1:8,1:8,session_i-13,:)),3);
        mean_or_upper_lower_all = nanmean(squeeze(odd_ratio_intracontact.(alignmentEvent)(1:8,9:end,session_i-13,:)),3);
        mean_or_lower_lower_all = nanmean(squeeze(odd_ratio_intracontact.(alignmentEvent)(9:end,9:end,session_i-13,:)),3);
        mean_or_lower_upper_all = nanmean(squeeze(odd_ratio_intracontact.(alignmentEvent)(9:end,1:8,session_i-13,:)),3);
        
        mean_or_upper_upper_session.(alignmentEvent)(session_i-13,1) = nanmean(mean_or_upper_upper_all(:));
        mean_or_upper_lower_session.(alignmentEvent)(session_i-13,1) = nanmean(mean_or_upper_lower_all(:));
        mean_or_lower_lower_session.(alignmentEvent)(session_i-13,1) = nanmean(mean_or_lower_lower_all(:));
        mean_or_lower_upper_session.(alignmentEvent)(session_i-13,1) = nanmean(mean_or_lower_upper_all(:));
        

        
    end
    
    odd_ratio_plot_data = nanmean(odd_ratio_intracontact.(alignmentEvent),4);
    euSessions = executiveBeh.nhpSessions.EuSessions(executiveBeh.nhpSessions.EuSessions > 13)-13;
    xSessions = executiveBeh.nhpSessions.XSessions(executiveBeh.nhpSessions.XSessions > 13)-13;
    
    subplot(3,4,alignmentEvent_i)
    imagesc(nanmean(odd_ratio_plot_data,3))
    title(alignmentEvent)
    set(gca,'CLim',[0 50])
    hline(8.5,'r'); vline(8.5,'r')
    colormap(viridis)
    colorbar
    
    subplot(3,4,alignmentEvent_i+4)
    imagesc(nanmean(odd_ratio_plot_data(:,:,euSessions),3))
    title(alignmentEvent)
    set(gca,'CLim',[0 50])
    hline(8.5,'r'); vline(8.5,'r')
    colormap(viridis)
    colorbar   
    
    subplot(3,4,alignmentEvent_i+8)
    imagesc(nanmean(odd_ratio_plot_data(:,:,xSessions),3))
    title(alignmentEvent)
    set(gca,'CLim',[0 50])
    hline(8.5,'r'); vline(8.5,'r')
    colormap(viridis)
    colorbar       
end

%%

data = []; alignLabel = []; monkeyLabel = []; measureLabel = [];

nSessions = length(14:29);

for alignmentEvent_i = 1:length(alignmentEvent_list)
    alignmentEvent = alignmentEvent_list{alignmentEvent_i};
    
    data = [data; mean_or_upper_upper_session.(alignmentEvent); ...
        mean_or_lower_lower_session.(alignmentEvent);...
        mean_or_upper_lower_session.(alignmentEvent);...
        mean_or_lower_upper_session.(alignmentEvent)];
    
    alignLabel = [alignLabel; repmat({[int2str(alignmentEvent_i) '_' alignmentEvent_list{alignmentEvent_i}]},nSessions*4,1)];
    
    monkeyLabel = [monkeyLabel; repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),4,1)];

    measureLabel = [measureLabel; repmat({'1_upper_upper'},nSessions,1);...
        repmat({'2_lower_lower'},nSessions,1); repmat({'3_upper_lower'},nSessions,1);...
        repmat({'4_lower_upper'},nSessions,1)];

end

clear intraLFP_odds_figure
intraLFP_odds_figure(1,1) = gramm('x',measureLabel,'y',data);
intraLFP_odds_figure(1,1).stat_summary('geom',{'point','line','errorbar'});
intraLFP_odds_figure(1,1).axe_property('YLim',[0 25]);
intraLFP_odds_figure.facet_grid([],alignLabel)
figure('Renderer', 'painters', 'Position', [100 100 1000 300]);
intraLFP_odds_figure.draw();

clear intraLFP_odds_figure
intraLFP_odds_figure(1,1) = gramm('x',measureLabel,'y',data);
intraLFP_odds_figure(1,1).stat_summary('geom',{'point','line','errorbar'});
intraLFP_odds_figure(1,1).axe_property('YLim',[0 35]);
intraLFP_odds_figure.facet_grid(monkeyLabel,alignLabel)
figure('Renderer', 'painters', 'Position', [100 100 1000 600]);
intraLFP_odds_figure.draw();









