%% Get session details and parameters
getAnalysisParameters;
depth_micrometers = flipud([-1575:150:1125]');
plotDepth = linspace(1,19,19)*10;
perpendicularSessions = sessionInformation.session;


%% Extract LFP data & calculate power
% For each perpendicular session
for session = 14:29
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    
    % Load input data
    inputLFP = load(['C:\Users\Steven\Desktop\tempTEBA\dataRepo\2012_Cmand_EuX\rawData\' sessionName],...
        'AD1*','AD2*','AD3*','AD4*');
    
    % Get LFP channels recorded during session
    lfpChannels = fieldnames(inputLFP);
    
    % Find channels in grey matter
    cortexIdx = [sessionInformation.LFPRange(sessionInformation.session == session, 1)...
        : sessionInformation.LFPRange(sessionInformation.session == session, 2)];
    
    cortexLFP = lfpChannels(cortexIdx);
    
    % Assign each channel to the relevant depth, across sessions
    for ii = 1:length(cortexLFP)
        channelDepthMap{ii,session-13} = cortexLFP{ii};
    end
    
end

outputDir = [dataDir 'monkeyLFP\SEF\'];
save([outputDir 'channelDepthMap'],'channelDepthMap','-v7.3')