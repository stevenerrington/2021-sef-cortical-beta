%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
analysisWindows = {[-400:-200],[400:600],[400:600],[-400:-200]};
eventBin = {1,1,1,1,1};
loadDir = 'D:\projectCode\project_stoppingLFP\data\eeg_lfp\';
printFigFlag = 0;

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
        if alignmentIdx == 2
            trials = executiveBeh.ttm_c.NC{session,executiveBeh.midSSDindex(session)}.all;
        else
            trials = executiveBeh.ttm_CGO{session,executiveBeh.midSSDindex(session)}.C_matched;
        end
        
        % Save output for each alignment on each session
        loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
        load([loadDir loadfile_label]);
        
        % Get zero point
        alignmentZero = abs(eeg_lfp_burst.eventWindows{alignmentIdx}(1));
        
        % Find channels in L2, L3, L5, L6
        ch_depths = []; ch_depths = corticalLFPmap.depth(corticalLFPmap.session == session);
        
        % Here, some sessions don't have many contacts in lower layers. We
        % account for that here.
        ch_l2 = 2;
        ch_l3 = 6;
        ch_l5 = 10;
        ch_l6 = min([max(ch_depths) 14]);
        
        for ii = 1:length(trials)
            rasterplot.data.(alignmentEvent).eeg{ii,1} =...
                find(eeg_lfp_burst.EEG{1, 1}(trials(ii),:)) - alignmentZero;
            rasterplot.data.(alignmentEvent).lfp_L2{ii,1} =...
                find(eeg_lfp_burst.LFP{1, 1}(trials(ii),:,ch_l2)) - alignmentZero;
            rasterplot.data.(alignmentEvent).lfp_L3{ii,1} =...
                find(eeg_lfp_burst.LFP{1, 1}(trials(ii),:,ch_l3)) - alignmentZero;
            rasterplot.data.(alignmentEvent).lfp_L5{ii,1} =...
                find(eeg_lfp_burst.LFP{1, 1}(trials(ii),:,ch_l5)) - alignmentZero;
            rasterplot.data.(alignmentEvent).lfp_L6{ii,1} =...
                find(eeg_lfp_burst.LFP{1, 1}(trials(ii),:,ch_l6)) - alignmentZero;
        end
        
        % Collapse data across EEG and LFP's into one array for plotting
        rasterplot.collapsed.(alignmentEvent) =...
            [rasterplot.data.(alignmentEvent).eeg; rasterplot.data.(alignmentEvent).lfp_L2;...
            rasterplot.data.(alignmentEvent).lfp_L3; rasterplot.data.(alignmentEvent).lfp_L5;...
            rasterplot.data.(alignmentEvent).lfp_L6];
        
        % ... and get the corresponding labels for plotting
        rasterplot.collapsed.labels.(alignmentEvent) =...
            [repmat({'EEG'},length(rasterplot.data.(alignmentEvent).eeg),1);...
            repmat({'L2'},length(rasterplot.data.(alignmentEvent).lfp_L2),1);...
            repmat({'L3'},length(rasterplot.data.(alignmentEvent).lfp_L3),1);...
            repmat({'L5'},length(rasterplot.data.(alignmentEvent).lfp_L5),1);...
            repmat({'L6'},length(rasterplot.data.(alignmentEvent).lfp_L6),1)];
        
        
        %
        pBurst_EEG.(alignmentEvent)(sessionIdx-13,1) = mean(sum(eeg_lfp_burst.EEG{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero),2));
        pBurst_L2.(alignmentEvent)(sessionIdx-13,1) = mean(sum(eeg_lfp_burst.LFP{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,ch_l2),2));
        pBurst_L3.(alignmentEvent)(sessionIdx-13,1) = mean(sum(eeg_lfp_burst.LFP{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,ch_l3),2));
        pBurst_L5.(alignmentEvent)(sessionIdx-13,1) = mean(sum(eeg_lfp_burst.LFP{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,ch_l5),2));
        pBurst_L6.(alignmentEvent)(sessionIdx-13,1) = mean(sum(eeg_lfp_burst.LFP{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,ch_l6),2));
    end
    
    
    %% Generate raster figure
    if printFigFlag == 1
        clear eeg_lfp_raster
        % Fixation/target aligned raster
        eeg_lfp_raster(1,1)=gramm('x',rasterplot.collapsed.target,'color',rasterplot.collapsed.labels.target);
        eeg_lfp_raster(1,1).geom_raster('geom',{'point'});
        eeg_lfp_raster(1,1).axe_property('YDir','reverse');
        
        % Saccade aligned raster
        eeg_lfp_raster(1,2)=gramm('x',rasterplot.collapsed.saccade,'color',rasterplot.collapsed.labels.saccade);
        eeg_lfp_raster(1,2).geom_raster('geom',{'point'});
        eeg_lfp_raster(1,2).axe_property('YDir','reverse');
        
        % Stop-signal aligned raster
        eeg_lfp_raster(1,3)=gramm('x',rasterplot.collapsed.stopSignal,'color',rasterplot.collapsed.labels.stopSignal);
        eeg_lfp_raster(1,3).geom_raster('geom',{'point'});
        eeg_lfp_raster(1,3).axe_property('YDir','reverse');
        
        % Tone aligned raster
        eeg_lfp_raster(1,4)=gramm('x',rasterplot.collapsed.tone,'color',rasterplot.collapsed.labels.tone);
        eeg_lfp_raster(1,4).geom_raster('geom',{'point'});
        eeg_lfp_raster(1,4).axe_property('YDir','reverse');
        
        % Print the figure
        figure('Position',[100 100 1200 300]);
        eeg_lfp_raster.draw();
    end
