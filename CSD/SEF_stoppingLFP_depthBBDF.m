clear laminarContacts
laminarContacts.all = find(corticalLFPmap.laminarFlag == 1);
laminarTable = corticalLFPmap(laminarContacts.all,:);

laminarContacts.upper = find(laminarTable.depth < 9);
laminarContacts.lower = find(laminarTable.depth > 8);

bbdf_depth_cancAll_SSD = nan(17,3001,length([1:16]));

% Extract BBDF from files
for ii = 1:length(laminarContacts.all)
    lfp = laminarContacts.all(ii);
    depth = corticalLFPmap.depth(lfp);
    session = corticalLFPmap.session(lfp);
    fprintf('Analysing LFP number %i of %i. \n',ii,length(laminarContacts.all));
    
    bbdfData = load(['D:\projectCode\project_stoppingLFP\data\bbdf\bbdf_' int2str(lfp)]);
    
    bbdf_depth_cancAll_SSD(depth,:,session-13) = ...
        nanmean(bbdfData.bbdf.ssd(executiveBeh.ttx_canc{session},:));

    bbdf_depth_noncancAll_Saccade(depth,:,session-13) = ...
        nanmean(bbdfData.bbdf.ssd(executiveBeh.ttx_canc{session},:));
    
    bbdf_depth_cancAll_tone(depth,:,session-13) = ...
        nanmean(bbdfData.bbdf.tone(executiveBeh.ttx_canc{session},:));
    
    % Stop-signal (latency matched aligned)  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    c_temp_ssd = []; ns_temp_ssd = [];
    nc_temp_sacc = []; ns_temp_sacc = []; 
    c_temp_tone = []; ns_temp_tone = [];
    
    for ssdIdx = 1:length(executiveBeh.inh_SSD{session})
        c_temp_ssd(ssdIdx,:) = nanmean(bbdfData.bbdf.ssd(executiveBeh.ttm_CGO{session,ssdIdx}.C_matched, :));
        ns_temp_ssd(ssdIdx,:) = nanmean(bbdfData.bbdf.ssd(executiveBeh.ttm_CGO{session,ssdIdx}.GO_matched, :));
 
        nc_temp_sacc(ssdIdx,:) = nanmean(bbdfData.bbdf.saccade(executiveBeh.ttm_c.NC{session,ssdIdx}.all, :));
        ns_temp_sacc(ssdIdx,:) = nanmean(bbdfData.bbdf.saccade(executiveBeh.ttm_c.GO_NC{session,ssdIdx}.all, :));        

        c_temp_tone(ssdIdx,:) = nanmean(bbdfData.bbdf.ssd(executiveBeh.ttm_CGO{session,ssdIdx}.C_matched, :));
        ns_temp_tone(ssdIdx,:) = nanmean(bbdfData.bbdf.ssd(executiveBeh.ttm_CGO{session,ssdIdx}.GO_matched, :));       
    end
    
    bbdf_depth_cancLatency_SSD{ii,1} = nanmean(c_temp_ssd);
    bbdf_depth_nostopLatency_SSD{ii,1} = nanmean(ns_temp_ssd);   

    bbdf_depth_noncancLatency_Sacc{ii,1} = nanmean(nc_temp_sacc);
    bbdf_depth_nostopLatency_Sacc{ii,1} = nanmean(ns_temp_sacc);  
    
    bbdf_depth_cancLatency_Tone{ii,1} = nanmean(c_temp_tone);
    bbdf_depth_nostopLatency_Tone{ii,1} = nanmean(ns_temp_tone);  
    
end

% Normalise data
plotWindow = [-200:1000]+1000;
plotWindow_tone = [-600:0]+1000;

