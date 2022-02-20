
laminarContacts = corticalLFPcontacts.all(corticalLFPcontacts.subset.laminar.all);
euPerpIdx = 1:6; xPerpIdx = 7:16;

%% Convolve, and create trial specific BBDF
parfor lfpIdx = 1:length(laminarContacts)
    
    lfp = laminarContacts(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 696. \n',lfp);
    
    % Load in beta output data for session
    lfp_loadname_fixation = ['LFP\target\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target'];
    lfp_loadname_stopping = ['LFP\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
%     lfp_loadname_tone = ['LFP\tone\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_tone'];
    lfpOutput_fixation = parload([outputDir lfp_loadname_fixation]);
    lfpOutput_stopping = parload([outputDir lfp_loadname_stopping]);
%     lfpOutput_tone = parload([outputDir lfp_loadname_tone]);
    
    % Get behavioral information
    ssrt = round(bayesianSSRT.ssrt_mean(session));
    
    % Set analysis windows    
    fixationWindow = 1000+[-400:-200];
    stoppingWindow = 1000+[0:ssrt];
    ssrtWindow = 1000+[ssrt+200:ssrt+400];
%     toneWindow = 1000+[-400:-200];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Latency match LFP signals between canceled and no-stop
    c_temp_fixation = []; ns_temp_fixation = [];  
    c_temp_stopping = []; ns_temp_stopping = [];  
    c_temp_ssrt = []; ns_temp_ssrt = [];  
%     c_temp_tone = []; ns_temp_tone = [];  
    
    % For each SSD, get the aligned LFP
    for ii = 1:length(executiveBeh.inh_SSD{session})
        % If there are greater than 10 canceled, noncanc, nostop trials
        if length(executiveBeh.ttm_CGO{session,ii}.C_matched) >= 10 &&...
                length(executiveBeh.ttm_CGO{session,ii}.GO_matched) >= 10 &&...
                length(executiveBeh.ttm_c.NC{session,ii}.all) && 10
            
            % Fixation
            c_temp_fixation(ii,:) = nanmean(lfpOutput_fixation.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.C_matched, fixationWindow));
            ns_temp_fixation(ii,:) = nanmean(lfpOutput_fixation.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.GO_matched, fixationWindow));
            % Stopping
            c_temp_stopping(ii,:) = nanmean(lfpOutput_stopping.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.C_matched, stoppingWindow));
            ns_temp_stopping(ii,:) = nanmean(lfpOutput_stopping.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.GO_matched, stoppingWindow));
            % SSRT
            c_temp_ssrt(ii,:) = nanmean(lfpOutput_stopping.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.C_matched, ssrtWindow));
            ns_temp_ssrt(ii,:) = nanmean(lfpOutput_stopping.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.GO_matched, ssrtWindow));
            % Tone
%             c_temp_tone(ii,:) = nanmean(lfpOutput_tone.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.C_matched, toneWindow));
%             ns_temp_tone(ii,:) = nanmean(lfpOutput_tone.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.GO_matched, toneWindow));        
        else % If not enough trials, then just NaN out.
            c_temp_fixation(ii,:) = NaN(1,length(fixationWindow));
            ns_temp_fixation(ii,:) = NaN(1,length(fixationWindow));            
            c_temp_stopping(ii,:) = NaN(1,length(stoppingWindow));
            ns_temp_stopping(ii,:) = NaN(1,length(stoppingWindow));            
            c_temp_ssrt(ii,:) = NaN(1,length(ssrtWindow));
            ns_temp_ssrt(ii,:) = NaN(1,length(ssrtWindow));            
%             c_temp_tone(ii,:) = NaN(1,length(toneWindow));
%             ns_temp_tone(ii,:) = NaN(1,length(toneWindow));
        end
        
    end
    
    % Get power over the LFP windows
    fixation_power_canceled(lfpIdx,1) = bandpower(nanmean(c_temp_fixation));
    fiation_power_nostop(lfpIdx,1) = bandpower(nanmean(ns_temp_fixation));
    stopSignal_power_canceled(lfpIdx,1) = bandpower(nanmean(c_temp_stopping));
    stopSignal_power_nostop(lfpIdx,1) = bandpower(nanmean(ns_temp_stopping));
    ssrt_power_canceled(lfpIdx,1) = bandpower(nanmean(c_temp_ssrt));
    ssrt_power_nostop(lfpIdx,1) = bandpower(nanmean(ns_temp_ssrt));
%     tone_power_canceled(lfpIdx,1) = bandpower(nanmean(c_temp_tone));
%     tone_power_nostop(lfpIdx,1) = bandpower(nanmean(ns_temp_tone));

end


%%
depthTable = table(fixation_power_canceled, fiation_power_nostop,...
    stopSignal_power_canceled, stopSignal_power_nostop,...
    ssrt_power_canceled, ssrt_power_nostop);


depthTable = [corticalLFPmap(corticalLFPcontacts.subset.laminar.all,:), ...
    depthTable];

depths = unique(depthTable.depth);

for ii = 1:max(depths)
    depthLFPidx = []; depthLFPidx = find(depthTable.depth == depths(ii));
    
    a{ii} = depthTable.fixation_power_canceled(depthLFPidx)
    b{ii} = depthTable.fiation_power_nostop(depthLFPidx)
    c{ii} = depthTable.stopSignal_power_canceled(depthLFPidx)
    d{ii} = depthTable.stopSignal_power_nostop(depthLFPidx)
    e{ii} = depthTable.ssrt_power_canceled(depthLFPidx)
    f{ii} = depthTable.ssrt_power_nostop(depthLFPidx)
    
end



%% Figure

[repmat({'Fixation'},509,1); repmat({'STOP'},509,1); repmat({'SSRT'},509,1)];
[repmat({'Canceled'},509*3,1); repmat({'No-stop'},509*3,1)];
[fixation_power_canceled;stopSignal_power_canceled;ssrt_power_canceled;...
    fiation_power_nostop;stopSignal_power_nostop;ssrt_power_nostop];
