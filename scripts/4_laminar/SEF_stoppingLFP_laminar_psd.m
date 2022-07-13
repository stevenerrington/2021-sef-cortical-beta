
%% Extract LFP data
laminarContacts = corticalLFPcontacts.all(corticalLFPcontacts.subset.laminar.all);

parfor lfpIdx = 1:length(laminarContacts)
    
    % Get electrode information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lfp = laminarContacts(lfpIdx)
    session = sessionLFPmap.session(lfp);
    depth = sessionLFPmap.depth(lfp);
    
    % Get session name (to load in relevant file) %%%%%%%%%%%%%%%%%%%%
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(laminarContacts));
    
    % Load in beta output data for session %%%%%%%%%%%%%%%%%%%%%%%%%%%
    lfp_loadname = fullfile('LFP','stopSignal',['lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal']);
    lfpOutput = parload(fullfile(outputDir, lfp_loadname));
    LFP_all{lfpIdx} = lfpOutput.filteredLFP.all;
    
    % Get behavioral information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    % Get power information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialise arrays
    c_temp = []; nc_temp = []; ns_temp = [];
    % Set window to calculate power over [SSRT + [200:400])
    window = [1000+round(ssrt)+200:1000+round(ssrt)+400];
    
    % For each SSD
    for ii = 1:length(executiveBeh.inh_SSD{session})
        % If there is greater than 10 trials, then work out the beta power
        if length(executiveBeh.ttm_CGO{session,ii}.C_matched) >= 10 &&...
                length(executiveBeh.ttm_CGO{session,ii}.GO_matched) >= 10 &&...
                length(executiveBeh.ttm_c.NC{session,ii}.all) && 10
            
            % For (c)canceled, (nc) noncanceled, and (ns) no-stop trials at
            % each SSD
            c_temp(ii,:) = nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.C_matched, window));
            nc_temp(ii,:) = nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_c.NC{session,ii}.all, window));
            ns_temp(ii,:) = nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.GO_matched, window));
            
        else
            % If less than ten trials, just NaN it out.
            c_temp(ii,:) = NaN(1,length(window));
            nc_temp(ii,:) = NaN(1,length(window));
            ns_temp(ii,:) = NaN(1,length(window));
        end
        
    end
    
    % Get the power of the  (non-latency matched) beta-actvity within the stopping period
    % for each contact, for...
    % ... canceled trials
    stopSignal_power_canceled_unmatched(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttx_canc{session}, window)),...
        1000,[14 29]);
    % ... noncanceled trials    
    stopSignal_power_noncanceled_unmatched(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttx.sNC{session}, window)),...
        1000,[14 29]);
    % ... nostop trials
    stopSignal_power_nostop_unmatched(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttx.GO{session}, window)),...
        1000,[14 29]);
    
    
    % Get the power of the (latency matched) beta-actvity within the stopping period
    % for each contact, for...
    stopSignal_power_canceled_beta(lfpIdx,1) = bandpower(nanmean(c_temp),1000,[14 29]);
    stopSignal_power_noncanc_beta(lfpIdx,1) = bandpower(nanmean(nc_temp),1000,[14 29]);
    stopSignal_power_nostop_beta(lfpIdx,1) = bandpower(nanmean(ns_temp),1000,[14 29]);

    
    stopSignal_power_canceled_gamma(lfpIdx,1) = bandpower(nanmean(c_temp),1000,[80 160]);
    stopSignal_power_noncanc_gamma(lfpIdx,1) = bandpower(nanmean(nc_temp),1000,[80 160]);
    stopSignal_power_nostop_gamma(lfpIdx,1) = bandpower(nanmean(ns_temp),1000,[80 160]);
    
    % Also calculate power regardless of trial type
    stopSignal_power_allSSRT(lfpIdx,1) = bandpower(nanmean(lfpOutput.filteredLFP.beta(:, window)),1000,[14 29]);
    stopSignal_power_all(lfpIdx,1) = bandpower(nanmean(lfpOutput.filteredLFP.beta(:, :)),1000,[14 29]);
    
end

