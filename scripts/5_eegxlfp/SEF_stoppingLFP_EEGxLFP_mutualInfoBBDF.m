

%% Analysis plans

% Get BBDF aligned on fixation, target, saccade, stop-signal, and tone.
% Calculate MI for upper/lower against EEG.

for session_i = 14:29
    
    EEG_LFP_bbdf_EEG = {};
    EEG_LFP_bbdf_LFP_upper = {};
    EEG_LFP_bbdf_LFP_lower = {};
    
    %% Cycle through alignments
    parfor alignmentIdx = 1:length(eventAlignments)
        alignmentEvent = eventAlignments{alignmentIdx};
        fprintf(['Session %i | analysing data aligned on ' alignmentEvent '. \n'],session_i);        
        %% Get BBDF for EEG
        % Load in EEG data from directory & threshold bursts    eegDir = fullfile(dataDir,'eeg');
        eegName = fullfile('betaBurst',['eeg_session' int2str(session_i) '_' FileNames{session_i} '_betaOutput_' alignmentEvent]);
        eegBetaBurst = []; eegBetaBurst = parload(fullfile(eegDir,eegName));
        [eegBetaBurst] = thresholdBursts_EEG(eegBetaBurst.betaOutput, eegBetaBurst.betaOutput.medianLFPpower*6);
        
        EEG_LFP_bbdf_EEG{alignmentIdx,1} = BetaBurstConvolver(eegBetaBurst.burstData.burstTime);
        
        
        %% Get BBDF for upper and lower layers
        loadfile_label = ['eeg_lfp_session' int2str(session_i) '_' alignmentEvent '.mat'];
        data_in = []; data_in = load(fullfile(loadDir, loadfile_label));
                
        lfp_burst_time_upper = {}; lfp_burst_time_lower = {};
        
        alignmentZero = abs(data_in.eeg_lfp_burst.eventWindows{alignmentIdx}(1));
        for trl_i = 1:size(data_in.eeg_lfp_burst.LFP_upper{1, 1},1)
            lfp_burst_time_upper{trl_i,1} =...
                find(data_in.eeg_lfp_burst.LFP_upper{1, 1}(trl_i,:) == 1) - alignmentZero;
            lfp_burst_time_lower{trl_i,1} =...
                find(data_in.eeg_lfp_burst.LFP_lower{1, 1}(trl_i,:) == 1) - alignmentZero;
        end
        
        EEG_LFP_bbdf_LFP_upper{alignmentIdx,1} = BetaBurstConvolver(lfp_burst_time_upper);
        EEG_LFP_bbdf_LFP_lower{alignmentIdx,1} = BetaBurstConvolver(lfp_burst_time_lower);

    end   
    
    EEG_LFP_bbdf = struct();
    
    for alignmentIdx = 1:length(eventAlignments)
        alignmentEvent = eventAlignments{alignmentIdx};
        EEG_LFP_bbdf.(alignmentEvent).LFP_Upper = EEG_LFP_bbdf_LFP_upper{alignmentIdx,1};
        EEG_LFP_bbdf.(alignmentEvent).LFP_Lower = EEG_LFP_bbdf_LFP_lower{alignmentIdx,1};
        EEG_LFP_bbdf.(alignmentEvent).EEG = EEG_LFP_bbdf_EEG{alignmentIdx,1};
    end
    
    out_filename = fullfile(dataDir,'eeg_lfp','bbdf',['eeg_lfp_bbdf_session' int2str(session_i) '.mat']);
    save(out_filename,'EEG_LFP_bbdf','-v7.3')
    
end


%% Analysis: Mutual Information
bbdf_average_LFP_upper = {};
bbdf_average_LFP_lower = {};
bbdf_average_EEG = {};

clear bbdf_average* mi_analysis*
parfor session_i = 14:29
    in_filename = fullfile(dataDir,'eeg_lfp','bbdf',['eeg_lfp_bbdf_session' int2str(session_i) '.mat']);
    data_in = load(in_filename);
    
    trial_idx = []; trial_idx = executiveBeh.ttx.GO{session_i};
    
    alignmentIdx = 2;
    alignmentEvent = eventAlignments{alignmentIdx};
    
    % Get BBDF on trial subset
    bbdf_window = [-800:500] + 1000;
    
    bbdf_average_LFP_upper{session_i} = data_in.EEG_LFP_bbdf.(alignmentEvent).LFP_Upper(trial_idx,bbdf_window);
    bbdf_average_LFP_lower{session_i} = data_in.EEG_LFP_bbdf.(alignmentEvent).LFP_Lower(trial_idx,bbdf_window);
    bbdf_average_EEG{session_i} = data_in.EEG_LFP_bbdf.(alignmentEvent).EEG(trial_idx,bbdf_window);
    
    fprintf(['Session %i | running mutual information analysis, aligned on ' alignmentEvent '. \n'],session_i);
    
    % Calculate mutual information
    [mi_analysis_mi_upper_eeg{session_i-13},...
        mi_analysis_p_upper_eeg{session_i-13}] =...
        quickMI(bbdf_average_LFP_upper{session_i}',...
        bbdf_average_EEG{session_i}',...
        'nBins', 5, 'delay',10);
    
    
    [mi_analysis_mi_lower_eeg{session_i-13},...
        mi_analysis_p_lower_eeg{session_i-13}] =...
        quickMI(bbdf_average_LFP_lower{session_i}',...
        bbdf_average_EEG{session_i}',...
        'nBins', 5, 'delay',10);
    
    
    [mi_analysis_mi_upper_lower{session_i-13},...
        mi_analysis_p_upper_lower{session_i-13}] =...
        quickMI(bbdf_average_LFP_upper{session_i}',...
        bbdf_average_LFP_lower{session_i}',...
        'nBins', 5, 'delay',5);

end

%% Generate figure
%  Now we have all the data in an organised format, we can now generate
%  figures

% First, we start by making sure we have a clean space to work with
clear inputData inputLabels eeg_lfp_BBDF

% Then, we take the concatenated EEG, upper, and lower BBDF data and
% concatenate it into one array to feed into the function
inputData = [mi_analysis_mi_upper_eeg'; mi_analysis_mi_lower_eeg'; mi_analysis_mi_upper_lower'];
% We then do this for the labels too. Here the label matches the
% corresponding index in the BBDF inputData.
inputLabels = [repmat({'1_Upper-EEG'},length(mi_analysis_mi_upper_eeg),1);...
    repmat({'2_Lower-EEG'},length(mi_analysis_mi_lower_eeg),1);...
    repmat({'3_Upper-Lower'},length(mi_analysis_mi_upper_lower),1)];

% Once that's all in place, we can feed it into our graph function (gramm)
eeg_lfp_BBDF(1,1)=gramm('x',[-800:500],'y',inputData,'color',inputLabels);

% and set the properties of the figure
eeg_lfp_BBDF(1,1).stat_summary();
eeg_lfp_BBDF(1,1).axe_property('XLim',[-800 200]);
eeg_lfp_BBDF(1,1).axe_property('YLim',[0 0.2]);

% Then, we're all good to go. Create the figure!
figure('Renderer', 'painters', 'Position', [100 100 400 300]);
eeg_lfp_BBDF.draw();

