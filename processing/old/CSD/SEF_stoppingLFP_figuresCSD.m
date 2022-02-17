
%% PSD Figure
% All monkeys %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f_h = figure('Renderer', 'painters', 'Position', [100 100 700 800]); hold on;
ax1 = subplot(3, 3, [1 2]); % Power spectral density
P_PSD_BASIC(nanmean(PSD_sessionMean.all,3), f{1}, f_h, ax1)
set(ax1,'clim', [-50 50]); box off

ax2 = subplot(3, 3, 3); hold on;
plot(nanmean(stoppingPower_cancNorm,2),[1:17],'color',colors.canceled)
plot(nanmean(stoppingPower_noncancNorm,2),[1:17],'color',colors.noncanc)
plot(nanmean(stoppingPower_nostopNorm,2),[1:17],'color',colors.nostop)
set(gca,'linewidth', 1, 'fontsize', 10, 'ydir', 'rev', ...
    'xlim', [0 1], 'ylim', [1 17]); box off

% Separate monkeys %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ax3 = subplot(3, 3, [4 5]);
P_PSD_BASIC(nanmean(PSD_sessionMean.all(:,:,[1 2 3 4 5 6]),3), f{1}, f_h, ax3)
set(ax3,'clim', [-50 50]); box off

ax4 = subplot(3, 3, 6); hold on;
plot(nanmean(stoppingPower_cancNorm(:,[1 2 3 4 5 6]),2),[1:17],'color',colors.canceled)
plot(nanmean(stoppingPower_noncancNorm(:,[1 2 3 4 5 6]),2),[1:17],'color',colors.noncanc)
plot(nanmean(stoppingPower_nostopNorm(:,[1 2 3 4 5 6]),2),[1:17],'color',colors.nostop)
set(gca,'linewidth', 1, 'fontsize', 10, 'ydir', 'rev', ...
    'xlim', [0 1], 'ylim', [1 17]); box off

ax5 = subplot(3, 3, [7 8]);
P_PSD_BASIC(nanmean(PSD_sessionMean.all(:,:,[7:end]),3), f{1}, f_h, ax5)
set(ax5,'clim', [-50 50]); box off

ax6 = subplot(3, 3, 9); hold on;
plot(nanmean(stoppingPower_cancNorm(:,[7:end]),2),[1:17],'color',colors.canceled)
plot(nanmean(stoppingPower_noncancNorm(:,[7:end]),2),[1:17],'color',colors.noncanc)
plot(nanmean(stoppingPower_nostopNorm(:,[7:end]),2),[1:17],'color',colors.nostop)
set(gca,'linewidth', 1, 'fontsize', 10, 'ydir', 'rev', ...
    'xlim', [0 1], 'ylim', [1 17]); box off



%% CSD Figure

if ~exist('TV', 'var');         TV = [-1000:2000];  end
if ~exist('tlim', 'var');       tlim = [-100 250];         end

f_h = figure('Renderer', 'painters', 'Position', [100 100 1250 900]); hold on;

% All monkeys %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax1 = subplot(3, 3, 1);
P_CSD_BASIC(nanmean(CSD_sessionMean.canceled(2:end-1, :, :),3),...
    TV, tlim, f_h, ax1)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean),'k--')

ax2 = subplot(3, 3, 2);
P_CSD_BASIC(nanmean(CSD_sessionMean.nostop(2:end-1, :, :),3),...
    TV, tlim, f_h, ax2)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean),'k--')

ax3 = subplot(3, 3, 3);
P_CSD_BASIC(nanmean(CSD_sessionMean.canceled(2:end-1, :, :),3)-...
    nanmean(CSD_sessionMean.nostop(2:end-1, :, :),3),...
    TV, tlim, f_h, ax3)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean),'k--')


% Monkey Eu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax4 = subplot(3, 3, 4);
P_CSD_BASIC(nanmean(CSD_sessionMean.canceled(2:end-1, :, [1 2 3 4 5 6]),3),...
    TV, tlim, f_h, ax4)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.EuSessions)),'k--')

ax5 = subplot(3, 3, 5);
P_CSD_BASIC(nanmean(CSD_sessionMean.nostop(2:end-1, :, [1 2 3 4 5 6]),3),...
    TV, tlim, f_h, ax5)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.EuSessions)),'k--')

ax6 = subplot(3, 3, 6);
P_CSD_BASIC(nanmean(CSD_sessionMean.canceled(2:end-1, :, [1 2 3 4 5 6]),3)-...
    nanmean(CSD_sessionMean.nostop(2:end-1, :, [1 2 3 4 5 6]),3),...
    TV, tlim, f_h, ax6)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.EuSessions)),'k--')

% Monkey X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax7 = subplot(3, 3, 7);
P_CSD_BASIC(nanmean(CSD_sessionMean.canceled(2:end-1, :, [7:end]),3),...
    TV, tlim, f_h, ax7)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.XSessions)),'k--')

ax8 = subplot(3, 3, 8);
P_CSD_BASIC(nanmean(CSD_sessionMean.nostop(2:end-1, :, [7:end]),3),...
    TV, tlim, f_h, ax8)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.XSessions)),'k--')

ax9 = subplot(3, 3, 9);
P_CSD_BASIC(nanmean(CSD_sessionMean.canceled(2:end-1, :, [7:end]),3)-...
    nanmean(CSD_sessionMean.nostop(2:end-1, :, [7:end]),3),...
    TV, tlim, f_h, ax9)
vline(0,'k-'); vline(mean(bayesianSSRT.ssrt_mean(executiveBeh.nhpSessions.XSessions)),'k--')


% Figure settings
colorMinMax = [-30 30];
set(ax1, 'clim', colorMinMax); set(ax2, 'clim', colorMinMax); set(ax3, 'clim', colorMinMax); set(ax4, 'clim', colorMinMax);
set(ax5, 'clim', colorMinMax); set(ax6, 'clim', colorMinMax); set(ax7, 'clim', colorMinMax); set(ax8, 'clim', colorMinMax);
set(ax9, 'clim', colorMinMax);

set(ax1, 'xlim', [-100 600]); set(ax2, 'xlim', [-100 600]); set(ax3, 'xlim', [-100 600]); set(ax4, 'xlim', [-100 600]);
set(ax5, 'xlim', [-100 600]); set(ax6, 'xlim', [-100 600]); set(ax7, 'xlim', [-100 600]); set(ax8, 'xlim', [-100 600]);
set(ax9, 'xlim', [-100 600]); 