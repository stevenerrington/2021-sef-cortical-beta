outputDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingLFP\data\monkeyLFP\';
% Load parameters for analysis
getAnalysisParameters; % Separate script holding all key parameters.
   

%% Extract Beta Bursts
tic
for eventType = [6]
    eventLabel = eventNames{eventType};
    alignmentParameters.eventN = eventType;
    fprintf(['Analysing data aligned on ' eventLabel '. \n']);
    
    %% Extract EEG data & calculate power
    for session = 1:29
        fprintf('...extracting beta on session number %i of 29. \n',session);
        % Get session name (to load in relevant file)
        sessionName = FileNames{session};
        
        % Clear workspace
%         clear trials eventTimes inputLFP cleanLFP alignedLFP filteredLFP betaOutput morletLFP pTrl_burst
        
        % Setup key behavior variables
        ssrt = bayesianSSRT.ssrt_mean(session);
        eventTimes = executiveBeh.TrialEventTimes_Overall{session};

        % Load the LFP channels recorded for that session
        fprintf('Analysing session %d of %d... \n', session, 29);
        inputLFP = load(['C:\Users\Steven\Desktop\tempTEBA\dataRepo\2012_Cmand_EuX\rawData\' sessionName],...
            'AD1*','AD2*','AD3*','AD4*');
        
        lfpChannels = fieldnames(inputLFP);
        morletSession_temp = [];
        
        parfor k=1:numel(lfpChannels)
            if (isnumeric(inputLFP.(lfpChannels{k})))
                fprintf('Analysing LFP %d of %d... \n', k, numel(lfpChannels));
                
                filteredLFP = [];
                
                % Pre-process & filter analog data (EEG/LFP), and align on event
                filter = 'all';
                filterFreq = filterBands.(filter);
                [~, filteredLFP.(filter)] = tidyRawSignal(inputLFP.(lfpChannels{k}), ephysParameters, filterFreq,...
                    eventTimes, alignmentParameters);
                
%                 filter = 'beta';
%                 filterFreq = filterBands.(filter);
%                 [~, filteredLFP.(filter)] = tidyRawSignal(inputLFP.(lfpChannels{k}), ephysParameters, filterFreq,...
%                     eventTimes, alignmentParameters);
%                 
%                 filter = 'lowGamma';
%                 filterFreq = filterBands.(filter);
%                 [~, filteredLFP.(filter)] = tidyRawSignal(inputLFP.(lfpChannels{k}), ephysParameters, filterFreq,...
%                     eventTimes, alignmentParameters);
                
                % (b) Convolve using Morlet Wave Transformation, calculate power, and determine
                % bursts in data (i.e. Wessel, 2020, JNeurosci)
                [morletLFP] = convMorletWaveform(filteredLFP.all,morletParameters);
                
%                 morletSession_temp = [morletSession_temp;morletLFP];
                
%                 savename_morlet = ['morletData\lfp_session' int2str(session) '_' lfpChannels{k} '_morlet_' eventLabel];
%                 savename_lfp = ['filteredData\lfp_session' int2str(session) '_' lfpChannels{k} '_filteredLFP_' eventLabel];
% %                 
                [betaOutput] = betaBurstCount_LFP(morletLFP, morletParameters);
                savename_betaBurst = ['betaBurst\' eventLabel '\lfp_session' int2str(session) '_' lfpChannels{k} '_betaOutput_' eventLabel];
                
                parsave_betaburst([outputDir savename_betaBurst], betaOutput)          
                
            end
        end
        
    end
end
% toc
% 
% %% Extract LFP
% tic
% for eventType = [2]
%     eventLabel = eventNames{eventType};
%     alignmentParameters.eventN = eventType;
%     fprintf(['Analysing data aligned on ' eventLabel '. \n']);
%     
%     %% Extract EEG data & calculate power
%     for session = 14:29
%         % Get session name (to load in relevant file)
%         sessionName = FileNames{session};
%         
%         % Clear workspace
% %         clear trials eventTimes inputLFP cleanLFP alignedLFP filteredLFP betaOutput morletLFP pTrl_burst
%         
%         % Setup key behavior variables
%         ssrt = bayesianSSRT.ssrt_mean(session);
%         eventTimes = executiveBeh.TrialEventTimes_Overall{session};
% 
%         % Load the LFP channels recorded for that session
%         fprintf('...analysing session %d of %d... \n', session, 29);
%         inputLFP = load(['C:\Users\Steven\Desktop\tempTEBA\dataRepo\2012_Cmand_EuX\rawData\' sessionName],...
%             'AD1*','AD2*','AD3*','AD4*');
%         
%         lfpChannels = fieldnames(inputLFP);
%       
%         parfor k=1:numel(lfpChannels)
%             if (isnumeric(inputLFP.(lfpChannels{k})))
%                 fprintf('......analysing LFP %d of %d... \n', k, numel(lfpChannels));
%                 
%                 filteredLFP = [];
%                 
%                 % Pre-process & filter analog data (EEG/LFP), and align on event
%                 filter = 'all';
%                 filterFreq = filterBands.(filter);
%                 [~, filteredLFP.(filter)] = tidyRawSignal(inputLFP.(lfpChannels{k}), ephysParameters, filterFreq,...
%                     eventTimes, alignmentParameters);
%                 
%                 filter = 'beta';
%                 filterFreq = filterBands.(filter);
%                 [~, filteredLFP.(filter)] = tidyRawSignal(inputLFP.(lfpChannels{k}), ephysParameters, filterFreq,...
%                     eventTimes, alignmentParameters);
%                 
%                 filter = 'lowGamma';
%                 filterFreq = filterBands.(filter);
%                 [~, filteredLFP.(filter)] = tidyRawSignal(inputLFP.(lfpChannels{k}), ephysParameters, filterFreq,...
%                     eventTimes, alignmentParameters);
% 
%                 savename_LFP = ['LFP\' eventLabel '\lfp_session' int2str(session) '_' lfpChannels{k} '_betaOutput_' eventLabel];
%                 
%                 parsave_filtered([outputDir savename_LFP], filteredLFP)          
%                 
%             end
%         end
%     end
% end
% toc
% 
