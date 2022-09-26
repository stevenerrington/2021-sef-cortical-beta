%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');

layerLabel = {'LFP_upper','LFP_lower'};
window_edges = {[-600:50:200],[0:50:800],[-200:50:600],[-600:50:200]};

n_windows = length(window_edges{1})-1;

trl_burst_diff_lfp = {};
trl_burst_diff_lfp_shuffled = {};

%% Analysis: extract the number of observations within each time bin, for each contact,
%            across events and sessions.
load(fullfile(dataDir,'eeg_lfp','trl_burst_diff_lfp_chisquare.mat'));

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
lfp_count = 0;
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
                    'tail','right','alpha',0.05/n_windows);
                [h_shuf,p_shuf,stats_shuf] = fishertest(crosstab_lfp_eeg.shuf.(alignmentEvent){session_i,lfp_i,window_i},...
                    'tail','right','alpha',0.05/n_windows);
                
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
        
        fig_data.alignment{loop_i,1} = [int2str(alignment_i) '_' alignmentEvent];
        fig_data.OR_obs{loop_i,1} = nanmean(fisherstats.(alignmentEvent).obs.odds{session_i-13});
        fig_data.H_obs{loop_i,1} = nanmean(fisherstats.(alignmentEvent).obs.h{session_i-13});
        fig_data.OR_shuf{loop_i,1} = nanmean(fisherstats.(alignmentEvent).shuf.odds{session_i-13});
        fig_data.H_shuf{loop_i,1} = nanmean(fisherstats.(alignmentEvent).shuf.h{session_i-13});
        
        fig_data.OR_diff{loop_i,1} = fig_data.OR_obs{loop_i,1}-fig_data.OR_shuf{loop_i,1};
        fig_data.H_diff{loop_i,1} =  fig_data.H_obs{loop_i,1} -  fig_data.H_shuf{loop_i,1};
        
        fig_data.time{loop_i,1} = getMidBin(window_edges{alignment_i});
        fig_data.session{loop_i,1} = executiveBeh.nhpSessions.monkeyNameLabel{session_i};
        
        eeg_lfp_OR.(alignmentEvent){session_i-13,:} = nanmean(fisherstats.(alignmentEvent).obs.odds{session_i-13});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obs_cond_label = [repmat({'obs'},loop_i,1);repmat({'shuf'},loop_i,1)];
alignment_label = [fig_data.alignment;fig_data.alignment];
monkey_label = [fig_data.session;fig_data.session];

clear figure_oddsratio_eegxlfp

figure_oddsratio_eegxlfp(1,1)=gramm('x',[fig_data.time;fig_data.time],'y',[fig_data.OR_obs;fig_data.OR_shuf],'color',obs_cond_label);
figure_oddsratio_eegxlfp(2,1)=gramm('x',[fig_data.time;fig_data.time],'y',[fig_data.H_obs;fig_data.H_shuf],'color',obs_cond_label);

figure_oddsratio_eegxlfp(1,1).stat_summary(); 
figure_oddsratio_eegxlfp(1,1).facet_grid([],alignment_label,'scale','free_x');

figure_oddsratio_eegxlfp(2,1).stat_summary('geom',{'point','errorbar'}); 
figure_oddsratio_eegxlfp(2,1).facet_grid([],alignment_label,'scale','free_x');

figure_oddsratio_eegxlfp(1,1).axe_property('YLim',[0 15]); 
figure_oddsratio_eegxlfp(2,1).axe_property('YLim',[0 0.25]); 

figure_oddsratio_eegxlfp(1,1).geom_hline('yintercept',1); 

figure('Renderer', 'painters', 'Position', [100 100 1000 600]);
figure_oddsratio_eegxlfp.draw();

%% 
clear figure_oddsratio_eegxlfp_monkey

figure_oddsratio_eegxlfp_monkey(1,1)=gramm('x',[fig_data.time;fig_data.time],'y',[fig_data.OR_obs;fig_data.OR_shuf],'color',obs_cond_label);
figure_oddsratio_eegxlfp_monkey(2,1)=gramm('x',[fig_data.time;fig_data.time],'y',[fig_data.H_obs;fig_data.H_shuf],'color',obs_cond_label);

figure_oddsratio_eegxlfp_monkey(1,1).stat_summary('geom',{'point','errorbar'}); 
figure_oddsratio_eegxlfp_monkey(1,1).facet_grid(monkey_label,alignment_label,'scale','free');

