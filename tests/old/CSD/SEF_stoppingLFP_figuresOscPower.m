
if ~exist('TV', 'var');         TV = [-1000:2000];  end
if ~exist('tlim', 'var');       tlim = [-100 1000];         end

%% Power
f_h = figure('Renderer', 'painters', 'Position', [100 100 1250 900]); hold on;
% All monkeys %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax1 = subplot(3, 3, 1);
P_CSD_BASIC(nanmean(pow_sessionMean.canceled(2:end-1, :, :),3),...
    TV, tlim, f_h, ax1)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean),'k--')
set(ax1,'clim',[40 70]); colormap(parula)

ax2 = subplot(3, 3, 2);
P_CSD_BASIC(nanmean(pow_sessionMean.nostop(2:end-1, :, :),3),...
    TV, tlim, f_h, ax2)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean),'k--')
set(ax2,'clim',[40 70]); colormap(parula)

% Euler 
ax4 = subplot(3, 3, 4);
P_CSD_BASIC(nanmean(pow_sessionMean.canceled(2:end-1, :, [1:6]),3),...
    TV, tlim, f_h, ax4)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean),'k--')
set(ax4,'clim',[40 70]); colormap(parula)

ax5 = subplot(3, 3, 5);
P_CSD_BASIC(nanmean(pow_sessionMean.nostop(2:end-1, :, [1:6]),3),...
    TV, tlim, f_h, ax5)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean),'k--')
set(ax5,'clim',[40 70]); colormap(parula)

% Xena
ax7 = subplot(3, 3, 7);
P_CSD_BASIC(nanmean(pow_sessionMean.canceled(2:end-1, :, [7:end]),3),...
    TV, tlim, f_h, ax7)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean),'k--')
set(ax7,'clim',[40 70]); colormap(parula)

ax8 = subplot(3, 3, 8);
P_CSD_BASIC(nanmean(pow_sessionMean.nostop(2:end-1, :, [7:end]),3),...
    TV, tlim, f_h, ax8)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean),'k--')
set(ax8,'clim',[40 70]); colormap(parula)
