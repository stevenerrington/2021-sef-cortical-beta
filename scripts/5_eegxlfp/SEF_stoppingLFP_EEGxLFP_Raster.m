%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'fixate','target','saccade','stopSignal','tone'};
eventWindows = {[-1000 1000],[-1000 1000],[-1000 1000],[-1000 1000],[-1000 1000],};
analysisWindows = {[200:400],[-400:-200],[400:600],[0:200],[-400:-200]};
eventBin = {1,1,1,1,1};
loadDir = fullfile(dataDir,'eeg_lfp');
printFigFlag = 0;

%% Find active trials (when tone was sounded)
for sessionIdx = 1:29
    ttx.activeTrials{sessionIdx} = find(~isnan(executiveBeh.TrialEventTimes_Overall{sessionIdx}(:,6)));
end

%% Extract data from files
% For each session
for sessionIdx = 14:29
    % Get the admin/details
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest
    for alignmentIdx = 1:5
        % Get the desired alignment
        alignmentEvent = eventAlignments{alignmentIdx};
        
        % Get trials of interest
        trials = []; trials_shuffled = [];
        
        if alignmentIdx == 3 % If aligning on saccade, then we will look at error trials
            trials = executiveBeh.ttx.sNC{session};
        else % Otherwise, we will just look at canceled trials
            trials = executiveBeh.ttx_canc{session};
        end
        
        trials_shuffled = trials(randperm(numel(trials)));
        
        
        % Save output for each alignment on each session
        loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
        load(fullfile(loadDir, loadfile_label));
        
        % Get zero point
        alignmentZero = abs(eeg_lfp_burst.eventWindows{alignmentIdx}(1));
        
        % Find channels in L2, L3, L5, L6
        ch_depths = []; ch_depths = corticalLFPmap.depth(corticalLFPmap.session == session);
        
        % Here, some sessions don't have many contacts in lower layers. We
        % account for that here. I'm just plotting one channel per layer
        % for greater representitiveness. More channels = greater p(burst | time)
        ch_l2 = 1;
        ch_l3 = 5;
        ch_l5 = 9;
        ch_l6 = min([max(ch_depths) 14]);
        
        % For each trial of interest
        for ii = 1:length(trials)
            % Get the time point of when a burst occured relative to the
            % time of event (0; alignmentZero). Save this output as a cell
            % array to be plotted in gramm later. Do this for:
            %      EEG:
            rasterplot.data.(alignmentEvent).eeg{ii,1} =...
                find(eeg_lfp_burst.EEG{1, 1}(trials(ii),:)) - alignmentZero;
            %      L2:
            rasterplot.data.(alignmentEvent).lfp_L2{ii,1} =...
                find(eeg_lfp_burst.LFP_raw{1, 1}(trials(ii),:,ch_l2)) - alignmentZero;
            %      L3:
            rasterplot.data.(alignmentEvent).lfp_L3{ii,1} =...
                find(eeg_lfp_burst.LFP_raw{1, 1}(trials(ii),:,ch_l3)) - alignmentZero;
            %      L5:
            rasterplot.data.(alignmentEvent).lfp_L5{ii,1} =...
                find(eeg_lfp_burst.LFP_raw{1, 1}(trials(ii),:,ch_l5)) - alignmentZero;
            %      L6:
            rasterplot.data.(alignmentEvent).lfp_L6{ii,1} =...
                find(eeg_lfp_burst.LFP_raw{1, 1}(trials(ii),:,ch_l6)) - alignmentZero;
        end
        
        % We are going to print for each session, so for this, we can just
        % make a temporary structure holding the data for this session only (i.e. we
        % aren't saving through the loop for each session). To do this:
        
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
        
        
        % However, we will save the proportion of bursts observed in the
        % analysis window for each epoch on each session. As we are just
        % looking at the perp sessions (14 onwards), I will subtract 13
        % from the array index for saving (session 14, now is index 1). I
        % am using mean(sum(data)), as this will give the proportion of
        % trials in which a burst was observed
        
        pBurst_EEG.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(eeg_lfp_burst.EEG{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero),2) > 0 );
        pBurst_L2.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(eeg_lfp_burst.LFP_raw{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,ch_l2),2) > 0 );
        pBurst_L3.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(eeg_lfp_burst.LFP_raw{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,ch_l3),2) > 0 );
        pBurst_L5.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(eeg_lfp_burst.LFP_raw{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,ch_l5),2) > 0 );
        pBurst_L6.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(eeg_lfp_burst.LFP_raw{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,ch_l6),2) > 0 );

        
        
        input = [];
        
        input = eeg_lfp_burst.LFP_raw{1, 1}(trials,analysisWindows{alignmentIdx}+alignmentZero,:);
        
        
        pBurst_upper_all.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(squeeze(sum(input(:,:,[laminarAlignment.l2,laminarAlignment.l3]) > 0,2)),2) > 0);
        pBurst_lower_all.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(squeeze(sum(input(:,:,[laminarAlignment.l5(1):end]) > 0,2)),2) > 0);
        pBurst_all_all.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(squeeze(sum(input(:,:,[1:end]) > 0,2)),2) > 0);
        pBurst_ind_all.(alignmentEvent)(sessionIdx-13,1) = nanmean(nanmean(squeeze(sum(input(:,:,[1:end])>0,2)) > 0));
                
        pBurst_L2_all.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(squeeze(sum(input(:,:,laminarAlignment.l2) > 0,2)),2) > 0);
        pBurst_L3_all.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(squeeze(sum(input(:,:,laminarAlignment.l3) > 0,2)),2) > 0);
        pBurst_L5_all.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(squeeze(sum(input(:,:,laminarAlignment.l5) > 0,2)),2) > 0);
        pBurst_L6_all.(alignmentEvent)(sessionIdx-13,1) = nanmean(sum(squeeze(sum(input(:,:,13:end) > 0,2)),2) > 0);
        
    end
    
    
    %% After we have run the analysis for all epochs in a given session, we can then print the figure
    
    % If we choose to print the figure for each session (printFigFlag)
    if printFigFlag == 1
        clear eeg_lfp_raster % we will clear any existing gramm plot with that variable name
        
        % ... and will plot the:
        % Fixation/target aligned raster
        eeg_lfp_raster(1,1)=gramm('x',rasterplot.collapsed.target,'color',rasterplot.collapsed.labels.target);
        eeg_lfp_raster(1,1).geom_raster('geom',{'point'});
        eeg_lfp_raster(1,1).axe_property('YDir','reverse');
        eeg_lfp_raster(1,1).axe_property('XLim',[-600 200]);
        
        % Stop-signal aligned raster
        eeg_lfp_raster(1,2)=gramm('x',rasterplot.collapsed.stopSignal,'color',rasterplot.collapsed.labels.stopSignal);
        eeg_lfp_raster(1,2).geom_raster('geom',{'point'});
        eeg_lfp_raster(1,2).axe_property('YDir','reverse');
        eeg_lfp_raster(1,2).axe_property('XLim',[-200 600]);
        
        % Tone aligned raster
        eeg_lfp_raster(1,3)=gramm('x',rasterplot.collapsed.tone,'color',rasterplot.collapsed.labels.tone);
        eeg_lfp_raster(1,3).geom_raster('geom',{'point'});
        eeg_lfp_raster(1,3).axe_property('YDir','reverse');
        eeg_lfp_raster(1,3).axe_property('XLim',[-600 200]);        
        
        
        % Saccade aligned raster
        eeg_lfp_raster(1,4)=gramm('x',rasterplot.collapsed.saccade,'color',rasterplot.collapsed.labels.saccade);
        eeg_lfp_raster(1,4).geom_raster('geom',{'point'});
        eeg_lfp_raster(1,4).axe_property('YDir','reverse');
        eeg_lfp_raster(1,4).axe_property('XLim',[0 800]);
        
        % ... and then generate it
        figure('Position',[100 100 1200 300]);
        eeg_lfp_raster.draw();
    end
