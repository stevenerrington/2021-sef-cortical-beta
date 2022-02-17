%% Calculate proportion of trials with burst (-200-SSRT to -200 ms pre-target)

parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfp,length(corticalLFPcontacts.all));
    
    % Load in beta output data for session
    loadname = ['betaBurst\target\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target'];
    betaOutput = parload([outputDir loadname])
    
    % Calculate p(trials) with burst
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6)
    
    
    interBurstInterval = [];

    for trl = 1:length(betaOutput.burstData.burstTime)
        interBurstInterval = [interBurstInterval; diff(betaOutput.burstData.burstTime{trl})];
    end
    
    interBurstInterval_ch{lfpIdx} = interBurstInterval;
    
end

interBurstInterval_all = [];

for lfpIdx = 1:length(corticalLFPcontacts.all)
    interBurstInterval_all = [interBurstInterval_all; interBurstInterval_ch{lfpIdx}];
end

figure('Renderer', 'painters', 'Position', [100 100 500 300]);
histogram(interBurstInterval_all,[0:20:2500],'LineStyle','None')
xlabel('Inter-burst interval (ms)')
ylabel('Frequency')
box off


interBurstInterval_filtered = interBurstInterval_all(interBurstInterval_all > 60);

figure('Renderer', 'painters', 'Position', [100 100 500 300]);
histogram(interBurstInterval_filtered,[0:20:2500],'LineStyle','None')
xlabel('Inter-burst interval (ms)')
ylabel('Frequency')
box off

var(interBurstInterval_filtered)/mean(interBurstInterval_filtered)
