% Get indicies of contacts that fall into perpendicular penetrations
laminarContacts = corticalLFPcontacts.all(corticalLFPcontacts.subset.laminar.all);
euPerpIdx = 1:6; xPerpIdx = 7:16;

%% Convolve, and create trial specific BBDF
parfor lfpIdx = 1:length(laminarContacts)
    
    % Get admin details
    lfp = laminarContacts(lfpIdx)
    session = sessionLFPmap.session(lfp);
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 696. \n',lfp);
    
    % Load in beta output data for session
    % ... for fixation
    lfp_loadname_fixation = fullfile('LFP','target',['lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target']);
    lfpOutput_fixation = parload(fullfile(fullfile(dataDir,'lfp'), lfp_loadname_fixation));
    % ... for stopping and post-ssrt
    lfp_loadname_stopping = fullfile('LFP','stopSignal',['lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal']);
    lfpOutput_stopping = parload(fullfile(fullfile(dataDir,'lfp'), lfp_loadname_stopping));
    
    % Get behavioral information
    ssrt = round(bayesianSSRT.ssrt_mean(session));
    
    % Set analysis windows    
    fixationWindow = 1000+[-400:-200];
    stoppingWindow = 1000+[0:ssrt];
    ssrtWindow = 1000+[ssrt+100:ssrt+300];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Latency match LFP signals between canceled and no-stop
    %  initialise array
    c_temp_fixation = []; ns_temp_fixation = [];  
    c_temp_stopping = []; ns_temp_stopping = [];  
    c_temp_ssrt = []; ns_temp_ssrt = [];  
    
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
                        
        else % If not enough trials, then just NaN out.
            c_temp_fixation(ii,:) = NaN(1,length(fixationWindow)); ns_temp_fixation(ii,:) = NaN(1,length(fixationWindow));            
            c_temp_stopping(ii,:) = NaN(1,length(stoppingWindow)); ns_temp_stopping(ii,:) = NaN(1,length(stoppingWindow));            
            c_temp_ssrt(ii,:) = NaN(1,length(ssrtWindow)); ns_temp_ssrt(ii,:) = NaN(1,length(ssrtWindow));            
        end
        
    end
    
    % For each of these windows (fix, stop, ssrt), get the power
    fixation_power_canceled(lfpIdx,1) = bandpower(nanmean(c_temp_fixation),1000,[14 29]);
    fixation_power_nostop(lfpIdx,1) = bandpower(nanmean(ns_temp_fixation),1000,[14 29]);
    stopSignal_power_canceled(lfpIdx,1) = bandpower(nanmean(c_temp_stopping),1000,[14 29]);
    stopSignal_power_nostop(lfpIdx,1) = bandpower(nanmean(ns_temp_stopping),1000,[14 29]);
    ssrt_power_canceled(lfpIdx,1) = bandpower(nanmean(c_temp_ssrt),1000,[14 29]);
    ssrt_power_nostop(lfpIdx,1) = bandpower(nanmean(ns_temp_ssrt),1000,[14 29]);

end


% Collate the power data into a table
depthTable = table(fixation_power_canceled, fixation_power_nostop,...
    stopSignal_power_canceled, stopSignal_power_nostop,...
    ssrt_power_canceled, ssrt_power_nostop);

% And combine this with the cortical lfp map for future subsetting (i.e. by
% monkey, laminar, depth, etc...)
depthTable = [corticalLFPmap(corticalLFPcontacts.subset.laminar.all,:), ...
    depthTable];

% Then add an extra label which splits the depths into laminar compartments
for contactIdx = 1:size(depthTable,1)
    % Find the depth and which layer it corresponds to in
    % laminarAlignment.list
    find_laminar = cellfun(@(c) find(c == depthTable.depth(contactIdx)), laminarAlignment.list, 'uniform', false);
    find_laminar = find(~cellfun(@isempty,find_laminar));
    % Create a new column with the corresponding laminar compartment label.
    depthTable.laminar(contactIdx,1) = laminarAlignment.labels(find_laminar);
    
    if find_laminar < 3
        depthTable.upper_lower(contactIdx,1) = {'Upper'};
    else
        depthTable.upper_lower(contactIdx,1) = {'Lower'};
    end
    
