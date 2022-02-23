%% Load dependencies
load('D:\projectCode\project_stoppingLFP\processing\procData\stoppingBeta.mat')

%% Run extraction function to get beta-burst properties across all contacts for canceled trials...
% ... following successful stopping (target-400:target-200)
fixBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeTarget...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);
% ... following successful stopping (ssrt:ssrt+300)
ssrtBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeSSRT...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);
% ... and prior to the tone (-300:tone; when inhibition needed to be held
%     until)
toneBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeTone...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);

%% Extract and align pBurst by cortical depth
perpSessions = 14:29; % This limits to the sessions in which we believe are perpendicular

% For each laminar penetration:
for sessionIdx = 1:length(perpSessions)
    session = perpSessions(sessionIdx);
    
    clear laminarLFPidx
    % Find the contacts in the brain for that penetration
    laminarLFPidx = find(corticalLFPmap.session == session & corticalLFPmap.cortexFlag == 1);
    for lfpIdx = 1:length(laminarLFPidx)
        % Map the contact to a pre-assigned cortical depth (Godlove et al.,
        % 2012)
        lfp = laminarLFPidx(lfpIdx);
        depth = corticalLFPmap.depth(lfp);
        
        % Extract the proportion of beta-bursts observed during SSRT, post-SSRT and pre-tone
        % for that contact.
        fixTime_pBurst_depth(depth,sessionIdx) = fixBeta.timing.canceled.pTrials_burst(lfp);
        stopTime_pBurst_depth(depth,sessionIdx) = stoppingBeta.timing.canceled.pTrials_burst(lfp);
        cancelTime_pBurst_depth(depth,sessionIdx) = ssrtBeta.timing.canceled.pTrials_burst(lfp);
        toneTime_pBurst_depth(depth,sessionIdx) = toneBeta.timing.canceled.pTrials_burst(lfp);
    end
end


%% Clean up extracted data

% Normalise pBursts due to variability between sessions
clear normalisedPower normalisedBursts rawBursts
% Take the proportion of bursts observed in a penetration and make the
% value relative to the maximal pBursts observed (i.e. channel with most
% bursts will = 1).
normalisedBursts = cancelTime_pBurst_depth./nanmax(cancelTime_pBurst_depth);
rawBursts = cancelTime_pBurst_depth;

%% Arrange data for figure generation
inputBurstList = {stopTime_pBurst_depth,cancelTime_pBurst_depth, toneTime_pBurst_depth};
periodName = {'Fix time','Stop time','Cancel time', 'Tone time'};

count = 0;
clear depthBurst depthBurstNorm label

for periodIdx = 1:length(periodName)
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
clear betaburst_depth_figure
%Averages with confidence interval
betaburst_depth_figure(1,1)= gramm('x',depthLabel,'y',depthBurst,'color',periodLabel);
betaburst_depth_figure(1,2)= gramm('x',depthLabel(strcmp(monkeyLabel,'Monkey Eu')),'y',depthBurst(strcmp(monkeyLabel,'Monkey Eu')),'color',periodLabel(strcmp(monkeyLabel,'Monkey Eu')));
betaburst_depth_figure(1,3)= gramm('x',depthLabel(strcmp(monkeyLabel,'Monkey X')),'y',depthBurst(strcmp(monkeyLabel,'Monkey X')),'color',periodLabel(strcmp(monkeyLabel,'Monkey X')));

betaburst_depth_figure(1,1).stat_summary('geom',{'point','black_errorbar'});
betaburst_depth_figure(1,2).stat_summary('geom',{'point','black_errorbar'});
betaburst_depth_figure(1,3).stat_summary('geom',{'point','black_errorbar'});

% betaburst_depth_figure(1,1).axe_property('XDir','Reverse');
% betaburst_depth_figure(1,2).axe_property('XDir','Reverse');
% betaburst_depth_figure(1,3).axe_property('XDir','Reverse');

% betaburst_depth_figure.coord_flip();

% g(1,1).axe_property('YLim',[0.25 1]);
% g(1,2).axe_property('YLim',[0.25 1]);
figure('Renderer', 'painters', 'Position', [100 100 1200 250]);
betaburst_depth_figure.draw();