clear bbdf_depth_norm_SSD bbdf_depth_norm_Tone bbdf_depth_norm_Saccade
for session = 1:16
    bbdf_depth_norm_SSD(:,:,session) = (bbdf_depth_cancAll_SSD(:,plotWindow,session)-...
        nanmean(nanmean(bbdf_depth_cancAll_SSD(:,plotWindow,session))))./...
        nanstd(nanstd(bbdf_depth_cancAll_SSD(:,plotWindow,session)));
    
    bbdf_depth_norm_Saccade(:,:,session) = (bbdf_depth_noncancAll_Saccade(:,plotWindow,session)-...
        nanmean(nanmean(bbdf_depth_noncancAll_Saccade(:,plotWindow,session))))./...
        nanstd(nanstd(bbdf_depth_noncancAll_Saccade(:,plotWindow,session)));

    bbdf_depth_norm_Tone(:,:,session) = (bbdf_depth_cancAll_tone(:,plotWindow_tone,session)-...
        nanmean(nanmean(bbdf_depth_cancAll_tone(:,plotWindow_tone,session))))./...
        nanstd(nanstd(bbdf_depth_cancAll_tone(:,plotWindow_tone,session)));
end


% Extract BBDF from files
for ii = 1:length(laminarContacts.all)
    bbdf_depth_diff{ii} = bbdf_depth_cancLatency_SSD{ii} - bbdf_depth_nostopLatency_SSD{ii};
end
    


%% Produce figures
% SSRT Aligned
bbdfAverage = nanmean(bbdf_depth_norm_SSD(:,:,:),3);
bbdfAverageSmooth = H_2DSMOOTH(bbdfAverage);

figure('Renderer', 'painters', 'Position', [100 100 1500 300]);
subplot(1,3,1)
imagesc('XData',[-200:1000],'YData',1:171,'CData',bbdfAverageSmooth)
xlim([-200 1000]); ylim([1 171]);
colorbar; vline(0,'k'); vline(mean(bayesianSSRT.ssrt_mean),'k--')
set(gca,'YDir','Reverse')
set(gca,'CLim',[-5 5])
colormap(parula) 

bbdfAverage_Eu = nanmean(bbdf_depth_norm_SSD(:,:,[1 2 3 4 5 6]),3);
bbdfAverageSmooth_Eu = H_2DSMOOTH(bbdfAverage_Eu);
subplot(1,3,2)
imagesc('XData',[-200:1000],'YData',1:171,'CData',bbdfAverageSmooth_Eu)
xlim([-200 1000]); ylim([1 171]);
colorbar; vline(0,'k'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.EuSessions)),'k--')
set(gca,'YDir','Reverse')
set(gca,'CLim',[-7 7])
colormap(parula) 

bbdfAverage_X = nanmean(bbdf_depth_norm_SSD(:,:,[7:end]),3);
bbdfAverageSmooth_X = H_2DSMOOTH(bbdfAverage_X);
subplot(1,3,3)
imagesc('XData',[-200:1000],'YData',1:171,'CData',bbdfAverageSmooth_X)
xlim([-200 1000]); ylim([1 171]);
colorbar; vline(0,'k'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.XSessions)),'k--')
set(gca,'YDir','Reverse')
set(gca,'CLim',[-7 7])
colormap(parula) 

% Tone aligned
bbdfAverage_tone = nanmean(bbdf_depth_norm_Tone(:,:,:),3);
bbdfAverageSmooth_tone = H_2DSMOOTH(bbdfAverage_tone);

figure('Renderer', 'painters', 'Position', [100 100 1500 300]);
subplot(1,3,1)
imagesc('XData',[-600:100],'YData',1:171,'CData',bbdfAverageSmooth_tone)
xlim([-600 100]); ylim([1 171]);
colorbar; vline(0,'k')
set(gca,'YDir','Reverse')
set(gca,'CLim',[-8 8])
colormap(parula) 

bbdfAverage_Eu_tone = nanmean(bbdf_depth_norm_Tone(:,:,[1 2 3 4 5 6]),3);
bbdfAverageSmooth_Eu_tone = H_2DSMOOTH(bbdfAverage_Eu_tone);
subplot(1,3,2)
imagesc('XData',[-600:100],'YData',1:171,'CData',bbdfAverageSmooth_Eu_tone)
xlim([-600 100]); ylim([1 171]);
colorbar; vline(0,'k'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.EuSessions)),'k--')
set(gca,'YDir','Reverse')
set(gca,'CLim',[-8 8])
colormap(parula) 

