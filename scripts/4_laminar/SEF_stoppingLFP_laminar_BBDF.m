% Get contacts that fall in perpendicular penetration
clear laminarContacts
laminarContacts.all = find(corticalLFPmap.laminarFlag == 1);
laminarTable = corticalLFPmap(laminarContacts.all,:);
laminarContacts.upper = find(laminarTable.depth < 9);
laminarContacts.lower = find(laminarTable.depth > 8);

% Initialise array
bbdf_depth_cancAll_SSD = nan(17,3001,length([1:16]));

% Extract BBDF from files
for ii = 1:length(laminarContacts.all)
    
    % Get admin information (session, depth, etc...)
    lfp = laminarContacts.all(ii);
    depth = corticalLFPmap.depth(lfp);
    session = corticalLFPmap.session(lfp);
    fprintf('Analysing LFP number %i of %i. \n',ii,length(laminarContacts.all));
    
    % Load the previously extracted BBDF
    bbdfData = load(fullfile(matDir,'bbdf',['bbdf_' int2str(lfp)]));
        
    % Latency-match BBDF
    %  Initialise loops to be used in array
    c_temp_fix = []; ns_temp_fix = [];
    c_temp_ssd = []; ns_temp_ssd = [];
    nc_temp_sacc = []; ns_temp_sacc = [];
    c_temp_tone = []; ns_temp_tone = [];
    
    % For each SSD
    for ssdIdx = 1:length(executiveBeh.inh_SSD{session})
        % Fixation aligned BBDF
        c_temp_fix(ssdIdx,:) = nanmean(bbdfData.bbdf.target(executiveBeh.ttm_CGO{session,ssdIdx}.C_matched, :));
        ns_temp_fix(ssdIdx,:) = nanmean(bbdfData.bbdf.target(executiveBeh.ttm_CGO{session,ssdIdx}.GO_matched, :));
        
        % SSD aligned BBDF
        c_temp_ssd(ssdIdx,:) = nanmean(bbdfData.bbdf.ssd(executiveBeh.ttm_CGO{session,ssdIdx}.C_matched, :));
        ns_temp_ssd(ssdIdx,:) = nanmean(bbdfData.bbdf.ssd(executiveBeh.ttm_CGO{session,ssdIdx}.GO_matched, :));
        
        % Saccade aligned BBDF
        nc_temp_sacc(ssdIdx,:) = nanmean(bbdfData.bbdf.saccade(executiveBeh.ttm_c.NC{session,ssdIdx}.all, :));
        ns_temp_sacc(ssdIdx,:) = nanmean(bbdfData.bbdf.saccade(executiveBeh.ttm_c.GO_NC{session,ssdIdx}.all, :));
        
        % Tone aligned BBDF
        c_temp_tone(ssdIdx,:) = nanmean(bbdfData.bbdf.tone(executiveBeh.ttm_CGO{session,ssdIdx}.C_matched, :));
        ns_temp_tone(ssdIdx,:) = nanmean(bbdfData.bbdf.tone(executiveBeh.ttm_CGO{session,ssdIdx}.GO_matched, :));
    end
    
    % Average across SSD latency matched BBDFs
    bbdf_depth_cancLatency_fix{ii,1} = nanmean(c_temp_fix);
    bbdf_depth_nostopLatency_fix{ii,1} = nanmean(ns_temp_fix);
    
    bbdf_depth_cancLatency_SSD{ii,1} = nanmean(c_temp_ssd);
    bbdf_depth_nostopLatency_SSD{ii,1} = nanmean(ns_temp_ssd);
    
    bbdf_depth_noncancLatency_Sacc{ii,1} = nanmean(nc_temp_sacc);
    bbdf_depth_nostopLatency_Sacc{ii,1} = nanmean(ns_temp_sacc);
    
    bbdf_depth_cancLatency_Tone{ii,1} = nanmean(c_temp_tone);
    bbdf_depth_nostopLatency_Tone{ii,1} = nanmean(ns_temp_tone);
    
    
    bbdf_depth_cancAll_Fix(depth,:,session-13) = nanmean(c_temp_fix);
    bbdf_depth_cancAll_SSD(depth,:,session-13) = nanmean(c_temp_ssd);
    bbdf_depth_noncancAll_Saccade(depth,:,session-13) = nanmean(nc_temp_sacc);
    bbdf_depth_cancAll_tone(depth,:,session-13) = nanmean(c_temp_tone);
    
end

% Set plot windows
plotWindow_fix = [-600:0]+1000;
plotWindow_ssd = [-200:600]+1000;
plotWindow_saccade = [-200:600]+1000;
plotWindow_tone = [-600:0]+1000;