%% CSD Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Align LFPs by depth to input into the CSD analysis function
for lfpIdx = 1:length(laminarContacts)
    
    % Get contact and session information
    lfp = laminarContacts(lfpIdx);
    session = sessionLFPmap.session(lfp);
    depth = sessionLFPmap.depth(lfp);
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(laminarContacts));
    
    % Determine the number of trials
    nTrls = size(LFP_all{lfpIdx},1);
    
    % Organise signals by depth x time x trial for CSD analysis
    for ii = 1:nTrls
        LFP_aligned{session-13}(depth,:,ii) = LFP_all{lfpIdx}(ii,:);
    end
end

% Run laminar toolbox %%
clear CSDanalysis PSDanalysis

% For each session with perp penetrations
parfor session = 1:16
    fprintf('Analysing session number %i of 16. \n',session);
    % Set baseline window for CSD
    baselineWin = [0:100]+1000; % This is 0 to 100 ms after the stop-signal
    
    % Run current source density analysis (0.4 conductance, 150 um spacing
    % on electrode)...
    CSDanalysis{session} = D_CSD_BASIC(LFP_aligned{session}, 'cndt', 0.4, 'spc', 150);
    % ..and baseline correct
    CSDanalysis{session} = CSD_blCorr(CSDanalysis{session}, baselineWin)  
    
    % Run power spectral density analysis
    [~, PSDanalysis{session}, f{session}] = D_PSD_BASIC(LFP_aligned{session});
    [o_out{session}, p_out{session}] = D_CSDBAND_BASIC(LFP_aligned{session}, 1000, 0.15, [15 29]);

end

% Sort and organise CSD output %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear variable to make sure we're working from a clean slate
clear CSD_sessionMean PSD_sessionMean osc_sessionMean pow_sessionMean

% Intialise arrays
%    ... for CSD
CSD_sessionMean.canceled = nan(17,3000,length([1:16]));
CSD_sessionMean.noncanceled = nan(17,3000,length([1:16]));
CSD_sessionMean.nostop = nan(17,3000,length([1:16]));
%    ... for OSC and power
osc_sessionMean.canceled = nan(17,3000,length([1:16])); 
osc_sessionMean.nostop = nan(17,3000,length([1:16]));
pow_sessionMean.canceled = nan(17,3000,length([1:16])); 
pow_sessionMean.nostop = nan(17,3000,length([1:16]));

%    ... and power spectral density
PSD_sessionMean.all = nan(17,129,length([1:16]));

% With these arrays initialised, for each laminar session
for session = 1:16
    fprintf('Analysing session number %i of 16. \n',session);
    
    % loop through and get the average CSD at each SSD (for latency
    % matching)
    
    % Initialise the arrays in which data will be inputed
    c_temp = []; ns_temp = []; osc_c_temp = []; osc_ns_temp = []; pow_c_temp = []; pow_ns_temp = [];
    
    % For each SSD
    for ii = 1:length(executiveBeh.inh_SSD{session})
        % If there are enough canceled or latency-matched no-stop trials
        if ~isempty(executiveBeh.ttm_c.C{session+13,ii}) || ~isempty(executiveBeh.ttm_c.GO_C{session+13,ii})
            
            % Get the mean CSD for the given session for canceled (c) and
            % no-stop (ns) at the given SSD
            c_temp(:,:,ii) = nanmean(CSDanalysis{session}(:,:, executiveBeh.ttm_c.C{session+13,ii}.all),3);
            ns_temp(:,:,ii) = nanmean(CSDanalysis{session}(:,:, executiveBeh.ttm_c.GO_C{session+13,ii}.all),3);
            
            % Get the mean OSC for the given session for canceled (c) and
            % no-stop (ns) at the given SSD
            osc_c_temp(:,:,ii) = nanmean(o_out{session}(:,:, executiveBeh.ttm_c.C{session+13,ii}.all),3);
            osc_ns_temp(:,:,ii) = nanmean(o_out{session}(:,:, executiveBeh.ttm_c.GO_C{session+13,ii}.all),3);
            
            % Get the mean power for the given session for canceled (c) and
            % no-stop (ns) at the given SSD       
            pow_c_temp(:,:,ii) = nanmean(p_out{session}(:,:, executiveBeh.ttm_c.C{session+13,ii}.all),3);
            pow_ns_temp(:,:,ii) = nanmean(p_out{session}(:,:, executiveBeh.ttm_c.GO_C{session+13,ii}.all),3);
       
        else
            continue
        end
    end
    
    % Average across all SSD's in order to latency match.
    
    CSD_sessionMean.canceled(1:size(CSDanalysis{session},1),:,session) =...
        nanmean(c_temp,3);
    CSD_sessionMean.nostop(1:size(CSDanalysis{session},1),:,session) =...
        nanmean(ns_temp,3);
    
    osc_sessionMean.canceled(1:size(o_out{session},1),:,session) =...
        nanmean(osc_c_temp,3);
    osc_sessionMean.nostop(1:size(o_out{session},1),:,session) =...
        nanmean(osc_ns_temp,3);    
    
    pow_sessionMean.canceled(1:size(p_out{session},1),:,session) =...
        nanmean(pow_c_temp,3);
    pow_sessionMean.nostop(1:size(p_out{session},1),:,session) =...
        nanmean(pow_ns_temp,3);       
    
    % As PSD is across trials, we can just take the mean of all trials.
    PSD_sessionMean.all(1:size(CSDanalysis{session},1),:,session) =...
        nanmean(PSDanalysis{session},3);    
    
