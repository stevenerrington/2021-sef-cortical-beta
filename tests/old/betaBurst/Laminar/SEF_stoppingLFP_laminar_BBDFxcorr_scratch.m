
load noisysignals s1 s2;  % load sensor signals
[acor,lag] = xcorr(s2',s1');
[~,I] = max(abs(acor));
timeDiff = lag(I)         % sensor 2 leads sensor 1 by 350 samples

figure;
subplot(311); plot(s1); title('s1');
subplot(312); plot(s2); title('s2');
subplot(313); plot(lag,acor);
title('Cross-correlation between s1 and s2')







[xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:),...
    xcorr_out.(alignmentEvent).lag.eeg_upper(sessionIdx-13,:)] =...
    xcorr(xcorr_out.(alignmentEvent).bbdf.eeg(sessionIdx-13,alignmentWindow),...
    xcorr_out.(alignmentEvent).bbdf.upper(sessionIdx-13,alignmentWindow),...
    'none');




for sessionIdx = 14:29
    figure;
    subplot(321); plot(xcorr_out.(alignmentEvent).bbdf.eeg(sessionIdx-13,alignmentWindow)); title('EEG');
    subplot(323); plot(xcorr_out.(alignmentEvent).bbdf.upper(sessionIdx-13,alignmentWindow)); title('Upper');
    subplot(325); plot(xcorr_out.(alignmentEvent).lag.eeg_upper(sessionIdx-13,:),...
        xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:));
    [~,I] = max(abs(xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:)));
    timeDiff = xcorr_out.(alignmentEvent).lag.eeg_upper(sessionIdx-13,I);         % sensor 2 leads sensor 1 by 350 samples  
    vline(timeDiff)
    
    subplot(322); plot(xcorr_out.(alignmentEvent).bbdf.shuffled_eeg(sessionIdx-13,alignmentWindow));
    subplot(324); plot(xcorr_out.(alignmentEvent).bbdf.shuffled_upper(sessionIdx-13,alignmentWindow)); 
    subplot(326); plot(xcorr_out.(alignmentEvent).lag.shuffled_eeg_upper(sessionIdx-13,:),...
        xcorr_out.(alignmentEvent).analysis.shuffled_eeg_upper(sessionIdx-13,:));
    [~,I] = max(abs(xcorr_out.(alignmentEvent).analysis.shuffled_eeg_upper(sessionIdx-13,:)));
    timeDiff = xcorr_out.(alignmentEvent).lag.shuffled_eeg_upper(sessionIdx-13,I);         % sensor 2 leads sensor 1 by 350 samples  
    vline(timeDiff)    
    title(['Session ' int2str(sessionIdx)])

    
    observed_minus_shuffle = xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:)-...
    xcorr_out.(alignmentEvent).analysis.shuffled_eeg_upper(sessionIdx-13,:);

    figure; plot(xcorr_out.(alignmentEvent).lag.shuffled_eeg_upper(sessionIdx-13,:),...
        observed_minus_shuffle)
    title(['Session ' int2str(sessionIdx)])

    [~,I] = max(abs(observed_minus_shuffle));
    timeDiff = xcorr_out.(alignmentEvent).lag.shuffled_eeg_upper(sessionIdx-13,I);         % sensor 2 leads sensor 1 by 350 samples  
    vline(timeDiff)    
    
end

figure; plot(xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:)-...
    xcorr_out.(alignmentEvent).analysis.shuffled_eeg_upper(sessionIdx-13,:))
