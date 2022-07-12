window = [-500 1000];
binSize = 50;
times = window(1)+25:binSize:window(2)-25;

sessionList = 1:29;
for sessionIdx = 1:length(sessionList)
    session = sessionList(sessionIdx);
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    %% Get EEG bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % clear trials
    trials = 1:length(executiveBeh.TrialEventTimes_Overall{session}(:,1));
    ssrt = bayesianSSRT.ssrt_mean(session); timeThreshold_stop = [0 round(ssrt)];
    [stopBeh] = extractStopBehData(executiveBeh,session);
    
    eegDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';
    eegName = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_stopSignal'];
    
    % clear eegBetaBurst;
    eegBetaBurst = parload([eegDir eegName]);
    [eegBetaBurst] = thresholdBursts(eegBetaBurst.betaOutput, eegBetaBurst.betaOutput.medianLFPpower*6);
    
    blockList = unique(stopBeh.blockN);
    for blockIdx = 1:length(blockList)
        blockTrls = stopBeh.trialN(stopBeh.blockN == blockList(blockIdx));
        eeg_block_trlBurstFlag = [];
        
        for ii = 1:length(blockTrls)
            eeg_block_trlBurstFlag(ii,1) =...
                sum(eegBetaBurst.burstData.burstTime{blockTrls(ii)} > timeThreshold_stop(1) &...
                eegBetaBurst.burstData.burstTime{blockTrls(ii)} <= timeThreshold_stop(2)) > 0;
        end
        
        eeg_block_pBurst(blockIdx) = mean(eeg_block_trlBurstFlag);
        exp_block_pStop(blockIdx) = mean(stopBeh.ss_presented(blockTrls));
        
    end
    
    
    
    %% Get LFP bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % clear sessionLFP
    sessionLFP = find(sessionLFPmap.session == session & sessionLFPmap.cortexFlag == 1);
    
    for lfpidx = 1:length(sessionLFP)
        lfp = sessionLFP(lfpidx);
        lfpName = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
        lfpBetaBurst = parload([outputDir lfpName]);
        [lfpBetaBurst] = thresholdBursts(lfpBetaBurst.betaOutput, lfpBetaBurst.betaOutput.medianLFPpower*6);
        lfp_block_trlBurstFlag = [];
        
        for blockIdx = 1:length(blockList)
            blockTrls = stopBeh.trialN(stopBeh.blockN == blockList(blockIdx));
            
            for ii = 1:length(blockTrls)
                lfp_block_trlBurstFlag(ii,blockIdx) =...
                    sum(lfpBetaBurst.burstData.burstTime{blockTrls(ii)} > timeThreshold_stop(1) &...
                    lfpBetaBurst.burstData.burstTime{blockTrls(ii)} <= timeThreshold_stop(2)) > 0;
            end
        end
        
        
        lfp_block_pBurst(lfpidx,:) = mean(lfp_block_trlBurstFlag);
        
    end
    
    
end

lfpTest = mean(lfp_block_pBurst)

figure; subplot(1,2,1)
scatter(lfpTest(2:end), exp_block_pStop(1:end-1)); lsline
hold on
scatter(lfpTest, exp_block_pStop); lsline

subplot(1,2,2)
scatter(eeg_block_pBurst(2:end), exp_block_pStop(1:end-1)); lsline


