%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
eventBin = {1,1,1,1,1};
saveDir = 'D:\projectCode\project_stoppingLFP\data\eeg_lfp\';

% Initialise arrays
burstCounts_LFP_raw = {}; burstCounts_LFP_all = {};
burstCounts_LFP_upper = {}; burstCounts_LFP_lower = {};

%% Extract data from files
% For each session
for sessionIdx = 1:29
        % Get the admin/details
        session = sessionIdx;
        fprintf('Analysing session %i of %i. \n',session, 29)
        
        % ... and for each epoch of interest
    for alignmentIdx = 1:4
        % Get the desired alignment
        alignmentEvent = eventAlignments{alignmentIdx};
               
        % Get window sizes to oompare p(bursts)
        window = eventWindows{alignmentIdx};
        binSize = eventBin{alignmentIdx};
        times = window(1)+(binSize/2):binSize:window(2)-(binSize/2);

        %% Get EEG bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % clear trials
        trials = [];
        trials = 1:length(executiveBeh.TrialEventTimes_Overall{session}(:,1));
        
        % Load in EEG data from directory & threshold bursts
        eegDir = 'D:\projectCode\project_stoppingEEG\data\monkeyEEG\';
        eegName = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_' alignmentEvent];
        eegBetaBurst = parload([eegDir eegName]);
        [eegBetaBurst] = thresholdBursts_EEG(eegBetaBurst.betaOutput, eegBetaBurst.betaOutput.medianLFPpower*6);
        
        % Find the maximum number of bursts that occured in a trial and
        % initialise an array
        maxNBurst_eeg = max(cellfun('length',eegBetaBurst.burstData.burstTime(trials)));
        eegMatrix = nan(size(trials,2),maxNBurst_eeg);
        
        % For each trial in the session
        for trlIdx = 1:length(trials)
            trl = trials(trlIdx);
            % Get the time of a burst, if one occured in a trial
            if ~isempty(eegBetaBurst.burstData.burstTime{trl})
                eegMatrix(trlIdx,1:length(eegBetaBurst.burstData.burstTime{trl})) =...
                    eegBetaBurst.burstData.burstTime{trl}';
            else
                continue
            end
        end
        
        % Get an array (0 or 1) of burst times for each bin around the
        % epoch
        alignedBurstData_EEG = alignTimeStamps(eegMatrix, zeros(length(eegMatrix),1));
        eegBurstTimes = trimTimeStamps(alignedBurstData_EEG, window);
        
        % Save this for EEG, split by the aligment event, and the session
        burstCounts_EEG{1,1} = {};
        burstCounts_EEG{1,1} = spikeCounts(eegBurstTimes, window, binSize);
        
        
        %% Get LFP bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % For the session we've extracted the EEG from, find the cortical
        % channels from which we recorded LFP
        sessionLFP = find(corticalLFPmap.session == session);
        nLFPs = length(sessionLFP);
        % Initialise an array
        burstCounts_LFPall = [];
        
        % For each LFP in the session
        parfor lfpidx = 1:nLFPs
            % Load in the relevant data and threshold bursts
            lfp = sessionLFP(lfpidx);
            lfpName = ['betaBurst\' alignmentEvent '\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_' alignmentEvent];
            lfpBetaBurst = parload([outputDir lfpName]);
            [lfpBetaBurst] = thresholdBursts(lfpBetaBurst.betaOutput, lfpBetaBurst.betaOutput.medianLFPpower*6);
            
            % Find the maximum number of bursts that occured in a trial and
            % initialise an array
            maxNBurst_lfp = max(cellfun('length',lfpBetaBurst.burstData.burstTime(trials)));
            lfpMatrix = nan(size(trials,2),maxNBurst_lfp);
            
           % For each trial in the session
            for trlIdx = 1:length(trials)
                trl = trials(trlIdx);
                % Get the time of a burst, if one occured in a trial
                if ~isempty(lfpBetaBurst.burstData.burstTime{trl})
                    lfpMatrix(trlIdx,1:length(lfpBetaBurst.burstData.burstTime{trl})) =...
                        lfpBetaBurst.burstData.burstTime{trl}';
                else
                    continue
                end
            end
            
            % Get an array (0 or 1) of burst times for each bin around the
            % epoch
            alignedBurstData_LFP = alignTimeStamps(lfpMatrix, zeros(length(lfpMatrix),1));
            lfpBurstTimes = trimTimeStamps(alignedBurstData_LFP, window);
            % Save this for LFP channel
            burstCounts_LFPall(:,:,lfpidx) = spikeCounts(lfpBurstTimes, window, binSize);
        end
                
        % After looping through all the channels, save the nBursts sorted
        % on alignment and sessionIdx
        burstCounts_LFP_raw{1,1} = {};
        burstCounts_LFP_raw{1,1} = burstCounts_LFPall;
        burstCounts_LFP_all{1,1} = double(sum(burstCounts_LFPall,3) > 0);

        % I'll then look to split these data by upper and lower layers
        % by first finding the layer in which channels were located
        upperContacts = find(corticalLFPmap.depth(sessionLFP) < 9);
        lowerContacts = find(corticalLFPmap.depth(sessionLFP) > 8); 
        
        % And splitting the output accordingly
        burstCounts_LFP_upper{1,1} = double(sum(burstCounts_LFPall(:,:,upperContacts),3) > 0);
        burstCounts_LFP_lower{1,1} = double(sum(burstCounts_LFPall(:,:,lowerContacts),3) > 0);
            
        % Setup structure to save: memory limitations
        savefile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];

        % Collate information into one saveable structure
        eeg_lfp_burst = struct();
        eeg_lfp_burst.EEG = burstCounts_EEG;
        eeg_lfp_burst.LFP = burstCounts_LFP_raw;
        eeg_lfp_burst.eventAlignments = eventAlignments;
        eeg_lfp_burst.eventWindows = eventWindows;
        eeg_lfp_burst.eventBins = eventBin;
        
        % Save output for each alignment on each session
        save([saveDir savefile_label],'eeg_lfp_burst','-v7.3')
        % This can be loaded in to future analyses.
    end
end






