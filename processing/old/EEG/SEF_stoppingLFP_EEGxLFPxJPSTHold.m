

%% Reorganise parfor cells into structure
for sessionIdx = 1:29
    for alignmentIdx = 1:5
        alignmentEvent = eventAlignments{alignmentIdx};
        
        JPSTH_burstCounts.(alignmentEvent).EEG{sessionIdx} = burstCounts_EEG{alignmentIdx,sessionIdx};
        JPSTH_burstCounts.(alignmentEvent).LFP_raw{sessionIdx} = burstCounts_LFP_raw{alignmentIdx,sessionIdx};
        JPSTH_burstCounts.(alignmentEvent).LFP_all{sessionIdx} = burstCounts_LFP_all{alignmentIdx,sessionIdx};
        JPSTH_burstCounts.(alignmentEvent).LFP_upper{sessionIdx} = burstCounts_LFP_upper{alignmentIdx,sessionIdx};
        JPSTH_burstCounts.(alignmentEvent).LFP_lower{sessionIdx} = burstCounts_LFP_lower{alignmentIdx,sessionIdx};
    end
end

% Saved -> Output for JPSTH



%% Run JPSTH Analysis
warning off

for sessionIdx = 1:29
    fprintf('Running JPSTH code for session %i of %i. \n', sessionIdx, 29)
    for alignmentIdx = 1:5
        alignmentEvent = eventAlignments{alignmentIdx};
        binSize = eventBin{alignmentIdx};
        
        % All contacts/EEG
        jspthAnalysis.(alignmentEvent).all{sessionIdx} =...
            jpsth(JPSTH_burstCounts.(alignmentEvent).EEG{sessionIdx},...
            JPSTH_burstCounts.(alignmentEvent).LFP_all{sessionIdx}, binSize);
        
        if sessionIdx > 13
            % Upper layer contacts/EEG
            jspthAnalysis.(alignmentEvent).upper{sessionIdx} =...
                jpsth(JPSTH_burstCounts.(alignmentEvent).EEG{sessionIdx},...
                JPSTH_burstCounts.(alignmentEvent).LFP_upper{sessionIdx}, binSize);
            
            % Lower layer contacts/EEG
            jspthAnalysis.(alignmentEvent).lower{sessionIdx} =...
                jpsth(JPSTH_burstCounts.(alignmentEvent).EEG{sessionIdx},...
                JPSTH_burstCounts.(alignmentEvent).LFP_lower{sessionIdx}, binSize);
            
            % Upper/lower layer contacts
            jspthAnalysis.(alignmentEvent).inter{sessionIdx} =...
                jpsth(JPSTH_burstCounts.(alignmentEvent).LFP_upper{sessionIdx},...
                JPSTH_burstCounts.(alignmentEvent).LFP_lower{sessionIdx}, binSize);
        end
    end
end

%% Get session averages

for sessionIdx = 1:29
    for alignmentIdx = 1:5
        alignmentEvent = eventAlignments{alignmentIdx};

        jpsthSession.(alignmentEvent).matrix(:,:,sessionIdx) = jspthAnalysis.(alignmentEvent).all{sessionIdx}.unnormalizedJPSTH;
        jpsthSession.(alignmentEvent).xCorr(sessionIdx,:) = jspthAnalysis.(alignmentEvent).all{sessionIdx}.xcorrHist;
        jpsthSession.(alignmentEvent).psth1(sessionIdx,:) = jspthAnalysis.(alignmentEvent).all{sessionIdx}.psth_1;
        jpsthSession.(alignmentEvent).psth2(sessionIdx,:) = jspthAnalysis.(alignmentEvent).all{sessionIdx}.psth_2;
        jpsthSession.(alignmentEvent).psthAll(sessionIdx,:) = jspthAnalysis.(alignmentEvent).all{sessionIdx}.pstch;
        jpsthSession.(alignmentEvent).covar(sessionIdx,:) = jspthAnalysis.(alignmentEvent).all{sessionIdx}.covariogram;
        jpsthSession.(alignmentEvent).sigLow(sessionIdx,:) = jspthAnalysis.(alignmentEvent).all{sessionIdx}.sigLow;
        jpsthSession.(alignmentEvent).sigHigh(sessionIdx,:) = jspthAnalysis.(alignmentEvent).all{sessionIdx}.sigHigh;
    end
    
end


%% Figure generation

