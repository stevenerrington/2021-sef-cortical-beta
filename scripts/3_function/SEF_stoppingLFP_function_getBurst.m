%% Get beta-burst features for each condition and epoch. %%%%%%%%%%%%%%%%%
clc;

% If the data is already extracted, then load it in.
if exist(fullfile(dataDir,'burst', 'burstData_stopping.mat'),'file') == 2
    loadBurstData
else % Otherwise, extract the data
    %% For baseline/fixation period (-400 to -200 ms, pre-target) %%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on fixation... | \n')
    fixationBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_baseline...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    fixationBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_baseline...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    fixationBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_baseline...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    
    %% For target period (0 to 200 ms, post-target) %%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on target... | \n')
    targetBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_target...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    targetBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_target...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    targetBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_target...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    
    %% For stopping period (0 to SSRT ms, post-stop-signal) %%%%%%%%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on stop signal... | \n')
    stoppingBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_stop...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    stoppingBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_stop...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    stoppingBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_stop...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    
    %% For SSRT period (SSRT+200 to SSRT + 400 ms, post-stop-signal) %%%%%%%%%
    fprintf('Extracting beta-burst information aligned on ssrt... | \n')
    ssrtBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_ssrt...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    ssrtBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_ssrt...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    ssrtBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_ssrt...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,dataDir);
    
    %% For pretone period (-400 to -200, pre-tone) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on tone (pre-tone)... | \n')
    pretoneBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [-300 -100],dataDir);
    pretoneBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [-300 -100],dataDir);
    pretoneBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [-300 -100],dataDir);
    
    %% For posttone period (100 to 300, pre-tone) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on tone(post-tone)... | \n')
    posttoneBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300],dataDir);
    posttoneBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300],dataDir);
    posttoneBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300],dataDir);
    
    %% For early error period (100 to 300 ms, post-saccade)
    fprintf('Extracting beta-burst information aligned on saccade (early-error)... | \n')
    errorBeta_early.timing.noncanc = SEF_stoppingLFP_function_getBurst_saccade...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300],dataDir);
    errorBeta_early.timing.nostop = SEF_stoppingLFP_function_getBurst_saccade...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300],dataDir);
 
    
    %% For late error period (400 to 600 ms, post-saccade)
    fprintf('Extracting beta-burst information aligned on saccade (early-error)... | \n')
    errorBeta_late.timing.noncanc = SEF_stoppingLFP_function_getBurst_saccade...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [400 600],dataDir);
    errorBeta_late.timing.nostop = SEF_stoppingLFP_function_getBurst_saccade...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [400 600],dataDir);
        
    
    %% For proactive control (baseline)
    % Clear the main variable
    fprintf('Extracting beta-burst information aligned on baseline (proactive)... | \n')
    clear proactiveBeta
    
    % Find the no-stop trials after no-stop, canceled, and non-canceled trials
    % by session.
    for ii = 1:29
        % No-stop after non-canceled
        ttx.GO_after_NC{ii} = executiveBeh.Trials.all{ii}.t_GO_after_NC;
        % No-stop after canceled
        ttx.GO_after_C{ii} = executiveBeh.Trials.all{ii}.t_GO_after_C;
        % No-stop after no-stop
        ttx.GO_after_GO{ii} = executiveBeh.Trials.all{ii}.t_GO_after_GO;
    end
    
    
    proactiveBeta.timing.bl_canceled = SEF_stoppingLFP_function_getBurst_baseline...
        (corticalLFPcontacts.all, ttx.GO_after_C, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, dataDir);
    proactiveBeta.timing.bl_noncanceled = SEF_stoppingLFP_function_getBurst_baseline...
        (corticalLFPcontacts.all,ttx.GO_after_NC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, dataDir);
    proactiveBeta.timing.bl_nostop = SEF_stoppingLFP_function_getBurst_baseline...
        (corticalLFPcontacts.all,ttx.GO_after_GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, dataDir);
    
    
    %% Save output
    saveDir = fullfile(dataDir,'burst');
    save(fullfile(saveDir, 'burstData_fixation'),'fixationBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_target'),'targetBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_stopping'),'stoppingBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_ssrt'),'ssrtBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_pretone'),'pretoneBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_posttone'),'posttoneBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_earlyError'),'errorBeta_early','-v7.3')
    
end













