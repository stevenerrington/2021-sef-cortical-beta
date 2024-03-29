
%% Extract relevant data

% For each LFP in cortex
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    % Get the relative index and session
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 509. \n',lfp);
    
    % Load in beta output data for session
    loadname = fullfile('betaBurst','saccade',['lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_saccade']);
    betaOutput = parload(fullfile(fullfile(dataDir,'lfp'), loadname));
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, sessionBLpower(session)*burstThreshold);
    
    % Get GO trials following NC, and the preceding NC trial (these are
    % paired)
    trialGO = executiveBeh.Trials.all{session}.t_GO_after_NC;
    trialNC = executiveBeh.Trials.all{session}.t_GO_after_NC-1;
    
    % Get RT's within session
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4) - ...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    % Initialise the arrays
    burstFlag = []; RTslowing = [];
    
    % For each GO trial
    for trlIdx = 1:length(trialGO)
        % Get whether a burst occured within the given time window
        % post-saccade (no burst = 0, burst = 1)
        window = [400 600]
        burstFlag(trlIdx,1) = double(sum((betaOutput.burstData.burstTime{trialNC(trlIdx)} < window(2) &...
            betaOutput.burstData.burstTime{trialNC(trlIdx)} > window(1)) == 1) > 0);
        % Get the change in RT from the NC to the GO trial
        % minus values represent slowing, positive values represent
        % speeding.
        RTslowing(trlIdx,1) = sessionRT(trialNC(trlIdx))-sessionRT(trialGO(trlIdx));
    end
    
    % Compile the burst flag and RT adapation into one array for future use
    logTable{lfpIdx} = [burstFlag, RTslowing];
    
end

%% Model 1: Logistic regression
%  Here, I looked at fitting a logistic regression see the association between a
%  burst (0 or 1) in the error trial, and RT adaption in the following
%  trial

% Initialise array
rtSlow_model = [];

% For each contact
for lfpIdx = 1:length(corticalLFPcontacts.all)
    fprintf('Analysing LFP number %i of 509. \n',lfpIdx);
    % Get the burst and RT adaptation for the contact
    burstFlag = logTable{lfpIdx}(:,1); RTslowing = logTable{lfpIdx}(:,2);
    % Convert into a table for the regression function
    regressionTable = table(burstFlag, RTslowing);
    % Run the regression
    model = fitglm(regressionTable,'burstFlag ~ RTslowing','link','logit','Distribution','binomial');
    % Save the regression output (R^2 value and p-value in rtSlow_model,
    % and beta value in rtSlow_betaValue
    rtSlow_model(lfpIdx,:) = [model.Rsquared.Ordinary, model.Coefficients.pValue(2)];
    rtSlow_betaValue(lfpIdx,:) = model.Coefficients.Estimate';
end

% After running this for all contacts, find those with a sig p-value
% (p< 1 / nContacts - multiple comparisons)
% Also tried this at p = 0.01
pSigLevel = 0.05/length(corticalLFPcontacts.all);
sigSlow = find(rtSlow_model(:,2) < pSigLevel);

% For each significant contact, I then printed a figure to check over
for idx = 1:length(sigSlow)
    lfpIdx = sigSlow(idx);
    % Create figure
    figure; hold on
    % Plot the RT adapation and burst values
    scatter(logTable{lfpIdx}(:,2),logTable{lfpIdx}(:,1))
    
    % Derive values from regression equation, and plot that.
    rtSlowRange = linspace(-200,10,200);
    beta = rtSlow_betaValue(lfpIdx,:);
    plot(rtSlowRange, 1./(1+exp(-(beta(1)+beta(2)*rtSlowRange))))
    
end

% I don't think this works particularly well, so I run with option 2.

%% Model 2: Independent groups comparison between error trials with/without a burst
%  For each contact
for lfpIdx = 1:length(corticalLFPcontacts.all)
    clear lfpBurstRTtable 
    % Get the burst and RT adaptation for the contact
    lfpBurstRTtable = logTable{(lfpIdx)};
    
    % Run a t-test on differences in RT adaption between trials with bursts
    % and those without
    [h, ~, ~, tstat_out] = ttest2(...
        lfpBurstRTtable(lfpBurstRTtable(:,1) == 1,2),... % RT on go following error trials with burst
        lfpBurstRTtable(lfpBurstRTtable(:,1) == 0,2),... % RT on go following error trials without burst
        'alpha',pSigLevel);... % Setting alpha level at 1/509 for multiple comparisons
    
    % Get test output
    rt_ttest(lfpIdx,1) = h; % Significant flag (1 = significant difference at p = 1/509)
    
    rt_ttest(lfpIdx,2) = nanmean... % mean difference between groups
        (lfpBurstRTtable(lfpBurstRTtable(:,1) == 1,2))-... %  RT on go following error trials with burst
        nanmean(lfpBurstRTtable(lfpBurstRTtable(:,1) == 0,2)); % RT on go following error trials without burst
    % Here, -ve represents greater slowing with burst
    
    rt_ttest(lfpIdx,3) = tstat_out.tstat; % Get the t-statistic

    
end

%% Plot figures

% Histogram of significant and non-significant differences in RT-adaptation between
% burst/no-burst
rtAdjustment_histogram(1,1)= gramm('x',rt_ttest(:,2),...% Here I am plotting the difference in RT adaptation between trials with a burst, and trials without. -ve values = greater slowing with burst
    'color',rt_ttest(:,1));
rtAdjustment_histogram(1,1).stat_bin('edges',-100:20:100,'dodge',0,'geom','bar');
figure('Renderer', 'painters', 'Position', [100 100 300 250]);
rtAdjustment_histogram.draw();

% Pie chart showing significant direction differences (non-sig,
% positive RT adaptation with burst, negative RT adaptation with burst)
pContactType = [sum(rt_ttest(:,1) == 0),... % Non-significant
    sum(rt_ttest(:,1) == 1 & rt_ttest(:,2) > 0),... % Greater slowing w/o burst
    sum(rt_ttest(:,1) == 1 & rt_ttest(:,2) < 0)];   % Greater slowing w/ burst
figure('Renderer', 'painters', 'Position', [100 100 300 250]);
explode = [1 1 1];
pie(pContactType,explode)


% Bar chart showing differences in burst/no-burst RT adaptation for an example contact
clear rtAdjustment_a
% - First, find the lfp with the greatest difference
posIdx = find(rt_ttest(:,1) == 1);
[~,closestIndex] = sort(abs(rt_ttest(posIdx,2)-max(rt_ttest(posIdx,2))));
lfpIdx = posIdx(closestIndex == 1);

% - Then plot this example contact
rtAdjustment_a(1,1)= gramm('x',logTable{(lfpIdx)}(:,1),...
    'y',logTable{(lfpIdx)}(:,2));
rtAdjustment_a(1,1).stat_summary('geom',{'bar','black_errorbar'});
rtAdjustment_a(1,1).axe_property('XLim',[-0.5 1.5]);
rtAdjustment_a(1,1).axe_property('YLim',[-200 200]);
figure('Renderer', 'painters', 'Position', [100 100 300 250]);
rtAdjustment_a.draw();