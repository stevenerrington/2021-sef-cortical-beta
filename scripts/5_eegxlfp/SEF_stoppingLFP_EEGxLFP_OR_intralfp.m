%% Co-activation between channels in SEF
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');

layerLabel = {'LFP_upper','LFP_lower'};
window_edges = {[-600:50:200],[0:50:800],[-200:50:600],[-600:50:200]};

n_windows = length(window_edges{1})-1;


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
                    
                    %.and find the number of observations in each bin (+/- EEG, +/- LFP)
                    % For the observed condition
                    sum_eegA_lfpA.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'+lfp_i, +lfp_j'));
                    sum_eegA_lfpB.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'+lfp_i, -lfp_j'));
                    sum_eegB_lfpA.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'-lfp_i, +lfp_j'));
                    sum_eegB_lfpB.(alignmentEvent).obs(session_i-13,lfp_i_i,lfp_i_j,window_i) =...
                        sum(strcmp(trl_burst_diff_lfp.(alignmentEvent){lfp_i_i,lfp_i_j,window_i}(:,2),'-lfp_i, -lfp_j'));
                    
                    % For the shuffled condition
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

if ~exist('lfpxlfp_fisher_crosstab.mat')
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
                        
                        
                        % Then we can run the Fisher Exact Test function to get
                        % the Odds ratio and corresponding flag for
                        % significance and p-value.
                        clear h_obs p_obs stats_obs h_shuf p_shuf stats_shuf
                        [h_obs,p_obs,stats_obs] = fishertest(crosstab_lfpi_lfpj.obs.(alignmentEvent){session_i,lfp_i_i,lfp_i_j,window_i},...
                            'tail','right','alpha',0.05/n_windows);
                        [h_shuf,p_shuf,stats_shuf] = fishertest(crosstab_lfpi_lfpj.shuf.(alignmentEvent){session_i,lfp_i_i,lfp_i_j,window_i},...
                            'tail','right','alpha',0.05/n_windows);
                        
                        % We will then tidy this output and place it in the
                        % organized variable name to call in future.
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
    
    % We then save the output for future use.
    save('D:\projectCode\project_stoppingLFP\data\eeg_lfp\lfpxlfp_fisher_crosstab.mat','fisherstats','crosstab_lfpi_lfpj')
else
    load('D:\projectCode\project_stoppingLFP\data\eeg_lfp\lfpxlfp_fisher_crosstab.mat', 'fisherstats')
end
%% Figure: produce heatmaps of odds ratios across contacts

% Clear the work space
clear odd_ratio_intracontact h_intracontact
% Define the epochs
alignmentEvent_list = {'target','saccade','stopSignal','tone'};

% Generate the figure
figure('Renderer', 'painters', 'Position', [100 100 1500 800]);

