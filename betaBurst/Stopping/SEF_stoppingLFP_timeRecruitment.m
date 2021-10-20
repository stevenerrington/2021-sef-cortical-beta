%% Calculate proportion of trials with burst (-200-SSRT to -200 ms pre-target)

timeWin = [-1000:2000]; zeroTime = abs(timeWin(1));

parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 509. \n',lfp);
    
    % Load in beta output data for session
    loadname_stopSignal = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    betaOutput_stopSignal = parload([outputDir loadname_stopSignal]);
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    % Calculate p(trials) with burst
    [betaOutput_stopSignal] = thresholdBursts(betaOutput_stopSignal.betaOutput, betaOutput_stopSignal.betaOutput.medianLFPpower*6)
    
    nTrls = size(betaOutput_stopSignal.burstData,1);
    burstTimeDensity_lfpIdx = zeros(nTrls,length(timeWin));
    
    for trl = 1:nTrls
        validBurst =[];
        validBurst = find(betaOutput_stopSignal.burstData.burstTime{trl} > 0 & ...
            betaOutput_stopSignal.burstData.burstTime{trl} < ssrt &...
             betaOutput_stopSignal.burstData.burstOnset{trl} > -1000 &...
             betaOutput_stopSignal.burstData.burstOffset{trl} < 1000);
        
        if ~isempty(validBurst)
            onsetTimes = []; offsetTimes = [];
            onsetTimes = betaOutput_stopSignal.burstData.burstOnset{trl}(validBurst);
            offsetTimes = betaOutput_stopSignal.burstData.burstOffset{trl}(validBurst);
            
            burstTimeDensity_lfpIdx(trl,min(onsetTimes)+zeroTime:max(offsetTimes)+zeroTime) = 1;
        end
    end
    
    burstTimeDensity_lfp{lfpIdx} = burstTimeDensity_lfpIdx;
    
end

pBurst_Density = [];
for lfpIdx = 1:length(corticalLFPcontacts.all)
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};

    pBurst_Density.canceled{lfpIdx} = nanmean(burstTimeDensity_lfp{lfpIdx}(trials.canceled,:));
    pBurst_Density.noncanceled{lfpIdx} = nanmean(burstTimeDensity_lfp{lfpIdx}(trials.noncanceled,:));
    pBurst_Density.nostop{lfpIdx} = nanmean(burstTimeDensity_lfp{lfpIdx}(trials.nostop,:));
end

%%

clear testfigure

% Fixation aligned
testfigure(1,1)=gramm('x',timeWin,'y',[pBurst_Density.canceled';...
    pBurst_Density.nostop';pBurst_Density.noncanceled'],...
    'color',[repmat({'Canceled'},length(pBurst_Density.canceled),1);...
    repmat({'No-stop'},length(pBurst_Density.nostop),1);...
    repmat({'Non-canceled'},length(pBurst_Density.noncanceled),1)]);

% GRAMM Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
testfigure(1,1).stat_summary();
testfigure(1,1).axe_property('XLim',[-1000 2000]);
testfigure(1,1).geom_vline('xintercept',0,'style','k-');
testfigure(1,1).axe_property('YLim',[0.0000 0.15]);
testfigure(1,1).no_legend();
testfigure(1,1).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 800 600]);
testfigure.draw();

