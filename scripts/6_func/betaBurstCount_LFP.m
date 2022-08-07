function [betaOutput] = betaBurstCount_LFP(morletLFP, morletParameters,medianCutoff)

medianLFPpower = nanmedian(morletLFP(:));

%% Calculate bursts
if nargin < 3
    medianCutoff = 1;
end
betaOutput.burstData = table();

% For each trial
for trl = 1:size(morletLFP,1)
    % Clear loop variables
    clear peakTime peakPower peakIdx nBursts burstFrequency burstTime burstPower...
                burstOnset_time burstOffset_time burstDuration_time burst_freqMax...
                burst_freqMin
        
    clear inputData
    
    % Get trial data for all frequencies
    inputData = squeeze(morletLFP(trl,:,:))';
    
    if ~isnan(inputData(1,1))
        
        % Find frequency and timing of peaks in this band (using imregionalmax function)
        [allPeakFreq,allPeakTime] = find(imregionalmax(inputData));
        
        for peakIdx = 1:length(allPeakFreq)
            peakPower(peakIdx,1) = inputData(allPeakFreq(peakIdx),allPeakTime(peakIdx));
        end
        
        nBursts = sum(peakPower > medianLFPpower*medianCutoff);
        burstFrequency{:,1} = ...
            allPeakFreq(find(peakPower > medianLFPpower*medianCutoff))+...
            morletParameters.frequencies(1)-1;
        burstTime{:,1} = ...
            allPeakTime(find(peakPower > medianLFPpower*medianCutoff))-1000;
        burstPower{:,1} = ...
            peakPower(find(peakPower > medianLFPpower*medianCutoff));
        
        [burstOnset_t,burstOffset_t,burstMinFreq_t,burstMaxFreq_t,burstDuration_t,burstVolume_t] = ...
            getBurstRanges (nBursts, burstTime, burstFrequency,inputData,...
            morletParameters,medianLFPpower,medianCutoff);
        
        burstOnset{:,1} = burstOnset_t;
        burstOffset{:,1} = burstOffset_t;
        burstMinFreq{:,1} = burstMinFreq_t;
        burstMaxFreq{:,1} = burstMaxFreq_t;
        burstDuration {:,1} = burstDuration_t;
        burstVolume {:,1} = burstVolume_t;
        
    else
        nBursts = 0;
        burstFrequency{:,1} = [];
        burstTime{:,1} = [];
        burstPower{:,1} = [];
        burstOnset{:,1} = []; burstOffset{:,1} = [];
        burstMinFreq{:,1} = []; burstMaxFreq{:,1} = [];
        burstDuration {:,1} = [];
        burstVolume {:,1} = [];
    end
    
    betaOutput.burstData(trl,:) = table(trl,nBursts,burstFrequency,burstTime, burstPower,...
        burstOnset,burstOffset,burstDuration,burstMinFreq,burstMaxFreq, burstVolume);
    
    
end

betaOutput.medianLFPpower = medianLFPpower;
betaOutput.threshold = medianLFPpower*medianCutoff;


