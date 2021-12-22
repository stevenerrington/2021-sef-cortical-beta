



%% 
% load([outputDir 'stoppingBeta.mat']);
% Extracted by:
stoppingBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTime...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap);
stoppingBeta.timing.noncanceled = SEF_stoppingLFP_getAverageBurstTime...
    (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap);
stoppingBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTime...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap);


% Concatenate across all sessions
cancTimes_stopSignal = []; noncancTimes_stopSignal = []; nostopTimes_stopSignal = [];
clear inputContacts
inputContacts = 1:length(corticalLFPcontacts.all);

for lfpIdx = 1:length(inputContacts)
    lfp = inputContacts(lfpIdx);
    cancTimes_stopSignal = [cancTimes_stopSignal;stoppingBeta.timing.canceled.burstTimes{lfp}];
    noncancTimes_stopSignal = [noncancTimes_stopSignal;stoppingBeta.timing.noncanceled.burstTimes{lfp}];
    nostopTimes_stopSignal = [nostopTimes_stopSignal;stoppingBeta.timing.nostop.burstTimes{lfp}];
end


%% Figure
% Get labels for figure
allBurstTimes_stopSignal = [nostopTimes_stopSignal;noncancTimes_stopSignal;cancTimes_stopSignal];
alltrialLabels_stopSignal = [repmat({'No-stop'},length(nostopTimes_stopSignal),1);...
    repmat({'Non-canceled'},length(noncancTimes_stopSignal),1),;...
    repmat({'Canceled'},length(cancTimes_stopSignal),1)];

% Set up figures
clear testfigure

% % BBDF
testfigure(1,1)=gramm('x',time,'y',[bbdf_canceled(inputContacts);...
    bbdf_nostop(inputContacts);bbdf_noncanceled(inputContacts)],...
    'color',[repmat({'Canceled'},length(inputContacts),1);...
    repmat({'No-stop'},length(inputContacts),1);...
    repmat({'Non-canceled'},length(inputContacts),1)]); 
testfigure(1,1).stat_summary();
testfigure(1,1).axe_property('XLim',[-250 500]); 
testfigure(1,1).geom_vline('xintercept',0,'style','k-')
testfigure(1,1).geom_vline('xintercept',mean(bayesianSSRT.ssrt_mean),'style','k--')
testfigure(1,1).axe_property('YLim',[0.0000 0.0025]);
testfigure(1,1).no_legend();

testfigure.set_names('y','');
testfigure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 350 350]);
testfigure.draw();
