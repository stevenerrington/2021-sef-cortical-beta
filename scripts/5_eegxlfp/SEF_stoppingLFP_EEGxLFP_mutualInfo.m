%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'fixate','target','saccade','stopSignal','tone'};
loadDir = fullfile(dataDir,'eeg_lfp');


clear mutualInfo_upper_eeg mutualInfo_lower_eeg mutualInfo_upper_lower
clear p_upper_eeg p_lower_eeg p_upper_lower

% Define session information
for session_i = 14:29
    session = session_i;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest (just fixation here)
    alignment_i = 2;
    % Get the desired alignment
    alignmentEvent = eventAlignments{alignment_i};
    
    % Get trials of interest
    trials = []; trials_shuffled = [];
    trials = executiveBeh.ttx.GO{session_i};
    % We can then shuffled the conditions
    trials_shuffled = trials(randperm(numel(trials)));
    
    % Save output for each alignment on each session
    loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
    data_in = load(fullfile(loadDir, loadfile_label));
    
    % Get zero point
    alignmentZero = abs(data_in.eeg_lfp_burst.eventWindows{alignment_i}(1));
    
    % Get burst data (1 ms sample)
    clear data1 data2
    data1 = data_in.eeg_lfp_burst.EEG{1}(trials,:);
    data2 = data_in.eeg_lfp_burst.LFP_upper{1}(trials,:);
    data3 = data_in.eeg_lfp_burst.LFP_lower{1}(trials,:);
    

    % Bin burst data 
    binEdges = [-1000:50:1000];

    %  ... for data 1
    clear xc xd xe xf xg data1_bin data2_bin data3_bin
    xc = mat2cell(data1, ones(1,size(data1,1)), size(data1,2));
    xd = cellfun(@(x) find(x == 1), xc, 'Uni',0);
    xe = cellfun(@(x) x - 1000, xd, 'Uni',0);
    [xf,~] = cellfun(@(x) histcounts(x,binEdges), xe, 'Uni',0);
    data1_bin = cell2mat(xf) > 0;
    
    %  ... for data 2
    clear xc xd xe xf xg
    xc = mat2cell(data2, ones(1,size(data2,1)), size(data2,2));
    xd = cellfun(@(x) find(x == 1), xc, 'Uni',0);
    xe = cellfun(@(x) x - 1000, xd, 'Uni',0);
    [xf,~] = cellfun(@(x) histcounts(x,binEdges), xe, 'Uni',0);
    data2_bin = cell2mat(xf) > 0;
    
    %  ... for data 3
    clear xc xd xe xf xg
    xc = mat2cell(data3, ones(1,size(data3,1)), size(data3,2));
    xd = cellfun(@(x) find(x == 1), xc, 'Uni',0);
    xe = cellfun(@(x) x - 1000, xd, 'Uni',0);
    [xf,~] = cellfun(@(x) histcounts(x,binEdges), xe, 'Uni',0);
    data3_bin = cell2mat(xf) > 0;
    
    % Calculate mutual information
    
    [mutualInfo_upper_eeg(session_i-13,:),p_upper_eeg(session_i-13,:)] =...
        quickMI(data1_bin',data2_bin','nBins', 4);
    
    [mutualInfo_lower_eeg(session_i-13,:),p_lower_eeg(session_i-13,:)] =...
        quickMI(data1_bin',data3_bin','nBins', 4);
  
    [mutualInfo_upper_lower(session_i-13,:),p_upper_lower(session_i-13,:)] =...
        quickMI(data2_bin',data3_bin','nBins', 4);
end


for session_i = 1:16
   plotMI_upper_eeg{session_i} = mutualInfo_upper_eeg(session_i,:);
   plotMI_lower_eeg{session_i} = mutualInfo_lower_eeg(session_i,:);
   plotMI_upper_lower{session_i} = mutualInfo_upper_lower(session_i,:);  
end




%% Figure: Mutual information 
clear mi_layer_eeg_figure % clear the gramm variable, incase it already exists

% Input relevant data into the gramm function, and set the parameters
% Fixation aligned
mi_layer_eeg_figure(1,1)=gramm('x',getMidBin(binEdges),...
    'y',[plotMI_upper_eeg';plotMI_lower_eeg';plotMI_upper_lower'],...
    'color',[repmat({'1_Upper/EEG'},16,1);repmat({'2_Lower/EEG'},16,1);...
    repmat({'3_Upper/Lower'},16,1)]);


mi_layer_eeg_figure(1,1).stat_summary(); 

mi_layer_eeg_figure(1,1).set_names('x','Time before EEG burst (ms)');
mi_layer_eeg_figure.set_names('y','Mutual Information (bits)'); 
mi_layer_eeg_figure(1,1).axe_property('XLim',[-100 500]); 


figure('Renderer', 'painters', 'Position', [100 100 400 300]);
mi_layer_eeg_figure.draw();