%%% ALL SESSIONS/GROUPED BY MONKEY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sessionComparisons = {1:29,executiveBeh.nhpSessions.EuSessions,executiveBeh.nhpSessions.XSessions};
sessionLabels = {'all','monkeyEu','monkeyX'};

for figIdx = 1:length(sessionComparisons)
    inputSessions = sessionComparisons{figIdx};
    fig = figure('Renderer', 'painters', 'Position', [100 100 1200 800]);
    for alignmentIdx = 1:4
        alignmentEvent = eventAlignments{alignmentIdx};
        window = eventWindows{alignmentIdx}; binSize = eventBin{alignmentIdx};
        clear times; times = window(1)+(binSize/2):binSize:window(2)-(binSize/2);
        
        subplot(5,4,alignmentIdx)
        area(times, nanmean(jpsthSession.(alignmentEvent).psth1(inputSessions,:)),'LineStyle','None')
        xlim([times(1) times(end)])
        title(alignmentEvent)
        
        subplot(5,4,4+alignmentIdx)
        area(times, nanmean(jpsthSession.(alignmentEvent).psth2(inputSessions,:)),'LineStyle','None')
        xlim([times(1) times(end)])
        
        subplot(5,4,[8+alignmentIdx 12+alignmentIdx])
        imagesc('XData',times,'YData',times,'CData',nanmean(jpsthSession.(alignmentEvent).matrix(:,:,inputSessions),3))
        xlim([times(1) times(end)]); ylim([times(1) times(end)])
        vline(0,'k'); hline(0,'k');
        colorbar('southoutside')
        
        subplot(5,4,16+alignmentIdx)
        area(times, nanmean(jpsthSession.(alignmentEvent).psthAll(inputSessions,:)),'LineStyle','None')
        xlim([times(1) times(end)]);
        
        %     % Cut - not sure if this is the needed adjustment
        %     subplot(5,4,16+alignmentIdx)
        %     area(times(2:end), diff(nanmean(jpsthSession.(alignmentEvent).psthAll(inputSessions,:))),'LineStyle','None')
        %     xlim([times(1) times(end)]); ylim([-0.25 1])
        
    end
    
    filename = ['C:\Users\Steven\Desktop\JPSTH output\jpsth_collapsed_unnormalised_' sessionLabels{figIdx} '.pdf'];
    set(fig,'Units','Inches');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(fig,filename,'-dpdf','-r0')
    close all
end

%%% INDIVIDUAL SESSION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for sessionIdx = 1:29
    fig = figure('Renderer', 'painters', 'Position', [100 100 1200 800]);
    for alignmentIdx = 1:4
        alignmentEvent = eventAlignments{alignmentIdx};
        window = eventWindows{alignmentIdx}; binSize = eventBin{alignmentIdx};
        clear times; times = window(1)+(binSize/2):binSize:window(2)-(binSize/2);
        
        subplot(5,4,alignmentIdx)
        area(times, jpsthSession.(alignmentEvent).psth1(sessionIdx,:),'LineStyle','None')
        xlim([times(1) times(end)])
        title(alignmentEvent)
        
        subplot(5,4,4+alignmentIdx)
        area(times, jpsthSession.(alignmentEvent).psth2(sessionIdx,:),'LineStyle','None')
        xlim([times(1) times(end)])
        
        subplot(5,4,[8+alignmentIdx 12+alignmentIdx])
        imagesc('XData',times,'YData',times,'CData',jpsthSession.(alignmentEvent).matrix(:,:,sessionIdx))
        xlim([times(1) times(end)]); ylim([times(1) times(end)])
        vline(0,'k'); hline(0,'k');
        colorbar('southoutside')
        
        subplot(5,4,16+alignmentIdx)
        area(times, jpsthSession.(alignmentEvent).psthAll(sessionIdx,:),'LineStyle','None')
        xlim([times(1) times(end)]);
        
        %     % Cut - not sure if this is the needed adjustment
        %     subplot(5,4,16+alignmentIdx)
        %     area(times(2:end), diff(nanmean(jpsthSession.(alignmentEvent).psthAll(inputSessions,:))),'LineStyle','None')
        %     xlim([times(1) times(end)]); ylim([-0.25 1])
        
    end
    
    filename = ['C:\Users\Steven\Desktop\JPSTH output\jpsth_collapsed_unnormalised_session' int2str(sessionIdx) '.pdf'];
    set(fig,'Units','Inches');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(fig,filename,'-dpdf','-r0')
    close all
end
