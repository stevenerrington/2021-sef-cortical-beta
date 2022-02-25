%% Co-activation between SEF and MFC EEG
% Set up parameters
eventAlignments = {'target','saccade','stopSignal','tone'};
eventWindows = {[-800 200],[-200 800],[-200 800],[-800 200]};
analysisWindows = {[-400:-200],[400:600],[400:600],[-400:-200]};
eventBin = {1,1,1,1,1};
loadDir = 'D:\projectCode\project_stoppingLFP\data\eeg_lfp\';
printFigFlag = 0;

%% Extract data from files
% For each session
for sessionIdx = 14:29
    % Get the admin/details
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % ... and for each epoch of interest
    for alignmentIdx = 1:4
        % Get the desired alignment
        alignmentEvent = eventAlignments{alignmentIdx};
 
     end
    
end

inputData = [eeg_all_BBDF; lfp_upper_BBDF; lfp_lower_BBDF];
inputLabels = [eeg_all_label; lfp_upper_label; lfp_lower_label];