figure_oddsratio_eegxlfp_monkey(2,1).stat_summary('geom',{'point','errorbar'}); 
figure_oddsratio_eegxlfp_monkey(2,1).facet_grid(monkey_label,alignment_label,'scale','free_x');

% figure_oddsratio_eegxlfp_monkey(1,1).axe_property('YLim',[0 25]); 
figure_oddsratio_eegxlfp_monkey(2,1).axe_property('YLim',[0 0.25]); 

figure_oddsratio_eegxlfp_monkey(1,1).geom_hline('yintercept',1); 

figure('Renderer', 'painters', 'Position', [100 100 1000 600]);
figure_oddsratio_eegxlfp_monkey.draw();

%% Diff 

clear figure_oddsratio_eegxlfp_diff

figure_oddsratio_eegxlfp_diff(1,1)=gramm('x',[fig_data.time],'y',[fig_data.OR_diff]);
figure_oddsratio_eegxlfp_diff(2,1)=gramm('x',[fig_data.time],'y',[fig_data.H_diff]);

figure_oddsratio_eegxlfp_diff(1,1).stat_summary('geom',{'point','errorbar'}); 
figure_oddsratio_eegxlfp_diff(1,1).facet_grid([],fig_data.alignment,'scale','free');

figure_oddsratio_eegxlfp_diff(2,1).stat_summary('geom',{'point','errorbar'}); 
figure_oddsratio_eegxlfp_diff(2,1).facet_grid([],fig_data.alignment,'scale','free_x');

figure_oddsratio_eegxlfp_diff(1,1).axe_property('YLim',[-5 5]); 
figure_oddsratio_eegxlfp_diff(2,1).axe_property('YLim',[-0.2 0.2]); 

figure_oddsratio_eegxlfp_diff(1,1).geom_hline('yintercept',0); 
figure_oddsratio_eegxlfp_diff(2,1).geom_hline('yintercept',0); 

figure('Renderer', 'painters', 'Position', [100 100 1000 600]);
figure_oddsratio_eegxlfp_diff.draw();

%% 
clear figure_oddsratio_eegxlfp_diff_monkey

figure_oddsratio_eegxlfp_diff_monkey(1,1)=gramm('x',[fig_data.time],'y',[fig_data.OR_diff]);
figure_oddsratio_eegxlfp_diff_monkey(2,1)=gramm('x',[fig_data.time],'y',[fig_data.H_diff]);

figure_oddsratio_eegxlfp_diff_monkey(1,1).stat_summary('geom',{'point','errorbar'}); 
figure_oddsratio_eegxlfp_diff_monkey(1,1).facet_grid(fig_data.session,fig_data.alignment,'scale','free');

figure_oddsratio_eegxlfp_diff_monkey(2,1).stat_summary('geom',{'point','errorbar'}); 
figure_oddsratio_eegxlfp_diff_monkey(2,1).facet_grid(fig_data.session,fig_data.alignment,'scale','free_x');

figure_oddsratio_eegxlfp_diff_monkey(1,1).axe_property('YLim',[-6 6]); 
figure_oddsratio_eegxlfp_diff_monkey(2,1).axe_property('YLim',[-0.3 0.3]); 

figure_oddsratio_eegxlfp_diff_monkey(1,1).geom_hline('yintercept',0); 
figure_oddsratio_eegxlfp_diff_monkey(2,1).geom_hline('yintercept',0); 

figure('Renderer', 'painters', 'Position', [100 100 1000 600]);
figure_oddsratio_eegxlfp_diff_monkey.draw();


%%

for alignment_i = 1:length(eventAlignments)
    alignmentEvent = eventAlignments{alignment_i};
    eeg_lfp_OR.(alignmentEvent) = NaN(length(14:29),18);
    
    for session_i = 14:29
        n_lfp = max(find(~cellfun(@isempty, trl_burst_diff_lfp_shuf.(alignmentEvent)(session_i,:,1))));
        
        % Loop through each channel
        for lfp_i = 1:n_lfp
            eeg_lfp_OR.(alignmentEvent)(session_i-13,lfp_i) = ...
                nanmean(fisherstats.(alignmentEvent).obs.odds{session_i-13}(lfp_i,:))-...
                nanmean(fisherstats.(alignmentEvent).shuf.odds{session_i-13}(lfp_i,:));
        end
    end
    
end


figure;
for alignment_i = 1:length(eventAlignments)
    alignmentEvent = eventAlignments{alignment_i};
    subplot(4,1,alignment_i)
    imagesc(nanmean(eeg_lfp_OR.(alignmentEvent)))
    colormap(viridis); set(gca,'CLim', [0 50])
end
