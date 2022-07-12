eeg_lfp_diffBurstTime_layer.observed.upper = [];
eeg_lfp_diffBurstTime_layer.observed.lower = [];

eeg_lfp_diffBurstTime_layer.shuffled.upper = [];
eeg_lfp_diffBurstTime_layer.shuffled.lower = [];

eeg_lfp_diffBurstTime_layer.labels = {};

layerLabel = laminarAlignment.compart_label;

sessionList = 14:29;

% sessionList = euPerpIdx; % xenaPerpIdx

% This code loops through all the LFPs in a given session, determines
% whether it is an upper or lower layer contact, and then concatenates the
% times into the relevant structure (upper or lower).
for sessionIdx = 1:length(sessionList)
    session = sessionList(sessionIdx);
    fprintf('Analysing session %i of %i. \n',sessionIdx, length(sessionList))
    
    nTrls = size(eeg_lfp_diffBurstTime.observed{session},1);
    nLFPs = size(eeg_lfp_diffBurstTime.observed{session},2);
    
    for lfpIdx = 1:nLFPs
        
        % Find the depth and which layer it corresponds to in
        % laminarAlignment.list
        find_laminar = cellfun(@(c) find(c == lfpIdx), laminarAlignment.compart, 'uniform', false);
        find_laminar = find(~cellfun(@isempty,find_laminar));
        
        eeg_lfp_diffBurstTime_layer.labels =...
            [eeg_lfp_diffBurstTime_layer.labels;...
            repmat(executiveBeh.nhpSessions.monkeyNameLabel(session+13),nTrls,1)];
        
        for trlIdx = 1:nTrls
            eeg_lfp_diffBurstTime_layer.observed.(layerLabel{find_laminar}) = ...
                [eeg_lfp_diffBurstTime_layer.observed.(layerLabel{find_laminar}),...
                eeg_lfp_diffBurstTime.observed{session}{trlIdx,lfpIdx}];

            eeg_lfp_diffBurstTime_layer.shuffled.(layerLabel{find_laminar}) = ...
                [eeg_lfp_diffBurstTime_layer.shuffled.(layerLabel{find_laminar}),...
                eeg_lfp_diffBurstTime.shuffled{session}{trlIdx,lfpIdx}];        
        end
    end
end

%%

displayWindow = [-250:10:250];

figure('Renderer', 'painters', 'Position', [100 100 400 250]); hold on
histogram(eeg_lfp_diffBurstTime_layer.observed.upper,displayWindow,'DisplayStyle','stairs');
histogram(eeg_lfp_diffBurstTime_layer.observed.lower,displayWindow,'DisplayStyle','stairs');

histogram(eeg_lfp_diffBurstTime_layer.shuffled.upper,displayWindow,'DisplayStyle','stairs');
histogram(eeg_lfp_diffBurstTime_layer.shuffled.lower,displayWindow,'DisplayStyle','stairs');

xlim([displayWindow(1) displayWindow(end)])
% ylim([0 0.02])
legend({'upper-obs','lower-obs','upper-shuf','lower-shuf'},'location','eastoutside')


% ylim([0.005 0.020])



%% 

nanmean(eeg_lfp_diffBurstTime_layer.observed.lower > -50 &...
    eeg_lfp_diffBurstTime_layer.observed.lower < 0)
