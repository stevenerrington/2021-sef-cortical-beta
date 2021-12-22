
behDir = 'C:\Users\Steven\Desktop\NN_2021_Beh\';
fileLabel = 'N2info_';

clear timingBeh

for session = 1:29
    
    clear behavior
    load ([behDir fileLabel int2str(session)],'behavior')
    
    timingBeh{session}.standard.SSD = behavior.SSDlist_all;
    timingBeh{session}.standard.pNC = behavior.pNC_all;
    timingBeh{session}.standard.nTr = behavior.stopTrCount_all;
    
    
    timingBeh{session}.canceled.nTr = behavior.stopTrCount_C;
    timingBeh{session}.canceled.HazardRate_standard = behavior.HazR_SSD_C;
    timingBeh{session}.canceled.HazardRate_subjective = behavior.HazR_SSD_subjFixed.C(1,:);
    timingBeh{session}.canceled.HazardRate_dynamic = behavior.HazR_SSD_dyn.C;
    
    timingBeh{session}.seenStop.pNC = behavior.pNC_ssSeen;
    timingBeh{session}.seenStop.nTr = behavior.stopTrCount_ssSeen;
    timingBeh{session}.seenStop.HazardRate_standard = behavior.HazR_SSD_ssSeen;
    timingBeh{session}.seenStop.HazardRate_subjective = behavior.HazR_SSD_subjFixed.ssSeen(1,:);
    timingBeh{session}.seenStop.HazardRate_dynamic = behavior.HazR_SSD_dyn.ssSeen;

end







