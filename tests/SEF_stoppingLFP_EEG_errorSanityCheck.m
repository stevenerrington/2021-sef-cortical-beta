%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
eventBin = {1,1,1,1};
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
    for alignmentIdx = 2
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
        
        convTest.(alignmentEvent){session} = BetaBurstConvolver (eegBetaBurst.burstData.burstTime);
        
    end
end


%% Extract data from files
% For each session
for sessionIdx = 14:29
    % Get the admin/details
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest
    alignmentIdx = 2;
    % Get the desired alignment
    alignmentEvent = eventAlignments{alignmentIdx};
    
    % Get trials of interest
    if alignmentIdx == 2
        trials = executiveBeh.ttx.sNC{session};
    else
        trials = executiveBeh.ttx_canc{session};
    end
    
    % Save output for each alignment on each session
    loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
    load([loadDir loadfile_label]);
    
    % Get zero point
    alignmentZero = abs(eeg_lfp_burst.eventWindows{alignmentIdx}(1));
    
    
    pBurst_EEG_temp.(alignmentEvent)(sessionIdx-13,1) = mean(sum(eeg_lfp_burst.EEG{1, 1}(trials,[100:300]+alignmentZero),2) > 0 );
    
end

burstTiming.saccade.noncanc = SEF_stoppingEEG_getAverageBurstTime(14:29,...
    executiveBeh.ttx.sNC,FileNames, bayesianSSRT, [100 300], 'saccade');

compArray = [pBurst_EEG_temp.saccade, burstTiming.saccade.noncanc.pTrials_burst];


%%
for sessionIdx = 1:29
    nc_mean{sessionIdx} = nanmean(convTest.saccade{sessionIdx}(executiveBeh.ttx.sNC{sessionIdx},:));
    ns_mean{sessionIdx} = nanmean(convTest.saccade{sessionIdx}(executiveBeh.ttx.GO{sessionIdx},:));
end

clear burstTime_rasterPlot
sessionList = 14:29;
groupLabels = [repmat({'No-stop'},length(sessionList),1); repmat({'Non-canceled'},length(sessionList),1)];
burstTime_rasterPlot(1,1) = gramm('x',[-1000:2000],...
    'y',[ns_mean(sessionList)';nc_mean(sessionList)'],...
    'color',[repmat({'No-stop'},length(sessionList),1);repmat({'Non-canceled'},length(sessionList),1)]); 
burstTime_rasterPlot(1,1).stat_summary()

burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot.set_color_options('map',[colors.nostop;colors.noncanc]);
burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot(1,1).axe_property('XLim',[-250 500]); 
burstTime_rasterPlot(1,1).axe_property('YLim',[0.00025 0.0025]);

figure('Renderer', 'painters', 'Position', [100 100 250 500]);
burstTime_rasterPlot.draw();