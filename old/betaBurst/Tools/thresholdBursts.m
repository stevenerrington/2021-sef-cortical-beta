function [betaOutput] = thresholdBursts(betaOutput, threshold)

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
    
    betaOutput.burstData.burstOnset{trl} =...
        betaOutput.burstData.burstOnset{trl}(index{trl});
    
    betaOutput.burstData.burstOffset{trl} =...
        betaOutput.burstData.burstOffset{trl}(index{trl});
    
    betaOutput.burstData.burstDuration{trl} =...
        betaOutput.burstData.burstDuration{trl}(index{trl});
    
    betaOutput.burstData.burstMinFreq{trl} =...
        betaOutput.burstData.burstMinFreq{trl}(index{trl});
    
    betaOutput.burstData.burstMaxFreq{trl} =...
        betaOutput.burstData.burstMaxFreq{trl}(index{trl});
    
    betaOutput.burstData.burstVolume{trl} =...
        betaOutput.burstData.burstVolume{trl}(index{trl});
    
end
betaOutput.threshold = threshold;

end
