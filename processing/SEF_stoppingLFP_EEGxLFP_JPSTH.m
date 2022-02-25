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
        
        % Get trials of interest
        if alignmentIdx == 2
            trials = executiveBeh.ttm_c.NC{session,executiveBeh.midSSDindex(session)}.all;
        else
            trials = executiveBeh.ttm_CGO{session,executiveBeh.midSSDindex(session)}.C_matched;
        end
        
        % Save output for each alignment on each session
        loadfile_label = ['eeg_lfp_session' int2str(session) '_' alignmentEvent '.mat'];
        load([loadDir loadfile_label]);
        
        % Get zero point
        alignmentZero = abs(eeg_lfp_burst.eventWindows{alignmentIdx}(1));
        
        eeg_lfp_burst
        
        
        
        
        
    end
    
end