% For each alignment
for alignmentEvent_i = 1:length(alignmentEvent_list)
    % Get the name of the event
    alignmentEvent = alignmentEvent_list{alignmentEvent_i};
    
    % For each combination of each electrode, across windows and sessions,
    % get the differential odds ratio (observed - shuffled) and find the
    % proportion of significant sessions.
    for session_i = 14:29
        for window_i = 1:n_windows
            for lfp_i_i = 1:18
                for lfp_i_j = 1:18
                    % If the contact is the same, then we will NaN it out.
                    if lfp_i_i == lfp_i_j
                        odd_ratio_intracontact.(alignmentEvent)(lfp_i_i,lfp_i_j,session_i-13,window_i) = NaN;
                    else
                        try
                            % Get P(Sig) contacts
                            h_intracontact.(alignmentEvent)(lfp_i_i,lfp_i_j,session_i-13,window_i) = ...
                                fisherstats.(alignmentEvent).obs.h{session_i-13}(lfp_i_i,lfp_i_j,window_i) > ...
                                fisherstats.(alignmentEvent).shuf.h{session_i-13}(lfp_i_i,lfp_i_j,window_i);
                            % Get Odds Ratio
                            odd_ratio_intracontact.(alignmentEvent)(lfp_i_i,lfp_i_j,session_i-13,window_i) = ...
                                fisherstats.(alignmentEvent).obs.odds{session_i-13}(lfp_i_i,lfp_i_j,window_i) - ...
                                fisherstats.(alignmentEvent).shuf.odds{session_i-13}(lfp_i_i,lfp_i_j,window_i);
                        catch
                        end
                    end
                end
            end
        end

        
        % For the given session, initialse arrays
        mean_or_upper_upper_all = [];  mean_or_lower_lower_all = [];
        mean_or_upper_lower_all = []; 
        
        % Then find the mean odds ratios for upper x upper, lower x lower,
        % upper x lower contacts, just taking the lower left triangle of
        % the matrix
        mean_or_upper_upper_all = tril(nanmean(squeeze(odd_ratio_intracontact.(alignmentEvent)(1:8,1:8,session_i-13,:)),3));
        mean_or_upper_upper_all(mean_or_upper_upper_all == 0) = NaN;
        mean_or_upper_lower_all = tril(nanmean(squeeze(odd_ratio_intracontact.(alignmentEvent)(1:8,9:end,session_i-13,:)),3));
        mean_or_upper_upper_all(mean_or_upper_upper_all == 0) = NaN;
        mean_or_lower_lower_all = tril(nanmean(squeeze(odd_ratio_intracontact.(alignmentEvent)(9:end,9:end,session_i-13,:)),3));
        mean_or_upper_upper_all(mean_or_upper_upper_all == 0) = NaN;
        
        mean_or_upper_upper_session.(alignmentEvent)(session_i-13,1) = nanmean(mean_or_upper_upper_all(:));
        mean_or_upper_lower_session.(alignmentEvent)(session_i-13,1) = nanmean(mean_or_upper_lower_all(:));
        mean_or_lower_lower_session.(alignmentEvent)(session_i-13,1) = nanmean(mean_or_lower_lower_all(:));
        
        
        
    end
    
    % We are then going to plot the data
    % Find the Eu and X sessions relative to the first perp session.
    % Get the mean OR matrix across sessions and windows.
    odd_ratio_plot_data = []; odd_ratio_plot_data = nanmean(odd_ratio_intracontact.(alignmentEvent),4);
    euSessions = executiveBeh.nhpSessions.EuSessions(executiveBeh.nhpSessions.EuSessions > 13)-13;
    xSessions = executiveBeh.nhpSessions.XSessions(executiveBeh.nhpSessions.XSessions > 13)-13;
    
    % Then we will divide the data into Eu and X's indiviudal arrays for
    % plotting
    all_fig_data = []; eu_fig_data = []; x_fig_data =[];
    all_fig_data = tril(nanmean(odd_ratio_plot_data,3));
    all_fig_data(all_fig_data == 0) = nan;
    eu_fig_data = tril(nanmean(odd_ratio_plot_data(:,:,euSessions),3));
    eu_fig_data(eu_fig_data == 0) = nan;
    x_fig_data = tril(nanmean(odd_ratio_plot_data(:,:,xSessions),3));
    x_fig_data(x_fig_data == 0) = nan;
    
    
    % % Generate the figure
    % Subplot 1: all data, across all sessions
    % Note: alphadata argument allows us to wipe out the upper right corner
    % when plotting.
    subplot(3,4,alignmentEvent_i)
    imagesc(nanmean(all_fig_data,3),'AlphaData',~isnan(nanmean(all_fig_data,3)))
    title(alignmentEvent)
    set(gca,'CLim',[0 50])
    hline(8.5,'r'); vline(8.5,'r')
    colormap(viridis)
    colorbar
    
    % Subplot 2: Eu data, across all sessions
    subplot(3,4,alignmentEvent_i+4)
    imagesc(nanmean(eu_fig_data,3),'AlphaData',~isnan(nanmean(eu_fig_data,3)))
    title(alignmentEvent)
    set(gca,'CLim',[0 50])
    hline(8.5,'r'); vline(8.5,'r')
    colormap(viridis)
    colorbar
    
    % Subplot 3: X data, across all sessions
    subplot(3,4,alignmentEvent_i+8)
    imagesc(nanmean(x_fig_data,3),'AlphaData',~isnan(nanmean(x_fig_data,3)))
    title(alignmentEvent)
    set(gca,'CLim',[0 50])
    hline(8.5,'r'); vline(8.5,'r')
    colormap(viridis)
    colorbar