end

%% Normalise the power data for each contact
%  so that it is proportional the maximal power
%  recorded for the given session.

for sessionIdx = 14:29
    % Find the contacts within each perp session
    sessionContacts = []; sessionContacts = find(depthTable.session == sessionIdx);
    
    % Get the maximal power in the session for each epoch.
    maxPower_session_fixation = ...
        max([depthTable.fixation_power_canceled(sessionContacts); depthTable.fixation_power_nostop(sessionContacts)]);
    maxPower_session_stopping = ...
        max([depthTable.stopSignal_power_canceled(sessionContacts); depthTable.stopSignal_power_nostop(sessionContacts)]);
    maxPower_session_ssrt = ...
        max([depthTable.ssrt_power_canceled(sessionContacts); depthTable.ssrt_power_nostop(sessionContacts)]);
    
    
    depths = [];
    depth_session = depthTable.depth(sessionContacts);
    maxpower_depth(sessionIdx-13,1) = depth_session(find(depthTable.stopSignal_power_canceled(sessionContacts)...
        == max(depthTable.stopSignal_power_canceled(sessionContacts))));
    
    
    % Adjust the values in the table to normalise against the maximal power
    depthTable.fixation_power_nostop(sessionContacts) = depthTable.fixation_power_nostop(sessionContacts);%./maxPower_session_fixation;
    depthTable.fixation_power_canceled(sessionContacts) = depthTable.fixation_power_canceled(sessionContacts);%./maxPower_session_fixation;
    depthTable.stopSignal_power_canceled(sessionContacts) = depthTable.stopSignal_power_canceled(sessionContacts);%./maxPower_session_stopping;
    depthTable.stopSignal_power_nostop(sessionContacts) = depthTable.stopSignal_power_nostop(sessionContacts);%./maxPower_session_stopping;
    depthTable.ssrt_power_canceled(sessionContacts) = depthTable.ssrt_power_canceled(sessionContacts);%./maxPower_session_ssrt;
    depthTable.ssrt_power_nostop(sessionContacts) = depthTable.ssrt_power_nostop(sessionContacts);%./maxPower_session_ssrt;
end

%% Output data for JASP
writetable(depthTable,fullfile(rootDir,'results','jasp_tables','depth_power_epoch.csv'),'WriteRowNames',true)

% Run a quick one-way t-test to find out if the contact with the maximal
% beta power was significantly far enough from the L3/5 border.
[h, p, ~, stats] = ttest((maxpower_depth - 8) * 150);

%% Generate figure
%  Here we are plotting a point and 95% CI plot for each layer. We then
%  create 3 figures for each epoch.
% ... Stopping beta-power on canceled/no-stop trials across layers
clear fig_stopping_depth fig_stopping_gramm
fig_stopping_depth = [depthTable.upper_lower; depthTable.upper_lower];
fig_stopping_label = [repmat({'Canceled'},249,1); repmat({'No-stop'},249,1)];
fig_stopping_data = [depthTable.stopSignal_power_canceled;depthTable.stopSignal_power_nostop];
fig_stopping_gramm(1,1) = gramm('x',fig_stopping_depth,'y',fig_stopping_data,'color',fig_stopping_label);
fig_stopping_gramm(1,1).stat_summary('geom',{'point','errorbar'});
fig_stopping_gramm(1,1).axe_property('YLim',[0 1]);
fig_stopping_gramm(1,1).set_title('Stopping');
figure('Position',[100 100 500  400]);
fig_stopping_gramm.draw();


