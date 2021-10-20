window = [-1000 500];
binSize = 100;
times = window(1)+(binSize/2):binSize:window(2)-(binSize/2);

parfor sessionIdx = 1:29
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    %% Get EEG bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % clear trials
    trials = 1:length(executiveBeh.TrialEventTimes_Overall{session}(:,1));
    
    eegDir = 'D:\projectCode\project_stoppingEEG\data\monkeyEEG\';
    eegName = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_tone'];
    
    % clear eegBetaBurst;
    eegBetaBurst = parload([eegDir eegName]);
    [eegBetaBurst] = thresholdBursts_EEG(eegBetaBurst.betaOutput, eegBetaBurst.betaOutput.medianLFPpower*6);
    
    % clear maxNBurst_eeg eegMatrix
    maxNBurst_eeg = max(cellfun('length',eegBetaBurst.burstData.burstTime(trials)));
    eegMatrix = nan(size(trials,2),maxNBurst_eeg);
    
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
    alignedBurstData_EEG = alignTimeStamps(eegMatrix, zeros(length(eegMatrix),1));
    eegBurstTimes = trimTimeStamps(alignedBurstData_EEG, window);
    burstCounts_EEG{sessionIdx} = spikeCounts(eegBurstTimes, window, binSize);
    
    
    %% Get LFP bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % clear sessionLFP
    sessionLFP = find(corticalLFPmap.session == session);
    
    burstCounts_LFPall = [];
    for lfpidx = 1:length(sessionLFP)
        lfp = sessionLFP(lfpidx);
        lfpName = ['betaBurst\tone\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_tone'];
        lfpBetaBurst = parload([outputDir lfpName]);
        [lfpBetaBurst] = thresholdBursts(lfpBetaBurst.betaOutput, lfpBetaBurst.betaOutput.medianLFPpower*6);
        
        maxNBurst_lfp = max(cellfun('length',lfpBetaBurst.burstData.burstTime(trials)));
        %     clear lfpMatrix;
        lfpMatrix = nan(size(trials,2),maxNBurst_lfp);
        
        for trlIdx = 1:length(trials)
            trl = trials(trlIdx);
            if ~isempty(lfpBetaBurst.burstData.burstTime{trl})
                lfpMatrix(trlIdx,1:length(lfpBetaBurst.burstData.burstTime{trl})) =...
                    lfpBetaBurst.burstData.burstTime{trl}';
            else
                continue
            end
        end
        
        alignedBurstData_LFP = alignTimeStamps(lfpMatrix, zeros(length(lfpMatrix),1));
        lfpBurstTimes = trimTimeStamps(alignedBurstData_LFP, window);
        burstCounts_LFPall(:,:,lfpidx) = spikeCounts(lfpBurstTimes, window, binSize);
    end
    
    % Get number of beta-bursts for all contacts, upper contacts, and lower
    % contacts
    burstCounts_LFP_raw{sessionIdx} = burstCounts_LFPall;
    burstCounts_LFP_all{sessionIdx} = double(sum(burstCounts_LFPall,3) > 0);
    burstCounts_LFP_upper{sessionIdx} = double(sum(burstCounts_LFPall(:,:,[1:8]),3) > 0);
    burstCounts_LFP_lower{sessionIdx} = double(sum(burstCounts_LFPall(:,:,[9:end]),3) > 0);
    
end

% Run JPSTH Analysis
for sessionIdx = 1:29
    warning off
    jspthAnalysis.all{sessionIdx} = jpsth(burstCounts_EEG{sessionIdx},...
        burstCounts_LFP_all{sessionIdx}, binSize);
    jspthAnalysis.upper{sessionIdx} = jpsth(burstCounts_EEG{sessionIdx},...
        burstCounts_LFP_upper{sessionIdx}, binSize);
    jspthAnalysis.lower{sessionIdx} = jpsth(burstCounts_EEG{sessionIdx},...
        burstCounts_LFP_lower{sessionIdx}, binSize);
    
    jspthAnalysis.inter{sessionIdx} = jpsth(burstCounts_LFP_upper{sessionIdx},...
        burstCounts_LFP_lower{sessionIdx}, binSize);
end

laminarLabelNames = {'all','upper','lower','inter'};
for laminarLabelIdx = 1:2
    laminarLabel = laminarLabelNames{laminarLabelIdx};
    for sessionIdx = 1:29
        JPSTH_matrix.(laminarLabel)(:,:,sessionIdx) = jspthAnalysis.(laminarLabel){sessionIdx}.normalizedJPSTH;
        JPSTH_xHist.(laminarLabel)(:,:,sessionIdx) = jspthAnalysis.(laminarLabel){sessionIdx}.psth_1;
        JPSTH_yHist.(laminarLabel)(:,:,sessionIdx) = jspthAnalysis.(laminarLabel){sessionIdx}.psth_2;
        JPSTH_crossHist.(laminarLabel)(:,:,sessionIdx) = jspthAnalysis.(laminarLabel){sessionIdx}.pstch;
        JPSTH_covariagram.(laminarLabel)(:,:,sessionIdx) = jspthAnalysis.(laminarLabel){sessionIdx}.covariogram;
        JPSTH_xCorrHistogram.(laminarLabel)(:,:,sessionIdx) = jspthAnalysis.(laminarLabel){sessionIdx}.xcorrHist;
    end
end

for sessionIdx = 1:29
    JPSTH_matrix_all(:,:,sessionIdx) = jspthAnalysis.all{sessionIdx}.normalizedJPSTH;
    JPSTH_xCorr_all(sessionIdx,:) = jspthAnalysis.all{sessionIdx}.xcorrHist;
    JPSTH_psth1_all(sessionIdx,:) = jspthAnalysis.all{sessionIdx}.psth_1;
    JPSTH_psth2_all(sessionIdx,:) = jspthAnalysis.all{sessionIdx}.psth_2;
    JPSTH_psth_all(sessionIdx,:) = jspthAnalysis.all{sessionIdx}.pstch;
    JPSTH_covar_all(sessionIdx,:) = jspthAnalysis.all{sessionIdx}.covariogram;
 
end


%% Figure
% JPSTH
figure('Renderer', 'painters', 'Position', [100 100 1000 600]);
subplot(2,3,5)
imagesc('XData',times,'YData',times,'CData',nanmean(JPSTH_matrix_all(:,:,:),3))
colormap(jet)
vline(0,'k'); hline(0,'k'); xlim([times(1) times(end)])

subplot(2,3,2)
bar(times, nanmean(JPSTH_psth1_all),'LineStyle','None', 'BarWidth', 1)
vline(0,'k'); xlim([times(1) times(end)])

subplot(2,3,4)
bar(times, nanmean(JPSTH_psth2_all),'LineStyle','None', 'BarWidth', 1)
vline(0,'k'); xlim([times(1) times(end)])

subplot(2,3,3)
bar(times, nanmean(JPSTH_psth_all),'LineStyle','None', 'BarWidth', 1)
vline(0,'k'); xlim([times(1) times(end)])

subplot(2,3,6)
plot(-50:50,nanmean(JPSTH_xCorr_all))

subplot(2,3,1)
plot(-50:50,nanmean(JPSTH_covar_all))
