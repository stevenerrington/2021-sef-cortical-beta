%% Figure 1: p(Burst) over multiple epochs
clear poststop_Figure
% Generate labels for the conditions
nConds = 5;
allChannels = 1:length(corticalLFPcontacts.all);
euChannels = corticalLFPcontacts.subset.eu;
xChannels = corticalLFPcontacts.subset.x;

% - trial labels
groupLabels_nostop = repmat({'1_No-stop'},length(allChannels)*nConds,1);
groupLabels_canc = repmat({'2_Canceled'},length(allChannels)*nConds,1);
groupLabels_noncanc = repmat({'3_Noncanceled'},length(allChannels)*nConds,1);
 % - epoch labels
eventLabel_fixation = repmat({'1_Fixation'},length(allChannels),1);
eventLabel_target = repmat({'2_Target'},length(allChannels),1);
eventLabel_postaction_early = repmat({'3_PostAction_Early'},length(allChannels),1);
eventLabel_postaction_late = repmat({'4_PostAction_Late'},length(allChannels),1);
eventLabel_postTone = repmat({'5_PostTone_Late'},length(allChannels),1);

% Define data to use in the plot, split by trial type, and concatenated
% through epochs
burstDataNoStop = [fixationBeta.timing.nostop.pTrials_burst;...
                   targetBeta.timing.nostop.pTrials_burst;...
                   errorBeta_early.timing.nostop.pTrials_burst;...
                   errorBeta_late.timing.nostop.pTrials_burst;...
                   posttoneBeta.timing.nostop.pTrials_burst];
burstDataCanc = [fixationBeta.timing.canceled.pTrials_burst;...
                   targetBeta.timing.canceled.pTrials_burst;...
                   ssrtBeta.timing.canceled.pTrials_burst;...
                   pretoneBeta.timing.canceled.pTrials_burst;...
                   posttoneBeta.timing.canceled.pTrials_burst];
 burstDataNoncanc = [fixationBeta.timing.noncanceled.pTrials_burst;...
                   targetBeta.timing.noncanceled.pTrials_burst;...
                   errorBeta_early.timing.noncanc.pTrials_burst;...
                   errorBeta_late.timing.noncanc.pTrials_burst;...
                   posttoneBeta.timing.noncanceled.pTrials_burst];              
 

               
% Define data to use in the plot
trialLabels = [groupLabels_nostop;groupLabels_canc;groupLabels_noncanc];
eventLabels = repmat([eventLabel_fixation;eventLabel_target;...
    eventLabel_postaction_early;eventLabel_postaction_late;eventLabel_postTone],3,1);
burstData = [burstDataNoStop; burstDataCanc;burstDataNoncanc];
monkeyLabel = repmat(corticalLFPmap.monkeyName,15,1);

clear poststop_Figure
% Input information into gramm function for:
poststop_Figure(1,1) = gramm('x',eventLabels,'y',burstData,'color',trialLabels);

% Set figure properties
poststop_Figure(1,1).stat_summary('geom',{'point','line','errorbar'});
poststop_Figure(1,1).axe_property('YLim',[0.1 0.35]); 

poststop_Figure.set_color_options('map',[colors.nostop; colors.canceled; colors.noncanc]);
poststop_Figure.set_names('y','');

% Generate figure
figure('Renderer', 'painters', 'Position', [100 100 700 300]);
poststop_Figure.draw();



clear poststop_Figure_monkey
% Input information into gramm function for:
poststop_Figure_monkey(1,1) = gramm('x',eventLabels,'y',burstData,'color',trialLabels);

% Set figure properties
poststop_Figure_monkey(1,1).stat_summary('geom',{'point','line','errorbar'});
poststop_Figure_monkey(1,1).axe_property('YLim',[0.1 0.5]); 

poststop_Figure_monkey.set_color_options('map',[colors.nostop; colors.canceled; colors.noncanc]);
poststop_Figure_monkey.set_names('y','');
poststop_Figure_monkey.facet_grid([], monkeyLabel,'scale','free_y');

% Generate figure
figure('Renderer', 'painters', 'Position', [100 100 1200 300]);
poststop_Figure_monkey.draw();






