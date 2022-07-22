%% Get beta-burst features for each condition and epoch. %%%%%%%%%%%%%%%%%
clc;

% If the data is already extracted, then load it in.
if exist(fullfile(dataDir,'burst', 'burstData_stopping.mat'),'file') == 2
    loadBurstData
else % Otherwise, extract the data
    %% For baseline/fixation period (-400 to -200 ms, pre-target) %%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on fixation... | \n')
    fixationBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_baseline...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    fixationBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_baseline...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    fixationBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_baseline...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    
    %% For target period (0 to 200 ms, post-target) %%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on target... | \n')
    targetBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_target...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    targetBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_target...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    targetBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_target...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    
    %% For stopping period (0 to SSRT ms, post-stop-signal) %%%%%%%%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on stop signal... | \n')
    stoppingBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_stop...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    stoppingBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_stop...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    stoppingBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_stop...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    
    %% For SSRT period (SSRT+200 to SSRT + 400 ms, post-stop-signal) %%%%%%%%%
    fprintf('Extracting beta-burst information aligned on ssrt... | \n')
    ssrtBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_ssrt...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    ssrtBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_ssrt...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold,fullfile(dataDir,'lfp'));
    
    %% For pretone period (-400 to -200, pre-tone) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on tone (pre-tone)... | \n')
    pretoneBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [-400 -200],fullfile(dataDir,'lfp'));
    pretoneBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [-400 -200],fullfile(dataDir,'lfp'));
    pretoneBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [-400 -200],fullfile(dataDir,'lfp'));
    
    %% For posttone period (100 to 300, pre-tone) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Extracting beta-burst information aligned on tone(post-tone)... | \n')
    posttoneBeta.timing.canceled = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300],fullfile(dataDir,'lfp'));
    posttoneBeta.timing.nostop = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300],fullfile(dataDir,'lfp'));
    posttoneBeta.timing.noncanceled = SEF_stoppingLFP_function_getBurst_tone...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [100 300],fullfile(dataDir,'lfp'));
    
    %% For early error period (0 to 300 ms, post-saccade)
    fprintf('Extracting beta-burst information aligned on saccade (early-error)... | \n')
    errorBeta_early.timing.noncanc = SEF_stoppingLFP_function_getBurst_saccade...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [0 300],fullfile(dataDir,'lfp'));
    errorBeta_early.timing.nostop = SEF_stoppingLFP_function_getBurst_saccade...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [0 300],fullfile(dataDir,'lfp'));
    
    %% For late error period (300 to 600 ms, post-saccade)
    fprintf('Extracting beta-burst information aligned on saccade (late-error)... | \n')
    errorBeta_late.timing.noncanc = SEF_stoppingLFP_function_getBurst_saccade...
        (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [300 600],fullfile(dataDir,'lfp'));
    errorBeta_late.timing.nostop = SEF_stoppingLFP_function_getBurst_saccade...
        (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [300 600],fullfile(dataDir,'lfp'));
    
    
    %% Save output
    saveDir = fullfile(dataDir,'burst');
    save(fullfile(saveDir, 'burstData_fixation'),'fixationBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_target'),'targetBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_stopping'),'stoppingBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_ssrt'),'ssrtBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_pretone'),'pretoneBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_posttone'),'posttoneBeta','-v7.3')
    save(fullfile(saveDir, 'burstData_earlyError'),'errorBeta_early','-v7.3')
    save(fullfile(saveDir, 'burstData_lateError'),'errorBeta_late','-v7.3')
    
end













