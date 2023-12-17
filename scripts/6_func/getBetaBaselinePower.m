fullfile(dataDir,'lfp') = 'D:\projects\2021-sef-cortical-beta\data\lfp\';
% Load parameters for analysis
getAnalysisParameters; % Separate script holding all key parameters.
   

%% Extract Beta Bursts
tic
for eventType = [1]
    eventLabel = eventNames{eventType};
    alignmentParameters.eventN = eventType;
    fprintf(['Analysing data aligned on ' eventLabel '. \n']);
    
    %% Extract EEG data & calculate power
    parfor session = 1:29
        fprintf('...for session number %i of 29. \n',session);
        % Get session name (to load in relevant file)
        sessionName = FileNames{session};
        
        % Clear workspace
%         clear trials eventTimes inputLFP cleanLFP alignedLFP filteredLFP betaOutput morletLFP pTrl_burst
        
        % Setup key behavior variables
        ssrt = bayesianSSRT.ssrt_mean(session);
        eventTimes = executiveBeh.TrialEventTimes_Overall{session};

        % Load the LFP channels recorded for that session
        inputLFP = load(['D:\data\2012_Cmand_EuX\' sessionName '.mat'],...
            'AD1*','AD2*','AD3*','AD4*');
        
        lfpChannels = fieldnames(inputLFP);
        lfpPower_baseline = [];
        for k=1:numel(lfpChannels)
            if (isnumeric(inputLFP.(lfpChannels{k})))
%                 fprintf('Analysing LFP %d of %d... \n', k, numel(lfpChannels));
                
                filteredLFP = [];
                
                % Pre-process & filter analog data (EEG/LFP), and align on event
                filter = 'all';
                filterFreq = filterBands.(filter);
                [~, filteredLFP.(filter)] = tidyRawSignal(inputLFP.(lfpChannels{k}), ephysParameters, filterFreq,...
                    eventTimes, alignmentParameters);
          
                % (b) Convolve using Morlet Wave Transformation, calculate power, and determine
                % bursts in data (i.e. Wessel, 2020, JNeurosci)
                [morletLFP] = convMorletWaveform(filteredLFP.all,morletParameters);
                
                windowPower = []
                windowPower = morletLFP(:,1100:1600,:);
                lfpPower_baseline(k) = nanmedian(windowPower(:));
                
            end
        end
        lfpPowerSession_baseline{session} = lfpPower_baseline;
        
    end
end