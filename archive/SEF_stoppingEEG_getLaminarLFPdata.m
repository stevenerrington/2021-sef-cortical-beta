%% Get session details and parameters
getAnalysisParameters;

%% Filter each channel in cortex at the desired band.
load('C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyLFP\SEF\channelDepthMap.mat')
load('C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyLFP\SEF\channelLabels.mat')
outputDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyLFP\SEF\';


% For each session
for session = 14:29
    
    clear eventTimes corticalLFP_labels inputLFP
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    eventTimes = executiveBeh.TrialEventTimes_Overall{session};
    
    % Get labels for cortical LFP's for session
    corticalLFP_labels = channelDepthMap(:,session-13);
    emptyIdx = cellfun(@isempty,corticalLFP_labels);
    corticalLFP_labels(emptyIdx) = [];
    
    % Load input data
    inputLFP = load(['C:\Users\Steven\Desktop\tempTEBA\dataRepo\2012_Cmand_EuX\rawData\' sessionName],...
        'AD1*','AD2*','AD3*','AD4*');
    
    % For each filter band
    for filterIdx = 5 % beta (5) all Gamma (8)
        filter = filterNames{filterIdx};
        filterFreq = filterBands.(filter);
        fprintf(['  ...analysing ' filter ' activity. \n']);
        
        for eventIdx = [2, 3, 4] % target, stop-signal, saccade
            eventLabel = eventNames{eventIdx};
            alignmentParameters.eventN = eventIdx;
            fprintf(['  ....aligned on ' event '. \n']);
            
            % For each channel in the cortex
            parfor ii = 1:length(corticalLFP_labels)
                fprintf('  ....analysing cortical channel number %i of %i. \n',ii,length(corticalLFP_labels));
                
                filteredLFP = []; morletLFP = []; channelLFP = [];
                
                % Get channel label
                LFPidx = corticalLFP_labels{ii,:};
                depthlabel = ['corticalDepth_' int2str(ii)];
                channelLFP = inputLFP.(LFPidx);
                
                % Aligned filtered data
                [~, filteredLFP] = tidyRawSignal(channelLFP, ephysParameters, filterFreq,...
                    eventTimes, alignmentParameters);
                
                [morletLFP] = convMorletWaveform(filteredLFP,morletParameters);
                
                % Save the output and clear for the next session
                outputDir = [matDir 'monkeyLFP\SEF\'];
                out_lfpFilename = ['SEF_' filter 'LFP' int2str(ii) '_session' int2str(session) '_' eventLabel];
                out_powerFilename = ['SEF_' filter 'LFP' int2str(ii) '_session' int2str(session) '_' eventLabel '_morlet'];
                
                parsave_filtered([outputDir 'filtered\' out_lfpFilename],filteredLFP)
                parsave_morlet([outputDir 'morletLFP\'  out_powerFilename],morletLFP)
                
            end
        end
    end
end


%% Get median LFP power for a given session

for session = 14:29
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('...analysing beta-power on session number %i of 29. \n',session);
    
    for filterIdx = 5 % beta (5) all Gamma (8)
        filter = filterNames{filterIdx};
        filterFreq = filterBands.(filter);
        fprintf(['  ...analysing ' filter ' activity. \n']);
        clear medianLFPpower_event
        
        % For each event alignment
        for eventType = [2, 3, 4]
            % Get the event name
            eventLabel = eventNames{eventType};
            fprintf(['....aligned on ' eventLabel '. \n']);
            clear medianLFPpower_channel
            
            % Get labels for cortical LFP's for session
            parfor channelIdx = 1:nChannels(session)
                fprintf('.....from channel %i of %i. \n',channelIdx, nChannels(session));
                morletLFP = [];
                
                % Load in morlet transformed data for the given session
                powerFilename = ['SEF_' filter 'LFP' int2str(channelIdx) '_session' int2str(session) '_' eventLabel '_morlet'];
                morletLFP = parload_morlet([dataDir 'morletLFP\'  powerFilename],'morletLFP');
                
                medianLFPpower_channel(channelIdx,1) = nanmedian(morletLFP(:));
            end
            medianLFPpower_event(eventType,1) = nanmedian(medianLFPpower_channel(medianLFPpower_channel > 0,:));
        end
    end
    medianLFPpower_session(session,1) = nanmedian(medianLFPpower_event(medianLFPpower_event > 0,:));
    
end


%% Get beta burst information
dataDir = [matDir 'monkeyLFP\SEF\'];

% For each session
for session = 14:29
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing beta-bursts on session number %i of 29. \n',session);
    filter = filterNames{5};
    filterFreq = filterBands.(filter);
    
    % For each event alignment
    for eventType = [2, 3, 4]
        % Get the event name
        eventLabel = eventNames{eventType};
        fprintf(['...analysing data aligned on ' eventLabel '. \n']);
        
        % Get labels for cortical LFP's for session
        parfor channelIdx = 1:nChannels(session)
            % Load in morlet transformed data for the given session
            powerFilename = ['SEF_' filter 'LFP' int2str(channelIdx) '_session' int2str(session) '_' eventLabel '_morlet'];
            morletLFP = []; morletLFP = parload_morlet([dataDir 'morletLFP\'  powerFilename],'morletLFP');
            
            % Run script to get beta burst information
            [betaBurst] = betaBurstCount_LFP(morletLFP, morletParameters,medianLFPpower_session(session));
            
            % Save output for the given channel (for file size more than
            % anything)
            out_betaFilename = ['SEF_' filter 'Info_LFP' int2str(channelIdx) '_session' int2str(session) '_' eventLabel];
            parsave_betaburst([dataDir 'betaBurst\'  out_betaFilename],betaBurst)
            
        end
    end
end



