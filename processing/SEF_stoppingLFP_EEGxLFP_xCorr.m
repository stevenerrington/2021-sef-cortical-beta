%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
eventData_EEG = {EEGbbdf_canceled_fix,EEGbbdf_noncanceled_saccade,EEGbbdf_canceled_ssd,EEGbbdf_canceled_tone};
eventData_EEGshuffled = {shuffledEEGbbdf_canceled_fix,shuffledEEGbbdf_noncanceled_saccade,shuffledEEGbbdf_canceled_ssd,shuffledEEGbbdf_canceled_tone};
eventData_LFP = {LFPbbdf_canceled_fix,LFPbbdf_noncanceled_saccade,LFPbbdf_canceled_ssd,LFPbbdf_canceled_tone};
eventData_LFPshuffled = {shuffledLFPbbdf_canceled_fix,shuffledLFPbbdf_noncanceled_saccade,shuffledLFPbbdf_canceled_ssd,shuffledLFPbbdf_canceled_tone};
analysisWindows = {[-400:-200],[400:600],[400:600],[-400:-200]};
eventBin = {1,1,1,1,1};
loadDir = 'D:\projectCode\project_stoppingLFP\data\eeg_lfp\';
printFigFlag = 0;

clear xcorr_out xcorr_plot

%% Extract data from files
% For each session
for sessionIdx = 14:29
    % Get the admin/details
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    
    sessionLFPidx_upper = []; sessionLFPidx_lower = [];
    sessionLFPidx_upper = find(corticalLFPmap.session == session &...
        corticalLFPmap.depth <= 8);
    sessionLFPidx_lower = find(corticalLFPmap.session == session &...
        corticalLFPmap.depth > 8);
    
    
    % ... and for each epoch of interest
    for alignmentIdx = 1:4
        % Get the desired alignment
        alignmentEvent = eventAlignments{alignmentIdx};
        alignmentWindow = [];
        alignmentWindow = [eventWindows{alignmentIdx}(1):eventWindows{alignmentIdx}(end)]+1000;
        
        % Initialise array and data
        align_bbdfData_EEG = {}; align_bbdfData_EEG = eventData_EEG{alignmentIdx};
        align_bbdfData_LFP = {}; align_bbdfData_LFP = eventData_LFP{alignmentIdx};
        align_bbdfData_EEGshuffled = {}; align_bbdfData_EEGshuffled = eventData_EEGshuffled{alignmentIdx};
        align_bbdfData_LFPshuffled = {}; align_bbdfData_LFPshuffled = eventData_LFPshuffled{alignmentIdx};
        
        % Regular %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        % Get BBDF
        xcorr_out.(alignmentEvent).bbdf.eeg(sessionIdx-13,:) = align_bbdfData_EEG{session};
        xcorr_out.(alignmentEvent).bbdf.upper(sessionIdx-13,:) = nanmean(cell2mat(align_bbdfData_LFP(sessionLFPidx_upper)));
        xcorr_out.(alignmentEvent).bbdf.lower(sessionIdx-13,:) = nanmean(cell2mat(align_bbdfData_LFP(sessionLFPidx_lower)));

        % EEG x Upper X-corr
        [xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:),...
            xcorr_out.(alignmentEvent).lag.eeg_upper(sessionIdx-13,:)] =...
            xcorr(xcorr_out.(alignmentEvent).bbdf.eeg(sessionIdx-13,alignmentWindow),...
            xcorr_out.(alignmentEvent).bbdf.upper(sessionIdx-13,alignmentWindow),...
            'none');

        % EEG x Lower X-corr        
        [xcorr_out.(alignmentEvent).analysis.eeg_lower(sessionIdx-13,:),...
            xcorr_out.(alignmentEvent).lag.eeg_lower(sessionIdx-13,:)] =...
            xcorr(xcorr_out.(alignmentEvent).bbdf.eeg(sessionIdx-13,alignmentWindow),...
            xcorr_out.(alignmentEvent).bbdf.lower(sessionIdx-13,alignmentWindow),...
            'none');
        
        % Upper x Lower X-corr        
        [xcorr_out.(alignmentEvent).analysis.upper_lower(sessionIdx-13,:),...
            xcorr_out.(alignmentEvent).lag.upper_lower(sessionIdx-13,:)] =...
            xcorr(xcorr_out.(alignmentEvent).bbdf.upper(sessionIdx-13,alignmentWindow),...
            xcorr_out.(alignmentEvent).bbdf.lower(sessionIdx-13,alignmentWindow),...
            'none');
        
        % Shuffled %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        xcorr_out.(alignmentEvent).bbdf.shuffled_eeg(sessionIdx-13,:) = align_bbdfData_EEGshuffled{session};
        xcorr_out.(alignmentEvent).bbdf.shuffled_upper(sessionIdx-13,:) = nanmean(cell2mat(align_bbdfData_LFPshuffled(sessionLFPidx_upper)));
        xcorr_out.(alignmentEvent).bbdf.shuffled_lower(sessionIdx-13,:) = nanmean(cell2mat(align_bbdfData_LFPshuffled(sessionLFPidx_lower)));
        
        % EEG x Upper X-corr
        [xcorr_out.(alignmentEvent).analysis.shuffled_eeg_upper(sessionIdx-13,:),...
            xcorr_out.(alignmentEvent).lag.shuffled_eeg_upper(sessionIdx-13,:)] =...
            xcorr(xcorr_out.(alignmentEvent).bbdf.shuffled_eeg(sessionIdx-13,alignmentWindow),...
            xcorr_out.(alignmentEvent).bbdf.shuffled_upper(sessionIdx-13,alignmentWindow),...
            'none');

        % EEG x Lower X-corr        
        [xcorr_out.(alignmentEvent).analysis.shuffled_eeg_lower(sessionIdx-13,:),...
            xcorr_out.(alignmentEvent).lag.shuffled_eeg_lower(sessionIdx-13,:)] =...
            xcorr(xcorr_out.(alignmentEvent).bbdf.shuffled_eeg(sessionIdx-13,alignmentWindow),...
            xcorr_out.(alignmentEvent).bbdf.shuffled_lower(sessionIdx-13,alignmentWindow),...
            'none');
        
        % Upper x Lower X-corr        
        [xcorr_out.(alignmentEvent).analysis.shuffled_upper_lower(sessionIdx-13,:),...
            xcorr_out.(alignmentEvent).lag.shuffled_upper_lower(sessionIdx-13,:)] =...
            xcorr(xcorr_out.(alignmentEvent).bbdf.shuffled_upper(sessionIdx-13,alignmentWindow),...
            xcorr_out.(alignmentEvent).bbdf.shuffled_lower(sessionIdx-13,alignmentWindow),...
            'none');
        
    end
    
