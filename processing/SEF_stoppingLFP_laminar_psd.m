
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
    lfp_loadname = ['LFP\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    lfpOutput = parload([outputDir lfp_loadname])
    LFP_all{lfpIdx} = lfpOutput.filteredLFP.all;
    
    % Get behavioral information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    % Get power information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stop-signal (latency matched aligned)
    c_temp = []; nc_temp = []; ns_temp = [];
    window = [1000+round(ssrt)+200:1000+round(ssrt)+400];
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        if length(executiveBeh.ttm_CGO{session,ii}.C_matched) >= 10 &&...
                length(executiveBeh.ttm_CGO{session,ii}.GO_matched) >= 10 &&...
                length(executiveBeh.ttm_c.NC{session,ii}.all) && 10
            
            c_temp(ii,:) = nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.C_matched, window));
            nc_temp(ii,:) = nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_c.NC{session,ii}.all, window));
            ns_temp(ii,:) = nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.GO_matched, window));
            
        else
            c_temp(ii,:) = NaN(1,length(window));
            nc_temp(ii,:) = NaN(1,length(window));
            ns_temp(ii,:) = NaN(1,length(window));
        end
        
    end
    
    % Get the power of the beta-actvity within the stopping period
    % for each contact, for...
    % ... canceled trials
    stopSignal_power_canceled_unmatched(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttx_canc{session}, window)));
    % ... noncanceled trials    
    stopSignal_power_noncanceled_unmatched(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttx.sNC{session}, window)));
    % ... nostop trials
    stopSignal_power_nostop_unmatched(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttx.GO{session}, window)));
    
    % Average power over this stopping period:
    stopSignal_power_canceled(lfpIdx,1) = bandpower(nanmean(c_temp));
    stopSignal_power_noncanc(lfpIdx,1) = bandpower(nanmean(nc_temp));
    stopSignal_power_nostop(lfpIdx,1) = bandpower(nanmean(ns_temp));
    
    stopSignal_power_allSSRT(lfpIdx,1) = bandpower(nanmean(lfpOutput.filteredLFP.beta(:, window)));
    stopSignal_power_all(lfpIdx,1) = bandpower(nanmean(lfpOutput.filteredLFP.beta(:, :)));
    
end

%% CSD Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Align LFPs by depth
for lfpIdx = 1:length(laminarContacts)
    
    % get contact and session information
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

% Run laminar toolbox
clear CSDanalysis PSDanalysis

parfor session = 1:16
    fprintf('Analysing session number %i of 16. \n',session);
    % Set baseline window for CSD
    baselineWin = [0:100]+1000;
    
    % Run current source density analysis
    CSDanalysis{session} = D_CSD_BASIC(LFP_aligned{session}, 'cndt', 0.4, 'spc', 150);
    % And baseline correct
    CSDanalysis{session} = CSD_blCorr(CSDanalysis{session}, baselineWin)  
    
    % Run power spectral density analysis
    [~, PSDanalysis{session}, f{session}] = D_PSD_BASIC(LFP_aligned{session});
    [o_out{session}, p_out{session}] = D_CSDBAND_BASIC(LFP_aligned{session}, 1000, 0.15, [15 29]);

end

%% Sort and organise CSD output
clear CSD_sessionMean PSD_sessionMean osc_sessionMean pow_sessionMean

% Intialise arrays:
CSD_sessionMean.canceled = nan(17,3000,length([1:16]));
CSD_sessionMean.noncanceled = nan(17,3000,length([1:16]));
CSD_sessionMean.nostop = nan(17,3000,length([1:16]));

osc_sessionMean.canceled = nan(17,3000,length([1:16])); 
osc_sessionMean.nostop = nan(17,3000,length([1:16]));
pow_sessionMean.canceled = nan(17,3000,length([1:16])); 
pow_sessionMean.nostop = nan(17,3000,length([1:16]));

PSD_sessionMean.all = nan(17,129,length([1:16]));

% For each laminar session
for session = 1:16
    fprintf('Analysing session number %i of 16. \n',session);
    
    % Loop through and get the average CSD at each SSD (for latency
    % matching)
    c_temp = []; ns_temp = []; osc_c_temp = []; osc_ns_temp = []; pow_c_temp = []; pow_ns_temp = [];
    for ii = 1:length(executiveBeh.inh_SSD{session})
        if ~isempty(executiveBeh.ttm_c.C{session+13,ii}) || ~isempty(executiveBeh.ttm_c.GO_C{session+13,ii})
            c_temp(:,:,ii) = nanmean(CSDanalysis{session}(:,:, executiveBeh.ttm_c.C{session+13,ii}.all),3);
            ns_temp(:,:,ii) = nanmean(CSDanalysis{session}(:,:, executiveBeh.ttm_c.GO_C{session+13,ii}.all),3);

            osc_c_temp(:,:,ii) = nanmean(o_out{session}(:,:, executiveBeh.ttm_c.C{session+13,ii}.all),3);
            osc_ns_temp(:,:,ii) = nanmean(o_out{session}(:,:, executiveBeh.ttm_c.GO_C{session+13,ii}.all),3);
       
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
    
    PSD_sessionMean.all(1:size(CSDanalysis{session},1),:,session) =...
        nanmean(PSDanalysis{session},3);    
    
end


%% Compare power at depths
stoppingPower = nan(length(1:17),3,length([14:29]));
stoppingPower_all = nan(length(1:17),1,length([14:29]));

for lfpIdx = 1:length(laminarContacts)
    
    lfp = laminarContacts(lfpIdx);
    session = sessionLFPmap.session(lfp);
    depth = sessionLFPmap.depth(lfp);
    
    stoppingPower(depth,1,session-13) = stopSignal_power_canceled(lfpIdx);
    stoppingPower(depth,2,session-13) = stopSignal_power_noncanc(lfpIdx);
    stoppingPower(depth,3,session-13) = stopSignal_power_nostop(lfpIdx);
    
    stoppingPower_all(depth,1,session-13) = stopSignal_power_all(lfpIdx);    
end

% Normalise power to the maximum observed in a session/penetration.

for session = 1:16
    stoppingPower_norm(:,session) = stoppingPower_all(:,:,session)./...
        nanmax(stoppingPower_all(:,:,session));
    
    stoppingPower_trlType_norm(:,:,session) = stoppingPower(:,:,session)...
        /max(max(stoppingPower(:,:,session)));

end

for session = 1:16
    stoppingPower_cancNorm(:,session) = stoppingPower_trlType_norm(:,1,session);
    stoppingPower_noncancNorm(:,session) = stoppingPower_trlType_norm(:,2,session);
    stoppingPower_nostopNorm(:,session) = stoppingPower_trlType_norm(:,3,session);

end

%% Generate relevant figures in a second script
SEF_stoppingLFP_figuresCSD