% Normalise data (Z-score - relative to window)
clear bbdf_depth_norm_SSD bbdf_depth_norm_Tone bbdf_depth_norm_Saccade
for session = 1:16
    % Take the BBDF and normalise it by calculating values relative to mean
    % of the window
    
    % ...for fixation
    bbdf_depth_norm_Fix(:,:,session) = (bbdf_depth_cancAll_Fix(:,plotWindow_fix,session)-...
        nanmean(nanmean(bbdf_depth_cancAll_Fix(:,plotWindow_fix,session))))./...
        nanstd(nanstd(bbdf_depth_cancAll_Fix(:,plotWindow_fix,session)));
    
    % ...for SSD
    bbdf_depth_norm_SSD(:,:,session) = (bbdf_depth_cancAll_SSD(:,plotWindow_ssd,session)-...
        nanmean(nanmean(bbdf_depth_cancAll_SSD(:,plotWindow_ssd,session))))./...
        nanstd(nanstd(bbdf_depth_cancAll_SSD(:,plotWindow_ssd,session)));
    
    % ...for saccade
    bbdf_depth_norm_Saccade(:,:,session) = (bbdf_depth_noncancAll_Saccade(:,plotWindow_saccade,session)-...
        nanmean(nanmean(bbdf_depth_noncancAll_Saccade(:,plotWindow_saccade,session))))./...
        nanstd(nanstd(bbdf_depth_noncancAll_Saccade(:,plotWindow_saccade,session)));
    
    % ...for saccade
    bbdf_depth_norm_Tone(:,:,session) = (bbdf_depth_cancAll_tone(:,plotWindow_tone,session)-...
        nanmean(nanmean(bbdf_depth_cancAll_tone(:,plotWindow_tone,session))))./...
        nanstd(nanstd(bbdf_depth_cancAll_tone(:,plotWindow_tone,session)));
end


% Average data across sessions for upper (ch 1:8) and lower (ch 9:end) layers and save
% output for each aligned epoch (fixation, SSD, saccade, and tone)
for session = 1:16
    bbdf_upper_Fix{session,1} = nanmean(bbdf_depth_norm_Fix(1:8,:,session));
    bbdf_lower_Fix{session,1} = nanmean(bbdf_depth_norm_Fix(9:end,:,session));
    
    bbdf_upper_SSD{session,1} = nanmean(bbdf_depth_norm_SSD(1:8,:,session));
    bbdf_lower_SSD{session,1} = nanmean(bbdf_depth_norm_SSD(9:end,:,session));
    
    bbdf_upper_Saccade{session,1} = nanmean(bbdf_depth_norm_Saccade(1:8,:,session));
    bbdf_lower_Saccade{session,1} = nanmean(bbdf_depth_norm_Saccade(9:end,:,session));
    
    bbdf_upper_Tone{session,1} = nanmean(bbdf_depth_norm_Tone(1:8,:,session));
    bbdf_lower_Tone{session,1} = nanmean(bbdf_depth_norm_Tone(9:end,:,session));
end


%% Smooth BBDF for figures
sessionList = {[1:16],[1:6],[7:16]};

for sessionIdx = 1:length(sessionList)
    sessionInput = [];
    sessionInput = sessionList{sessionIdx};
    clear bbdfAverage*
    % Fixation-aligned session average BBDF x depth x time
    bbdfAverage_fix = nanmean(bbdf_depth_norm_Fix(:,:,sessionInput),3); % Average BBDF across sessions
    bbdfAverageSmooth_fix = H_2DSMOOTH(bbdfAverage_fix); % Smooth the BBDF across depth and time
    
    % SSD-aligned session average BBDF x depth x time
    bbdfAverage_ssd = nanmean(bbdf_depth_norm_SSD(:,:,sessionInput),3); % Average BBDF across sessions
    bbdfAverageSmooth_ssd = H_2DSMOOTH(bbdfAverage_ssd); % Smooth the BBDF across depth and time
    
    % Saccade-aligned session average BBDF x depth x time
    bbdfAverage_sacc = nanmean(bbdf_depth_norm_Saccade(:,:,sessionInput),3); % Average BBDF across sessions
    bbdfAverageSmooth_sacc = H_2DSMOOTH(bbdfAverage_sacc); % Smooth the BBDF across depth and time
    
    % Tone-aligned session average BBDF x depth x time
    bbdfAverage_tone = nanmean(bbdf_depth_norm_Tone(:,:,sessionInput),3); % Average BBDF across sessions
    bbdfAverageSmooth_tone = H_2DSMOOTH(bbdfAverage_tone); % Smooth the BBDF across depth and time
    
    
    %% Produce figures: BBDF Heatmap
    % Set parameters
    clim_x = [-6 6];
    
    % Generate figure
    figure('Renderer', 'painters', 'Position', [100 100 1500 250]);
    
    % - Fixation aligned subplot
    subplot(1,4,1)
    imagesc('XData',[plotWindow_fix]-1000,'YData',1:171,'CData',bbdfAverageSmooth_fix)
    xlim([plotWindow_fix(1)-1000 plotWindow_fix(end)-1000]); ylim([1 171]);
    vline(0,'k');
    set(gca,'YDir','Reverse')
    set(gca,'CLim',clim_x)
    colormap(viridis)
    
    % - Saccade aligned subplot
    subplot(1,4,2)
    imagesc('XData',[plotWindow_saccade]-1000,'YData',1:171,'CData',bbdfAverageSmooth_sacc)
    xlim([plotWindow_saccade(1)-1000 plotWindow_saccade(end)-1000]); ylim([1 171]);
    vline(0,'k');
    set(gca,'YDir','Reverse')
    set(gca,'CLim',clim_x)
    colormap(viridis)
    
    % - SSD aligned subplot
    subplot(1,4,3)
    imagesc('XData',[plotWindow_ssd]-1000,'YData',1:171,'CData',bbdfAverageSmooth_ssd)
    xlim([plotWindow_ssd(1)-1000 plotWindow_ssd(end)-1000]); ylim([1 171]);
    vline(0,'k'); vline(mean(bayesianSSRT.ssrt_mean),'k--')
    set(gca,'YDir','Reverse')
    set(gca,'CLim',clim_x)
    colormap(viridis)
    
    % - Tone aligned subplot
    subplot(1,4,4)
    imagesc('XData',[plotWindow_tone]-1000,'YData',1:171,'CData',bbdfAverageSmooth_tone)
    xlim([plotWindow_tone(1)-1000 plotWindow_tone(end)-1000]); ylim([1 171]);
    vline(0,'k');
    set(gca,'YDir','Reverse')
    set(gca,'CLim',clim_x)
    colormap(viridis)
    