bbdfAverage_X_tone = nanmean(bbdf_depth_norm_Tone(:,:,[7:end]),3);
bbdfAverageSmooth_X_tone = H_2DSMOOTH(bbdfAverage_X_tone);
subplot(1,3,3)
imagesc('XData',[-600:100],'YData',1:171,'CData',bbdfAverageSmooth_X_tone)
xlim([-600 100]); ylim([1 171]);
colorbar; vline(0,'k')
set(gca,'YDir','Reverse')
set(gca,'CLim',[-8 8])
colormap(parula) 
% 

 
%% Produce figures
% SSRT Aligned

bbdfAverage = [];
bbdfAverage = nanmean(bbdf_depth_norm_Saccade(:,:,:),3);
bbdfAverageSmooth = H_2DSMOOTH(bbdfAverage);

figure('Renderer', 'painters', 'Position', [100 100 1500 300]);
subplot(1,3,1)
imagesc('XData',[-200:1000],'YData',1:171,'CData',bbdfAverageSmooth)
xlim([-200 1000]); ylim([1 171]);
colorbar; vline(0,'k')
set(gca,'YDir','Reverse')
% set(gca,'CLim',[0.1 1.5])

subplot(1,3,2)
bbdfAverage_Eu_saccade = nanmean(bbdf_depth_norm_Saccade(:,:,[1 2 3 4 5 6]),3);
bbdfAverageSmooth_Eu_saccade = H_2DSMOOTH(bbdfAverage_Eu_saccade);
imagesc('XData',[-200:1000],'YData',1:171,'CData',bbdfAverageSmooth_Eu_saccade)
xlim([-200 1000]); ylim([1 171]);
colorbar; vline(0,'k');
set(gca,'YDir','Reverse')

subplot(1,3,3)
bbdfAverage_X_saccade = nanmean(bbdf_depth_norm_Saccade(:,:,[7:end]),3);
bbdfAverageSmooth_X_saccade = H_2DSMOOTH(bbdfAverage_X_saccade);
imagesc('XData',[-200:1000],'YData',1:171,'CData',bbdfAverageSmooth_X_saccade)
xlim([-200 1000]); ylim([1 171]);
colorbar; vline(0,'k');
set(gca,'YDir','Reverse')





%%
clear testfigure
time = [-1000:2000];
ssrt_time = [-500:1000];

% Fixation aligned
testfigure(1,1)=gramm('x',time,'y',[bbdf_depth_cancLatency_SSD(laminarTable.depth > 8);...
    bbdf_depth_nostopLatency_SSD(laminarTable.depth > 8)],...
    'color',[repmat({'Canceled'},sum(laminarTable.depth > 8),1);...
    repmat({'No-stop'},sum(laminarTable.depth > 8),1)]);

testfigure(1,2)=gramm('x',time,'y',[bbdf_depth_cancLatency_SSD(laminarTable.monkeyFlag == 0 & laminarTable.depth > 8);...
    bbdf_depth_nostopLatency_SSD(laminarTable.monkeyFlag == 0  & laminarTable.depth > 8)],...
    'color',[repmat({'Canceled'},sum(laminarTable.monkeyFlag == 0  & laminarTable.depth > 8),1);...
    repmat({'No-stop'},sum(laminarTable.monkeyFlag == 0  & laminarTable.depth > 8),1)]);

testfigure(1,3)=gramm('x',time,'y',[bbdf_depth_cancLatency_SSD(laminarTable.monkeyFlag == 1  & laminarTable.depth > 8);...
    bbdf_depth_nostopLatency_SSD(laminarTable.monkeyFlag == 1 & laminarTable.depth > 8)],...
    'color',[repmat({'Canceled'},sum(laminarTable.monkeyFlag == 1 & laminarTable.depth > 8),1);...
    repmat({'No-stop'},sum(laminarTable.monkeyFlag == 1  & laminarTable.depth > 8),1)]);

testfigure(2,1)=gramm('x',time,'y',[bbdf_depth_cancLatency_SSD(laminarTable.depth < 9);...
    bbdf_depth_nostopLatency_SSD(laminarTable.depth < 9)],...
    'color',[repmat({'Canceled'},sum(laminarTable.depth < 9),1);...
    repmat({'No-stop'},sum(laminarTable.depth < 9),1)]);