end

%%
for sessionIdx = 14:29
    for alignmentIdx = 1:3
        alignmentEvent = eventAlignments{alignmentIdx};
        
        % BBDF
        xcorr_plot.(alignmentEvent).bbdf_eeg{sessionIdx-13,:} = ...
            xcorr_out.(alignmentEvent).bbdf.eeg(sessionIdx-13,:);
        xcorr_plot.(alignmentEvent).bbdf_upper{sessionIdx-13,:} = ...
            xcorr_out.(alignmentEvent).bbdf.upper(sessionIdx-13,:);
        xcorr_plot.(alignmentEvent).bbdf_lower{sessionIdx-13,:} = ...
            xcorr_out.(alignmentEvent).bbdf.lower(sessionIdx-13,:);
        
        
        % Cross-correlation
        xcorr_plot.(alignmentEvent).xcorr_eeg_upper{sessionIdx-13,:} = ...
            xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:)-...
            xcorr_out.(alignmentEvent).analysis.shuffled_eeg_upper(sessionIdx-13,:);
        
        
        xcorr_plot.(alignmentEvent).xcorr_eeg_lower{sessionIdx-13,:} = ...
            xcorr_out.(alignmentEvent).analysis.eeg_lower(sessionIdx-13,:)-...
            xcorr_out.(alignmentEvent).analysis.shuffled_eeg_lower(sessionIdx-13,:);
        
        
        xcorr_plot.(alignmentEvent).xcorr_upper_lower{sessionIdx-13,:} = ...
            xcorr_out.(alignmentEvent).analysis.upper_lower(sessionIdx-13,:)-...
            xcorr_out.(alignmentEvent).analysis.shuffled_upper_lower(sessionIdx-13,:);
        
        % Find max
        if max(xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:)) == 0 | ...
                max(xcorr_out.(alignmentEvent).analysis.eeg_lower(sessionIdx-13,:)) == 0| ...
                max(xcorr_out.(alignmentEvent).analysis.upper_lower(sessionIdx-13,:)) == 0
            
            xcorr_out.(alignmentEvent).max.eeg_upper(sessionIdx-13,1) = NaN;
            xcorr_out.(alignmentEvent).max.eeg_lower(sessionIdx-13,1) = NaN;
            xcorr_out.(alignmentEvent).max.upper_lower(sessionIdx-13,1) = NaN;
            
        else
            xcorr_out.(alignmentEvent).max.eeg_upper(sessionIdx-13,1) = ...
                xcorr_out.(alignmentEvent).lag.eeg_upper(sessionIdx-13,...
                (xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:)...
                == max(xcorr_out.(alignmentEvent).analysis.eeg_upper(sessionIdx-13,:))));
            
            xcorr_out.(alignmentEvent).max.eeg_lower(sessionIdx-13,1) = ...
                xcorr_out.(alignmentEvent).lag.eeg_lower(sessionIdx-13,...
                (xcorr_out.(alignmentEvent).analysis.eeg_lower(sessionIdx-13,:)...
                == max(xcorr_out.(alignmentEvent).analysis.eeg_lower(sessionIdx-13,:))));
            
            xcorr_out.(alignmentEvent).max.upper_lower(sessionIdx-13,1) = ...
                xcorr_out.(alignmentEvent).lag.upper_lower(sessionIdx-13,...
                (xcorr_out.(alignmentEvent).analysis.upper_lower(sessionIdx-13,:)...
                == max(xcorr_out.(alignmentEvent).analysis.upper_lower(sessionIdx-13,:))));
        end
        
        
    end
