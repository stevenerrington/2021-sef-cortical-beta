load('D:\projectCode\project_stoppingLFP\processing\procData\stoppingBeta.mat')


ssrtBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeSSRT...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);

ssrtBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeTone...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);


%% Get depth alignment parameters
pBurst_depth = nan(19, 15);
laminarAlignment.list = {[1:4],[5:8],[9:12],[13:17]};
laminarAlignment.l2 = 1:4; laminarAlignment.l3 = 5:8;
laminarAlignment.l5 = 9:12; laminarAlignment.l6 = 13:17;
laminarAlignment.labels = {'L2','L3','L5','L6'};
euPerpIdx = 1:6; xenaPerpIdx = 7:16;


%% Extract and align pBurst by cortical depth
perpSessions = 14:29;
for sessionIdx = 1:length(perpSessions)
    session = perpSessions(sessionIdx);
    
    clear laminarLFPidx
    laminarLFPidx = find(corticalLFPmap.session == session & corticalLFPmap.laminarFlag == 1);
    for lfpIdx = 1:length(laminarLFPidx)
        lfp = laminarLFPidx(lfpIdx);
        depth = corticalLFPmap.depth(lfp); 
        
        stopTime_pBurst_depth(depth,sessionIdx) = stoppingBeta.timing.canceled.pTrials_burst(lfp); 
        cancelTime_pBurst_depth(depth,sessionIdx) = ssrtBeta.timing.canceled.pTrials_burst(lfp); 
    end
end




% Normalise pBursts due to variability between sessions
clear normalisedPower normalisedBursts rawBursts
normalisedBursts = cancelTime_pBurst_depth./nanmax(cancelTime_pBurst_depth);
rawBursts = cancelTime_pBurst_depth;

inputBurstList = {stopTime_pBurst_depth,cancelTime_pBurst_depth};
periodName = {'Stop time','Cancel time'};

count = 0;
clear depthBurst depthBurstNorm label

for periodIdx = 1:2
    clear inputBursts
inputBursts = inputBurstList{periodIdx};
  
% Sort bursts into 4 separate layers (L2, L3, L5, L6)
for sessionIdx = 1:16
    for depthGroupIdx = 1:4
        count = count + 1;

        depthBurst(count,1) = nanmean(inputBursts...
            (laminarAlignment.list{depthGroupIdx},sessionIdx));
                
        depthLabel{count,1} = laminarAlignment.labels{depthGroupIdx};
        
        periodLabel{count,1} = periodName{periodIdx};
        
        if ismember(sessionIdx,euPerpIdx); monkeyLabel{count,1} = 'Monkey Eu';
        else; monkeyLabel{count,1} = 'Monkey X';
        end
        
    end
end  
    
end


%% Create Figure
clear g
%Averages with confidence interval
g(1,1)= gramm('x',depthLabel,'y',depthBurst,'color',periodLabel);
g(1,2)= gramm('x',depthLabel(strcmp(monkeyLabel,'Monkey Eu')),'y',depthBurst(strcmp(monkeyLabel,'Monkey Eu')),'color',periodLabel(strcmp(monkeyLabel,'Monkey Eu')));
g(1,3)= gramm('x',depthLabel(strcmp(monkeyLabel,'Monkey X')),'y',depthBurst(strcmp(monkeyLabel,'Monkey X')),'color',periodLabel(strcmp(monkeyLabel,'Monkey X')));

g(1,1).stat_summary('type','sem','geom',{'point','black_errorbar'});
g(1,2).stat_summary('type','sem','geom',{'point','black_errorbar'});
g(1,3).stat_summary('type','sem','geom',{'point','black_errorbar'});

g(1,1).axe_property('XDir','Reverse');
g(1,2).axe_property('XDir','Reverse');
g(1,3).axe_property('XDir','Reverse');

g.coord_flip();

% g(1,1).axe_property('YLim',[0.25 1]);
% g(1,2).axe_property('YLim',[0.25 1]);
figure('Renderer', 'painters', 'Position', [100 100 1200 250]);
g.draw();