end


%% Compare power at depths

% Initialise arrays
stoppingPower_beta = nan(length(1:17),3,length([14:29]));
stoppingPower_gamma = nan(length(1:17),3,length([14:29]));
stoppingPower_all = nan(length(1:17),1,length([14:29]));

% For each contact in perpendcular penetrations
for lfpIdx = 1:length(laminarContacts)
    
    % Get the relevant admin
    lfp = laminarContacts(lfpIdx);
    session = sessionLFPmap.session(lfp);
    depth = sessionLFPmap.depth(lfp);
    
    % Get the latency-matched band power for canceled (1), non-canceled
    % (2), and no-stop (3) trials. (num corresponds to column in
    % stoppingPower array).
    stoppingPower_beta(depth,1,session-13) = stopSignal_power_canceled_beta(lfpIdx);
    stoppingPower_beta(depth,2,session-13) = stopSignal_power_noncanc_beta(lfpIdx);
    stoppingPower_beta(depth,3,session-13) = stopSignal_power_nostop_beta(lfpIdx);
    
    stoppingPower_gamma(depth,1,session-13) = stopSignal_power_canceled_gamma(lfpIdx);
    stoppingPower_gamma(depth,2,session-13) = stopSignal_power_noncanc_gamma(lfpIdx);
    stoppingPower_gamma(depth,3,session-13) = stopSignal_power_nostop_gamma(lfpIdx);
    
    stoppingPower_all(depth,1,session-13) = stopSignal_power_all(lfpIdx);    
end

% To compare across sessions, here I will normalise power to the 
% maximum observed in a session/penetration.
for session = 1:16
    % In a given session, the depth with the maximum power will be valued
    % at 1, whilst the other values are proportional to this.
    for trialTypeIdx = 1:3
%     stoppingPower_norm(:,session) = stoppingPower_all(:,trialTypeIdx,session)./...
%         nanmax(stoppingPower_all(:,trialTypeIdx,session));
    % Here, I am looking at the max across all trial types
    stoppingPower_trlType_norm_beta(:,trialTypeIdx,session) = stoppingPower_beta(:,trialTypeIdx,session)...
        /max(max(stoppingPower_beta(:,trialTypeIdx,session)));
    stoppingPower_trlType_norm_gamma(:,trialTypeIdx,session) = stoppingPower_gamma(:,trialTypeIdx,session)...
        /max(max(stoppingPower_gamma(:,trialTypeIdx,session)));
    end
    
end

% Here, I then split the power into separate arrays for each trial type.
for session = 1:16
    stoppingPower_cancNorm_beta(:,session) = stoppingPower_trlType_norm_beta(:,1,session);
    stoppingPower_noncancNorm_beta(:,session) = stoppingPower_trlType_norm_beta(:,2,session);
    stoppingPower_nostopNorm_beta(:,session) = stoppingPower_trlType_norm_beta(:,3,session);

    stoppingPower_cancNorm_gamma(:,session) = stoppingPower_trlType_norm_gamma(:,1,session);
    stoppingPower_noncancNorm_gamma(:,session) = stoppingPower_trlType_norm_gamma(:,2,session);
    stoppingPower_nostopNorm_gamma(:,session) = stoppingPower_trlType_norm_gamma(:,3,session);
end
