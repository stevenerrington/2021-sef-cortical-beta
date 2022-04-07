function burstTiming = SEF_stoppingLFP_getAverageBurstTimeSSRT(lfpList,...
    trialList, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold)

dataDir = 'D:\projectCode\project_stoppingLFP\data\monkeyLFP\';
warning off
event = 'stopSignal';
burstTiming = table();

parfor lfpIdx = 1:length(lfpList)
    
    lfp = lfpList(lfpIdx);
    session = sessionLFPmap.session(lfp);
    timeThreshold = [bayesianSSRT.ssrt_mean(session)+200 bayesianSSRT.ssrt_mean(session)+400];
%     timeThreshold = [bayesianSSRT.ssrt_mean(session)+200 bayesianSSRT.ssrt_mean(session)+200+bayesianSSRT.ssrt_mean(session)];
    
    %     clear betaOutput trial_betaBurst_timing burstTimes trialBurstFlag trlBurstTimes
  
    % Get session name (to load in relevant file)
    lfpName = sessionLFPmap.channelNames{lfp};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(lfpList));
    
    % Save output
    loadFile = ['betaBurst\' event '\lfp_session' int2str(session) '_' lfpName '_betaOutput_' event];
    betaOutputRaw = parload([dataDir loadFile]);
    [betaOutput] = thresholdBursts(betaOutputRaw.betaOutput, sessionBLpower(session)*burstThreshold);
    
    trial_betaBurst_timing = []; trial_betaBurst_freq = [];
    trialBurstFlag = []; trlBurstTimes = [];
    trlBurstFreq = []; trlBurstOnset = []; trlBurstOffset = [];
    trlBurstDuration = []; trlBurstVolume = [];
    
    trial_betaBurst_onset = [];
    trial_betaBurst_offset = [];
    trial_betaBurst_duration = [];
    trial_betaBurst_volume = [];    
    
    
    for trlIdx = 1:length(trialList{session})
        trial = trialList{session}(trlIdx);
        trial_betaBurst_freq = [trial_betaBurst_freq;...
            betaOutput.burstData.burstFrequency{trial}];
        
        trial_betaBurst_timing = [trial_betaBurst_timing;...
            betaOutput.burstData.burstTime{trial}];

        trial_betaBurst_onset = [trial_betaBurst_onset;...
            betaOutput.burstData.burstOnset{trial}];        
        
        trial_betaBurst_offset = [trial_betaBurst_offset;...
            betaOutput.burstData.burstOffset{trial}];           
        
        trial_betaBurst_duration = [trial_betaBurst_duration;...
            betaOutput.burstData.burstDuration{trial}];              
        
        trial_betaBurst_volume = [trial_betaBurst_volume;...
            betaOutput.burstData.burstVolume{trial}];               
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        trialBurstFlag(trlIdx,1) = sum(betaOutput.burstData.burstTime{trial} > timeThreshold(1) &...
            betaOutput.burstData.burstTime{trial} <= timeThreshold(2)) > 0;
        
        trlBurstTimes{trlIdx,1} = betaOutput.burstData.burstTime{trial}...
            (betaOutput.burstData.burstTime{trial} > -250 &...
            betaOutput.burstData.burstTime{trial} <= 500);
        
        trlBurstFreq{trlIdx,1} = betaOutput.burstData.burstFrequency{trial}...
            (betaOutput.burstData.burstTime{trial} > -250 &...
            betaOutput.burstData.burstTime{trial} <= 500);
        
        trlBurstOnset{trlIdx,1} = betaOutput.burstData.burstOnset{trial}...
            (betaOutput.burstData.burstTime{trial} > -250 &...
            betaOutput.burstData.burstTime{trial} <= 500)+...
            betaOutput.burstData.burstTime{trial}...
            (betaOutput.burstData.burstTime{trial} > -250 &...
            betaOutput.burstData.burstTime{trial} <= 500);        
        
        trlBurstOffset{trlIdx,1} = betaOutput.burstData.burstOffset{trial}...
            (betaOutput.burstData.burstTime{trial} > -250 &...
            betaOutput.burstData.burstTime{trial} <= 500)+...
            betaOutput.burstData.burstTime{trial}...
            (betaOutput.burstData.burstTime{trial} > -250 &...
            betaOutput.burstData.burstTime{trial} <= 500);               
        
        trlBurstDuration{trlIdx,1} = betaOutput.burstData.burstDuration{trial}...
            (betaOutput.burstData.burstTime{trial} > -250 &...
            betaOutput.burstData.burstTime{trial} <= 500);           
        
         trlBurstVolume{trlIdx,1} = betaOutput.burstData.burstVolume{trial}...
            (betaOutput.burstData.burstTime{trial} > -250 &...
            betaOutput.burstData.burstTime{trial} <= 500);
        
     
    end
    
    burstTimes = trial_betaBurst_timing(trial_betaBurst_timing > timeThreshold(1) &...
        trial_betaBurst_timing <= timeThreshold(2));
    burstOnset = trial_betaBurst_onset(trial_betaBurst_timing > timeThreshold(1) &...
        trial_betaBurst_timing <= timeThreshold(2));
    burstOffset = trial_betaBurst_offset(trial_betaBurst_timing > timeThreshold(1) &...
        trial_betaBurst_timing <= timeThreshold(2));    
    burstDuration = trial_betaBurst_duration(trial_betaBurst_timing > timeThreshold(1) &...
        trial_betaBurst_timing <= timeThreshold(2));      
    burstVolume = trial_betaBurst_volume(trial_betaBurst_timing > timeThreshold(1) &...
        trial_betaBurst_timing <= timeThreshold(2)); 
    burstFreqs = trial_betaBurst_freq(trial_betaBurst_timing > timeThreshold(1) &...
        trial_betaBurst_timing <= timeThreshold(2));
    
    mean_burstTime(lfpIdx) = mean(burstTimes); std_burstTime(lfpIdx) = std(burstTimes); sem_burstTime(lfpIdx) = std(burstTimes)/...
        sqrt(length(burstTimes));

    mean_burstOnset(lfpIdx) = mean(burstOnset); std_burstOnset(lfpIdx) = std(burstOnset); sem_burstOnset(lfpIdx) = std(burstOnset)/...
        sqrt(length(burstOnset));

    mean_burstOffset(lfpIdx) = mean(burstOffset); std_burstOffset(lfpIdx) = std(burstOffset); sem_burstOffset(lfpIdx) = std(burstOffset)/...
        sqrt(length(burstOffset));

    mean_burstDuration(lfpIdx) = mean(burstDuration); std_burstDuration(lfpIdx) = std(burstDuration); sem_burstDuration(lfpIdx) = std(burstDuration)/...
        sqrt(length(burstDuration));    
    
    mean_burstVolume(lfpIdx) = mean(burstVolume); std_burstVolume(lfpIdx) = std(burstVolume); sem_burstVolume(lfpIdx) = std(burstVolume)/...
        sqrt(length(burstVolume));    
    
    mean_burstFreq(lfpIdx) = mean(burstFreqs); modal_burstFreq(lfpIdx) = mode(burstFreqs);

        
    burstTimes_all{lfpIdx} = trlBurstTimes; burstFreqs_all{lfpIdx} = trlBurstFreq;
    burstOnset_all{lfpIdx} = trlBurstOnset; burstOffset_all{lfpIdx} = trlBurstOffset;
    burstDuration_all{lfpIdx} = trlBurstDuration; burstVolume_all{lfpIdx} = trlBurstVolume;
    
    
    pTrials_burst(lfpIdx) =...
        sum(trialBurstFlag)./length(trialBurstFlag);
    
    
    mean_ssrt(lfpIdx) = bayesianSSRT.ssrt_mean(session); std_ssrt(lfpIdx) = bayesianSSRT.ssrt_std(session);
    triggerFailures(lfpIdx) = bayesianSSRT.triggerFailures(session);
    
end

burstTiming.mean_burstTime = mean_burstTime';burstTiming.std_burstTime = std_burstTime';
burstTiming.sem_burstTime = sem_burstTime';burstTiming.burstTimes = burstTimes_all';

burstTiming.mean_burstOnset = mean_burstOnset'; burstTiming.std_burstOnset = std_burstOnset';
burstTiming.sem_burstOnset = sem_burstOnset'; burstTiming.burstOnset = burstOnset_all';

burstTiming.mean_burstOffset = mean_burstOffset'; burstTiming.std_burstOffset = std_burstOffset';
burstTiming.sem_burstOffset = sem_burstOffset'; burstTiming.burstOffset = burstOffset_all';

burstTiming.mean_burstDuration = mean_burstDuration'; burstTiming.std_burstDuration = std_burstDuration';
burstTiming.sem_burstDuration = sem_burstDuration'; burstTiming.burstDuration = burstDuration_all';

burstTiming.mean_burstVolume = mean_burstVolume'; burstTiming.std_burstVolume = std_burstVolume';
burstTiming.sem_burstVolume = sem_burstVolume'; burstTiming.burstVolume = burstVolume_all';

burstTiming.mean_burstFreq = mean_burstFreq'; burstTiming.modal_burstFreq = modal_burstFreq';
burstTiming.burstFreqs = burstFreqs_all';

burstTiming.pTrials_burst = pTrials_burst'; burstTiming.mean_ssrt = mean_ssrt';
burstTiming.std_ssrt = std_ssrt'; burstTiming.triggerFailures = triggerFailures';



end





