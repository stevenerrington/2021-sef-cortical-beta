eeg_lfp_diffBurstTime_layer.observed.l2 = [];
eeg_lfp_diffBurstTime_layer.observed.l3 = [];
eeg_lfp_diffBurstTime_layer.observed.l5 = [];
eeg_lfp_diffBurstTime_layer.observed.l6 = [];
eeg_lfp_diffBurstTime_layer.shuffled.l2 = [];
eeg_lfp_diffBurstTime_layer.shuffled.l3 = [];
eeg_lfp_diffBurstTime_layer.shuffled.l5 = [];
eeg_lfp_diffBurstTime_layer.shuffled.l6 = [];

layerLabel = {'l2','l3','l5','l6'};

for session = 1:16
    fprintf('Analysing session %i of %i. \n',session, 16)
    
    nTrls = size(eeg_lfp_diffBurstTime.observed{session},1);
    nLFPs = size(eeg_lfp_diffBurstTime.observed{session},2);
    
    for lfpIdx = 1:nLFPs
        
        % Find the depth and which layer it corresponds to in
        % laminarAlignment.list
        find_laminar = cellfun(@(c) find(c == lfpIdx), laminarAlignment.list, 'uniform', false);
        find_laminar = find(~cellfun(@isempty,find_laminar));
        
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
layerLabel = [repmat({'L2'},length(eeg_lfp_diffBurstTime_layer.observed.l2),1);...
    repmat({'L3'},length(eeg_lfp_diffBurstTime_layer.observed.l3),1);...
    repmat({'L5'},length(eeg_lfp_diffBurstTime_layer.observed.l5),1);...
    repmat({'L6'},length(eeg_lfp_diffBurstTime_layer.observed.l6),1)];

eeg_lfp_diffDensity(1,1)=gramm('x',...
    [eeg_lfp_diffBurstTime_layer.observed.l2'; eeg_lfp_diffBurstTime_layer.observed.l3';...
    eeg_lfp_diffBurstTime_layer.observed.l5'; eeg_lfp_diffBurstTime_layer.observed.l6'],...
    'color',layerLabel);

eeg_lfp_diffDensity(1,2)=gramm('x',...
    [eeg_lfp_diffBurstTime_layer.shuffled.l2'; eeg_lfp_diffBurstTime_layer.shuffled.l3';...
    eeg_lfp_diffBurstTime_layer.shuffled.l5'; eeg_lfp_diffBurstTime_layer.shuffled.l6'],...
    'color',layerLabel);


eeg_lfp_diffDensity(1,1).stat_bin('geom','line'); eeg_lfp_diffDensity(1,2).stat_bin('geom','line');
eeg_lfp_diffDensity.axe_property('XLim',[-500 500]);
figure('Renderer', 'painters', 'Position', [100 100 800 400]);
eeg_lfp_diffDensity.draw();

%% 

displayWindow = [-250:10:250];

figure('Renderer', 'painters', 'Position', [100 100 800 250]); 
subplot(1,2,1); hold on;
histogram(eeg_lfp_diffBurstTime_layer.observed.l2,displayWindow,'DisplayStyle','stairs','Normalization','Probability');
histogram(eeg_lfp_diffBurstTime_layer.observed.l3,displayWindow,'DisplayStyle','stairs','Normalization','Probability');
histogram(eeg_lfp_diffBurstTime_layer.observed.l5,displayWindow,'DisplayStyle','stairs','Normalization','Probability');
histogram(eeg_lfp_diffBurstTime_layer.observed.l6,displayWindow,'DisplayStyle','stairs','Normalization','Probability');


xlim([displayWindow(1) displayWindow(end)])
ylim([0 0.02])

vline(mean(eeg_lfp_diffBurstTime_layer.observed.l2),'b--')
vline(mean(eeg_lfp_diffBurstTime_layer.observed.l3),'o--')
vline(mean(eeg_lfp_diffBurstTime_layer.observed.l5),'y--')
vline(mean(eeg_lfp_diffBurstTime_layer.observed.l6),'r--')

subplot(1,2,2); hold on;
histogram(eeg_lfp_diffBurstTime_layer.shuffled.l2,displayWindow,'DisplayStyle','stairs','Normalization','Probability');
histogram(eeg_lfp_diffBurstTime_layer.shuffled.l3,displayWindow,'DisplayStyle','stairs','Normalization','Probability');
histogram(eeg_lfp_diffBurstTime_layer.shuffled.l5,displayWindow,'DisplayStyle','stairs','Normalization','Probability');
histogram(eeg_lfp_diffBurstTime_layer.shuffled.l6,displayWindow,'DisplayStyle','stairs','Normalization','Probability');



%%




