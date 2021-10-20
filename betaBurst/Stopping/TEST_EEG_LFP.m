
% Parameters
for session = 14:29
    windowSize = 25;
    windowRange = [-250:windowSize:500];
    fprintf('Analysing session number %i of %i. \n',session, 29);
    
    clear pBurst_window_EEG pBurst_window_LFP
    %% Session EEG Data
    % Load in beta output data for session
    eegDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';
    eegName = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_stopSignal'];
    clear eegBetaBurst; eegBetaBurst = parload([eegDir eegName]);
    [eegBetaBurst] = thresholdBursts(eegBetaBurst.betaOutput, eegBetaBurst.betaOutput.medianLFPpower*6);
    
    % Get number of bursts in window for each trial
    for trl = 1:size(eegBetaBurst.burstData.burstTime)
        [eegBurstFlag] = histcounts(eegBetaBurst.burstData.burstTime{trl},windowRange);
        eegBurst(trl,:) = double(eegBurstFlag > 0);
    end
    
    pBurst_window_EEG = nanmean(eegBurst);
    
    %% Session LFP Data
    lfpDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingLFP\data\monkeyLFP\';
    
    idxLFP_session = find(sessionLFPmap.session == session & sessionLFPmap.cortexFlag == 1);
    nLFP_session = length(idxLFP_session);
    lfpBurst = [];
    
    for lfpidx = 1:nLFP_session
        fprintf('Analysing LFP number %i of %i. \n',lfpidx, nLFP_session);
        lfp = idxLFP_session(lfpidx);
        lfpName = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
        lfpBetaBurst = parload([outputDir lfpName]);
        [lfpBetaBurst] = thresholdBursts(lfpBetaBurst.betaOutput, lfpBetaBurst.betaOutput.medianLFPpower*6);
        
        for trl = 1:size(lfpBetaBurst.burstData.burstTime)
            [lfpBurstFlag] = histcounts(lfpBetaBurst.burstData.burstTime{trl},windowRange);
            lfpBurst(trl,:) = double(lfpBurstFlag > 0);
        end
        
        pBurst_window_LFP(lfpidx,:) = nanmean(lfpBurst);
    end
    
    
    %%
    pBurst_window_LFPmean = mean(pBurst_window_LFP);
    
    for lfpWindow = 1:length(windowRange)-1
        for eegWindow = 1:length(windowRange)-1
            eeg_lfp_correlation_session(eegWindow,lfpWindow,session) = pBurst_window_EEG(eegWindow).*pBurst_window_LFPmean(lfpWindow);
        end
    end
    
    figure('Renderer', 'painters', 'Position', [100 100 300 250]);
    imagesc('XData',windowRange,'YData',windowRange,'CData',eeg_lfp_correlation_session(:,:,session))
    colorbar
    xlabel('LFP time'); ylabel('EEG time')
    xlim([windowRange(1) windowRange(end)])
    ylim([windowRange(1) windowRange(end)])
    vline(0,'r-'); hline(0,'r-')
end 


eeg_lfp_correlation_all = eeg_lfp_correlation_session(:,:,:);
eeg_lfp_correlation_euler = eeg_lfp_correlation_session(:,:,executiveBeh.nhpSessions.EuSessions);
eeg_lfp_correlation_xena = eeg_lfp_correlation_session(:,:,executiveBeh.nhpSessions.XSessions);

figure('Renderer', 'painters', 'Position', [100 100 800 250]);
clim = [0.00005 0.00035];
subplot(1,3,1)
imagesc('XData',windowRange,'YData',windowRange,'CData',mean(eeg_lfp_correlation_all,3))
caxis(clim)
xlabel('LFP time'); ylabel('EEG time')
xlim([windowRange(1) windowRange(end)])
ylim([windowRange(1) windowRange(end)])
vline(0,'k-'); hline(0,'k-')

subplot(1,3,2)
imagesc('XData',windowRange,'YData',windowRange,'CData',mean(eeg_lfp_correlation_euler,3))
caxis(clim)
xlabel('LFP time'); ylabel('EEG time')
xlim([windowRange(1) windowRange(end)])
ylim([windowRange(1) windowRange(end)])
vline(0,'k-'); hline(0,'k-')

subplot(1,3,3)
imagesc('XData',windowRange,'YData',windowRange,'CData',mean(eeg_lfp_correlation_xena,3))
caxis(clim)
xlabel('LFP time'); ylabel('EEG time')
xlim([windowRange(1) windowRange(end)])
ylim([windowRange(1) windowRange(end)])
vline(0,'k-'); hline(0,'k-')
    









%% Cross-correlation
    
eegDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';
eegName = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_stopSignal'];
clear eegBetaBurst; eegBetaBurst = parload([eegDir eegName]);
[eegBetaBurst] = thresholdBursts(eegBetaBurst.betaOutput, eegBetaBurst.betaOutput.medianLFPpower*6);

eegBDF = BetaBurstConvolver(eegBetaBurst.burstData.burstTime);

eeg_bbdf_canceled = nanmean(eegBDF(executiveBeh.ttx_canc{session}, :));
eeg_bbdf_noncanceled = nanmean(eegBDF(executiveBeh.ttx.sNC{session}, :));
eeg_bbdf_nostop = nanmean(eegBDF(executiveBeh.ttx.GO{session}, :));


lfpidx = 10
lfp = idxLFP_session(lfpidx);
lfpName = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
lfpBetaBurst = parload([outputDir lfpName]);
[lfpBetaBurst] = thresholdBursts(lfpBetaBurst.betaOutput, lfpBetaBurst.betaOutput.medianLFPpower*6);

lfpBDF = BetaBurstConvolver(lfpBetaBurst.burstData.burstTime);

lfp_bbdf_canceled = nanmean(lfpBDF(executiveBeh.ttx_canc{session}, :));
lfp_bbdf_noncanceled = nanmean(lfpBDF(executiveBeh.ttx.sNC{session}, :));
lfp_bbdf_nostop = nanmean(lfpBDF(executiveBeh.ttx.GO{session}, :));


figure;
plot(eeg_bbdf_canceled); hold on; plot(lfp_bbdf_canceled)
window = [-250:25:500]+1000;
figure
[c,lags] = xcorr(eeg_bbdf_canceled(:,window),lfp_bbdf_canceled(:,window),'normalized');
stem(lags,c)

