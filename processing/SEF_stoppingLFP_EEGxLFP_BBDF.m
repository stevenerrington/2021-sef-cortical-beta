%% Get EEG average BBDF
window = [-500 1000];
binSize = 50;
times = window(1)+25:binSize:window(2)-25;

perpSessions = 14:29;

%% Get EEG average BBDF
parfor sessionIdx = 14:29
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    ssrt = round(bayesianSSRT.ssrt_mean(session));
    
    % Get EEG bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    eegDir = 'D:\projectCode\project_stoppingEEG\data\monkeyEEG\';
    eeg_target = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_target'];
    eeg_stopSignal = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_stopSignal'];
    eeg_saccade = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_saccade'];
    eeg_tone = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_tone'];
    
    % clear eegBetaBurst;
    eegBetaBurst_target = parload([eegDir eeg_target]);
    eegBetaBurst_stopSignal = parload([eegDir eeg_stopSignal]);
    eegBetaBurst_saccade = parload([eegDir eeg_saccade]);
	eegBetaBurst_tone = parload([eegDir eeg_tone]);
    
    [eegBetaBurst_target] = thresholdBursts_EEG(eegBetaBurst_target.betaOutput, eegBetaBurst_target.betaOutput.medianLFPpower*6);
    [eegBetaBurst_stopSignal] = thresholdBursts_EEG(eegBetaBurst_stopSignal.betaOutput, eegBetaBurst_stopSignal.betaOutput.medianLFPpower*6);
    [eegBetaBurst_saccade] = thresholdBursts_EEG(eegBetaBurst_saccade.betaOutput, eegBetaBurst_saccade.betaOutput.medianLFPpower*6);
	[eegBetaBurst_tone] = thresholdBursts_EEG(eegBetaBurst_tone.betaOutput, eegBetaBurst_tone.betaOutput.medianLFPpower*6);
    

    EEG_SessionBDF_target = BetaBurstConvolver(eegBetaBurst_target.burstData.burstTime);
    EEG_SessionBDF_stopSignal = BetaBurstConvolver(eegBetaBurst_stopSignal.burstData.burstTime);
    EEG_SessionBDF_saccade = BetaBurstConvolver(eegBetaBurst_saccade.burstData.burstTime);
    EEG_SessionBDF_tone = BetaBurstConvolver(eegBetaBurst_tone.burstData.burstTime);
    
    
    c_temp_fix = []; ns_temp_fix = [];
    c_temp_ssd = []; ns_temp_ssd = [];
    c_temp_tone = []; ns_temp_tone = [];
    nc_temp_saccade = []; ns_temp_saccade = [];
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        c_temp_fix(ii,:) = nanmean(EEG_SessionBDF_target(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_fix(ii,:) = nanmean(EEG_SessionBDF_target(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        c_temp_ssd(ii,:) = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_ssd(ii,:) = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        c_temp_tone(ii,:) = nanmean(EEG_SessionBDF_saccade(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_tone(ii,:) = nanmean(EEG_SessionBDF_saccade(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        nc_temp_saccade(ii,:) = nanmean(EEG_SessionBDF_tone(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_temp_saccade(ii,:) = nanmean(EEG_SessionBDF_tone(executiveBeh.ttm_c.GO_NC{session,ii}.all, :));
    end
    
    EEGbbdf_canceled_fix{sessionIdx,1} = nanmean(c_temp_fix);
    EEGbbdf_nostop_fix{sessionIdx,1} = nanmean(ns_temp_fix);       
    
    EEGbbdf_canceled_ssd{sessionIdx,1} = nanmean(c_temp_ssd);
    EEGbbdf_nostop_ssd{sessionIdx,1} = nanmean(ns_temp_ssd);   
    
    EEGbbdf_canceled_tone{sessionIdx,1} = nanmean(c_temp_tone);
    EEGbbdf_nostop_tone{sessionIdx,1} = nanmean(ns_temp_tone); 
    
    EEGbbdf_noncanceled_saccade{sessionIdx,1} = nanmean(nc_temp_saccade);
    EEGbbdf_nostop_saccade{sessionIdx,1} = nanmean(ns_temp_saccade);       
end



%% Get LFP average BBDF
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    ssrt = round(bayesianSSRT.ssrt_mean(session));
    
    bbdf = parload(['D:\projectCode\project_stoppingLFP\data\bbdf\bbdf_' int2str(lfpIdx)]);
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    c_temp_fix = []; ns_temp_fix = [];
    c_temp_ssd = []; ns_temp_ssd = [];
    c_temp_tone = []; ns_temp_tone = [];
    nc_temp_saccade = []; ns_temp_saccade = [];
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        c_temp_fix(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_fix(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        c_temp_ssd(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_ssd(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        c_temp_tone(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        ns_temp_tone(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        nc_temp_saccade(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_temp_saccade(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_c.GO_NC{session,ii}.all, :));
    end
    
    LFPbbdf_canceled_fix{lfpIdx,1} = nanmean(c_temp_fix);
    LFPbbdf_nostop_fix{lfpIdx,1} = nanmean(ns_temp_fix);       
    
    LFPbbdf_canceled_ssd{lfpIdx,1} = nanmean(c_temp_ssd);
    LFPbbdf_nostop_ssd{lfpIdx,1} = nanmean(ns_temp_ssd);   
    
    LFPbbdf_canceled_tone{lfpIdx,1} = nanmean(c_temp_tone);
    LFPbbdf_nostop_tone{lfpIdx,1} = nanmean(ns_temp_tone); 
    
    LFPbbdf_noncanceled_saccade{lfpIdx,1} = nanmean(nc_temp_saccade);
    LFPbbdf_nostop_saccade{lfpIdx,1} = nanmean(ns_temp_saccade);     
end


%%
time = [-1000:2000];
eeg_all_BBDF = EEGbbdf_canceled_fix(14:29);
eeg_all_label = repmat({'1_EEG'},length(14:29),1);

lfp_upper_BBDF = []; lfp_lower_BBDF = [];
lfp_upper_label = []; lfp_lower_label = [];


for session = 14:29
    sessionLFPidx_upper = []; sessionLFPidx_lower = [];
    sessionLFPidx_upper = find(corticalLFPmap.session == session &...
        corticalLFPmap.depth <= 8);
    sessionLFPidx_lower = find(corticalLFPmap.session == session &...
        corticalLFPmap.depth > 8);
    
    lfp_upper_BBDF = [lfp_upper_BBDF; LFPbbdf_canceled_ssd(sessionLFPidx_upper)];
    lfp_lower_BBDF = [lfp_lower_BBDF; LFPbbdf_canceled_ssd(sessionLFPidx_lower)];

    lfp_upper_label = [lfp_upper_label; repmat({'2_Upper'},length(sessionLFPidx_upper),1)];
    lfp_lower_label = [lfp_lower_label; repmat({'3_Lower'},length(sessionLFPidx_lower),1)];
end

clear inputData inputLabels eeg_lfp_BBDF
inputData = [eeg_all_BBDF; lfp_upper_BBDF; lfp_lower_BBDF];
inputLabels = [eeg_all_label; lfp_upper_label; lfp_lower_label];

eeg_lfp_BBDF(1,1)=gramm('x',time,'y',inputData,'color',inputLabels);
eeg_lfp_BBDF(1,1).stat_summary();
eeg_lfp_BBDF(1,1).axe_property('XLim',[-200 800]);
eeg_lfp_BBDF(1,1).axe_property('YLim',[0 0.003]);

figure('Renderer', 'painters', 'Position', [100 100 400 300]);
eeg_lfp_BBDF.draw();

