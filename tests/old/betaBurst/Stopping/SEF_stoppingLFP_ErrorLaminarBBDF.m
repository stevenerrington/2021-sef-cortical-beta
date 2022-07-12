
%% Extract mean BBDF across depths
timeWindow = [900:2000];
errorLaminarBBDF = nan(length(1:17),length(timeWindow),length([14:29]));
errorDiffLaminarBBDF = nan(length(1:17),length(timeWindow),length([14:29]));

corticalLFPmap = sessionLFPmap(sessionLFPmap.cortexFlag == 1,:);
 
for session = 14:29
    for depth = 1:17
        lfpIdx = find(corticalLFPmap.session == session & corticalLFPmap.depth == depth);
        
        if ~isempty(lfpIdx)
            errorLaminarBBDF(depth,:,session-13) = saccade_bbdf_noncanceled{lfpIdx,1}(:,timeWindow)*100;
            
            errorDiffLaminarBBDF(depth,:,session-13) = saccade_bbdf_noncanceled{lfpIdx,1}(:,timeWindow)*100-...
                saccade_bbdf_nostop{lfpIdx,1}(:,timeWindow)*100;
        end
    end
end

normalize = 0;
if normalize
    for session = 14:29
        errorLaminarBBDF(:,:,session-13) = errorLaminarBBDF(:,:,session-13)./...
            nanmax(nanmax(errorLaminarBBDF(:,:,session-13)));
        
        errorDiffLaminarBBDF(:,:,session-13) = errorDiffLaminarBBDF(:,:,session-13)./...
            nanmax(nanmax(errorDiffLaminarBBDF(:,:,session-13)));
    end
end


clear meanLaminarError meanLaminarError_eu meanLaminarError_x...
    plotLaminarError_all plotLaminarError_eu plotLaminarError_x...
    smoothPlotLaminarError_all smoothPlotLaminarError_eu smoothPlotLaminarError_x


%% Generate figure data

euPerpSessions = executiveBeh.nhpSessions.EuSessions(executiveBeh.nhpSessions.EuSessions > 13);
xPerpSessions = executiveBeh.nhpSessions.XSessions(executiveBeh.nhpSessions.XSessions > 13);

meanLaminarError_all = nanmean(errorLaminarBBDF,3);
meanLaminarError_eu = nanmean(errorLaminarBBDF(:,:,euPerpSessions-13),3);
meanLaminarError_x = nanmean(errorLaminarBBDF(:,:,xPerpSessions-13),3);

meanLaminarErrorDiff_all = nanmean(errorDiffLaminarBBDF,3);
meanLaminarErrorDiff_eu = nanmean(errorDiffLaminarBBDF(:,:,euPerpSessions-13),3);
meanLaminarErrorDiff_x = nanmean(errorDiffLaminarBBDF(:,:,xPerpSessions-13),3);

[smoothPlotLaminarError_all] = H_2DSMOOTH(meanLaminarError_all);
[smoothPlotLaminarError_eu] = H_2DSMOOTH(meanLaminarError_eu);
[smoothPlotLaminarError_x] = H_2DSMOOTH(meanLaminarError_x);

[smoothPlotLaminarErrorDiff_all] = H_2DSMOOTH(meanLaminarErrorDiff_all);
[smoothPlotLaminarErrorDiff_eu] = H_2DSMOOTH(meanLaminarErrorDiff_eu);
[smoothPlotLaminarErrorDiff_x] = H_2DSMOOTH(meanLaminarErrorDiff_x);

%% Create figure
figure('Renderer', 'painters', 'Position', [100 100 1200 600]);
subplot(2,3,1)
imagesc(timeWindow-1000,1:17,smoothPlotLaminarError_all)
set(gca,'YDir','reverse'); colorbar
vline(0,'k'); vline(600,'k--'); hline(8.5,'k')
ylabel('Non-canceled activity'); title('Combined')

subplot(2,3,2)
imagesc(timeWindow-1000,1:17,smoothPlotLaminarError_eu)
set(gca,'YDir','reverse'); colorbar
vline(0,'k'); vline(600,'k--'); hline(8.5,'k'); title('Monkey Eu')

subplot(2,3,3)
imagesc(timeWindow-1000,1:17,smoothPlotLaminarError_x)
set(gca,'YDir','reverse'); colorbar
vline(0,'k'); vline(600,'k--'); hline(8.5,'k'); title('Monkey X')

subplot(2,3,4)
imagesc(timeWindow-1000,1:17,smoothPlotLaminarErrorDiff_all)
set(gca,'YDir','reverse'); colorbar
vline(0,'k'); vline(600,'k--'); hline(8.5,'k')
ylabel('Differential activity');

subplot(2,3,5)
imagesc(timeWindow-1000,1:17,smoothPlotLaminarErrorDiff_eu)
set(gca,'YDir','reverse'); colorbar
vline(0,'k'); vline(600,'k--'); hline(8.5,'k')
xlabel('Time from Saccade (ms)')

subplot(2,3,6)
imagesc(timeWindow-1000,1:17,smoothPlotLaminarErrorDiff_x)
set(gca,'YDir','reverse'); colorbar
vline(0,'k'); vline(600,'k--'); hline(8.5,'k')
