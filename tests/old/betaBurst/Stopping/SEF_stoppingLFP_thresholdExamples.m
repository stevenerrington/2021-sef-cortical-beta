session = 8;
channel = 10;

% Get session name (to load in relevant file)
sessionName = FileNames{session};
fprintf('Analysing LFP number %i of 696. \n',lfp);

% Load in beta output data for session
loadname_target = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
betaOutput_target = parload([outputDir loadname_target])





%%

medianLFPpower = nanmedian(morletLFP(:));

canceledTrls = executiveBeh.ttx_canc{session};

%%  226
trl = canceledTrls(20);
inputData = squeeze(morletLFP(trl,:,:))';

clear allPeakFreq allPeakTime peakPower
[allPeakFreq,allPeakTime] = find(imregionalmax(inputData));
for peakIdx = 1:length(allPeakFreq)
    peakPower(peakIdx,1) = inputData(allPeakFreq(peakIdx),allPeakTime(peakIdx));
end

clear supraThresholdBurstIdx_2 supraThresholdBurstIdx_4 supraThresholdBurstIdx_6
supraThresholdBurstIdx_2 = find(peakPower > medianLFPpower*2);
supraThresholdBurstIdx_4 = find(peakPower > medianLFPpower*4);
supraThresholdBurstIdx_6 = find(peakPower > medianLFPpower*6);



figure('Renderer', 'painters', 'Position', [100 100 1000 300]);
subplot(1,3,1); hold on
imagesc(inputData);
scatter(allPeakTime(supraThresholdBurstIdx_2),allPeakFreq(supraThresholdBurstIdx_2),'r','Filled')
xlim([900 1500]); ylim([0.5 14.5])

subplot(1,3,2); hold on
imagesc(inputData);
scatter(allPeakTime(supraThresholdBurstIdx_4),allPeakFreq(supraThresholdBurstIdx_4),'r','Filled')
xlim([900 1500]); ylim([0.5 14.5])

subplot(1,3,3); hold on
imagesc(inputData);
scatter(allPeakTime(supraThresholdBurstIdx_6),allPeakFreq(supraThresholdBurstIdx_6),'r','Filled')
xlim([900 1500]); ylim([0.5 14.5])



%%
figure;
surf(1:size(inputData,1),1:size(inputData,2),inputData)


%% TESTING: BURST ALIGNED LFP
burstAlignedLFP_all = [];
for trlIdx = 1:length(canceledTrls)
    trl = canceledTrls(trlIdx);
    
    inputData = squeeze(morletLFP(trl,:,:))';
    
    clear allPeakFreq allPeakTime peakPower
    [allPeakFreq,allPeakTime] = find(imregionalmax(inputData));
    
    for peakIdx = 1:length(allPeakFreq)
        peakPower(peakIdx,1) = inputData(allPeakFreq(peakIdx),allPeakTime(peakIdx));
    end
    
    clear supraThresholdBurstIdx_2 supraThresholdBurstIdx_4 supraThresholdBurstIdx_6
    burstList = find(peakPower > medianLFPpower*6);
    
    burstAlignedLFP_trl = nan(length(burstList), 1001);
    for burstIdx = 1:length(burstList)
        
        try
            burstAlignedLFP_trl(burstIdx,:) = nanmean(inputData(:,...
                [(allPeakTime(burstList(burstIdx))-500):(allPeakTime(burstList(burstIdx))+500)]));
        catch
            continue
        end
        
    end
    
    burstAlignedLFP_all = [burstAlignedLFP_all;burstAlignedLFP_trl];
    
end

figure;
hold on
for ii = 1:size(burstAlignedLFP_all)
    plot([-500:500],burstAlignedLFP_all(ii,:),'color',[0 0 0 0.25])
    
end




%%
figure('Renderer', 'painters', 'Position', [100 100 1000 300]);