end

%% Produce Figures: BBDF Layer
clear bbdf_layer_epoch % clear the gramm variable, incase it already exists

% Input relevant data into the gramm function, and set the parameters
% Fixation aligned
bbdf_layer_epoch(1,1)=gramm('x',plotWindow_fix-1000,'y',[bbdf_upper_Fix; bbdf_lower_Fix],...
    'color',[repmat({'Upper'},16,1);repmat({'Lower'},16,1)]);
bbdf_layer_epoch(1,1).stat_summary();
bbdf_layer_epoch(1,1).axe_property('XLim',[plotWindow_fix(1)-1000 plotWindow_fix(end)-1000]); bbdf_layer_epoch(1,1).axe_property('YLim',[-6 6]);
bbdf_layer_epoch(1,1).geom_vline('xintercept',0,'style','k-'); bbdf_layer_epoch.set_names('y','');
bbdf_layer_epoch(1,1).no_legend();

% Saccade aligned
bbdf_layer_epoch(1,2)=gramm('x',plotWindow_saccade-1000,'y',[bbdf_upper_Saccade; bbdf_lower_Saccade],...
    'color',[repmat({'Upper'},16,1);repmat({'Lower'},16,1)]);
bbdf_layer_epoch(1,2).stat_summary();
bbdf_layer_epoch(1,2).axe_property('XLim',[plotWindow_saccade(1)-1000 plotWindow_saccade(end)-1000]); bbdf_layer_epoch(1,2).axe_property('YLim',[-6 6]);
bbdf_layer_epoch(1,2).geom_vline('xintercept',0,'style','k-'); bbdf_layer_epoch.set_names('y','');
bbdf_layer_epoch(1,2).no_legend();

% SSD aligned
bbdf_layer_epoch(1,3)=gramm('x',plotWindow_ssd-1000,'y',[bbdf_upper_SSD; bbdf_lower_SSD],...
    'color',[repmat({'Upper'},16,1);repmat({'Lower'},16,1)]);
bbdf_layer_epoch(1,3).stat_summary();
bbdf_layer_epoch(1,3).axe_property('XLim',[plotWindow_ssd(1)-1000 plotWindow_ssd(end)-1000]); bbdf_layer_epoch(1,3).axe_property('YLim',[-6 6]);
bbdf_layer_epoch(1,3).geom_vline('xintercept',0,'style','k-'); bbdf_layer_epoch.set_names('y','');
bbdf_layer_epoch(1,3).no_legend();

% Tone aligned
bbdf_layer_epoch(1,4)=gramm('x',plotWindow_tone-1000,'y',[bbdf_upper_Tone; bbdf_lower_Tone],...
    'color',[repmat({'Upper'},16,1);repmat({'Lower'},16,1)]);
bbdf_layer_epoch(1,4).stat_summary();
bbdf_layer_epoch(1,4).axe_property('XLim',[plotWindow_tone(1)-1000 plotWindow_tone(end)-1000]); bbdf_layer_epoch(1,4).axe_property('YLim',[-6 6]);
bbdf_layer_epoch(1,4).geom_vline('xintercept',0,'style','k-'); bbdf_layer_epoch.set_names('y','');
bbdf_layer_epoch(1,4).no_legend();

% Generate figure
figure('Renderer', 'painters', 'Position', [100 100 800 200]);
bbdf_layer_epoch.draw();



