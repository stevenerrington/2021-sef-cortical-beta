function [betaOutput] = betaBurstCount_lfp(morletLFP, morletParameters,medianCutoff)

%% Calculate bursts
medianLFPpower = nanmedian(morletLFP(:));

if nargin < 3
    medianCutoff = 0;
end

betaOutput.burstData = table();

% For each trial
for trl = 1:size(morletLFP,1)
    % Clear loop variables
    clear peakTime peakPower peakIdx nBursts burstFrequency burstTime burstPower
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
    else
        nBursts = 0;
        burstFrequency{:,1} = [];
        burstTime{:,1} = [];
        burstPower{:,1} = [];
    end
    
    betaOutput.burstData(trl,:) = table(trl,nBursts,burstFrequency,burstTime, burstPower);
    
    
end

betaOutput.medianLFPpower = medianLFPpower;
betaOutput.threshold = medianLFPpower*medianCutoff;