%% Output data to JASP: code works but needs cleaned!
eventList = {'fixation','target','postaction_early','postaction_late','tone'};
trialList = {'nostop','canceled','noncanceled'};

clear label; count= 0;
for eventIdx = 1:length(eventList)
    for trltypeIdx = 1:length(trialList)
        count = count + 1;
        label{1,count} = [eventList{eventIdx} '_' trialList{trltypeIdx}];
    end
end


stoppingMonitoring = table();

stoppingMonitoring = table(corticalLFPmap.channelN, corticalLFPmap.session,corticalLFPmap.monkeyName,...
    fixationBeta.timing.nostop.pTrials_burst,fixationBeta.timing.canceled.pTrials_burst,fixationBeta.timing.noncanceled.pTrials_burst,...
    targetBeta.timing.nostop.pTrials_burst, targetBeta.timing.canceled.pTrials_burst, targetBeta.timing.noncanceled.pTrials_burst,...
    errorBeta_early.timing.nostop.pTrials_burst, ssrtBeta.timing.canceled.pTrials_burst, errorBeta_early.timing.noncanc.pTrials_burst,...
    errorBeta_late.timing.nostop.pTrials_burst,  pretoneBeta.timing.canceled.pTrials_burst, errorBeta_late.timing.noncanc.pTrials_burst,...
    posttoneBeta.timing.nostop.pTrials_burst, posttoneBeta.timing.canceled.pTrials_burst, posttoneBeta.timing.noncanceled.pTrials_burst,...
    'VariableNames',[{'Channel','Session','Monkey'}, label]);


writetable(stoppingMonitoring,fullfile(rootDir,'results','jasp_tables','canc_nostop_epochComp.csv'),'WriteRowNames',true)



%% Analysis: Effect Size
n_bootstrap_iter = 100;

clear cohen_d
for bootstrap_i = 1:n_bootstrap_iter
    lfp_in = randsample(509,250,false);
    
    cohen_d.fixation_stopping(bootstrap_i,1) =...
        computeCohen_d(fixationBeta.timing.nostop.pTrials_burst(lfp_in),...
        fixationBeta.timing.canceled.pTrials_burst(lfp_in));
    
    cohen_d.fixation_error(bootstrap_i,1) =...
        computeCohen_d(fixationBeta.timing.nostop.pTrials_burst(lfp_in),...
        fixationBeta.timing.noncanceled.pTrials_burst(lfp_in));
    
    cohen_d.stopping_inh(bootstrap_i,1) =...
        computeCohen_d(stoppingBeta.timing.canceled.pTrials_burst(lfp_in),...
        stoppingBeta.timing.nostop.pTrials_burst(lfp_in));
    cohen_d.stopping_ssrt(bootstrap_i,1) =...
        computeCohen_d(pretoneBeta.timing.canceled.pTrials_burst(lfp_in),...
        pretoneBeta.timing.nostop.pTrials_burst(lfp_in));
    
    cohen_d.error_early(bootstrap_i,1) =...
        computeCohen_d(errorBeta_early.timing.noncanc.pTrials_burst(lfp_in),...
        errorBeta_early.timing.nostop.pTrials_burst(lfp_in));
    cohen_d.error_late(bootstrap_i,1) =...
        computeCohen_d(errorBeta_late.timing.noncanc.pTrials_burst(lfp_in),...
        errorBeta_late.timing.nostop.pTrials_burst(lfp_in));
end


%% Figure: Effect Size


% Define data to use in the plot
effectSize_labels =...
   [repmat({'1_Fixation_C_NS'},n_bootstrap_iter,1);...
    repmat({'4_Fixation_NC_NS'},n_bootstrap_iter,1);...
    repmat({'2_Stopping_inh'},n_bootstrap_iter,1);...
    repmat({'3_Stopping_SSRT'},n_bootstrap_iter,1);...
    repmat({'5_Error_early'},n_bootstrap_iter,1);...
    repmat({'6_Error_late'},n_bootstrap_iter,1)];

effectSize_data = [cohen_d.fixation_stopping; cohen_d.fixation_error;...
    cohen_d.stopping_inh; cohen_d.stopping_ssrt;...
    cohen_d.error_early; cohen_d.error_late];


