%% Load dependencies
load(fullfile(dataDir,'stoppingBeta.mat'));
pBurst_depth = nan(19, 15);

%% Run extraction function to get beta-burst properties across all contacts for canceled trials...
% ... following successful stopping (target-400:target-200)
fixBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeTarget...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
% ... following successful stopping (ssrt+200:ssrt+400)
ssrtBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeSSRT...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
% ... and prior to the tone (-200:tone; when inhibition needed to be held
%     until)
toneBeta.timing.canceled = SEF_stoppingLFP_getAverageBurstTimeTone...
    (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [-200 0],dataDir);

% ... we're also going to take a look at error beta here too.
errorBeta_late.timing.noncanc = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [300 600],dataDir);

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


%% Organise data for use in JASP
laminarContacts = corticalLFPcontacts.subset.laminar.all;
euPerpIdx = 1:6; xPerpIdx = 7:16;

for lfpIdx = 1:length(laminarContacts)
    
    % Get admin details
    lfp = laminarContacts(lfpIdx);
    session = sessionLFPmap.session(lfp);
    sessionName = FileNames{session};
    
    fixTime_pBurst_lfp(lfpIdx,1) = fixBeta.timing.canceled.pTrials_burst(lfp);
    stopTime_pBurst_lfp(lfpIdx,1) = stoppingBeta.timing.canceled.pTrials_burst(lfp);
    cancelTime_pBurst_lfp(lfpIdx,1) = ssrtBeta.timing.canceled.pTrials_burst(lfp);
    toneTime_pBurst_lfp(lfpIdx,1) = toneBeta.timing.canceled.pTrials_burst(lfp);   
    errorTime_pBurst_lfp(lfpIdx,1) = errorBeta_late.timing.noncanc.pTrials_burst(lfp);   
end

depthTable_pBurst = table();

% Collate the  data into a table
depthTable_pBurst = table(fixTime_pBurst_lfp, stopTime_pBurst_lfp,...
    cancelTime_pBurst_lfp, toneTime_pBurst_lfp, errorTime_pBurst_lfp);

% And combine this with the cortical lfp map for future subsetting (i.e. by
% monkey, laminar, depth, etc...)
depthTable_pBurst = [corticalLFPmap(corticalLFPcontacts.subset.laminar.all,:), ...
    depthTable_pBurst];

% Then add an extra label which splits the depths into laminar compartments
for contactIdx = 1:size(depthTable_pBurst,1)
    % Find the depth and which layer it corresponds to in
    % laminarAlignment.list
    find_laminar = cellfun(@(c) find(c == depthTable_pBurst.depth(contactIdx)), laminarAlignment.list, 'uniform', false);
    find_laminar = find(~cellfun(@isempty,find_laminar));
    % Create a new column with the corresponding laminar compartment label.
    depthTable_pBurst.laminar(contactIdx,1) = laminarAlignment.labels(find_laminar);
    
    if find_laminar < 3
        depthTable_pBurst.upper_lower(contactIdx,1) = {'Upper'};
    else
        depthTable_pBurst.upper_lower(contactIdx,1) = {'Lower'};
    end
    
end


writetable(depthTable_pBurst,fullfile(matDir,'exportJASP','depth_pBurst_epoch.csv'),'WriteRowNames',true)


%% Clean up extracted data

% Normalise pBursts due to variability between sessions
clear normalisedPower normalisedBursts rawBursts
% Take the proportion of bursts observed in a penetration and make the
% value relative to the maximal pBursts observed (i.e. channel with most
% bursts will = 1).
normalisedBursts = cancelTime_pBurst_depth./nanmax(cancelTime_pBurst_depth);
rawBursts = cancelTime_pBurst_depth;

%% Arrange data for figure generation
inputBurstList = {fixTime_pBurst_depth, stopTime_pBurst_depth,cancelTime_pBurst_depth, toneTime_pBurst_depth};
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
            
            % Get the mean pBurst for the given depth
            depthBurst(count,1) = nanmean(inputBursts...
                (laminarAlignment.list{depthGroupIdx},sessionIdx));
            
            % Get the appropriate label (L2, L3, L5, L6)
            depthLabel{count,1} = laminarAlignment.labels{depthGroupIdx};
            
            % Get the epoch label
            periodLabel{count,1} = periodName{periodIdx};
            
            % Get the monkey label
            if ismember(sessionIdx,euPerpIdx); monkeyLabel{count,1} = 'Monkey Eu';
            else; monkeyLabel{count,1} = 'Monkey X';
            end
            
        end
    end
    
end

table(depthLabel,periodLabel,depthBurst)

%% Create Figure
clear betaburst_depth_figure
%Averages with confidence interval
betaburst_depth_figure(1,1)= gramm('x',depthLabel,'y',depthBurst,'color',periodLabel);
betaburst_depth_figure(1,2)= gramm('x',depthLabel(strcmp(monkeyLabel,'Monkey Eu')),'y',depthBurst(strcmp(monkeyLabel,'Monkey Eu')),'color',periodLabel(strcmp(monkeyLabel,'Monkey Eu')));
betaburst_depth_figure(1,3)= gramm('x',depthLabel(strcmp(monkeyLabel,'Monkey X')),'y',depthBurst(strcmp(monkeyLabel,'Monkey X')),'color',periodLabel(strcmp(monkeyLabel,'Monkey X')));

betaburst_depth_figure(1,1).stat_summary('geom',{'point','line','black_errorbar'});
betaburst_depth_figure(1,2).stat_summary('geom',{'point','line','black_errorbar'});
betaburst_depth_figure(1,3).stat_summary('geom',{'point','line','black_errorbar'});

% betaburst_depth_figure(1,1).axe_property('XDir','Reverse');
% betaburst_depth_figure(1,2).axe_property('XDir','Reverse');
% betaburst_depth_figure(1,3).axe_property('XDir','Reverse');

% betaburst_depth_figure.coord_flip();

betaburst_depth_figure(1,2).axe_property('YLim',[0.0 0.5]);
betaburst_depth_figure(1,3).axe_property('YLim',[0.0 0.5]);
figure('Renderer', 'painters', 'Position', [100 100 1200 250]);
betaburst_depth_figure.draw();