end

% We then want to look at the proportion of bursts during each epoch,
% across sessions. To do this, we will make a boxplot.

%% Figure: boxplot p(burst) x eeg/depth x epoch

% Initialise the array
pBurst_combined = [];
pBurst_combined_labels = [];
pBurst_combined_epoch = [];

% Collate the data in a way to be used by gramm
%   For each alignment:
for alignmentIdx = 1:length(eventAlignments)
    % Get the event label
    alignmentEvent = eventAlignments{alignmentIdx};
    
    % Collapse data across EEG/Layers into one array and combine with those
    % in other alignments during the loop
    pBurst_combined = [pBurst_combined; ...
        pBurst_EEG.(alignmentEvent); pBurst_upper_all.(alignmentEvent);...
        pBurst_lower_all.(alignmentEvent);...
        pBurst_all_all.(alignmentEvent);...
        pBurst_ind_all.(alignmentEvent) ];
    
    % Apply the relevant EEG/depth labels
    pBurst_combined_labels =...
        [pBurst_combined_labels;...
        repmat({'EEG'},length(pBurst_EEG.(alignmentEvent)),1);...
        repmat({'Upper'},length(pBurst_upper_all.(alignmentEvent)),1);...
        repmat({'Lower'},length(pBurst_lower_all.(alignmentEvent)),1);...
        repmat({'All'},length(pBurst_lower_all.(alignmentEvent)),1);...
        repmat({'Individual'},length(pBurst_ind_all.(alignmentEvent)),1)];
    
    % and get the epoch label
    pBurst_combined_epoch =...
        [pBurst_combined_epoch;...
        repmat({[int2str(alignmentIdx) '_' alignmentEvent]},length(14:29)*5,1)];
        