end

%% Analysis: Include EEG OR for comparison

%%%%%%%%%%%%%%%% CHECK THIS! EEG OR ARE WRONG I THINK!
% Load in pre-processed data
load(fullfile(dataDir,'eeg_lfp','eeg_lfp_OR.mat'));

% Initiate structures for upper and lower x eeg analysis
mean_or_eeg_upper = struct; mean_or_eeg_lower = struct;

% For each alignment
for alignmentEvent_i = 1:length(alignmentEvent_list)
    alignmentEvent = alignmentEvent_list{alignmentEvent_i};
    
    % Initialise the arrays
    mean_or_eeg_upper.(alignmentEvent) = [];  mean_or_eeg_lower.(alignmentEvent) = [];
    
    % and store the mean OR across contacts in upper/lower layers in them.
    mean_or_eeg_upper.(alignmentEvent) = nanmean(eeg_lfp_OR.(alignmentEvent)(:,[1:8]),2);
    mean_or_eeg_lower.(alignmentEvent) = nanmean(eeg_lfp_OR.(alignmentEvent)(:,[9:end]),2);
    
end


%% Figure: Box/bar plot of OR across different signal combinations.
data = []; alignLabel = []; monkeyLabel = []; measureLabel = [];

nSessions = length(14:29);

for alignmentEvent_i = 1:length(alignmentEvent_list)
    alignmentEvent = alignmentEvent_list{alignmentEvent_i};
    
    data = [data; mean_or_upper_upper_session.(alignmentEvent); ...
        mean_or_lower_lower_session.(alignmentEvent);...
        mean_or_upper_lower_session.(alignmentEvent);...
        mean_or_eeg_upper.(alignmentEvent);...
        mean_or_eeg_lower.(alignmentEvent)];
    
    alignLabel = [alignLabel; repmat({[int2str(alignmentEvent_i) '_' alignmentEvent_list{alignmentEvent_i}]},nSessions*5,1)];
    
    monkeyLabel = [monkeyLabel; repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),5,1)];
    
    measureLabel = [measureLabel; repmat({'1_upper_upper'},nSessions,1);...
        repmat({'2_lower_lower'},nSessions,1); repmat({'3_upper_lower'},nSessions,1);...
        repmat({'4_upper_eeg'},nSessions,1);repmat({'5_lower_eeg'},nSessions,1)];
    
end

clear intraLFP_odds_figure
intraLFP_odds_figure(1,1) = gramm('x',measureLabel,'y',data);
intraLFP_odds_figure(1,1).stat_summary('geom',{'point','line','errorbar'});
intraLFP_odds_figure(1,1).axe_property('YLim',[-5 25]);
intraLFP_odds_figure.facet_grid([],alignLabel);
figure('Renderer', 'painters', 'Position', [100 100 1000 200]);
intraLFP_odds_figure.draw();

clear intraLFP_odds_figure
intraLFP_odds_figure(1,1) = gramm('x',measureLabel,'y',data);
intraLFP_odds_figure(1,1).stat_summary('geom',{'point','line','errorbar'});
intraLFP_odds_figure(1,1).axe_property('YLim',[-5 35]);
intraLFP_odds_figure.facet_grid(monkeyLabel,alignLabel);
figure('Renderer', 'painters', 'Position', [100 100 1000 400]);
intraLFP_odds_figure.draw();

intraLFP_burst_table = table(data,alignLabel,monkeyLabel,measureLabel);

%% Output: Write table for JASP analysis.
writetable(intraLFP_burst_table,fullfile(rootDir,'results','jasp_tables','intraLFP_burst_table.csv'),'WriteRowNames',true)
