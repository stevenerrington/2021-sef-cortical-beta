window = [-500 1000];
binSize = 50;
times = window(1):binSize:window(2);

for session = 14:29
fprintf('Analysing session %i of %i. \n',session, 29)

%% Get EEG bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear trials
trials = 1:length(executiveBeh.TrialEventTimes_Overall{session}(:,1));

eegDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';
eegName = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_saccade'];

% clear eegBetaBurst; 
eegBetaBurst = parload([eegDir eegName]); 
[eegBetaBurst] = thresholdBursts(eegBetaBurst.betaOutput, eegBetaBurst.betaOutput.medianLFPpower*6);

% clear maxNBurst_eeg eegMatrix
maxNBurst_eeg = max(cellfun('length',eegBetaBurst.burstData.burstTime(trials)));
eegMatrix = nan(size(trials,1),maxNBurst_eeg);

for trlIdx = 1:length(trials)
    trl = trials(trlIdx);
    if ~isempty(eegBetaBurst.burstData.burstTime{trl})
        eegMatrix(trlIdx,1:length(eegBetaBurst.burstData.burstTime{trl})) =...
            eegBetaBurst.burstData.burstTime{trl}';
    else 
        continue
    end
end

% clear alignedSpikeData1 timeStamps1 spikeCounts_signal1
alignedSpikeData1 = alignTimeStamps(eegMatrix, zeros(length(eegMatrix),1));
timeStamps1 = trimTimeStamps(alignedSpikeData1, window);
spikeCounts_signal1{session} = spikeCounts(timeStamps1, window, binSize);


%% Get LFP bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear sessionLFP
sessionLFP = find(sessionLFPmap.session == session & sessionLFPmap.cortexFlag == 1);

% clear alignedSpikeData2 timeStamps2 spikeCounts_signal2
spikeCounts_signalLFP = [];
for lfpidx = 1:length(sessionLFP)
%     fprintf('Analysing LFP %i of %i. \n',lfpidx, length(sessionLFP))
    lfp = sessionLFP(lfpidx);
    lfpName = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    lfpBetaBurst = parload([outputDir lfpName]);
    [lfpBetaBurst] = thresholdBursts(lfpBetaBurst.betaOutput, lfpBetaBurst.betaOutput.medianLFPpower*6);
    
    maxNBurst_lfp = max(cellfun('length',lfpBetaBurst.burstData.burstTime(trials)));
%     clear lfpMatrix;
    lfpMatrix = nan(size(trials,1),maxNBurst_lfp);
    
    for trlIdx = 1:length(trials)
        trl = trials(trlIdx);
        if ~isempty(lfpBetaBurst.burstData.burstTime{trl})
            lfpMatrix(trlIdx,1:length(lfpBetaBurst.burstData.burstTime{trl})) =...
                lfpBetaBurst.burstData.burstTime{trl}';
        else
            continue
        end
    end
    
    alignedSpikeData2 = alignTimeStamps(lfpMatrix, zeros(length(lfpMatrix),1));
    timeStamps2 = trimTimeStamps(alignedSpikeData2, window);
    spikeCounts_signalLFP(:,:,lfpidx) = spikeCounts(timeStamps2, window, binSize);
end

spikeCounts_signal2{session} = double(sum(spikeCounts_signalLFP,3) > 0);

% %% Find the co-incidence of beta-bursts in 200 ms period after SSD
% for trlIdx = 1:length(trials)
%     a = sum(spikeCounts_signal1(trlIdx,10:14) > 0);
%     b = sum(spikeCounts_signal2(trlIdx,10:14) > 0);
%     
%     c(trlIdx) = sum(a+b) > 1;
%     
% end
% 
% d(session) = mean(c);

end

%%
for session = 14:29
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    %% Get EEG bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % clear trials
    trials = executiveBeh.ttx.NC{session};
    
    clear a b c
    %% Find the co-incidence of beta-bursts in 200 ms period after SSD
    for trlIdx = 1:length(trials)
        a = sum(spikeCounts_signal1{session}(trlIdx,20:24) > 0);
        b = sum(spikeCounts_signal2{session}(trlIdx,20:24) > 0);
        
        c(trlIdx) = sum(a+b) > 1;
        
    end
    d(session) = mean(c);
end

%%
for session = 14:29
    warning off
    jpsthOut{session-13} = jpsth(spikeCounts_signal1{session},...
        spikeCounts_signal2{session}, binSize);
    
    test(:,:,session-13) = jpsthOut{session-13}.normalizedJPSTH;
    test2(session-13,:) = jpsthOut{session-13}.psth_1;
    test3(session-13,:) = jpsthOut{session-13}.psth_2;
    test4(session-13,:) = jpsthOut{session-13}.pstch;
    test5(session-13,:) = jpsthOut{session-13}.covariogram;

end




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
plotTimes =  [median([window(1) window(1)+binSize]):binSize:median([window(2)-binSize window(2)])];

figure('Renderer', 'painters', 'Position', [100 100 1200 600]);
subplot(2,4,1)
imagesc('XData',plotTimes,'YData',plotTimes,'CData',mean(test,3))
vline(0,'r-'); hline(0,'r'); title('normalised JPSTH');
xlabel('EEG'); ylabel('LFP')

subplot(2,4,2)
bar(plotTimes,mean(test2),'LineStyle','none','BarWidth',1)
vline(0,'r'); title('PSTH EEG')

subplot(2,4,3)
bar(plotTimes,mean(test3),'LineStyle','none','BarWidth',1)
vline(0,'r'); title('PSTH LFP')

subplot(2,4,4)
bar(plotTimes,mean(test4),'LineStyle','none','BarWidth',1)
vline(0,'r'); title('PSTH C')

subplot(2,4,5)
bar(mean(test5),'LineStyle','none','BarWidth',1)
vline(0,'r'); title('Covariogram')






