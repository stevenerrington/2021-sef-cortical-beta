%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
analysisWindows = {[-400:-200],[400:600],[400:600],[-400:-200]};
eventBin = {1,1,1,1,1};
jpsthBin = 50;
loadDir = 'D:\projectCode\2021-sef-cortical-beta\data\eeg_lfp\';
printFigFlag = 0;
binSize = 1;
warning off
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
        
        jpsthBinEdge = 0:jpsthBin:max(eventWindows{alignmentIdx})+alignmentZero;
        
        eeg_in = []; lfp_in = [];
        
        for binIdx = 1:length(jpsthBinEdge)-1
            for trlIdx = 1:size(eeg_lfp_burst.EEG{1, 1},1)
                eeg_in(trlIdx,binIdx) =...
                    sum(eeg_lfp_burst.EEG{1, 1}...
                    (trlIdx,jpsthBinEdge(binIdx)+1:jpsthBinEdge(binIdx+1)));
            end
        end
        
        for lfpIdx = 1:size(eeg_lfp_burst.LFP{1,1},3)
            for binIdx = 1:length(jpsthBinEdge)-1
                for trlIdx = 1:size(eeg_lfp_burst.EEG{1, 1},1)
                    lfp_in(trlIdx,binIdx,lfpIdx) =...
                        sum(eeg_lfp_burst.LFP{1, 1}...
                        (trlIdx,jpsthBinEdge(binIdx)+1:jpsthBinEdge(binIdx+1),lfpIdx));
                end
            end
        end
        
        for lfpIdx = 1:size(eeg_lfp_burst.LFP{1,1},3)
            jspthAnalysis.(alignmentEvent){sessionIdx,lfpIdx} =...
                jpsth(eeg_in,lfp_in(:,:,lfpIdx), jpsthBin);
        end
        
        
        
    end
end

%%

jpsth_xLFP_jpsth = struct();
jpsth_xEEG_psth = struct();
jpsth_xLFP_psth = struct();
jpsth_EEGxLFP_pstch = struct();
jpsth_EEGxLFP_xcorr = struct();
jpsth_EEGxLFP_xcovar = struct();
jpsth_EEGxLFP_sigHigh = struct();
jpsth_EEGxLFP_sigLow = struct();

count = 0;

for sessionIdx = 1:29
    % Get the admin/details
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    nLFP = max(find(~cellfun(@isempty,jspthAnalysis.target(sessionIdx,:))));
   % ... and for each epoch of interest
    
    for lfpIdx = 1:nLFP
            count = count + 1;
        
        for alignmentIdx = 1:4
            % Get the desired alignment
            alignmentEvent = eventAlignments{alignmentIdx};
            
            jpsthBinEdge_plot{sessionIdx,alignmentIdx} = 0:jpsthBin:max(eventWindows{alignmentIdx})+alignmentZero;
            
            jpsth_xLFP_jpsth.(alignmentEvent)(:,:,count) = jspthAnalysis.(alignmentEvent){sessionIdx,lfpIdx}.normalizedJPSTH;
            jpsth_xEEG_psth.(alignmentEvent)(sessionIdx,:) = jspthAnalysis.(alignmentEvent){sessionIdx,lfpIdx}.psth_1;
            jpsth_xLFP_psth.(alignmentEvent)(count,:) = jspthAnalysis.(alignmentEvent){sessionIdx,lfpIdx}.psth_2;
            jpsth_EEGxLFP_pstch.(alignmentEvent)(count,:) = jspthAnalysis.(alignmentEvent){sessionIdx,lfpIdx}.pstch;
            jpsth_EEGxLFP_xcorr.(alignmentEvent)(count,:) = jspthAnalysis.(alignmentEvent){sessionIdx,lfpIdx}.xcorrHist;
            jpsth_EEGxLFP_xcovar.(alignmentEvent)(count,:) = jspthAnalysis.(alignmentEvent){sessionIdx,lfpIdx}.covariogram;
            jpsth_EEGxLFP_sigHigh.(alignmentEvent){count,:} = jspthAnalysis.(alignmentEvent){sessionIdx,lfpIdx}.sigPeakEndpoints;
            jpsth_EEGxLFP_sigLow.(alignmentEvent){count,:} = jspthAnalysis.(alignmentEvent){sessionIdx,lfpIdx}.sigTroughEndpoints;
        end
    end
end


%%
corticalLayerLabels = {'Upper','Lower'};

for layerIdx = 1:length(corticalLayerLabels)
    
    inputSessions = 14:29;
    inputContacts = [];
    
    if strcmp(corticalLayerLabels{layerIdx}, 'Upper')
        inputContacts = find(corticalLFPmap.session >= 14 &...
            corticalLFPmap.depth <= 8);
    else
        inputContacts = find(corticalLFPmap.session >= 14 &...
            corticalLFPmap.depth > 8);
    end
    
    figure('Renderer', 'painters', 'Position', [100 100 1200 800]);
    
    
    for alignmentIdx = 1:4
        alignmentEvent = eventAlignments{alignmentIdx};
        alignmentZero = abs(eeg_lfp_burst.eventWindows{alignmentIdx}(1));
        
        
        ax = subplot(6,4,[alignmentIdx alignmentIdx+4]); hold on
        imagesc(jpsthBinEdge_plot{29,alignmentIdx}-alignmentZero,...
            jpsthBinEdge_plot{29,alignmentIdx}-alignmentZero,...
            nanmean(jpsth_xLFP_jpsth.(alignmentEvent)(:,:,inputContacts),3))
        plot(jpsthBinEdge_plot{29,alignmentIdx}-alignmentZero, jpsthBinEdge_plot{29,alignmentIdx}-alignmentZero, 'k--')
        minXY = min(jpsthBinEdge_plot{29,alignmentIdx}-alignmentZero);
        maxXY = max(jpsthBinEdge_plot{29,alignmentIdx}-alignmentZero);
        set(gca,'XLim',[minXY maxXY],'YLim',[minXY maxXY],'YDir','normal')
        vline(0,'k'); hline(0,'k')
        
        colormap(turbo)
        caxis([0 0.10])
        
        ax = subplot(6,4,[alignmentIdx+8]); hold on
        area(nanmean(jpsth_xEEG_psth.(alignmentEvent)(inputSessions,:)))
        set(ax,'XLim',[1 length(jpsthBinEdge)-1])
        set(ax,'YLim',[0 0.075])
        
        ax = subplot(6,4,[alignmentIdx+12]); hold on
        area(nanmean(jpsth_xLFP_psth.(alignmentEvent)(inputContacts,:)))
        set(ax,'XLim',[1 length(jpsthBinEdge)-1])
        set(ax,'YLim',[0 0.075])
        
        ax = subplot(6,4,[alignmentIdx+16]); hold on
        plot(nanmean(jpsth_EEGxLFP_pstch.(alignmentEvent)(inputContacts,:)))
        set(ax,'XLim',[1 length(jpsthBinEdge)-1])
        set(ax,'YLim',[0 0.075])
        
        ax = subplot(6,4,[alignmentIdx+20]); hold on
        plot(nanmean(jpsth_EEGxLFP_xcovar.(alignmentEvent)(inputContacts,:)))
        %     set(ax,'XLim',[1 length(jpsthBinEdge)-1])
        set(ax,'YLim',[0 0.075])
        
    end
            title(corticalLayerLabels{layerIdx})

    
    
end



