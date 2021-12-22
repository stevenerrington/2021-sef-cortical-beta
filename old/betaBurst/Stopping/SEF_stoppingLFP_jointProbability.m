
% Parameters
eventAlignments = {'fixate','saccade','stopSignal','tone'};
eventWindows = {[-1000 500],[-1000 2000],[-1000 2000],[-1000 500]};
eventZeros = {9:10, 13:14, 10:11, 9:10};
eventBin = {100,100,100,100};


clear jointBurstProb


for alignmentIdx = 1:4
    
     coincidenceBurstArray{alignmentIdx} = []; 

    for session = 1:29
        if alignmentIdx == 2
            trials = []; trials = executiveBeh.ttx.sNC{session};
        else
            trials = []; trials = executiveBeh.ttx_canc{session};
        end
        
        clear burstFlagArray
        burstFlagArray = [sum(JPSTH_burstCounts.(eventAlignments{alignmentIdx}).EEG{session}(trials,eventZeros{alignmentIdx}),2) > 0,...
            sum(JPSTH_burstCounts.(eventAlignments{alignmentIdx}).LFP_all{session}(trials,eventZeros{alignmentIdx}),2) > 0];
        
       
        eegBurstProb(session,alignmentIdx) = nanmean(sum(JPSTH_burstCounts.(eventAlignments{alignmentIdx}).EEG{session}(trials,eventZeros{alignmentIdx}),2) > 0);
        lfpBurstProb(session,alignmentIdx) = nanmean(sum(JPSTH_burstCounts.(eventAlignments{alignmentIdx}).LFP_all{session}(trials,eventZeros{alignmentIdx}),2) > 0);
        jointBurstProb(session,alignmentIdx) = nanmean(sum(burstFlagArray,2) == 2);
        
    end
    
end




