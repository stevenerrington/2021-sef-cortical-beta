%% Extract trial specific BBDFs

parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    ssrt = round(bayesianSSRT.ssrt_mean(session));
    
    bbdf = parload(['D:\projectCode\project_stoppingLFP\data\bbdf\bbdf_' int2str(lfpIdx)]);
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    % Get behavioral information
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    % Fixation aligned BBDF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bbdf_canceled_fixation{lfpIdx,1} = nanmean(bbdf.bbdf.fixate(trials.canceled, :));
    bbdf_noncanceled_fixation{lfpIdx,1} = nanmean(bbdf.bbdf.fixate(trials.noncanceled, :));
    bbdf_nostop_fixation{lfpIdx,1} = nanmean(bbdf.bbdf.fixate(trials.nostop, :));
        
    % Target aligned BBDF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bbdf_canceled_target{lfpIdx,1} = nanmean(bbdf.bbdf.target(trials.canceled, :));
    bbdf_noncanceled_target{lfpIdx,1} = nanmean(bbdf.bbdf.target(trials.noncanceled, :));
    bbdf_nostop_target{lfpIdx,1} = nanmean(bbdf.bbdf.target(trials.nostop, :));
    
    % Tone aligned BBDF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bbdf_canceled_tone{lfpIdx,1} = nanmean(bbdf.bbdf.tone(trials.canceled, :));
    bbdf_noncanceled_tone{lfpIdx,1} = nanmean(bbdf.bbdf.tone(trials.noncanceled, :));
    bbdf_nostop_tone{lfpIdx,1} = nanmean(bbdf.bbdf.tone(trials.nostop, :));
    
    
    % Stop-signal (latency matched aligned)  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    c_temp = []; nc_temp = []; ns_temp = [];
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        c_temp(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        nc_temp(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_temp(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
    end
    
    bbdf_canceled_stopSignal{lfpIdx,1} = nanmean(c_temp);
    bbdf_noncanceled_stopSignal{lfpIdx,1} = nanmean(nc_temp);
    bbdf_nostop_stopSignal{lfpIdx,1} = nanmean(ns_temp);   
    
    % SSRT (latency matched aligned)  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    bbdf_canceled_ssrt{lfpIdx,1} = bbdf_canceled_stopSignal{lfpIdx,1}...
        (1000+ssrt+[-500:1000]);
    bbdf_nostop_ssrt{lfpIdx,1} = bbdf_nostop_stopSignal{lfpIdx,1}...
        (1000+ssrt+[-500:1000]);
    
    % Saccade (latency matched aligned)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nc_sacc_temp = []; ns_sacc_temp = [];
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        nc_sacc_temp(ii,:) = nanmean(bbdf.bbdf.saccade(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_sacc_temp(ii,:) = nanmean(bbdf.bbdf.saccade(executiveBeh.ttm_c.GO_NC{session,ii}.all, :));
    end

    bbdf_noncanceled_saccade{lfpIdx,1} = nanmean(nc_sacc_temp);
    bbdf_nostop_saccade{lfpIdx,1} = nanmean(ns_sacc_temp);
    
end


%% Generate Figure

clear testfigure
time = [-1000:2000];
ssrt_time = [-500:1000];

% Fixation aligned
eventBBDFfigure(1,1)=gramm('x',time,'y',[bbdf_canceled_fixation;...
    bbdf_nostop_fixation;bbdf_noncanceled_fixation],...
    'color',[repmat({'Canceled'},length(bbdf_canceled_fixation),1);...
    repmat({'No-stop'},length(bbdf_nostop_fixation),1);...
    repmat({'Non-canceled'},length(bbdf_noncanceled_fixation),1)]);

% Target aligned
eventBBDFfigure(1,2)=gramm('x',time,'y',[bbdf_canceled_target;...
    bbdf_nostop_target;bbdf_noncanceled_target],...
    'color',[repmat({'Canceled'},length(bbdf_canceled_target),1);...
    repmat({'No-stop'},length(bbdf_nostop_target),1);...
    repmat({'Non-canceled'},length(bbdf_noncanceled_target),1)]);

% Stop-Signal aligned
eventBBDFfigure(1,3)=gramm('x',time,'y',[bbdf_canceled_stopSignal;...
    bbdf_nostop_stopSignal;bbdf_noncanceled_stopSignal],...
    'color',[repmat({'Canceled'},length(bbdf_canceled_stopSignal),1);...
    repmat({'No-stop'},length(bbdf_nostop_stopSignal),1);...
    repmat({'Non-canceled'},length(bbdf_noncanceled_stopSignal),1)]);

% SSRT aligned
eventBBDFfigure(2,1)=gramm('x',ssrt_time,'y',[bbdf_canceled_ssrt;...
    bbdf_nostop_ssrt],...
    'color',[repmat({'Canceled'},length(bbdf_canceled_ssrt),1);...
    repmat({'No-stop'},length(bbdf_nostop_ssrt),1)]);

% Saccade aligned
eventBBDFfigure(2,2)=gramm('x',time,'y',[bbdf_noncanceled_saccade;...
    bbdf_nostop_saccade],'color',[repmat({'Non-canceled'},length(bbdf_noncanceled_saccade),1);...
    repmat({'No-stop'},length(bbdf_nostop_saccade),1)]);

% Tone aligned
eventBBDFfigure(2,3)=gramm('x',time,'y',[bbdf_canceled_tone;...
    bbdf_nostop_tone;bbdf_noncanceled_tone],...
    'color',[repmat({'Canceled'},length(bbdf_canceled_tone),1);...
    repmat({'No-stop'},length(bbdf_nostop_tone),1);...
    repmat({'Non-canceled'},length(bbdf_noncanceled_tone),1)]);

% GRAMM Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eventBBDFfigure(1,1).stat_summary();
eventBBDFfigure(1,1).axe_property('XLim',[-800 800]);
eventBBDFfigure(1,1).geom_vline('xintercept',0,'style','k-');
eventBBDFfigure(1,1).axe_property('YLim',[0.0000 0.0035]);
eventBBDFfigure(1,1).no_legend();

eventBBDFfigure(1,2).stat_summary();
eventBBDFfigure(1,2).axe_property('XLim',[-200 600]);
eventBBDFfigure(1,2).geom_vline('xintercept',0,'style','k-');
eventBBDFfigure(1,2).axe_property('YLim',[0.0005 0.0025]);
eventBBDFfigure(1,2).no_legend();

eventBBDFfigure(1,3).stat_summary();
eventBBDFfigure(1,3).axe_property('XLim',[-200 200]);
eventBBDFfigure(1,3).geom_vline('xintercept',0,'style','k-');
eventBBDFfigure(1,3).axe_property('YLim',[0.0005 0.0020]);
eventBBDFfigure(1,3).no_legend();

eventBBDFfigure(2,1).stat_summary();
eventBBDFfigure(2,1).axe_property('XLim',[-200 800]);
eventBBDFfigure(2,1).geom_vline('xintercept',0,'style','k-');
eventBBDFfigure(2,1).axe_property('YLim',[0.0005 0.0020]);
eventBBDFfigure(2,1).no_legend();

eventBBDFfigure(2,2).stat_summary();
eventBBDFfigure(2,2).axe_property('XLim',[-200 600]);
eventBBDFfigure(2,2).geom_vline('xintercept',0,'style','k-');
eventBBDFfigure(2,2).axe_property('YLim',[0.0005 0.0025]);
eventBBDFfigure(2,2).no_legend();

eventBBDFfigure(2,3).stat_summary();
eventBBDFfigure(2,3).axe_property('XLim',[-600 200]);
eventBBDFfigure(2,3).geom_vline('xintercept',0,'style','k-');
eventBBDFfigure(2,3).axe_property('YLim',[0.0005 0.0025]);
eventBBDFfigure(2,3).no_legend();

eventBBDFfigure.set_names('y','');
eventBBDFfigure(1,1).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
eventBBDFfigure(1,2).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
eventBBDFfigure(1,3).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
eventBBDFfigure(2,1).set_color_options('map',[colors.canceled;colors.nostop]);
eventBBDFfigure(2,2).set_color_options('map',[colors.nostop;colors.noncanc]);
eventBBDFfigure(2,3).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 800 600]);
eventBBDFfigure.draw();

%% BBDF effect size analysis
ssrt_time = [-500:1000];
ssrt_bbdf_time = ssrt_time+abs(ssrt_time(1))+1;

error_time = [-1000:2000];
error_bbdf_time = error_time+abs(error_time(1))+1;

for idx = 1:509 
    ssd_canceled_bbdf(idx,:) = bbdf_canceled_stopSignal{idx};
    ssd_nostop_bbdf(idx,:) = bbdf_nostop_stopSignal{idx};
    
    ssrt_canceled_bbdf(idx,:) = bbdf_canceled_ssrt{idx};
    ssrt_nostop_bbdf(idx,:) = bbdf_nostop_ssrt{idx};

    error_noncanceled_bbdf(idx,:) = bbdf_noncanceled_saccade{idx};
    error_nostop_bbdf(idx,:) = bbdf_nostop_saccade{idx};
        
end

% Stop related analysis
for ii = 1:length(ssrt_bbdf_time)  
     ssd_effectSize(ii) = computeCohen_d(ssd_canceled_bbdf(:,ii), ssd_nostop_bbdf(:,ii));
     ssrt_effectSize(ii) = computeCohen_d(ssrt_canceled_bbdf(:,ii), ssrt_nostop_bbdf(:,ii));
end

% Error related analysis
for ii = 1:length(error_time)  
     error_effectSize(ii) = computeCohen_d(error_noncanceled_bbdf(:,ii), error_nostop_bbdf(:,ii));
end

figure('Renderer', 'painters', 'Position', [100 100 300 300]); hold on
plot(ssrt_time,ssd_effectSize,'color',[colors.canceled 0.5])
plot(ssrt_time,ssrt_effectSize,'color',[colors.canceled 1.0])
plot(error_time,error_effectSize,'color',[colors.noncanc 1.0])
xlim([-250 800]); xlabel('Time from event (ms)'); ylabel('Cohens D'); ylim([-0.25 1])
vline(0,'k'); hline([0.2 0.5 0.8],'k--')