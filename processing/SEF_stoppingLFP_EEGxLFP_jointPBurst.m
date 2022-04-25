%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
analysisWindows = {[-400:-200],[400:600],[0:200],[-400:-200]};
eventBin = {1,1,1,1};
loadDir = 'D:\projectCode\project_stoppingLFP\data\eeg_lfp\';
printFigFlag = 0;

%%
eegxlfp_cooccur.(alignmentEvent).preBurst = NaN(length(14:29),17);
eegxlfp_cooccur.(alignmentEvent).postBurst = NaN(length(14:29),17);
eegxlfp_cooccur.(alignmentEvent).preBurst_shuffled = NaN(length(14:29),17);
eegxlfp_cooccur.(alignmentEvent).postBurst_shuffled = NaN(length(14:29),17);

windowSize = 50;
%% Extract data from files
% For each session
for sessionIdx = 14:29
    % Get the admin/details
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest
    for alignmentIdx = 1:4
        % Get the desired alignment
        alignmentEvent = eventAlignments{alignmentIdx};
        
        % Get trials of interest
        trials = [];
        if alignmentIdx == 2
            trials = executiveBeh.ttx.sNC{session};
            trials_shuffled = executiveBeh.ttx.sNC{session}(randperm(numel(executiveBeh.ttx.sNC{session})));
        else
            trials = executiveBeh.ttx_canc{session};
            trials_shuffled = executiveBeh.ttx_canc{session}(randperm(numel(executiveBeh.ttx_canc{session})));
        end
        
        % Save output for each alignment on each session
        loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
        load([loadDir loadfile_label]);
        
        % Get zero point
        alignmentZero = abs(eeg_lfp_burst.eventWindows{alignmentIdx}(1));
        
        % Initialise arrays/clear each loop
        preburst_lfp = []; postburst_lfp = [];
        preburst_lfp_shuffled = []; postburst_lfp_shuffled = [];
        
        % Go through each trial
        count = 0;
        for trialIdx = 1:length(trials)
            % Get the actual trial index
            trial_in = trials(trialIdx);
            trial_in_shuffled = trials_shuffled(trialIdx);
            
            % Find bursts on the trial
            burstPoints = [];
            burstPoints = find(eeg_lfp_burst.EEG{1, 1}(trial_in,:) > 0);
            % and cut this down to those that just occur during the analysis
            % window/period of interest
            burstPoints = burstPoints(ismember(burstPoints-alignmentZero,analysisWindows{alignmentIdx}));
            
            % If there is a burst
            if ~isempty(burstPoints)
                % For each burst within the window
                for burstIdx = 1:length(burstPoints)
                    
                    % Count the burst
                    count = count + 1;
                    
                    % Define a window:
                    % 50 ms prior to the burst
                    burst_preWindow = [burstPoints(burstIdx)-windowSize:burstPoints(burstIdx)];
                    % 50 ms after the burst
                    burst_postWindow = [burstPoints(burstIdx):burstPoints(burstIdx)+windowSize];
                    
                    % Then for each electrode in the session
                    for LFPidx = 1:size(eeg_lfp_burst.LFP{1, 1},3)
                        % Find whether there was a burst in the pretone:
                        preburst_lfp(count,LFPidx) = sum(eeg_lfp_burst.LFP{1, 1}(trial_in,burst_preWindow,LFPidx)) > 0;
                        % or post-tone window:
                        postburst_lfp(count,LFPidx) = sum(eeg_lfp_burst.LFP{1, 1}(trial_in,burst_postWindow,LFPidx)) > 0;
                        
                        
                        preburst_lfp_shuffled(count,LFPidx) = sum(eeg_lfp_burst.LFP{1, 1}(trial_in_shuffled,burst_preWindow,LFPidx)) > 0;
                        postburst_lfp_shuffled(count,LFPidx) = sum(eeg_lfp_burst.LFP{1, 1}(trial_in_shuffled,burst_postWindow,LFPidx)) > 0;
                        
                        % This array will result in a nBurst in session x contact array,
                        % with a 1 indicating that a burst co-occured in EEG
                        % and the LFP contact in the window.
                        % Averaging this array will give you the p(trials)
                        % with a burst in EEG and LFP
                    end
                end
            end
        end
        
        eegxlfp_cooccur.(alignmentEvent).preBurst(sessionIdx-13,1:size(eeg_lfp_burst.LFP{1, 1},3)) = nanmean(preburst_lfp);
        eegxlfp_cooccur.(alignmentEvent).postBurst(sessionIdx-13,1:size(eeg_lfp_burst.LFP{1, 1},3)) = nanmean(postburst_lfp);
        
        eegxlfp_cooccur.(alignmentEvent).preBurst_shuffled(sessionIdx-13,1:size(eeg_lfp_burst.LFP{1, 1},3)) = nanmean(preburst_lfp_shuffled);
        eegxlfp_cooccur.(alignmentEvent).postBurst_shuffled(sessionIdx-13,1:size(eeg_lfp_burst.LFP{1, 1},3)) = nanmean(postburst_lfp_shuffled);
        
    end
    