clear fig_stopping_depth fig_stopping_gramm
fig_stopping_depth = [depthTable.upper_lower; depthTable.upper_lower];
fig_stopping_label = [repmat({'Canceled'},249,1); repmat({'No-stop'},249,1)];
fig_stopping_data = [depthTable.stopSignal_power_canceled;depthTable.stopSignal_power_nostop];
fig_stopping_gramm(1,1) = gramm('x',fig_stopping_depth,'y',fig_stopping_data,'color',fig_stopping_label);
fig_stopping_gramm(1,1).stat_summary('geom',{'point','errorbar'});
fig_stopping_gramm(1,1).axe_property('YLim',[0 1]);
fig_stopping_gramm(1,1).facet_grid(repmat(depthTable.monkeyName,2,1),[]);
figure('Position',[100 100 500 600]);
fig_stopping_gramm.draw();


%%

for session = 1:16

    betaIdx = []; gammaIdx = [];
    betaIdx = find(f{session} > filterBands.alpha(1) & ...
        f{session} < filterBands.beta(2));
    
    gammaIdx = find(f{session} > filterBands.allGamma(1) & ...
        f{session} < filterBands.allGamma(2));
    
    nCh = size(PSDanalysis{session},1);
    
    beta_depth([1:nCh],session) = nanmean(PSDanalysis{session}(:,betaIdx),2);
    gamma_depth([1:nCh],session) = nanmean(PSDanalysis{session}(:,gammaIdx),2);
    
end

figure('Position',[100 100 600 250]);
subplot(1,3,1)
plot(nanmean(beta_depth(:,:),2),1:17); hold on
plot(nanmean(gamma_depth(:,:),2),1:17)
xlim([-50 50]); ylim([1 17])
hline(8.5,'k--')
set(gca,'YDir','Reverse')

subplot(1,3,2)
plot(nanmean(beta_depth(:,euPerpIdx),2),1:17); hold on
plot(nanmean(gamma_depth(:,euPerpIdx),2),1:17)
xlim([-50 50]); ylim([1 17])
hline(8.5,'k--')
set(gca,'YDir','Reverse')

subplot(1,3,3)
plot(nanmean(beta_depth(:,xenaPerpIdx),2),1:17); hold on
plot(nanmean(gamma_depth(:,xenaPerpIdx),2),1:17)
xlim([-50 50]); ylim([1 17])
hline(8.5,'k--')
set(gca,'YDir','Reverse')

%% Archive
% 
% % ... Fixation beta-power on canceled/no-stop trials across layers
% fig_fixation_depth = [depthTable.laminar; depthTable.laminar];
% fig_fixation_label = [repmat({'Canceled'},249,1); repmat({'No-stop'},249,1)];
% fig_fixation_data = [fixation_power_canceled;fixation_power_nostop];
% fig_fixation_gramm(1,1) = gramm('x',fig_fixation_depth,'y',fig_fixation_data,'color',fig_fixation_label);
% fig_fixation_gramm(1,1).stat_summary('geom',{'point','errorbar'});
% fig_fixation_gramm(1,1).axe_property('YLim',[0 1]);
% fig_fixation_gramm(1,1).set_title('Fixation');
% figure('Position',[100 100 500 200]);
% fig_fixation_gramm.draw();
% 
% % ... SSRT beta-power on canceled/no-stop trials across layers
% fig_ssrt_depth = [depthTable.laminar; depthTable.laminar];
% fig_ssrt_label = [repmat({'Canceled'},249,1); repmat({'No-stop'},249,1)];
% fig_ssrt_data = [ssrt_power_canceled;ssrt_power_nostop];
% fig_ssrt_gramm(1,1) = gramm('x',fig_ssrt_depth,'y',fig_ssrt_data,'color',fig_ssrt_label);
% fig_ssrt_gramm(1,1).stat_summary('geom',{'point','errorbar'});
% fig_ssrt_gramm(1,1).axe_property('YLim',[0 1]);
% fig_ssrt_gramm(1,1).set_title('SSRT');
% figure('Position',[100 100 500 200]);
% fig_ssrt_gramm.draw();