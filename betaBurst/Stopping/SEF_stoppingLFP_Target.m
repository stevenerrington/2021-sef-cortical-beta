%% Calculate proportion of trials with burst
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    % Load in beta output data for session
    loadname = ['betaBurst\target\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target'];
    betaOutput = parload([outputDir loadname])
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    % Calculate p(trials) with burst
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.medianLFPpower*6)
    
    % Convolve and get density function
    SessionBDF = BetaBurstConvolver(betaOutput.burstData.burstTime);
    
    target_bbdf_canceled{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttx_canc{session}, :));
    target_bbdf_noncanceled{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttx.sNC{session}, :));
    target_bbdf_nostop{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttx.GO{session}, :));

end

clear inputContacts
inputContacts = 1:length(corticalLFPcontacts.all);

% % BBDF
testfigure(1,1)=gramm('x',time,'y',[target_bbdf_canceled(inputContacts);...
    target_bbdf_nostop(inputContacts);...
    target_bbdf_noncanceled(inputContacts)],...
    'color',[repmat({'Canceled'},length(inputContacts),1);...
    repmat({'No-stop'},length(inputContacts),1);...
    repmat({'Non-canceled'},length(inputContacts),1)]); 
testfigure(1,1).stat_summary();
testfigure(1,1).axe_property('XLim',[-250 750]); 
testfigure(1,1).geom_vline('xintercept',0,'style','k-')
testfigure(1,1).axe_property('YLim',[0.0000 0.0020]);
testfigure(1,1).no_legend();

testfigure.set_names('y','');
testfigure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 350 350]);
testfigure.draw();
