



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
% % sum(nanmean(pBurst_LFP_lower(:,find(getMidBin(bin) > 0 & getMidBin(bin) < 50))))
% % 
% % 
% % sum(nanmean(pBurst_LFPshuf_upper(:,find(getMidBin(bin) > -50 & getMidBin(bin) < 0))))
% % sum(nanmean(pBurst_LFPshuf_upper(:,find(getMidBin(bin) > 0 & getMidBin(bin) < 50))))
% % 
% % sum(nanmean(pBurst_LFPshuf_lower(:,find(getMidBin(bin) > -50 & getMidBin(bin) < 0))))
% % sum(nanmean(pBurst_LFPshuf_lower(:,find(getMidBin(bin) > 0 & getMidBin(bin) < 50))))
% % 
% % 
% % 
% % %% Figure: 50 ms burst window
% data = [eeg_pre_upper'; eeg_pre_lower'; eeg_pre_upper_shuf'; eeg_pre_lower_shuf';...
%     eeg_post_upper'; eeg_post_lower'; eeg_post_upper_shuf'; eeg_post_lower_shuf'];
% nSessions = length(14:29);
% 
% label_obs_shuf = repmat([repmat({'Obs.'},nSessions*2,1);repmat({'Shuf'},nSessions*2,1)],2,1);
% label_pre_post = [repmat({'1_pre-EEG'},nSessions*4,1);repmat({'2_post-EEG'},nSessions*4,1)];
% label_upper_lower = repmat([repmat({'Upper'},nSessions,1);repmat({'Lower'},nSessions,1)],4,1);
% 
% pBurst_layer_epoch_plot(1,1) = gramm('x',label_pre_post,...
%     'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Upper'));
% pBurst_layer_epoch_plot(1,2) = gramm('x',label_pre_post,...
%     'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Lower'));
% 
% 
% pBurst_layer_epoch_plot(1,1).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
% pBurst_layer_epoch_plot(1,2).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
% pBurst_layer_epoch_plot(1,1).axe_property('YLim',[1.0 1.8]);
% pBurst_layer_epoch_plot(1,2).axe_property('YLim',[1.0 1.8]);
% figure('Renderer', 'painters', 'Position', [100 100 700 300]);
% pBurst_layer_epoch_plot.draw();
% 
% % Figure: split by monkey
% monkeyLabels = {};
% monkeyLabels = repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),8,1);
% 
% pBurst_layer_epoch_plot(1,1) = gramm('x',label_pre_post,...
%     'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Upper') & strcmp(monkeyLabels,'Euler'));
% pBurst_layer_epoch_plot(1,2) = gramm('x',label_pre_post,...
%     'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Lower') & strcmp(monkeyLabels,'Euler'));
% pBurst_layer_epoch_plot(2,1) = gramm('x',label_pre_post,...
%     'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Upper') & strcmp(monkeyLabels,'Euler'));
% pBurst_layer_epoch_plot(2,2) = gramm('x',label_pre_post,...
%     'y',data,'color',label_obs_shuf,'subset',strcmp(label_upper_lower,'Lower') & strcmp(monkeyLabels,'Xena'));
% 
% pBurst_layer_epoch_plot(1,1).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
% pBurst_layer_epoch_plot(1,2).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
% pBurst_layer_epoch_plot(2,1).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
% pBurst_layer_epoch_plot(2,2).stat_summary('type','sem','geom',{'point','line','black_errorbar'});
% 
% pBurst_layer_epoch_plot(1,1).axe_property('YLim',[1.0 2]);
% pBurst_layer_epoch_plot(1,2).axe_property('YLim',[1.0 2]);
% pBurst_layer_epoch_plot(2,1).axe_property('YLim',[1.0 2]);
% pBurst_layer_epoch_plot(2,2).axe_property('YLim',[1.0 2]);
% 
% figure('Renderer', 'painters', 'Position', [100 100 700 600]);
% pBurst_layer_epoch_plot.draw();
% %% Analysis: Cumulative P(burst) through time relative to EEG burst
% 
% clear cumul_eeg_pre_* cumul_eeg_post_* bin_preEEG bin_postEEG
% 
% bin_preEEG = find(getMidBin(bin) < 0);
% bin_postEEG = find(getMidBin(bin) > 0);
% 
% for session_i = 14:29
%     fprintf('Analysing session %i of %i. \n',session_i, 29)
%     
%     for bin_i_pre = 1:length(bin_preEEG)
%         cumul_eeg_pre_upper_obs{session_i - 13}(1,bin_i_pre) =...
%             sum(pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_preEEG(1):bin_preEEG(bin_i_pre)));
%         cumul_eeg_pre_upper_shuf{session_i - 13}(1,bin_i_pre) =...
%             sum(pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_preEEG(1):bin_preEEG(bin_i_pre)));        
%         cumul_eeg_pre_lower_obs{session_i - 13}(1,bin_i_pre) =...
%             sum(pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_preEEG(1):bin_preEEG(bin_i_pre)));
%         cumul_eeg_pre_lower_shuf{session_i - 13}(1,bin_i_pre) =...
%             sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_preEEG(1):bin_preEEG(bin_i_pre)));    
%     end
%     
%     for bin_i_post = 1:length(bin_postEEG)
%         cumul_eeg_post_upper_obs{session_i - 13}(1,bin_i_post) =...
%             sum(pBurst_lfp_eeg.obs.upper{session_i-13}(:,bin_postEEG(1):bin_postEEG(bin_i_post)));
%         cumul_eeg_post_upper_shuf{session_i - 13}(1,bin_i_post) =...
%             sum(pBurst_lfp_eeg.shuf.upper{session_i-13}(:,bin_postEEG(1):bin_postEEG(bin_i_post)));        
%         cumul_eeg_post_lower_obs{session_i - 13}(1,bin_i_post) =...
%             sum(pBurst_lfp_eeg.obs.lower{session_i-13}(:,bin_postEEG(1):bin_postEEG(bin_i_post)));
%         cumul_eeg_post_lower_shuf{session_i - 13}(1,bin_i_post) =...
%             sum(pBurst_lfp_eeg.shuf.lower{session_i-13}(:,bin_postEEG(1):bin_postEEG(bin_i_post)));    
%     end
%     
% end
% 
% %% Figure: Cumulative P(burst) through time relative to EEG burst 
% clear cumul_pBurst_figure % clear the gramm variable, incase it already exists
% 
% % Input relevant data into the gramm function, and set the parameters
% % Fixation aligned
% cumul_pBurst_figure(1,1)=gramm('x',getMidBin(-[0:10:250]),...
%     'y',[cumul_eeg_pre_upper_obs';cumul_eeg_pre_upper_shuf';...
%     cumul_eeg_pre_lower_obs';cumul_eeg_pre_lower_shuf'],...
%     'color',[repmat({'1_Upper'},16,1);repmat({'2_Upper - Shuffled'},16,1);...
%     repmat({'3_Lower'},16,1);repmat({'4_Lower - Shuffled'},16,1)]);
% 
% cumul_pBurst_figure(1,2)=gramm('x',getMidBin([0:10:250]),...
%     'y',[cumul_eeg_post_upper_obs';cumul_eeg_post_upper_shuf';...
%     cumul_eeg_post_lower_obs';cumul_eeg_post_lower_shuf'],...
%     'color',[repmat({'1_Upper'},16,1);repmat({'2_Upper - Shuffled'},16,1);...
%     repmat({'3_Lower'},16,1);repmat({'4_Lower - Shuffled'},16,1)]);
% 
% cumul_pBurst_figure(1,1).stat_summary('type','sem','geom',{'point','errorbar'}); 
% cumul_pBurst_figure(1,2).stat_summary('type','sem','geom',{'point','errorbar'}); 
% 
% cumul_pBurst_figure(1,1).set_names('x','Time before EEG burst (ms)');
%  cumul_pBurst_figure(1,2).set_names('x','Time after EEG burst (ms)');
% cumul_pBurst_figure.set_names('y','Cumulative P(Burst)'); 
% 
% % cumul_pBurst_figure(1,1).axe_property('XLim',[0 50]); 
% %cumul_pBurst_figure(1,1).axe_property('YLim',[0 1]);
% % cumul_pBurst_figure(1,2).axe_property('XLim',[0 20]); 
% %cumul_pBurst_figure(1,2).axe_property('YLim',[0 1]);
% 
% 
% figure('Renderer', 'painters', 'Position', [100 100 900 300]);
% cumul_pBurst_figure.draw();
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
% 
% 
% 
% 
% 


% 
