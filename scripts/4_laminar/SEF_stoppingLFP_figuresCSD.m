
%% PSD Figure
% All monkeys %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f_h = figure('Renderer', 'painters', 'Position', [100 100 700 800]); hold on;
ax1 = subplot(3, 3, [1 2]); % Power spectral density
P_PSD_BASIC(nanmean(PSD_sessionMean.all,3), f{1}, f_h, ax1)
set(ax1,'clim', [-50 50]); box off

ax2 = subplot(3, 3, 3); hold on;
plot(nanmean(stoppingPower_cancNorm_beta,2),[1:17],'color','b')
plot(nanmean(stoppingPower_cancNorm_gamma,2),[1:17],'color','y')
set(gca,'linewidth', 1, 'fontsize', 10, 'ydir', 'rev', ...
    'xlim', [0 1], 'ylim', [1 17]); box off

% Separate monkeys %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ax3 = subplot(3, 3, [4 5]);
P_PSD_BASIC(nanmean(PSD_sessionMean.all(:,:,[1 2 3 4 5 6]),3), f{1}, f_h, ax3)
set(ax3,'clim', [-50 50]); box off

ax4 = subplot(3, 3, 6); hold on;
plot(nanmean(stoppingPower_cancNorm_beta(:,[1 2 3 4 5 6]),2),[1:17],'color','b')
plot(nanmean(stoppingPower_cancNorm_gamma(:,[1 2 3 4 5 6]),2),[1:17],'color','y')
set(gca,'linewidth', 1, 'fontsize', 10, 'ydir', 'rev', ...
    'xlim', [0 1], 'ylim', [1 17]); box off

ax5 = subplot(3, 3, [7 8]);
P_PSD_BASIC(nanmean(PSD_sessionMean.all(:,:,[7:end]),3), f{1}, f_h, ax5)
set(ax5,'clim', [-50 50]); box off

ax6 = subplot(3, 3, 9); hold on;
plot(nanmean(stoppingPower_cancNorm_beta(:,[7:end]),2),[1:17],'color','b')
plot(nanmean(stoppingPower_cancNorm_gamma(:,[7:end]),2),[1:17],'color','y')
set(gca,'linewidth', 1, 'fontsize', 10, 'ydir', 'rev', ...
    'xlim', [0 1], 'ylim', [1 17]); box off