end

%%

clear test
for alignmentIdx = 1:3
    alignmentEvent = eventAlignments{alignmentIdx};
    clear inputData inputLabels
    
    inputData = [xcorr_plot.(alignmentEvent).xcorr_eeg_upper; xcorr_plot.(alignmentEvent).xcorr_eeg_lower; xcorr_plot.(alignmentEvent).xcorr_upper_lower];
    inputLabels = [repmat({'1 EEG_Upper'}, length(xcorr_plot.(alignmentEvent).xcorr_eeg_upper),1);...
        repmat({'2 EEG Lower'}, length(xcorr_plot.(alignmentEvent).xcorr_eeg_lower),1);...
        repmat({'3 Upper Lower'}, length(xcorr_plot.(alignmentEvent).xcorr_upper_lower),1)];
    
    test(1,alignmentIdx)=gramm('x', xcorr_out.(alignmentEvent).lag.eeg_upper(1,:),...
        'y',inputData,'color',inputLabels);
    
    test(1,alignmentIdx).geom_line('alpha',0.10);    
    test(1,alignmentIdx).stat_summary();
    
end

figure('Renderer', 'painters', 'Position', [100 100 1200 300]);
test.draw();

%% 


clear test
for alignmentIdx = 1:3
    alignmentEvent = eventAlignments{alignmentIdx};
    clear inputData inputLabels
    
    inputData = [xcorr_out.(alignmentEvent).max.eeg_upper; xcorr_out.(alignmentEvent).max.eeg_lower; xcorr_out.(alignmentEvent).max.upper_lower];
    inputLabels = [repmat({'1 EEG_Upper'}, length(xcorr_out.(alignmentEvent).max.eeg_upper),1);...
        repmat({'2 EEG Lower'}, length(xcorr_out.(alignmentEvent).max.eeg_lower),1);...
        repmat({'3 Upper Lower'}, length(xcorr_out.(alignmentEvent).max.upper_lower),1)];
    
    test(1,alignmentIdx)=gramm('x',inputData,'color',inputLabels);
    
    test(1,alignmentIdx).geom_raster();
    test(1,alignmentIdx).axe_property('XLim',[-600 600]);
    
end

figure('Renderer', 'painters', 'Position', [100 100 1200 300]);
test.draw();