end

%% Export data for JASP analysis

laminarJASPdata = struct();

% Apply the relevant EEG/depth labels
laminarJASPdata.label = [repmat({'EEG'},length(pBurst_EEG.(alignmentEvent)),1);...
        repmat({'Upper'},length(pBurst_upper_all.(alignmentEvent)),1);...
        repmat({'Lower'},length(pBurst_lower_all.(alignmentEvent)),1);...
        repmat({'All'},length(pBurst_lower_all.(alignmentEvent)),1);...
        repmat({'Individual'},length(pBurst_ind_all.(alignmentEvent)),1)];

laminarJASPdata.monkey = repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),5,1);

for alignmentIdx = 1:length(eventAlignments)
    % Get the event label
    alignmentEvent = eventAlignments{alignmentIdx};

    laminarJASPdata.(alignmentEvent) =...
        [pBurst_EEG.(alignmentEvent); pBurst_upper_all.(alignmentEvent);...
        pBurst_lower_all.(alignmentEvent);...
        pBurst_all_all.(alignmentEvent);...
        pBurst_ind_all.(alignmentEvent)];
end

laminarJASPdata = struct2table(laminarJASPdata);
writetable(laminarJASPdata,fullfile(rootDir,'results','jasp_tables','laminarJASPdata.csv'),'WriteRowNames',true)
%% Figure 1: p(burst) across epochs and layers
% Setup the figure in gramm
clear eeg_lfp_burst_epoch % Clear the figure from matlabs memory as we're writing it new

% Input data into the gramm library:
eeg_lfp_burst_epoch(1,1)= gramm('x',pBurst_combined_epoch,'y',pBurst_combined,'color',pBurst_combined_labels);
% Set the figure up as a point/line figure with 95% CI error bar:
eeg_lfp_burst_epoch(1,1).stat_summary('type','sem','geom',{'point','line','errorbar'});
% Set figure parameters:
eeg_lfp_burst_epoch(1,1).axe_property('YLim',[0.0 1.00]);
%... and print it!
figure('Renderer', 'painters', 'Position', [100 100 400 300]);
eeg_lfp_burst_epoch.draw();

% Figure Supp 1: Split by monkey
clear eeg_lfp_burst_epoch % Clear the figure from matlabs memory as we're writing it new
monkeyLabels_all = repmat(laminarJASPdata.monkey,length(eventAlignments),1);

% Input data into the gramm library:
eeg_lfp_burst_epoch(1,1)= gramm('x',pBurst_combined_epoch,'y',pBurst_combined,'color',pBurst_combined_labels,'subset',strcmp(monkeyLabels_all,'Euler'));
eeg_lfp_burst_epoch(1,2)= gramm('x',pBurst_combined_epoch,'y',pBurst_combined,'color',pBurst_combined_labels,'subset',strcmp(monkeyLabels_all,'Xena'));
% Set the figure up as a point/line figure with 95% CI error bar:
eeg_lfp_burst_epoch(1,1).stat_summary('geom',{'point','line','errorbar'});
eeg_lfp_burst_epoch(1,2).stat_summary('geom',{'point','line','errorbar'});
% Set figure parameters:
eeg_lfp_burst_epoch(1,1).axe_property('YLim',[0.0 1.00]);
eeg_lfp_burst_epoch(1,2).axe_property('YLim',[0.0 1.00]);
%... and print it!
figure('Renderer', 'painters', 'Position', [100 100 800 300]);
eeg_lfp_burst_epoch.draw();

