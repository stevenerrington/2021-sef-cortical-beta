%% Get beta burst information
dataDir = [matDir 'monkeyLFP\SEF\'];
clear burstTiming 

% For each session
for session = 14:29
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    filter = filterNames{5}; eventType = 3; eventLabel = eventNames{eventType};
    
    fprintf('Analysing beta-bursts on session number %i of 29. \n',session);
    fprintf(['...analysing data aligned on ' eventLabel '. \n']);
    
    
    % Get labels for cortical LFP's for session
    for channelIdx = 1:nChannels(session)
        % Load in betaInfo
        in_betaFilename = ['SEF_' filter 'Info_LFP' int2str(channelIdx) '_session' int2str(session) '_' eventLabel];
        clear betaBurst; load([dataDir 'betaBurst\'  in_betaFilename])
        burstTiming{session}.canceled(channelIdx,:) = SEF_stoppingEEG_getAverageBurstTimeLFP(session, executiveBeh.ttx_canc, betaBurst, bayesianSSRT);
        burstTiming{session}.noncanc(channelIdx,:) = SEF_stoppingEEG_getAverageBurstTimeLFP(session, executiveBeh.ttx.NC, betaBurst, bayesianSSRT);
        burstTiming{session}.nostop(channelIdx,:) = SEF_stoppingEEG_getAverageBurstTimeLFP(session, executiveBeh.ttx.GO, betaBurst, bayesianSSRT);
    end
end


%%
laminar_pTrlBurst = NaN(17,length([14:29]));

for session = 14:29
    laminar_pTrlBurst([1:length(burstTiming{session}.canceled.pTrials_burst)],...
        session - 13) = burstTiming{session}.canceled.pTrials_burst; 
end
  

Mean = nanmean(laminar_pTrlBurst,2);
SEM = nanstd(laminar_pTrlBurst,0,2)./sum(~isnan(laminar_pTrlBurst),2);

figureSpace = [5:5:5*17];

figure('Renderer', 'painters', 'Position', [100 100 300 275]);
errorbar(Mean,figureSpace,SEM,'horizontal','o')
set(gca, 'YDir','reverse'); xlim([0 0.2])
hline(8.5*5,'r-'); yticks([0:5:5*17]);
ylim([0 90])