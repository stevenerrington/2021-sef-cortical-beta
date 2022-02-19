
%% Get main information tables
% Fixation: -400 to 200 ms pre-target
fixationBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeTarget...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);
fixationBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTimeSSRT...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);

% Post SSRT: 200 to 400 ms
ssrtBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeSSRT...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);
ssrtBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTimeSSRT...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);

% Pre tone: -400 to -200 ms
pretoneBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeTone...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [-400 -200]);
pretoneBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTimeTone...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [-400 -200]);

% Post tone: -400 to -200 ms
posttoneBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeTone...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300]);
posttoneBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTimeTone...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300]);






%% Produce post-ssrt-related activity figure
clear ssrt_figure
allChannels = 1:length(corticalLFPcontacts.all);
euChannels = corticalLFPcontacts.subset.eu;
xChannels = corticalLFPcontacts.subset.x;
time = [-1000:2000];

groupLabelsNoStop = repmat({'No-stop'},length(ssrtBeta.timing.nostop.pTrials_burst),1);
groupLabelsCanc = repmat({'Canceled'},length(ssrtBeta.timing.canceled.pTrials_burst),1);

burstDataNoStop = [ssrtBeta.timing.nostop.pTrials_burst];
burstDataCanc = [ssrtBeta.timing.canceled.pTrials_burst];

ssrt_figure(1,1) = gramm('x',[groupLabelsNoStop(allChannels);groupLabelsCanc(allChannels)],...
    'y',[burstDataNoStop(allChannels);burstDataCanc(allChannels)],'color',[groupLabelsNoStop(allChannels);groupLabelsCanc(allChannels)]);
ssrt_figure(1,2) = gramm('x',[groupLabelsNoStop(euChannels);groupLabelsCanc(euChannels)],...
    'y',[burstDataNoStop(euChannels);burstDataCanc(euChannels)],'color',[groupLabelsNoStop(euChannels);groupLabelsCanc(euChannels)]);
ssrt_figure(1,3) = gramm('x',[groupLabelsNoStop(xChannels);groupLabelsCanc(xChannels)],...
    'y',[burstDataNoStop(xChannels);burstDataCanc(xChannels)],'color',[groupLabelsNoStop(xChannels);groupLabelsCanc(xChannels)]);

ssrt_figure(1,1).stat_boxplot(); ssrt_figure(1,1).geom_jitter('alpha',0.1,'dodge',0.75);
ssrt_figure(1,2).stat_boxplot(); ssrt_figure(1,2).geom_jitter('alpha',0.1,'dodge',0.75);
ssrt_figure(1,3).stat_boxplot(); ssrt_figure(1,3).geom_jitter('alpha',0.1,'dodge',0.75);

ssrt_figure.set_names('y','');
ssrt_figure(1,1).axe_property('YLim',[0 1.0]); ssrt_figure(1,2).axe_property('YLim',[0 1.0]); ssrt_figure(1,3).axe_property('YLim',[0 1.0]); 

ssrt_figure(1,1).no_legend();ssrt_figure(1,2).no_legend();ssrt_figure(1,3).no_legend();

ssrt_figure.set_color_options('map',[colors.canceled; colors.nostop]);

figure('Renderer', 'painters', 'Position', [100 100 600 250]);
ssrt_figure.draw();

%%
groupLabels_nostop = repmat({'No-stop'},length(ssrtBeta.timing.nostop.pTrials_burst)*4,1);
groupLabels_canc = repmat({'Canceled'},length(ssrtBeta.timing.canceled.pTrials_burst)*4,1);

eventLabel_fixation = repmat({'Fixation'},length(ssrtBeta.timing.nostop.pTrials_burst),1);
eventLabel_SSRT = repmat({'SSRT'},length(ssrtBeta.timing.nostop.pTrials_burst),1);
eventLabel_preTone = repmat({'Pre-tone'},length(ssrtBeta.timing.nostop.pTrials_burst),1);
eventLabel_postTone = repmat({'Post-tone'},length(ssrtBeta.timing.nostop.pTrials_burst),1);

burstDataNoStop = [fixationBeta.timing.nostop.pTrials_burst;...
                   ssrtBeta.timing.nostop.pTrials_burst;...
                   pretoneBeta.timing.nostop.pTrials_burst;...
                   posttoneBeta.timing.nostop.pTrials_burst];
burstDataCanc = [fixationBeta.timing.canceled.pTrials_burst;...
                   ssrtBeta.timing.canceled.pTrials_burst;...
                   pretoneBeta.timing.canceled.pTrials_burst;...
                   posttoneBeta.timing.canceled.pTrials_burst];
               
 
trialLabels = [groupLabels_nostop;groupLabels_canc];
eventLabels = repmat([eventLabel_fixation;eventLabel_SSRT;eventLabel_preTone;eventLabel_postTone],2,1);
burstData = [burstDataNoStop; burstDataCanc];


poststop_Figure(1,1) = gramm('x',eventLabels,'y',burstData,'color',trialLabels);

poststop_Figure(1,1).stat_summary('geom',{'point','line','black_errorbar'});

poststop_Figure.set_names('y','');
poststop_Figure(1,1).axe_property('YLim',[0.1 0.3]); 

poststop_Figure(1,1).no_legend();

poststop_Figure.set_color_options('map',[colors.canceled; colors.nostop]);

figure('Renderer', 'painters', 'Position', [100 100 600 250]);
poststop_Figure.draw();
