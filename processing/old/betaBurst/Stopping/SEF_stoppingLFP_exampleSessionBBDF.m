for lfpIdx = 26
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
        
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 696. \n',lfp);
    
    % Load in beta output data for session
    loadname = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    betaOutput = parload([outputDir loadname]);
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    % Calculate p(trials) with burst
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6);
    
    % Convolve and get density function
    SessionBDF = BetaBurstConvolver(betaOutput.burstData.burstTime);
    
    
    clear bbdf_canceled bbdf_noncanceled bbdf_nostop
    for trlIdx = 1:size(trials.canceled,1)
        trl = trials.canceled(trlIdx);
        bbdf_canceled{trlIdx,1} = SessionBDF(trl, :);
    end
    
    for trlIdx = 1:size(trials.noncanceled,1)
        trl = trials.noncanceled(trlIdx);
        bbdf_noncanceled{trlIdx,1} = SessionBDF(trl, :);
    end
    
    for trlIdx = 1:size(trials.nostop,1)
        trl = trials.nostop(trlIdx);
        bbdf_nostop{trlIdx,1} = SessionBDF(trl, :);
    end
    
    clear testfigure
    time = [-1000:2000];
    testfigure(1,1)=gramm('x',time,'y',[bbdf_canceled;...
        bbdf_nostop;bbdf_noncanceled],...
        'color',[repmat({'Canceled'},length(bbdf_canceled),1);...
        repmat({'No-stop'},length(bbdf_nostop),1);...
        repmat({'Non-canceled'},length(bbdf_noncanceled),1)]);
    testfigure(1,1).stat_summary();
    testfigure(1,1).axe_property('XLim',[-250 500]);
    testfigure(1,1).geom_vline('xintercept',0,'style','k-');
    testfigure(1,1).geom_vline('xintercept',mean(bayesianSSRT.ssrt_mean),'style','k--');
    testfigure(1,1).axe_property('YLim',[0.0000 0.0035]);
    testfigure(1,1).no_legend();
    
    testfigure.set_names('y','');
    testfigure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
    
    figure('Renderer', 'painters', 'Position', [100 100 350 350]);
    testfigure.draw();
end

