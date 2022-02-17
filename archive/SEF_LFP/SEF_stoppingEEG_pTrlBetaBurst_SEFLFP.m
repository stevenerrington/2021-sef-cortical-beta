matDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\behavior\';
dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyLFP\SEF\';
load([matDir 'bayesianSSRT']); load([matDir 'executiveBeh']); load([matDir 'FileNames'])

%% Calculate proportion of trials with burst
count = 0;
for session = 14:29
    clear ssrt trials
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.NC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    
    for channelIdx = 1:nChannels(session)
        clear betaImport pTrl_burst
        fprintf('... on channel %i of %i \n',channelIdx,nChannels(session));
        
        count = count+1;
        % Load in beta output data for session
        load_betaFilename_target = ['betaBurst\SEF_betaInfo_LFP' int2str(channelIdx) '_session' int2str(session) '_target'];
        betaImport = parload([dataDir load_betaFilename_target]);
        
        % Calculate p(trials) with burst
        [pTrl_burst] = ssdBurstCount(betaTarget.betaBurst, ssrt, trials, session, executiveBeh);
        [pTrl_burst] = ssdBurstCount(betaSSD.betaBurst, ssrt, trials, session, executiveBeh);
        
        pBurstData.canc_baseline(count,:) = pTrl_burst.baseline.canceled;
        pBurstData.canc_ssd(count,:) = pTrl_burst.ssd.canceled;
        pBurstData.canc_ssrt(count,:) = pTrl_burst.ssrt.canceled;
        
        pBurstData.noncanc_baseline(count,:) = pTrl_burst.baseline.noncanc;
        pBurstData.noncanc_ssd(count,:) = pTrl_burst.ssd.noncanc;
        pBurstData.noncanc_ssrt(count,:) = pTrl_burst.ssrt.noncanc;
        
        pBurstData.nostop_baseline(count,:) = pTrl_burst.baseline.nostop;
        pBurstData.nostop_ssd(count,:) = pTrl_burst.ssd.nostop;
        pBurstData.nostop_ssrt(count,:) = pTrl_burst.ssrt.nostop;
        
    end
end


%%
clear pBurst_trialType

groupLabels = [repmat({'No-stop'},length(pBurstData.nostop_baseline),1);...
    repmat({'Non-canceled'},length(pBurstData.noncanc_baseline),1);...
    repmat({'Canceled'},length(pBurstData.canc_baseline),1);...
    repmat({'No-stop'},length(pBurstData.nostop_ssd),1);...
    repmat({'Non-canceled'},length(pBurstData.noncanc_ssd),1);...
    repmat({'Canceled'},length(pBurstData.canc_ssd),1)];



epochLabels = [repmat({'Baseline'},length(pBurstData.nostop_baseline)*3,1);...
    repmat({'post-SSD'},length(pBurstData.nostop_ssd)*3,1)];


burstData = [pBurstData.nostop_baseline; pBurstData.noncanc_baseline; pBurstData.canc_baseline;...
    pBurstData.nostop_ssd; pBurstData.noncanc_ssd; pBurstData.canc_ssd];

pBurst_trialType(1,1)= gramm('x',groupLabels,'y',burstData,'color',epochLabels);

% Bar Chart
pBurst_trialType(1,1).stat_summary('geom',{'bar','black_errorbar'},'type','sem');
pBurst_trialType(1,1).set_color_options('map','d3.schemePaired')

%These functions can be called on arrays of gramm objects
pBurst_trialType.set_names('x','Trial Type','y','p (burst | trial)');
pBurst_trialType.axe_property('YLim',[0 0.20]);

figure('Position',[100 100 400 300]);
pBurst_trialType.draw();

%% Export to JASP

BL_C = pBurstData.canc_baseline;
BL_NC = pBurstData.noncanc_baseline;
BL_NS = pBurstData.nostop_baseline;

SSD_C = pBurstData.canc_ssd;
SSD_NC = pBurstData.noncanc_ssd;
SSD_NS = pBurstData.nostop_ssd;

betaBurst_trialType = table(BL_C, BL_NC, BL_NS, SSD_C, SSD_NC, SSD_NS);

writetable(betaBurst_trialType,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\workingFolder\exportJASP\SEFLFP_pBurst_trlType.csv','WriteRowNames',true) 