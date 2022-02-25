% dependent on BBDF code first

% get xCorr for EEG BBDF x LFP BBDF average
% EEG
for session = 1:29
    xCorr_eeg_canc_stopSignal(session,:) = EEGbbdf_canceled_stopSignal{session};
    xCorr_eeg_canc_tone(session,:) = EEGbbdf_canceled_tone{session};
    
    xCorr_eeg_noncanc_saccade(session,:) = EEGbbdf_noncanceled_saccade{session};
end

% LFP
for lfpIdx = 1:length(corticalLFPcontacts.all)
    xCorr_lfp_canc_stopSignal(lfpIdx,:) = LFPbbdf_canceled_stopSignal{session};
    xCorr_lfp_canc_tone(lfpIdx,:) = LFPbbdf_canceled_tone{session};    

    xCorr_lfp_noncanc_saccade(lfpIdx,:) = LFPbbdf_noncanceled_saccade{session};    
end

%%
[c_all,lags_all] = xcorr(nanmean(xCorr_eeg_canc_stopSignal),...
    nanmean(xCorr_lfp_canc_stopSignal));
[c_upper,lags_upper] = xcorr(nanmean(xCorr_eeg_canc_stopSignal([14:29],:)),...
    nanmean(xCorr_lfp_canc_stopSignal(corticalLFPcontacts.subset.laminar.upper,:)));
[c_lower,lags_lower] = xcorr(nanmean(xCorr_eeg_canc_stopSignal([14:29],:)),...
    nanmean(xCorr_lfp_canc_stopSignal(corticalLFPcontacts.subset.laminar.lower,:)));


figure('Renderer', 'painters', 'Position', [100 100 1000 250]);
subplot(2,3,1)
plot(lags_all,c_all); xlim([-1000 1000])
vline(lags_all(c_all == max(c_all)))

subplot(2,3,3)
plot(lags_upper,c_upper); xlim([-1000 1000])
vline(lags_upper(c_upper == max(c_upper)))

subplot(2,3,5)
plot(lags_lower,c_lower); xlim([-1000 1000])
vline(lags_lower(c_lower == max(c_lower)))



%% 
[c_eu,lags_eu] = xcorr(nanmean(xCorr_eeg_canc_stopSignal(executiveBeh.nhpSessions.EuSessions,:)),...
    nanmean(xCorr_lfp_canc_stopSignal(corticalLFPcontacts.subset.eu,:)));
[c_x,lags_x] = xcorr(nanmean(xCorr_eeg_canc_stopSignal(executiveBeh.nhpSessions.XSessions,:)),...
    nanmean(xCorr_lfp_canc_stopSignal(corticalLFPcontacts.subset.x,:)));

figure('Renderer', 'painters', 'Position', [100 100 1000 250]);
subplot(1,3,1)
plot(lags_all,c_all); xlim([-1000 1000])
vline(lags_all(c_all == max(c_all)))

subplot(1,3,2)
plot(lags_eu,c_eu); xlim([-1000 1000])
vline(lags_eu(c_eu == max(c_eu)))

subplot(1,3,3)
plot(lags_x,c_x); xlim([-1000 1000])
vline(lags_x(c_x == max(c_x)))


%% 
[c_saccade,lags_saccade] = xcorr(nanmean(xCorr_eeg_noncanc_saccade(:,:)),...
    nanmean(xCorr_lfp_noncanc_saccade(:,:)));

figure('Renderer', 'painters', 'Position', [100 100 400 400]);
plot(lags_saccade,c_saccade); xlim([-1000 1000])
vline(lags(c_saccade == max(c_saccade)))


