function [betaOutput] = thresholdBursts_EEG(betaOutput, threshold)

index = cellfun(@(x) find(x > threshold),...
    betaOutput.burstData.burstPower, 'UniformOutput', false);


for trl = 1:size(betaOutput.burstData,1)
    betaOutput.burstData.nBursts(trl) = length(index{trl});
    
    betaOutput.burstData.burstFrequency{trl} =...
        betaOutput.burstData.burstFrequency{trl}(index{trl});
    
    betaOutput.burstData.burstTime{trl} =...
        betaOutput.burstData.burstTime{trl}(index{trl});
    
    betaOutput.burstData.burstPower{trl} =...
        betaOutput.burstData.burstPower{trl}(index{trl});
    

    
end
betaOutput.threshold = threshold;

end
