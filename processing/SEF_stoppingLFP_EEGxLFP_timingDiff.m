eeg_lfp_diffBurstTime_layer.observed.l2 = [];
eeg_lfp_diffBurstTime_layer.observed.l3 = [];
eeg_lfp_diffBurstTime_layer.observed.l5 = [];
eeg_lfp_diffBurstTime_layer.observed.l6 = [];
eeg_lfp_diffBurstTime_layer.shuffled.l2 = [];
eeg_lfp_diffBurstTime_layer.shuffled.l3 = [];
eeg_lfp_diffBurstTime_layer.shuffled.l5 = [];
eeg_lfp_diffBurstTime_layer.shuffled.l6 = [];
eeg_lfp_diffBurstTime_layer.labels = {};

layerLabel = {'l2','l3','l5','l6'};

sessionList = 1:16;

% sessionList = euPerpIdx; % xenaPerpIdx


for sessionIdx = 1:length(sessionList)
    session = sessionList(sessionIdx);
    fprintf('Analysing session %i of %i. \n',sessionIdx, length(sessionList))
    
    nTrls = size(eeg_lfp_diffBurstTime.observed{session},1);
    nLFPs = size(eeg_lfp_diffBurstTime.observed{session},2);
    
    for lfpIdx = 1:nLFPs
        
        % Find the depth and which layer it corresponds to in
        % laminarAlignment.list
        find_laminar = cellfun(@(c) find(c == lfpIdx), laminarAlignment.list, 'uniform', false);
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

displayWindow = [-500:10:500];

figure('Renderer', 'painters', 'Position', [100 100 400 250]); hold on
histogram(eeg_lfp_diffBurstTime_layer.observed.l2,displayWindow,'DisplayStyle','stairs','Normalization','probability');
histogram(eeg_lfp_diffBurstTime_layer.observed.l3,displayWindow,'DisplayStyle','stairs','Normalization','probability');
histogram(eeg_lfp_diffBurstTime_layer.observed.l5,displayWindow,'DisplayStyle','stairs','Normalization','probability');
histogram(eeg_lfp_diffBurstTime_layer.observed.l6,displayWindow,'DisplayStyle','stairs','Normalization','probability');

histogram(eeg_lfp_diffBurstTime_layer.shuffled.l2,displayWindow,'DisplayStyle','stairs','Normalization','probability');
histogram(eeg_lfp_diffBurstTime_layer.shuffled.l3,displayWindow,'DisplayStyle','stairs','Normalization','probability');
histogram(eeg_lfp_diffBurstTime_layer.shuffled.l5,displayWindow,'DisplayStyle','stairs','Normalization','probability');
histogram(eeg_lfp_diffBurstTime_layer.shuffled.l6,displayWindow,'DisplayStyle','stairs','Normalization','probability');

xlim([displayWindow(1) displayWindow(end)])
% ylim([0 0.02])
legend({'l2-obs','l3-obs','l5-obs','l6-obs','l2-shuf','l3-shuf','l5-shuf','l6-shuf'},'location','eastoutside')
vline(mean(eeg_lfp_diffBurstTime_layer.observed.l2),'b--')
vline(mean(eeg_lfp_diffBurstTime_layer.observed.l3),'o--')
vline(mean(eeg_lfp_diffBurstTime_layer.observed.l5),'y--')
vline(mean(eeg_lfp_diffBurstTime_layer.observed.l6),'r--')

ylim([0.005 0.020])