end

count = 0;
for sessionIdx = 14:29
    % Get the admin/details
    session = sessionIdx;
    monkey = executiveBeh.nhpSessions.monkeyNameLabel(sessionIdx);
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest
    for alignmentIdx = 1:4
        count = count + 1;
        alignmentEvent = eventAlignments{alignmentIdx};
        alignmentLabel = eventAlignments(alignmentIdx);
        
        layerLabel = {'Upper','Lower','All'};
        layerRef = {[1:8],[9:17],[1:17]};
        
        upper_regular_pre =  nanmean(eegxlfp_cooccur.(alignmentEvent).preBurst(sessionIdx-13,layerRef{1}),2);
        upper_regular_post =  nanmean(eegxlfp_cooccur.(alignmentEvent).postBurst(sessionIdx-13,layerRef{1}),2);
        upper_shuffled_pre =  nanmean(eegxlfp_cooccur.(alignmentEvent).preBurst_shuffled(sessionIdx-13,layerRef{1}),2);
        upper_shuffled_post =  nanmean(eegxlfp_cooccur.(alignmentEvent).postBurst_shuffled(sessionIdx-13,layerRef{1}),2);

        lower_regular_pre =  nanmean(eegxlfp_cooccur.(alignmentEvent).preBurst(sessionIdx-13,layerRef{2}),2);
        lower_regular_post =  nanmean(eegxlfp_cooccur.(alignmentEvent).postBurst(sessionIdx-13,layerRef{2}),2);
        lower_shuffled_pre =  nanmean(eegxlfp_cooccur.(alignmentEvent).preBurst_shuffled(sessionIdx-13,layerRef{2}),2);
        lower_shuffled_post =  nanmean(eegxlfp_cooccur.(alignmentEvent).postBurst_shuffled(sessionIdx-13,layerRef{2}),2);
        
        
        lfpxeeg_prepost_burst(count,:) = table(session,monkey,alignmentLabel,...
            upper_regular_pre,upper_regular_post,upper_shuffled_pre,upper_shuffled_post,...
            lower_regular_pre,lower_regular_post,lower_shuffled_pre,lower_shuffled_post);
        
    end
end

writetable(lfpxeeg_prepost_burst,'D:\projectCode\project_stoppingLFP\data\exportJASP\lfpxeeg_prepost_burst.csv','WriteRowNames',true)

%%

figureData = lfpxeeg_prepost_burst(strcmp(lfpxeeg_prepost_burst.alignmentLabel,'target'),:);

figure('Renderer', 'painters', 'Position', [100 100 450 400]);
subplot(2,2,1)
donut([nanmean(figureData.upper_regular_pre), 1-nanmean(figureData.upper_regular_pre)]);
subplot(2,2,2)
donut([nanmean(figureData.upper_regular_post), 1-nanmean(figureData.upper_regular_post)]);
subplot(2,2,3)
donut([nanmean(figureData.lower_regular_pre), 1-nanmean(figureData.lower_regular_pre)]);
subplot(2,2,4)
donut([nanmean(figureData.lower_regular_post), 1-nanmean(figureData.lower_regular_post)]);
