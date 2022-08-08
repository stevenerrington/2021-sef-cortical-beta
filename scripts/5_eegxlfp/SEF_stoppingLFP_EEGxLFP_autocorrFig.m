
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure: Autocorrelogram

clear temporal_corr_figure temporal_diff_figure % clear the gramm variable, incase it already exists

% Input relevant data into the gramm function, and set the parameters
temporal_corr_figure(1,1)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.obs.upper'; pBurst_lfp_eeg.shuf.upper';...
    pBurst_lfp_eeg.obs.lower'; pBurst_lfp_eeg.shuf.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Upper - Shuffled'},16,1);...
    repmat({'Lower'},16,1);repmat({'Lower - Shuffled'},16,1)]);
temporal_corr_figure(1,1).stat_summary();
temporal_corr_figure(1,1).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure.set_names('y','');
temporal_corr_figure.axe_property('YLim',[0.025 0.225]);
figure('Renderer', 'painters', 'Position', [100 100 500 300]);
temporal_corr_figure.draw();

% Difference between obs & shuffled
temporal_diff_figure(1,1)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.diff.upper'; pBurst_lfp_eeg.diff.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Lower'},16,1)]);
temporal_diff_figure(1,1).stat_summary();
temporal_diff_figure(1,1).geom_vline('xintercept',0,'style','k-'); 
temporal_diff_figure(1,1).geom_hline('yintercept',0,'style','k-'); 
temporal_diff_figure.set_names('y','');
temporal_diff_figure.axe_property('YLim',[-0.025 0.075]);
figure('Renderer', 'painters', 'Position', [100 100 400 300]);
temporal_diff_figure.draw();


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure: Split by monkey
monkeyLabels = {};
monkeyLabels = repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),4,1);
clear temporal_corr_figure_monkey temporal_corr_figure_monkey_diff
temporal_corr_figure_monkey(1,1)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.obs.upper'; pBurst_lfp_eeg.shuf.upper';...
    pBurst_lfp_eeg.obs.lower'; pBurst_lfp_eeg.shuf.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Upper - Shuffled'},16,1);...
    repmat({'Lower'},16,1);repmat({'Lower - Shuffled'},16,1)],...
    'subset',strcmp(monkeyLabels,'Euler'));
temporal_corr_figure_monkey(1,2)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.obs.upper'; pBurst_lfp_eeg.shuf.upper';...
    pBurst_lfp_eeg.obs.lower'; pBurst_lfp_eeg.shuf.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Upper - Shuffled'},16,1);...
    repmat({'Lower'},16,1);repmat({'Lower - Shuffled'},16,1)],...
    'subset',strcmp(monkeyLabels,'Xena'));
temporal_corr_figure_monkey(1,1).stat_summary();
temporal_corr_figure_monkey(1,2).stat_summary();
temporal_corr_figure_monkey(1,1).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure_monkey(1,2).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure_monkey.set_names('y','');
temporal_corr_figure_monkey.axe_property('YLim',[0.025 0.225]);
figure('Renderer', 'painters', 'Position', [100 100 1000 300]);
temporal_corr_figure_monkey.draw();


% Difference between obs & shuffled
monkeyLabels_diff = {};
monkeyLabels_diff = repmat(executiveBeh.nhpSessions.monkeyNameLabel(14:29),2,1);

temporal_corr_figure_monkey_diff(1,1)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.diff.upper'; pBurst_lfp_eeg.diff.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Lower'},16,1)],...
    'subset',strcmp(monkeyLabels_diff,'Euler'));
temporal_corr_figure_monkey_diff(1,2)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.diff.upper'; pBurst_lfp_eeg.diff.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Lower'},16,1)],...
    'subset',strcmp(monkeyLabels_diff,'Xena'));

temporal_corr_figure_monkey_diff(1,1).stat_summary();
temporal_corr_figure_monkey_diff(1,2).stat_summary();
temporal_corr_figure_monkey_diff(1,1).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure_monkey_diff(1,1).geom_hline('yintercept',0,'style','k-'); 
temporal_corr_figure_monkey_diff(1,2).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure_monkey_diff(1,2).geom_hline('yintercept',0,'style','k-'); 
temporal_corr_figure_monkey_diff.set_names('y','');
temporal_corr_figure_monkey_diff.axe_property('YLim',[-0.05 0.125]);

figure('Renderer', 'painters', 'Position', [100 100 800 300]);
temporal_corr_figure_monkey_diff.draw();







%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure: Split by Site
siteLabels = [];
siteLabels = repmat(executiveBeh.bioInfo.sessionSite(14:29),4,1);
clear temporal_corr_figure_site
temporal_corr_figure_site(1,1)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.obs.upper'; pBurst_lfp_eeg.shuf.upper';...
    pBurst_lfp_eeg.obs.lower'; pBurst_lfp_eeg.shuf.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Upper - Shuffled'},16,1);...
    repmat({'Lower'},16,1);repmat({'Lower - Shuffled'},16,1)],...
    'subset',siteLabels == 1);
temporal_corr_figure_site(1,2)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.obs.upper'; pBurst_lfp_eeg.shuf.upper';...
    pBurst_lfp_eeg.obs.lower'; pBurst_lfp_eeg.shuf.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Upper - Shuffled'},16,1);...
    repmat({'Lower'},16,1);repmat({'Lower - Shuffled'},16,1)],...
    'subset',siteLabels == 2);
temporal_corr_figure_site(1,3)=gramm('x',getMidBin(bin),...
    'y',[pBurst_lfp_eeg.obs.upper'; pBurst_lfp_eeg.shuf.upper';...
    pBurst_lfp_eeg.obs.lower'; pBurst_lfp_eeg.shuf.lower'],...
    'color',[repmat({'Upper'},16,1);repmat({'Upper - Shuffled'},16,1);...
    repmat({'Lower'},16,1);repmat({'Lower - Shuffled'},16,1)],...
    'subset',siteLabels == 3);
temporal_corr_figure_site(1,1).stat_summary();
temporal_corr_figure_site(1,2).stat_summary();
temporal_corr_figure_site(1,3).stat_summary();
temporal_corr_figure_site(1,1).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure_site(1,2).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure_site(1,3).geom_vline('xintercept',0,'style','k-'); 
temporal_corr_figure_site.set_names('y','');
temporal_corr_figure_site.axe_property('YLim',[0.025 0.20]);
figure('Renderer', 'painters', 'Position', [100 100 1000 300]);
temporal_corr_figure_site.draw();

