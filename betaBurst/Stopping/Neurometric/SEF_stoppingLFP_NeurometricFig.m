
[lfpPlotIdx,~] = find(testRaw == min(abs(testRaw(:,5))))


clear revisedNeurometricFigure

% Example session, pNC * bursts
SSD = repmat([lfp_neurometric_SSD{lfpPlotIdx,6}]',4,1);
pBurst_pNC_SSD = [[lfp_neurometric_pBurst{lfpPlotIdx,2}]';...
    [lfp_neurometric_pBurst{lfpPlotIdx,4}]';...
    [lfp_neurometric_pBurst{lfpPlotIdx,6}]';...
    [lfp_neurometric_pNC{lfpPlotIdx,10}]'];
pBurst_pNC_SSDgroup = [repmat({'2'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1);...
    repmat({'6'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1);...
    repmat({'10'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1);...
    repmat({'pNC'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1)];


revisedNeurometricFigure(1,1)=gramm('x',SSD,'y',pBurst_pNC_SSD,'color',pBurst_pNC_SSDgroup);
revisedNeurometricFigure(1,1).stat_summary
revisedNeurometricFigure(1,1).geom_point

% Example session, pNC - bursts
x = repmat([lfp_neurometric_SSD{lfpPlotIdx,6}]',3,1);
y = [[lfp_neurometric_pNC{lfpPlotIdx,2}-lfp_neurometric_pBurst{lfpPlotIdx,2}]';...
    [lfp_neurometric_pNC{lfpPlotIdx,6}-lfp_neurometric_pBurst{lfpPlotIdx,6}]';...
    [lfp_neurometric_pNC{lfpPlotIdx,10}-lfp_neurometric_pBurst{lfpPlotIdx,10}]']
c = [repmat({'2'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1);...
    repmat({'6'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1);...
    repmat({'10'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1)];

revisedNeurometricFigure(1,2)=gramm('x',x,'y',y,'color',c);
revisedNeurometricFigure(1,2).stat_summary
revisedNeurometricFigure(1,2).geom_point

% Histogram
revisedNeurometricFigure(1,3)=gramm('x',testRaw(:,6));
revisedNeurometricFigure(1,3).stat_bin('edges',[0:0.5:5], 'geom','bar')


% pBurst x Threshold
revisedNeurometricFigure(1,4)=gramm('x',[1:10],...
    'y',pBurst_Threshold_SSD,...
    'color',repmat({'A.Early';'B.Mid';'C.Late'}, 509,1));
revisedNeurometricFigure(1,4).stat_summary()

% Sum squared diff x threshold

meanDiff_plot = reshape(testRaw(:,[2, 6, 10]),509*3,1);
meanDiff_labels = [repmat(2,509,1); repmat(6,509,1); repmat(10,509,1)];
revisedNeurometricFigure(1,5)=gramm('x',meanDiff_labels,'y',meanDiff_plot);

revisedNeurometricFigure(1,5).stat_boxplot()
revisedNeurometricFigure(1,5).geom_jitter()

% Figure parameters
% revisedNeurometricFigure(1,1).no_legend();

revisedNeurometricFigure(1,2).axe_property('YLim',[-1.0 1.0]);
revisedNeurometricFigure(1,2).geom_hline();
% revisedNeurometricFigure(1,2).no_legend();

revisedNeurometricFigure(1,3).axe_property('XLim',[-0 5.0]);

% revisedNeurometricFigure(1,4).no_legend();

% revisedNeurometricFigure(1,5).no_legend();
revisedNeurometricFigure(1,5).axe_property('YLim',[-0.5 5.0]);
revisedNeurometricFigure(1,5).geom_hline();

% Generate figure
figure('Position',[100 100 1100 250]);
revisedNeurometricFigure.draw();



%%
[lfpPlotIdx,~] = find(mean(testRaw,2) == min(mean(testRaw,2)))

clear thresholdValues thresholdLabels
thresholdValues = reshape(testRaw-testRaw_shuffled,5090,1);
thresholdLabels = reshape(repmat([1:10],509,1),5090,1);
clear revised2NeurometricFigure

SSD = repmat([lfp_neurometric_SSD{lfpPlotIdx,6}]',4,1);
pBurst_pNC_SSD = [[lfp_neurometric_pBurst{lfpPlotIdx,2}]';...
    [lfp_neurometric_pBurst{lfpPlotIdx,4}]';...
    [lfp_neurometric_pBurst{lfpPlotIdx,6}]';...
    [lfp_neurometric_pNC{lfpPlotIdx,10}]'];
pBurst_pNC_SSDgroup = [repmat({'2'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1);...
    repmat({'4'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1);...
    repmat({'6'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1);...
    repmat({'pNC'},length(lfp_neurometric_pNC{lfpPlotIdx,2}),1)];


revised2NeurometricFigure(1,1)=gramm('x',SSD,'y',pBurst_pNC_SSD,'color',pBurst_pNC_SSDgroup);
revised2NeurometricFigure(1,1).stat_summary
revised2NeurometricFigure(1,1).geom_point
revised2NeurometricFigure(1,1).axe_property('YLim',[0 1]);

revised2NeurometricFigure(1,2)=gramm('x',...
    thresholdLabels,'y',thresholdValues);


revised2NeurometricFigure(1,2).stat_boxplot()
revised2NeurometricFigure(1,2).axe_property('YLim',[-1 1]);
revised2NeurometricFigure(1,2).geom_hline('yintercept',0)

figure('Position',[100 100 600 250]);
revised2NeurometricFigure(1,2).coord_flip();
revised2NeurometricFigure.draw();

