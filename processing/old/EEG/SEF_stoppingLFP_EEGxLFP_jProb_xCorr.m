for session = 1:29
    clear sessionLFPcontacts lfp_session_array eeg_session_mean c_all lags_all
    % Get LFP data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sessionLFPcontacts = find(corticalLFPmap.session == session);
    
    for ii = 1:length(sessionLFPcontacts)
        lfp_session_array.stopSignal(ii,:) = LFPbbdf_canceled_stopSignal{sessionLFPcontacts(ii)};
        lfp_session_array.ssrt(ii,:) = LFPbbdf_canceled_ssrt{sessionLFPcontacts(ii)};
        lfp_session_array.saccade(ii,:) = LFPbbdf_noncanceled_saccade{sessionLFPcontacts(ii)};
        lfp_session_array.tone(ii,:) = LFPbbdf_canceled_tone{sessionLFPcontacts(ii)};
    end
    
    lfp_session_mean.stopSignal = nanmean(lfp_session_array.stopSignal);
    lfp_session_mean.ssrt = nanmean(lfp_session_array.ssrt);
    lfp_session_mean.saccade = nanmean(lfp_session_array.saccade);
    lfp_session_mean.tone = nanmean(lfp_session_array.tone);
    
    % Get EEG data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eeg_session_mean.stopSignal = EEGbbdf_canceled_stopSignal{session};
    eeg_session_mean.ssrt = EEGbbdf_canceled_ssrt{session};
    eeg_session_mean.saccade = EEGbbdf_noncanceled_saccade{session};
    eeg_session_mean.tone = EEGbbdf_canceled_tone{session};
    events = {'stopSignal','ssrt','saccade','tone'};
    
    % Get joint probability %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for eventIdx = 1:length(events)
        eeg_lfp_jProb.(events{eventIdx}) =...
            lfp_session_mean.(events{eventIdx}) .*...
            eeg_session_mean.(events{eventIdx});
        
        [c_all,lags_all] = xcorr(eeg_session_mean.(events{eventIdx}),...
            lfp_session_mean.(events{eventIdx}));
        
        maxCorr.(events{eventIdx})(session,1) = lags_all(c_all == max(c_all));
        maxCorr.(events{eventIdx})(session,2) = c_all(c_all == max(c_all));
        
        
    end
    

end

figure('Renderer', 'painters', 'Position', [100 100 1000 250]);
subplot(1,4,1)
histogram(maxCorr.stopSignal(:,1))
subplot(1,4,2)
histogram(maxCorr.ssrt(:,1))
subplot(1,4,3)
histogram(maxCorr.tone(:,1))
subplot(1,4,4)
histogram(maxCorr.saccade(:,1))