end

%% Figure: boxplot p(burst) x eeg/depth x epoch
%   Initialise the array
pBurst_combined = [];
pBurst_combined_labels = [];
pBurst_combined_epoch = [];

%   For each alignment
for alignmentIdx = 1:4
    % Get the event label
    alignmentEvent = eventAlignments{alignmentIdx};
    
    % Collapse data across EEG/Layers into one array and combine with those
    % in other alignments during the loop
    pBurst_combined = [pBurst_combined; ...
        pBurst_EEG.(alignmentEvent); pBurst_L2.(alignmentEvent);...
        pBurst_L3.(alignmentEvent); pBurst_L5.(alignmentEvent); ...
        pBurst_L6.(alignmentEvent)];
    
    % Apply the relevant EEG/depth labels
    pBurst_combined_labels =...
        [pBurst_combined_labels;...
        repmat({'EEG'},length(pBurst_EEG.(alignmentEvent)),1);...
        repmat({'L2'},length(pBurst_L2.(alignmentEvent)),1);...
        repmat({'L3'},length(pBurst_L3.(alignmentEvent)),1);...
        repmat({'L5'},length(pBurst_L5.(alignmentEvent)),1);...
        repmat({'L6'},length(pBurst_L6.(alignmentEvent)),1)];
    
    % and get the epoch label
    pBurst_combined_epoch =...
        [pBurst_combined_epoch;...
        repmat({[int2str(alignmentIdx) '_' alignmentEvent]},length(14:29)*5,1)];
        
end

% Clear the figure from matlabs memory as we're writing it new
clear eeg_lfp_burst_epoch

% Input data into the gramm library
eeg_lfp_burst_epoch(1,1)= gramm('x',pBurst_combined_epoch,'y',pBurst_combined,'color',pBurst_combined_labels);
% Set the figure up as a point/line figure with 95% CI error bar
eeg_lfp_burst_epoch(1,1).stat_summary('geom',{'point','line','errorbar'});
% Set figure parameters
eeg_lfp_burst_epoch(1,1).axe_property('YLim',[0.0 0.75]);

%... and print it!
figure('Renderer', 'painters', 'Position', [100 100 400 300]);
eeg_lfp_burst_epoch.draw();

