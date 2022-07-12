%% Cut - monkey difference
bbdfAverage_Eu = nanmean(bbdf_depth_norm_SSD(:,:,[1 2 3 4 5 6]),3);
bbdfAverageSmooth_Eu = H_2DSMOOTH(bbdfAverage_Eu);
subplot(2,3,2)
imagesc('XData',[-200:1000],'YData',1:171,'CData',bbdfAverageSmooth_Eu)
xlim([-200 1000]); ylim([1 171]);
colorbar; vline(0,'k'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.EuSessions)),'k--')
set(gca,'YDir','Reverse')
set(gca,'CLim',clim_x)
colormap(parula) 

bbdfAverage_X = nanmean(bbdf_depth_norm_SSD(:,:,[7:end]),3);
bbdfAverageSmooth_X = H_2DSMOOTH(bbdfAverage_X);
subplot(2,3,3)
imagesc('XData',[-200:1000],'YData',1:171,'CData',bbdfAverageSmooth_X)
xlim([-200 1000]); ylim([1 171]);
colorbar; vline(0,'k'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.XSessions)),'k--')
set(gca,'YDir','Reverse')
set(gca,'CLim',clim_x)
colormap(parula) 

% Tone aligned
bbdfAverage_tone = nanmean(bbdf_depth_norm_Tone(:,:,:),3);
bbdfAverageSmooth_tone = H_2DSMOOTH(bbdfAverage_tone);

subplot(2,3,4)
imagesc('XData',[-600:100],'YData',1:171,'CData',bbdfAverageSmooth_tone)
xlim([-600 100]); ylim([1 171]);
colorbar; vline(0,'k')
set(gca,'YDir','Reverse')
set(gca,'CLim',[-8 8])
colormap(parula) 

bbdfAverage_Eu_tone = nanmean(bbdf_depth_norm_Tone(:,:,[1 2 3 4 5 6]),3);
bbdfAverageSmooth_Eu_tone = H_2DSMOOTH(bbdfAverage_Eu_tone);
subplot(2,3,5)
imagesc('XData',[-600:100],'YData',1:171,'CData',bbdfAverageSmooth_Eu_tone)
xlim([-600 100]); ylim([1 171]);
colorbar; vline(0,'k'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.EuSessions)),'k--')
set(gca,'YDir','Reverse')
set(gca,'CLim',clim_x)
colormap(parula) 

bbdfAverage_X_tone = nanmean(bbdf_depth_norm_Tone(:,:,[7:end]),3);
bbdfAverageSmooth_X_tone = H_2DSMOOTH(bbdfAverage_X_tone);
subplot(2,3,6)
imagesc('XData',[-600:100],'YData',1:171,'CData',bbdfAverageSmooth_X_tone)
xlim([-600 100]); ylim([1 171]);
colorbar; vline(0,'k')
set(gca,'YDir','Reverse')
set(gca,'CLim',clim_x)
colormap(parula) 
% 


bbdfAverage_fix = [];
bbdfAverage_fix = nanmean(bbdf_depth_norm_Saccade(:,:,:),3);
bbdfAverageSmooth_fix = H_2DSMOOTH(bbdfAverage_fix);

figure('Renderer', 'painters', 'Position', [100 100 1500 300]);
subplot(1,3,1)
imagesc('XData',[-200:1000],'YData',1:171,'CData',bbdfAverageSmooth_fix)
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


