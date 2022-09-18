

ntrls = 200;
p_coactive_list = [0.05, 0.8];
p_positive = 0.5;
n_windows = 17;

cond_list = {'low','adj','upper','lower','high','random'};

for cond_i = 1:length(cond_list)
        fprintf('Condition %i of %i ... | \n',cond_i,length(cond_list))
    for window_i = 1:n_windows
        fprintf('Window %i of %i ... | \n',window_i,n_windows)
        for lfp_i = 1:18
            for lfp_j = 1:18
                
                % Get conditional mapping.
                % For low across all contacts:
                if strcmp(cond_list{cond_i},'low')
                    p_coactive = p_coactive_list(1);
                    % For high similarity between contacts:
                elseif strcmp(cond_list{cond_i},'adj')
                    if lfp_j == lfp_i - 1 || lfp_j == lfp_i + 1
                        p_coactive = p_coactive_list(2);
                    else
                        p_coactive = p_coactive_list(1);
                    end
                    % For high similarity between upper layer contacts:
                elseif strcmp(cond_list{cond_i},'upper')
                    if ismember(lfp_i, 1:8) & ismember(lfp_j, 1:8)
                        p_coactive = p_coactive_list(2);
                    else
                        p_coactive = p_coactive_list(1);
                    end
                    % For high similarity between lower layer contacts:
                elseif strcmp(cond_list{cond_i},'lower')
                    if ismember(lfp_i, 9:18) & ismember(lfp_j, 9:18)
                        p_coactive = p_coactive_list(2);
                    else
                        p_coactive = p_coactive_list(1);
                    end
                    % For high similarity between lower layer contacts:
                elseif strcmp(cond_list{cond_i},'high')
                    p_coactive = p_coactive_list(2);
                elseif strcmp(cond_list{cond_i},'random')
                    p_coactive = rand;
                end
                
                
                lfp_array = [[0;0],[0;0]];
                
                for trl = 1:ntrls
                    % If coactive
                    if rand <= p_coactive
                        % If positive (co-occurance)
                        if rand <= p_positive
                            lfp_array(1,1) = lfp_array(1,1)+1;
                            % If negative (absence)
                        else
                            lfp_array(2,2) = lfp_array(2,2)+1;
                        end
                    else
                        if rand <= p_positive
                            lfp_array(1,2) = lfp_array(1,2)+1;
                            % If negative (absence)
                        else
                            lfp_array(2,1) = lfp_array(2,1)+1;
                        end
                    end
                end
                
                [h_sim,p_sim,stats_sim] = fishertest(lfp_array,'tail','right','alpha',0.05/17);
                
                fisherstats.simulated.h{cond_i}(lfp_i,lfp_j,window_i) = h_sim;
                fisherstats.simulated.p{cond_i}(lfp_i,lfp_j,window_i) = p_sim;
                fisherstats.simulated.odds{cond_i}(lfp_i,lfp_j,window_i) = stats_sim.OddsRatio;
                
                
            end
        end
    end
end


%%
figure('Renderer', 'painters', 'Position', [100 100 1500 400]);
for plot_i = 1:5
    
    plot_data = []; plot_data = nanmean(fisherstats.simulated.odds{plot_i},3);
    subplot(2,5,plot_i)
    imagesc(plot_data)
    colorbar
    colormap(viridis)
    set(gca,'Clim',[0 25])
    title(cond_list{plot_i})
    
    subplot(2,5,plot_i+5)
    scatter([1,2,3,4],...
        [nanmean(nanmean(plot_data([1:8],[1:8]))),...
        nanmean(nanmean(plot_data([9:18],[9:18]))),...
        nanmean(nanmean(plot_data([1:8],[9:18]))),...
        nanmean(nanmean(plot_data([9:18],[1:8])))],...
        'Filled')
    ylim([0 30]); xlim([0 5])
end


%% EEG


ntrls = 200;
p_coactive_list = [0.05, 0.8];
p_positive = 0.5;
n_windows = 17;

cond_list = {'low','adj','upper','lower','high','random'};

for cond_i = 1:length(cond_list)
        fprintf('Condition %i of %i ... | \n',cond_i,length(cond_list))
    for window_i = 1:n_windows
        fprintf('Window %i of %i ... | \n',window_i,n_windows)
        for eeg_i = 1
            for lfp_j = 1:18
                
                % Get conditional mapping.
                % For low across all contacts:
                if strcmp(cond_list{cond_i},'low')
                    p_coactive = p_coactive_list(1);
                    % For high similarity between contacts:
                elseif strcmp(cond_list{cond_i},'adj')
                    if lfp_j == eeg_i
                        p_coactive = p_coactive_list(2);
                    else
                        p_coactive = p_coactive_list(1);
                    end
                    % For high similarity between upper layer contacts:
                elseif strcmp(cond_list{cond_i},'upper')
                    if ismember(eeg_i, 1) & ismember(lfp_j, 1:8)
                        p_coactive = p_coactive_list(2);
                    else
                        p_coactive = p_coactive_list(1);
                    end
                    % For high similarity between lower layer contacts:
                elseif strcmp(cond_list{cond_i},'lower')
                    if ismember(eeg_i, 1) & ismember(lfp_j, 9:18)
                        p_coactive = p_coactive_list(2);
                    else
                        p_coactive = p_coactive_list(1);
                    end
                    % For high similarity between lower layer contacts:
                elseif strcmp(cond_list{cond_i},'high')
                    p_coactive = p_coactive_list(2);
                elseif strcmp(cond_list{cond_i},'random')
                    p_coactive = rand;
                end
                
                
                lfp_array = [[0;0],[0;0]];
                
                for trl = 1:ntrls
                    % If coactive
                    if rand <= p_coactive
                        % If positive (co-occurance)
                        if rand <= p_positive
                            lfp_array(1,1) = lfp_array(1,1)+1;
                            % If negative (absence)
                        else
                            lfp_array(2,2) = lfp_array(2,2)+1;
                        end
                    else
                        if rand <= p_positive
                            lfp_array(1,2) = lfp_array(1,2)+1;
                            % If negative (absence)
                        else
                            lfp_array(2,1) = lfp_array(2,1)+1;
                        end
                    end
                end
                
                [h_sim,p_sim,stats_sim] = fishertest(lfp_array,'tail','right','alpha',0.05/17);
                
                fisherstats.simulated_eeg.h{cond_i}(eeg_i,lfp_j,window_i) = h_sim;
                fisherstats.simulated_eeg.p{cond_i}(eeg_i,lfp_j,window_i) = p_sim;
                fisherstats.simulated_eeg.odds{cond_i}(eeg_i,lfp_j,window_i) = stats_sim.OddsRatio;
                
                
            end
        end
    end
end

%%
figure('Renderer', 'painters', 'Position', [100 100 1500 50]);
for plot_i = 1:5
    
    plot_data = []; plot_data = nanmean(fisherstats.simulated_eeg.odds{plot_i},3);
    subplot(1,5,plot_i)
    imagesc(plot_data)
    colorbar
    colormap(viridis)
    set(gca,'Clim',[0 25])
    title(cond_list{plot_i})
    
end