% Input information into gramm function for:
effectSize_Figure(1,1) = gramm('x',effectSize_labels,'y',effectSize_data,'color',effectSize_labels);

% Set figure properties
effectSize_Figure(1,1).stat_summary('geom',{'point','black_errorbar'});
% effectSize_Figure(1,1).geom_jitter();
effectSize_Figure.set_names('y','Effect Size');

% Generate figure
figure('Renderer', 'painters', 'Position', [100 100 400 300]);
effectSize_Figure.draw();




effectSize_epoch = table(...
    cohen_d.fixation_stopping, cohen_d.fixation_error,...
    cohen_d.stopping_inh, cohen_d.error_early,...
     cohen_d.stopping_ssrt, cohen_d.error_late,...
     'VariableNames',{'Fix_stopping','Fix_error','Stopping_inh','Error_early',...
     'Stopping_ssrt','Error_late'});



writetable(effectSize_epoch,fullfile(rootDir,'results','jasp_tables','effectSize_epoch.csv'),'WriteRowNames',true)



%% ARCHIVED:
% %% Figure 1: Boxplot p(Burst) at post-SSRT
% clear ssrt_figure
% % Define channel references
% allChannels = 1:length(corticalLFPcontacts.all);
% euChannels = corticalLFPcontacts.subset.eu;
% xChannels = corticalLFPcontacts.subset.x;
% 
% % Define time window
% time = [-1000:2000];
% 
% % Generate labels for the conditions
% groupLabelsNoStop = repmat({'No-stop'},length(ssrtBeta.timing.nostop.pTrials_burst),1);
% groupLabelsCanc = repmat({'Canceled'},length(ssrtBeta.timing.canceled.pTrials_burst),1);
% 
% % Define data to use in the plot
% burstDataNoStop = [ssrtBeta.timing.nostop.pTrials_burst];
% burstDataCanc = [ssrtBeta.timing.canceled.pTrials_burst];
% 
% % Input information into gramm function for:
%  % - all monkeys
% ssrt_figure(1,1) = gramm('x',[groupLabelsNoStop(allChannels);groupLabelsCanc(allChannels)],...
%     'y',[burstDataNoStop(allChannels);burstDataCanc(allChannels)],'color',[groupLabelsNoStop(allChannels);groupLabelsCanc(allChannels)]);
%  % - monkey Eu
% ssrt_figure(1,2) = gramm('x',[groupLabelsNoStop(euChannels);groupLabelsCanc(euChannels)],...
%     'y',[burstDataNoStop(euChannels);burstDataCanc(euChannels)],'color',[groupLabelsNoStop(euChannels);groupLabelsCanc(euChannels)]);
%  % - monkey X
% ssrt_figure(1,3) = gramm('x',[groupLabelsNoStop(xChannels);groupLabelsCanc(xChannels)],...
%     'y',[burstDataNoStop(xChannels);burstDataCanc(xChannels)],'color',[groupLabelsNoStop(xChannels);groupLabelsCanc(xChannels)]);
% 
% % Set figure properties
% ssrt_figure(1,1).stat_boxplot(); ssrt_figure(1,1).geom_jitter('alpha',0.1,'dodge',0.75);
% ssrt_figure(1,2).stat_boxplot(); ssrt_figure(1,2).geom_jitter('alpha',0.1,'dodge',0.75);
% ssrt_figure(1,3).stat_boxplot(); ssrt_figure(1,3).geom_jitter('alpha',0.1,'dodge',0.75);
% ssrt_figure.set_names('y','');
% ssrt_figure(1,1).axe_property('YLim',[0 1.0]); ssrt_figure(1,2).axe_property('YLim',[0 1.0]); ssrt_figure(1,3).axe_property('YLim',[0 1.0]); 
% ssrt_figure(1,1).no_legend();ssrt_figure(1,2).no_legend();ssrt_figure(1,3).no_legend();
% ssrt_figure.set_color_options('map',[colors.canceled; colors.nostop]);
% 
% % Generate figure
% figure('Renderer', 'painters', 'Position', [100 100 600 250]);
% ssrt_figure.draw();
