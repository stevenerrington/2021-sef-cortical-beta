
%% Generate Figure

clear testfigure
time = [-1000:2000];
ssrt_time = [-500:1000];

eegInputSessions = executiveBeh.nhpSessions.XSessions;
lfpInputSessions = corticalLFPcontacts.subset.x;
% EEG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SSD aligned
testfigure(1,1)=gramm('x',time,'y',[EEGbbdf_canceled_stopSignal(eegInputSessions);...
    EEGbbdf_nostop_stopSignal(eegInputSessions);EEGbbdf_noncanceled_stopSignal(eegInputSessions)],...
    'color',[repmat({'Canceled'},length(eegInputSessions),1);...
    repmat({'No-stop'},length(eegInputSessions),1);...
    repmat({'Non-canceled'},length(eegInputSessions),1)]);
% SSRT aligned
testfigure(1,2)=gramm('x',ssrt_time,'y',[EEGbbdf_canceled_ssrt(eegInputSessions);...
    EEGbbdf_nostop_ssrt(eegInputSessions)],...
    'color',[repmat({'Canceled'},length(eegInputSessions),1);...
    repmat({'No-stop'},length(eegInputSessions),1)]);
% Tone aligned
testfigure(1,3)=gramm('x',time,'y',[EEGbbdf_canceled_tone(eegInputSessions);...
    EEGbbdf_nostop_tone(eegInputSessions);EEGbbdf_noncanceled_tone(eegInputSessions)],...
    'color',[repmat({'Canceled'},length(eegInputSessions),1);...
    repmat({'No-stop'},length(eegInputSessions),1);...
    repmat({'Non-canceled'},length(eegInputSessions),1)]);
% Saccade aligned
testfigure(1,4)=gramm('x',time,'y',[EEGbbdf_noncanceled_saccade(eegInputSessions);...
    EEGbbdf_nostop_saccade(eegInputSessions)],...
    'color',[repmat({'Non-canceled'},length(eegInputSessions),1);...
    repmat({'No-stop'},length(eegInputSessions),1)]);

% LFP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SSD aligned
testfigure(2,1)=gramm('x',time,'y',[LFPbbdf_canceled_stopSignal(lfpInputSessions);...
    LFPbbdf_nostop_stopSignal(lfpInputSessions);LFPbbdf_noncanceled_stopSignal(lfpInputSessions)],...
    'color',[repmat({'Canceled'},length(lfpInputSessions),1);...
    repmat({'No-stop'},length(lfpInputSessions),1);...
    repmat({'Non-canceled'},length(lfpInputSessions),1)]);
% SSRT aligned
testfigure(2,2)=gramm('x',ssrt_time,'y',[LFPbbdf_canceled_ssrt(lfpInputSessions);...
    LFPbbdf_nostop_ssrt(lfpInputSessions)],...
    'color',[repmat({'Canceled'},length(lfpInputSessions),1);...
    repmat({'No-stop'},length(lfpInputSessions),1)]);
% Tone aligned
testfigure(2,3)=gramm('x',time,'y',[LFPbbdf_canceled_tone(lfpInputSessions);...
    LFPbbdf_nostop_tone(lfpInputSessions);LFPbbdf_noncanceled_tone(lfpInputSessions)],...
    'color',[repmat({'Canceled'},length(lfpInputSessions),1);...
    repmat({'No-stop'},length(lfpInputSessions),1);...
    repmat({'Non-canceled'},length(lfpInputSessions),1)]);
% Saccade aligned
testfigure(2,4)=gramm('x',time,'y',[LFPbbdf_noncanceled_saccade(lfpInputSessions);...
    LFPbbdf_nostop_saccade(lfpInputSessions)],...
    'color',[repmat({'Non-canceled'},length(lfpInputSessions),1);...
    repmat({'No-stop'},length(lfpInputSessions),1)]);


% GRAMM Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SSD - EEG
testfigure(1,1).stat_summary(); testfigure(1,1).no_legend;
testfigure(1,1).axe_property('XLim',[-200 200]); testfigure(1,1).axe_property('YLim',[0.0000 0.0040]);
testfigure(1,1).geom_vline('xintercept',0,'style','k-');
testfigure(1,1).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

% SSRT - EEG
testfigure(1,2).stat_summary(); testfigure(1,2).no_legend;
testfigure(1,2).axe_property('XLim',[-200 600]); testfigure(1,2).axe_property('YLim',[0.0000 0.0040]);
testfigure(1,2).geom_vline('xintercept',0,'style','k-');
testfigure(1,2).set_color_options('map',[colors.canceled;colors.nostop]);

% Tone - EEG
testfigure(1,3).stat_summary(); testfigure(1,3).no_legend;
testfigure(1,3).axe_property('XLim',[-600 200]); testfigure(1,3).axe_property('YLim',[0.0000 0.0060]);
testfigure(1,3).geom_vline('xintercept',0,'style','k-');
testfigure(1,3).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

% Saccade - EEG
testfigure(1,4).stat_summary(); testfigure(1,4).no_legend;
testfigure(1,4).axe_property('XLim',[-200 600]); testfigure(1,4).axe_property('YLim',[0.0000 0.0040]);
testfigure(1,4).geom_vline('xintercept',0,'style','k-');
testfigure(1,4).set_color_options('map',[colors.nostop;colors.noncanc]);

% SSD - LFP
testfigure(2,1).stat_summary(); testfigure(2,1).no_legend;
testfigure(2,1).axe_property('XLim',[-200 200]); testfigure(2,1).axe_property('YLim',[0.0000 0.0020]);
testfigure(2,1).geom_vline('xintercept',0,'style','k-');
testfigure(2,1).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

% SSRT - LFP
testfigure(2,2).stat_summary(); testfigure(2,2).no_legend;
testfigure(2,2).axe_property('XLim',[-200 600]); testfigure(2,2).axe_property('YLim',[0.0000 0.0020]);
testfigure(2,2).geom_vline('xintercept',0,'style','k-');
testfigure(2,2).set_color_options('map',[colors.canceled;colors.nostop]);

% Tone - LFP
testfigure(2,3).stat_summary(); testfigure(2,3).no_legend;
testfigure(2,3).axe_property('XLim',[-600 200]); testfigure(2,3).axe_property('YLim',[0.0000 0.0030]);
testfigure(2,3).geom_vline('xintercept',0,'style','k-');
testfigure(2,3).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

% Saccade - LFP
testfigure(2,4).stat_summary(); testfigure(2,4).no_legend;
testfigure(2,4).axe_property('XLim',[-200 600]); testfigure(2,4).axe_property('YLim',[0.0000 0.0020]);
testfigure(2,4).geom_vline('xintercept',0,'style','k-');
testfigure(2,4).set_color_options('map',[colors.nostop;colors.noncanc]);


figure('Renderer', 'painters', 'Position', [100 100 1400 600]);
testfigure.draw();