testfigure(2,2)=gramm('x',time,'y',[bbdf_depth_cancLatency_SSD(laminarTable.monkeyFlag == 0 & laminarTable.depth < 9);...
    bbdf_depth_nostopLatency_SSD(laminarTable.monkeyFlag == 0  & laminarTable.depth < 9)],...
    'color',[repmat({'Canceled'},sum(laminarTable.monkeyFlag == 0  & laminarTable.depth < 9),1);...
    repmat({'No-stop'},sum(laminarTable.monkeyFlag == 0  & laminarTable.depth < 9),1)]);

testfigure(2,3)=gramm('x',time,'y',[bbdf_depth_cancLatency_SSD(laminarTable.monkeyFlag == 1  & laminarTable.depth < 9);...
    bbdf_depth_nostopLatency_SSD(laminarTable.monkeyFlag == 1 & laminarTable.depth < 9)],...
    'color',[repmat({'Canceled'},sum(laminarTable.monkeyFlag == 1 & laminarTable.depth < 9),1);...
    repmat({'No-stop'},sum(laminarTable.monkeyFlag == 1  & laminarTable.depth < 9),1)]);


% GRAMM Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
testfigure(1,1).stat_summary();
testfigure(1,1).axe_property('XLim',[-200 1000]); testfigure(1,1).axe_property('YLim',[0.0002 0.002]); 
testfigure(1,1).geom_vline('xintercept',0,'style','k-'); testfigure.set_names('y','');

testfigure(1,2).stat_summary();
testfigure(1,2).axe_property('XLim',[-200 1000]); testfigure(1,2).axe_property('YLim',[0.0002 0.002]); 
testfigure(1,2).geom_vline('xintercept',0,'style','k-'); testfigure.set_names('y','');

testfigure(1,3).stat_summary();
testfigure(1,3).axe_property('XLim',[-200 1000]); testfigure(1,3).axe_property('YLim',[0.0002 0.002]); 
testfigure(1,3).geom_vline('xintercept',0,'style','k-'); testfigure.set_names('y','');

testfigure(2,1).stat_summary();
testfigure(2,1).axe_property('XLim',[-200 1000]); testfigure(2,1).axe_property('YLim',[0.0002 0.002]); 
testfigure(2,1).geom_vline('xintercept',0,'style','k-'); testfigure.set_names('y','');

testfigure(2,2).stat_summary();
testfigure(2,2).axe_property('XLim',[-200 1000]); testfigure(2,2).axe_property('YLim',[0.0002 0.002]); 
testfigure(2,2).geom_vline('xintercept',0,'style','k-'); testfigure.set_names('y','');

testfigure(2,3).stat_summary();
testfigure(2,3).axe_property('XLim',[-200 1000]); testfigure(2,3).axe_property('YLim',[0.0002 0.002]); 
testfigure(2,3).geom_vline('xintercept',0,'style','k-'); testfigure.set_names('y','');

figure('Renderer', 'painters', 'Position', [100 100 1500 600]);
testfigure.draw();




%%
clear testfigure
time = [-1000:2000];
ssrt_time = [-500:1000];

% Fixation aligned
testfigure(1,1)=gramm('x',time,'y',[bbdf_depth_cancLatency_SSD(laminarContacts.upper);...
    bbdf_depth_cancLatency_SSD(laminarContacts.lower)],...
    'color',[repmat({'Difference - Upper'},length(laminarContacts.upper),1);...
    repmat({'Difference - Lower'},length(laminarContacts.lower),1)]);

% GRAMM Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
testfigure(1,1).stat_summary();
testfigure(1,1).axe_property('XLim',[-200 1000]);
testfigure(1,1).geom_vline('xintercept',0,'style','k-');
testfigure(1,1).axe_property('YLim',[0.00025 0.00175]);
testfigure.set_names('y','');


figure('Renderer', 'painters', 'Position', [100 100 400 300]);
testfigure.draw();