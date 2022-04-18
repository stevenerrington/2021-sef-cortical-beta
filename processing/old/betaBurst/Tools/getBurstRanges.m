function[burstOnset,burstOffset,burstMinFreq,burstMaxFreq,burstDuration, burstVolume] = ...
    getBurstRanges (nBursts, burstTime, burstFrequency,inputData,...
    morletParameters, medianLFPpower, medianCutoff)


for peakIdx = 1:nBursts
    
    burstMaxTime = burstTime{:,1}(peakIdx)+1000;
    burstMainFreq = burstFrequency{:,1}(peakIdx)-...
    morletParameters.frequencies(1)+1;
    beta_power = inputData(burstMainFreq,burstMaxTime);
    
    freqLFPpower = inputData(burstMainFreq,:);
    timeLFPpower = inputData(:,burstMaxTime);
        
    % Duration spread
    burstStartTime = burstMaxTime; burstEndTime = burstMaxTime;
    
    startFlag = 1; endFlag = 1;
    
    while startFlag == 1; burstStartTime = burstStartTime-1;
        if burstStartTime < 1; startFlag = 0; else
            startFlag = freqLFPpower(:,burstStartTime) > medianLFPpower*medianCutoff;
        end
    end
    
    while endFlag == 1; burstEndTime = burstEndTime+1;
        if burstEndTime > length(freqLFPpower); endFlag = 0; else
            endFlag = freqLFPpower(:,burstEndTime) > medianLFPpower*medianCutoff;
        end
    end
    
    burstStartTime = burstStartTime - burstMaxTime;
    burstEndTime = burstEndTime - burstMaxTime;
    
    
    % Frequency spread
    burstStartFreq = burstMainFreq; burstEndFreq = burstMainFreq;
    
    startFlag = 1; endFlag = 1;
    
    while startFlag == 1; burstStartFreq = burstStartFreq-1;
        if burstStartFreq < 1; startFlag = 0;
        else startFlag = timeLFPpower(burstStartFreq,:) > medianLFPpower*medianCutoff;
        end
    end
    
    while endFlag == 1; burstEndFreq = burstEndFreq+1;
        if burstEndFreq > length(timeLFPpower); endFlag = 0;
        else endFlag = timeLFPpower(burstEndFreq,:) > medianLFPpower*medianCutoff;
        end
    end
    
    if burstEndFreq > 15; burstEndFreq = 15; end
        
    burstOnset(peakIdx,1) = burstStartTime;
    burstOffset(peakIdx,1) = burstEndTime;
    burstMaxFreq(peakIdx,1) = burstEndFreq+morletParameters.frequencies(1)-1;
    burstMinFreq(peakIdx,1) = burstStartFreq+morletParameters.frequencies(1)-1;
    burstDuration = burstOffset-burstOnset;
    burstVolume(peakIdx,1)  = (burstEndTime-burstStartTime)*...
        (burstEndFreq-burstStartFreq) *...
        beta_power;
    
    
end